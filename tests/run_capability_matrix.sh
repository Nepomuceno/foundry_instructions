#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULT_DIR="${ROOT_DIR}/results"
RESPONSE_DIR="${ROOT_DIR}/responses"
mkdir -p "${RESULT_DIR}" "${RESPONSE_DIR}"

SUBSCRIPTION_ID="74dda446-f8fe-4a3f-8ffd-14cf71f6b202"
RESOURCE_GROUP="n8n-test"
APIM_SERVICE="ai-gateway-eastus2"
APIM_SUBSCRIPTION="master"
GATEWAY_BASE="https://ai-gateway-eastus2.azure-api.net/openai"
DIRECT_BASE="https://admin-m8fg494d-eastus2.openai.azure.com/openai"

KEY="$(az rest --method post --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_SERVICE}/subscriptions/${APIM_SUBSCRIPTION}/listSecrets?api-version=2023-09-01-preview" --query primaryKey -o tsv)"
AI_TOKEN="$(az account get-access-token --resource https://ai.azure.com --query accessToken -o tsv)"

if [ -z "${KEY}" ] || [ -z "${AI_TOKEN}" ]; then
  echo "Missing APIM key or Entra token" >&2
  exit 1
fi

safe_name() {
  printf '%s' "$1" | tr '/:. ' '____'
}

json_string() {
  jq -Rn --arg value "$1" '$value'
}

write_attempt() {
  local deployment="$1"
  local capability="$2"
  local transport="$3"
  local method="$4"
  local url="$5"
  local auth_desc="$6"
  local request_json="$7"
  local response_path="$8"
  local http_status="$9"
  local curl_exit="${10}"
  local started_at="${11}"
  local ended_at="${12}"
  local notes="${13}"
  local file="${RESULT_DIR}/$(safe_name "${deployment}")__$(safe_name "${capability}")__$(safe_name "${transport}").json"
  local status="failed"
  if [ "${curl_exit}" -eq 0 ] && [ "${http_status}" -ge 200 ] && [ "${http_status}" -lt 300 ]; then
    status="passed"
  fi

  jq -n \
    --arg deployment "${deployment}" \
    --arg capability "${capability}" \
    --arg transport "${transport}" \
    --arg method "${method}" \
    --arg url "${url}" \
    --arg auth "${auth_desc}" \
    --argjson request "${request_json}" \
    --arg startedAt "${started_at}" \
    --arg endedAt "${ended_at}" \
    --arg status "${status}" \
    --argjson httpStatus "${http_status}" \
    --arg responseFile "$(basename "${response_path}")" \
    --arg notes "${notes}" \
    '{deployment:$deployment, capability:$capability, transport:$transport, method:$method, url:$url, auth:$auth, request:$request, startedAt:$startedAt, endedAt:$endedAt, status:$status, httpStatus:$httpStatus, responseFile:$responseFile, notes:$notes}' \
    > "${file}"
}

call_json() {
  local deployment="$1"
  local capability="$2"
  local transport="$3"
  local method="$4"
  local url="$5"
  local auth_type="$6"
  local request_json="$7"
  local notes="$8"
  local response_path="${RESPONSE_DIR}/$(safe_name "${deployment}")__$(safe_name "${capability}")__$(safe_name "${transport}").response"
  local tmp_path="${response_path}.tmp"
  local started_at
  local ended_at
  local http_status
  local curl_exit
  local auth_desc

  started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [ "${auth_type}" = "gateway" ]; then
    auth_desc="APIM subscription key in api-key header; value intentionally not saved"
    http_status="$(curl -sS -o "${tmp_path}" -w '%{http_code}' -X "${method}" "${url}" -H "api-key: ${KEY}" -H "Content-Type: application/json" -d "${request_json}")"
    curl_exit=$?
  else
    auth_desc="Microsoft Entra ID bearer token; value intentionally not saved"
    http_status="$(curl -sS -o "${tmp_path}" -w '%{http_code}' -X "${method}" "${url}" -H "Authorization: Bearer ${AI_TOKEN}" -H "Content-Type: application/json" -d "${request_json}")"
    curl_exit=$?
  fi
  ended_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if jq . "${tmp_path}" > "${response_path}.json" 2>/dev/null; then
    rm -f "${tmp_path}"
    response_path="${response_path}.json"
  else
    mv "${tmp_path}" "${response_path}.txt"
    response_path="${response_path}.txt"
  fi

  write_attempt "${deployment}" "${capability}" "${transport}" "${method}" "${url}" "${auth_desc}" "${request_json}" "${response_path}" "${http_status}" "${curl_exit}" "${started_at}" "${ended_at}" "${notes}"
}

