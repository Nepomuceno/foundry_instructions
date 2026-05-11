#!/usr/bin/env bash
set -u

OUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATEWAY_URL="https://ai-gateway-eastus2.azure-api.net"
SUBSCRIPTION_ID="74dda446-f8fe-4a3f-8ffd-14cf71f6b202"
RESOURCE_GROUP="n8n-test"
APIM_SERVICE="ai-gateway-eastus2"
APIM_SUBSCRIPTION="master"
API_VERSION="2024-10-21"

KEY="$(az rest --method post --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_SERVICE}/subscriptions/${APIM_SUBSCRIPTION}/listSecrets?api-version=2023-09-01-preview" --query primaryKey -o tsv)"

if [ -z "${KEY}" ]; then
  echo "Failed to retrieve APIM subscription key" >&2
  exit 1
fi

write_json() {
  local file="$1"
  local content="$2"
  printf '%s\n' "${content}" > "${file}"
}

json_escape() {
  jq -Rn --arg value "$1" '$value'
}

test_request() {
  local deployment="$1"
  local category="$2"
  local method="$3"
  local url="$4"
  local payload="$5"
  local safe_payload="$6"
  local file_safe
  local body_file
  local response_file
  local meta_file
  local started_at
  local ended_at
  local http_code
  local curl_exit
  local status

  file_safe="$(printf '%s' "${deployment}" | tr '/:. ' '____')"
  body_file="${OUT_DIR}/${file_safe}.response.json"
  meta_file="${OUT_DIR}/${file_safe}.test.json"
  response_file="${OUT_DIR}/${file_safe}.raw-response.txt"

  started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [ "${method}" = "POST" ]; then
    http_code="$(curl -sS -o "${response_file}" -w '%{http_code}' -X POST "${url}" -H "api-key: ${KEY}" -H "Content-Type: application/json" -d "${payload}")"
    curl_exit=$?
  else
    http_code="$(curl -sS -o "${response_file}" -w '%{http_code}' "${url}" -H "api-key: ${KEY}")"
    curl_exit=$?
  fi

  ended_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [ "${curl_exit}" -eq 0 ] && [ "${http_code}" -ge 200 ] && [ "${http_code}" -lt 300 ]; then
    status="passed"
  else
    status="failed"
  fi

  if jq . "${response_file}" > "${body_file}" 2>/dev/null; then
    rm -f "${response_file}"
  else
    mv "${response_file}" "${body_file}"
  fi

  jq -n \
    --arg deployment "${deployment}" \
    --arg category "${category}" \
    --arg gateway "${GATEWAY_URL}" \
    --arg method "${method}" \
    --arg url "${url}" \
    --arg apiVersion "${API_VERSION}" \
    --arg auth "APIM subscription key in api-key header; value intentionally not saved" \
    --argjson requestBody "${safe_payload}" \
    --arg startedAt "${started_at}" \
    --arg endedAt "${ended_at}" \
    --arg status "${status}" \
    --argjson httpStatus "${http_code}" \
    --arg responseFile "$(basename "${body_file}")" \
    '{deployment:$deployment, category:$category, gateway:$gateway, method:$method, url:$url, apiVersion:$apiVersion, auth:$auth, requestBody:$requestBody, startedAt:$startedAt, endedAt:$endedAt, status:$status, httpStatus:$httpStatus, responseFile:$responseFile}' \
    > "${meta_file}"

  printf '%s\t%s\t%s\n' "${deployment}" "${status}" "${http_code}" >> "${OUT_DIR}/summary.tsv"
}

chat_payload='{"messages":[{"role":"user","content":"Reply with OK only."}],"max_tokens":2}'
chat_safe='{"messages":[{"role":"user","content":"Reply with OK only."}],"max_tokens":2}'

responses_payload='{"model":"DEPLOYMENT_PLACEHOLDER","input":"Reply with OK only.","max_output_tokens":2}'
responses_safe='{"model":"DEPLOYMENT_PLACEHOLDER","input":"Reply with OK only.","max_output_tokens":2}'

image_payload='{"prompt":"A single blue dot on a white background.","n":1,"size":"1024x1024"}'
image_safe='{"prompt":"A single blue dot on a white background.","n":1,"size":"1024x1024"}'

tts_payload='{"input":"OK","voice":"alloy"}'
tts_safe='{"input":"OK","voice":"alloy"}'

rm -f "${OUT_DIR}/summary.tsv"
printf 'deployment\tstatus\thttp_status\n' > "${OUT_DIR}/summary.tsv"

chat_deployments=(
  "gpt-4o"
  "gpt-4.1"
  "gpt-5-chat"
  "gpt-5-mini"
  "gpt-5"
  "gpt-5.2"
  "gpt-oss-120b"
  "Phi-4-reasoning"
  "DeepSeek-V3.2"
  "gpt-5.4"
  "Kimi-K2.5"
  "grok-4-fast-reasoning"
  "ModelRouter"
  "gpt-5.4-pro"
  "grok-4-20-reasoning"
  "Mistral-Large-3"
  "grok-4-1-fast-reasoning"
  "gpt-5.4-mini"
)

response_deployments=(
  "gpt-5.1-codex-mini"
  "gpt-5.4-nano"
)

tts_deployments=(
  "gpt-4o-mini-tts"
  "gpt-audio"
  "gpt-audio-1.5"
)

image_deployments=(
  "gpt-image-1.5"
  "gpt-image-2"
  "FLUX.2-flex"
  "FLUX.2-pro"
)

for deployment in "${chat_deployments[@]}"; do
  test_request "${deployment}" "chat-completions" "POST" "${GATEWAY_URL}/openai/deployments/${deployment}/chat/completions?api-version=${API_VERSION}" "${chat_payload}" "${chat_safe}"
done

for deployment in "${response_deployments[@]}"; do
  payload="${responses_payload/DEPLOYMENT_PLACEHOLDER/${deployment}}"
  safe="${responses_safe/DEPLOYMENT_PLACEHOLDER/${deployment}}"
  test_request "${deployment}" "responses" "POST" "${GATEWAY_URL}/openai/responses?api-version=${API_VERSION}" "${payload}" "${safe}"
done

for deployment in "${tts_deployments[@]}"; do
  test_request "${deployment}" "audio-speech" "POST" "${GATEWAY_URL}/openai/deployments/${deployment}/audio/speech?api-version=${API_VERSION}" "${tts_payload}" "${tts_safe}"
done

for deployment in "${image_deployments[@]}"; do
  test_request "${deployment}" "image-generations" "POST" "${GATEWAY_URL}/openai/deployments/${deployment}/images/generations?api-version=${API_VERSION}" "${image_payload}" "${image_safe}"
done

jq -Rn '
  [inputs | select(length > 0) | split("\t")]
  | .[0] as $headers
  | .[1:]
  | map({deployment:.[0], status:.[1], httpStatus:(.[2] | tonumber)})
' "${OUT_DIR}/summary.tsv" > "${OUT_DIR}/summary.json"