call_binary() {
  local deployment="$1"
  local capability="$2"
  local transport="$3"
  local method="$4"
  local url="$5"
  local auth_type="$6"
  local request_json="$7"
  local extension="$8"
  local notes="$9"
  local response_path="${RESPONSE_DIR}/$(safe_name "${deployment}")__$(safe_name "${capability}")__$(safe_name "${transport}").${extension}"
  local started_at
  local ended_at
  local http_status
  local curl_exit
  local auth_desc

  started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [ "${auth_type}" = "gateway" ]; then
    auth_desc="APIM subscription key in api-key header; value intentionally not saved"
    http_status="$(curl -sS -o "${response_path}" -w '%{http_code}' -X "${method}" "${url}" -H "api-key: ${KEY}" -H "Content-Type: application/json" -d "${request_json}")"
    curl_exit=$?
  else
    auth_desc="Microsoft Entra ID bearer token; value intentionally not saved"
    http_status="$(curl -sS -o "${response_path}" -w '%{http_code}' -X "${method}" "${url}" -H "Authorization: Bearer ${AI_TOKEN}" -H "Content-Type: application/json" -d "${request_json}")"
    curl_exit=$?
  fi
  ended_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [ "${http_status}" -lt 200 ] || [ "${http_status}" -ge 300 ]; then
    if jq . "${response_path}" > "${response_path}.json" 2>/dev/null; then
      rm -f "${response_path}"
      response_path="${response_path}.json"
    fi
  fi

  write_attempt "${deployment}" "${capability}" "${transport}" "${method}" "${url}" "${auth_desc}" "${request_json}" "${response_path}" "${http_status}" "${curl_exit}" "${started_at}" "${ended_at}" "${notes}"
}

chat_payload_max_tokens() {
  jq -cn --arg model "$1" '{model:$model,messages:[{role:"user",content:"Reply with OK only."}],max_tokens:128}'
}

chat_payload_max_completion_tokens() {
  jq -cn --arg model "$1" '{model:$model,messages:[{role:"user",content:"Reply with OK only."}],max_completion_tokens:512}'
}

responses_payload() {
  jq -cn --arg model "$1" '{model:$model,input:"Reply with OK only.",max_output_tokens:512}'
}

vision_chat_payload() {
  jq -cn --arg model "$1" '{model:$model,messages:[{role:"user",content:[{type:"text",text:"What is the dominant color in this image? Reply one word."},{type:"image_url",image_url:{url:"https://dummyimage.com/64x64/0000ff/0000ff.png"}}]}],max_tokens:32}'
}

vision_responses_payload() {
  jq -cn --arg model "$1" '{model:$model,input:[{role:"user",content:[{type:"input_text",text:"What is the dominant color in this image? Reply one word."},{type:"input_image",image_url:"https://dummyimage.com/64x64/0000ff/0000ff.png"}]}],max_output_tokens:256}'
}

tool_chat_payload() {
  jq -cn --arg model "$1" '{model:$model,messages:[{role:"user",content:"Use the tool to report the weather for Paris."}],tools:[{type:"function",function:{name:"report_weather",description:"Report weather",parameters:{type:"object",properties:{city:{type:"string"}},required:["city"]}}}],tool_choice:"auto",max_tokens:128}'
}

tool_chat_payload_max_completion() {
  jq -cn --arg model "$1" '{model:$model,messages:[{role:"user",content:"Use the tool to report the weather for Paris."}],tools:[{type:"function",function:{name:"report_weather",description:"Report weather",parameters:{type:"object",properties:{city:{type:"string"}},required:["city"]}}}],tool_choice:"auto",max_completion_tokens:512}'
}

tool_responses_payload() {
  jq -cn --arg model "$1" '{model:$model,input:"Use the tool to report the weather for Paris.",tools:[{type:"function",name:"report_weather",description:"Report weather",parameters:{type:"object",properties:{city:{type:"string"}},required:["city"]}}],tool_choice:"auto",max_output_tokens:512}'
}

image_payload() {
  jq -cn --arg model "$1" '{model:$model,prompt:"A single blue dot on a plain white background.",n:1,size:"1024x1024"}'
}

tts_payload() {
  jq -cn --arg model "$1" '{model:$model,input:"OK",voice:"alloy",response_format:"mp3"}'
}

audio_chat_payload() {
  jq -cn --arg model "$1" '{model:$model,messages:[{role:"user",content:"Say OK."}],modalities:["text","audio"],audio:{voice:"alloy",format:"mp3"},max_completion_tokens:128}'
}

video_payload() {
  jq -cn --arg model "$1" '{model:$model,prompt:"A simple blue circle moves slowly across a plain white background.",seconds:"4",size:"720x1280"}'
}

rm -f "${RESULT_DIR}"/*.json "${RESPONSE_DIR}"/*

chat_max_tokens=(gpt-4o gpt-4.1 gpt-5-chat gpt-oss-120b DeepSeek-V3.2 Kimi-K2.5 grok-4-fast-reasoning ModelRouter grok-4-20-reasoning Mistral-Large-3 grok-4-1-fast-reasoning)
chat_max_completion=(gpt-5-mini gpt-5 gpt-5.2 gpt-5.4 gpt-5.4-nano gpt-5.4-mini)
responses_models=(gpt-4o gpt-4.1 gpt-5-chat gpt-5-mini gpt-5 gpt-5.2 gpt-5.1-codex-mini gpt-5.4 gpt-5.4-nano gpt-5.4-pro gpt-5.4-mini)
image_models=(gpt-image-1.5 gpt-image-2 FLUX.2-flex FLUX.2-pro)
tts_models=(gpt-4o-mini-tts)
audio_chat_models=(gpt-audio gpt-audio-1.5)
video_models=(sora-2)
vision_models=(gpt-4o gpt-5.4-nano)
tool_models=(gpt-4.1 gpt-5 gpt-5.4-nano Mistral-Large-3)
negative_probe_models=(Cohere-rerank-v4.0-fast Phi-4-reasoning)

for model in "${chat_max_tokens[@]}"; do
  payload="$(chat_payload_max_tokens "${model}")"
  call_json "${model}" "chat-completions" "direct-v1" "POST" "${DIRECT_BASE}/v1/chat/completions" "direct" "${payload}" "Primary chat-completion probe using v1 API."
  call_json "${model}" "chat-completions" "gateway-versioned" "POST" "${GATEWAY_BASE}/deployments/${model}/chat/completions?api-version=2025-04-01-preview" "gateway" "$(jq -cn '{messages:[{role:"user",content:"Reply with OK only."}],max_tokens:128}')" "Gateway versioned chat-completions probe."
done

for model in "${chat_max_completion[@]}"; do
  payload="$(chat_payload_max_completion_tokens "${model}")"
  call_json "${model}" "chat-completions" "direct-v1" "POST" "${DIRECT_BASE}/v1/chat/completions" "direct" "${payload}" "Primary chat-completion probe using max_completion_tokens for reasoning models."
  call_json "${model}" "chat-completions" "gateway-versioned" "POST" "${GATEWAY_BASE}/deployments/${model}/chat/completions?api-version=2025-04-01-preview" "gateway" "$(jq -cn '{messages:[{role:"user",content:"Reply with OK only."}],max_completion_tokens:512}')" "Gateway versioned chat-completions probe using max_completion_tokens."
done

for model in "${responses_models[@]}"; do
  payload="$(responses_payload "${model}")"
  call_json "${model}" "responses" "direct-v1" "POST" "${DIRECT_BASE}/v1/responses" "direct" "${payload}" "Responses API positive probe from deployment metadata/catalog where applicable."
  call_json "${model}" "responses" "gateway-versioned" "POST" "${GATEWAY_BASE}/responses?api-version=2025-04-01-preview" "gateway" "${payload}" "Gateway versioned Responses API probe; APIM does not expose /openai/v1."
done

for model in "${vision_models[@]}"; do
  call_json "${model}" "image-input-chat" "direct-v1" "POST" "${DIRECT_BASE}/v1/chat/completions" "direct" "$(vision_chat_payload "${model}")" "Image input capability probe using chat content parts."
  call_json "${model}" "image-input-responses" "direct-v1" "POST" "${DIRECT_BASE}/v1/responses" "direct" "$(vision_responses_payload "${model}")" "Image input capability probe using Responses API input_image."
done

for model in "${tool_models[@]}"; do
  if [[ "${model}" == gpt-5* ]]; then
    call_json "${model}" "tool-calling-chat" "direct-v1" "POST" "${DIRECT_BASE}/v1/chat/completions" "direct" "$(tool_chat_payload_max_completion "${model}")" "Tool calling probe using chat/completions function tools with max_completion_tokens."
  else
    call_json "${model}" "tool-calling-chat" "direct-v1" "POST" "${DIRECT_BASE}/v1/chat/completions" "direct" "$(tool_chat_payload "${model}")" "Tool calling probe using chat/completions function tools."
  fi
  call_json "${model}" "tool-calling-responses" "direct-v1" "POST" "${DIRECT_BASE}/v1/responses" "direct" "$(tool_responses_payload "${model}")" "Tool calling probe using Responses API function tools."
done

for model in "${image_models[@]}"; do
  payload="$(image_payload "${model}")"
  call_json "${model}" "image-generations" "gateway-versioned" "POST" "${GATEWAY_BASE}/deployments/${model}/images/generations?api-version=2025-04-01-preview" "gateway" "${payload}" "Image generation probe through gateway versioned Azure OpenAI API."
done

for model in "${tts_models[@]}"; do
  payload="$(tts_payload "${model}")"
  call_binary "${model}" "audio-speech" "gateway-versioned" "POST" "${GATEWAY_BASE}/deployments/${model}/audio/speech?api-version=2025-04-01-preview" "gateway" "${payload}" "mp3" "TTS probe; binary MP3 saved when successful."
done

for model in "${audio_chat_models[@]}"; do
  payload="$(audio_chat_payload "${model}")"
  call_json "${model}" "audio-chat" "direct-v1" "POST" "${DIRECT_BASE}/v1/chat/completions" "direct" "${payload}" "Audio model probe requesting text plus audio output; response includes base64 audio in JSON."
  call_json "${model}" "audio-chat" "gateway-versioned" "POST" "${GATEWAY_BASE}/deployments/${model}/chat/completions?api-version=2025-04-01-preview" "gateway" "${payload}" "Gateway audio model probe requesting text plus audio output."
done

for model in "${video_models[@]}"; do
  payload="$(video_payload "${model}")"
  call_json "${model}" "video-generation-job" "direct-v1" "POST" "${DIRECT_BASE}/v1/videos" "direct" "${payload}" "Sora 2 documented v1 video creation route; creates an async job only."
  call_json "${model}" "video-generation-job" "gateway-v1" "POST" "${GATEWAY_BASE}/v1/videos" "gateway" "${payload}" "Gateway v1 video probe; expected to fail unless APIM imports /openai/v1."
done

for model in "${negative_probe_models[@]}"; do
  call_json "${model}" "chat-completions" "direct-v1" "POST" "${DIRECT_BASE}/v1/chat/completions" "direct" "$(chat_payload_max_tokens "${model}")" "Direct chat probe for model with metadata chatCompletion=true or ambiguous APIM behavior."
  call_json "${model}" "responses" "direct-v1" "POST" "${DIRECT_BASE}/v1/responses" "direct" "$(responses_payload "${model}")" "Responses negative/compatibility probe."
done

jq -s '[.[] | {deployment, capability, transport, status, httpStatus, responseFile, notes}]' "${RESULT_DIR}"/*.json > "${ROOT_DIR}/capability-summary.json"

jq -r '
  ["Deployment","Capability","Transport","Status","HTTP","Response File","Notes"],
  (.[] | [.deployment,.capability,.transport,.status,(.httpStatus|tostring),.responseFile,.notes])
  | @tsv
' "${ROOT_DIR}/capability-summary.json" > "${ROOT_DIR}/capability-summary.tsv"

{
  printf '# Azure AI Foundry Model Capability Test Matrix\n\n'
  printf 'Generated: `%s`\n\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'Secrets are not saved. APIM keys and Entra bearer tokens were held only in shell variables.\n\n'
  printf '## Summary\n\n'
  printf '| Deployment | Capability | Transport | Status | HTTP | Response File |\n'
  printf '|---|---|---|---|---:|---|\n'
  jq -r '.[] | "| `\(.deployment)` | `\(.capability)` | `\(.transport)` | \(.status) | \(.httpStatus) | `\(.responseFile)` |"' "${ROOT_DIR}/capability-summary.json"
} > "${ROOT_DIR}/capability-matrix.md"
