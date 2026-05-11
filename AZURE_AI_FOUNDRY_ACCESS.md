# Azure AI Foundry Access And Limits

Generated from Azure CLI on 2026-05-07 for the `admin-m8fg494d-eastus2` Azure AI Foundry account.

No API keys, subscription keys, bearer tokens, or other secrets are stored in this document.

## Audience And Access Model

| Audience | Access method | What they can call |
|---|---|---|
| Owner/admin | Azure CLI, Microsoft Entra ID, Azure portal, direct Foundry endpoints, APIM management | Deployments, quotas, APIM configuration, direct diagnostics |
| API consumers | APIM subscription key supplied by the owner | Public gateway endpoints only; no Azure portal or direct Foundry access |

Share `AI_GATEWAY_CONSUMER_GUIDE.md` with API consumers. Do not share Azure subscription IDs, Entra tokens, APIM management commands, or direct Foundry credentials with consumers.

## Azure Account

| Field | Value |
|---|---|
| Subscription | `ME-MngEnvMCAP589614-ganepomu-1` |
| Subscription ID | `74dda446-f8fe-4a3f-8ffd-14cf71f6b202` |
| Tenant ID | `dc1bedca-3b80-4a5b-95db-89c67a9f8809` |
| Tenant domain | `MngEnvMCAP589614.onmicrosoft.com` |
| Signed-in user | `admin@MngEnvMCAP589614.onmicrosoft.com` |

## Foundry Resource

| Field | Value |
|---|---|
| Account name | `admin-m8fg494d-eastus2` |
| Resource group | `n8n-test` |
| Kind | `AIServices` |
| Region | `eastus2` |
| SKU | `S0` |
| Default project | `hack-foundry` |
| Public network access | `Enabled` |
| Local key auth | `Disabled` |
| Network ACLs | none configured |

Local key authentication is disabled on the Foundry account. Direct access should use Microsoft Entra ID bearer tokens. Gateway access should use the API Management subscription mechanism configured on the APIM service.

Consumers do not need Azure access. They only need the gateway base URL and the APIM subscription key provided by the owner.

## Direct Endpoints

| Purpose | Endpoint |
|---|---|
| AI Foundry API | `https://admin-m8fg494d-eastus2.services.ai.azure.com/` |
| Azure AI Model Inference API | `https://admin-m8fg494d-eastus2.services.ai.azure.com/` |
| Azure OpenAI legacy API | `https://admin-m8fg494d-eastus2.openai.azure.com/` |
| Azure OpenAI via Cognitive Services path | `https://admin-m8fg494d-eastus2.cognitiveservices.azure.com/openai` |
| Cognitive Services base endpoint | `https://admin-m8fg494d-eastus2.cognitiveservices.azure.com/` |
| Mistral AI API | `https://admin-m8fg494d-eastus2.services.ai.azure.com/` |
| Cohere AI API | `https://admin-m8fg494d-eastus2.services.ai.azure.com/` |
| OpenAI Sora API | `https://admin-m8fg494d-eastus2.openai.azure.com/` |
| OpenAI Realtime API | `https://admin-m8fg494d-eastus2.openai.azure.com/` |
| OpenAI Whisper API | `https://admin-m8fg494d-eastus2.openai.azure.com/` |
| OpenAI DALL-E API | `https://admin-m8fg494d-eastus2.openai.azure.com/` |

## API Gateway

| Field | Value |
|---|---|
| Gateway type | Azure API Management |
| Gateway name | `ai-gateway-eastus2` |
| Resource group | `n8n-test` |
| Region | `East US 2` |
| SKU | `BasicV2`, capacity `1` |
| Public gateway URL | `https://ai-gateway-eastus2.azure-api.net` |
| Public network access | `Enabled` |
| Developer portal | `Disabled` |
| Managed identity | System-assigned |
| Principal ID | `f1352897-5957-4269-b613-65979194ca1f` |
| Tenant ID | `dc1bedca-3b80-4a5b-95db-89c67a9f8809` |

## Gateway APIs

| API ID | Display name | Gateway path | Backend | Subscription required | Subscription key parameter |
|---|---|---|---|---|---|
| `admin-m8fg494d-eastus2` | `admin-m8fg494d-eastus2` | `/admin-m8fg494d-eastus2` | `https://admin-m8fg494d-eastus2.services.ai.azure.com/` | yes | header `api-key` or query `subscription-key` |
| `azure-openai-api` | `Azure OpenAI API` | `/openai` | `https://admin-m8fg494d-eastus2.cognitiveservices.azure.com/openai` | yes | header `api-key` or query `api-key` |

Gateway product:

| Product ID | Display name | State | Subscription required |
|---|---|---|---|
| `admin-m8fg494d-eastus2-hack-foundry-ai-q9kq1pl2g0` | `admin-m8fg494d-eastus2-hack-foundry-ai-q9kq1pl2g0` | `published` | yes |

The `azure-openai-api` policy uses API Management managed identity to authenticate to Azure Cognitive Services:

```xml
<authentication-managed-identity resource="https://cognitiveservices.azure.com" output-token-variable-name="managed-id-access-token" ignore-error="false" />
<set-header name="Authorization" exists-action="override">
  <value>@("Bearer " + (string)context.Variables["managed-id-access-token"])</value>
</set-header>
```

Client calls to APIM still require an APIM subscription key because both gateway APIs have `subscriptionRequired: true`. This APIM instance is configured to accept the key through `api-key`, not the default `Ocp-Apim-Subscription-Key`, for the `/openai` API.

For consumer-facing documentation, use only gateway URLs:

| Gateway surface | Base URL | Key header |
|---|---|---|
| OpenAI-compatible API | `https://ai-gateway-eastus2.azure-api.net/openai` | `api-key: <provided-key>` |
| Foundry/provider pass-through API | `https://ai-gateway-eastus2.azure-api.net/admin-m8fg494d-eastus2` | `api-key: <provided-key>` |

## Access Patterns

### Gateway OpenAI-Compatible Calls

Use this path for API consumers. Consumers should call APIM instead of the Foundry account directly.

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/deployments/<deployment-id>/chat/completions?api-version=<api-version>" \
  -H "api-key: <apim-subscription-key>" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'
```

The gateway also exposes OpenAI v1-compatible routes through wildcard APIM operations for `GET`, `POST`, and `DELETE` under `/openai/v1/*`:

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/v1/responses" \
  -H "api-key: <apim-subscription-key>" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-5.4-nano","input":"Reply with OK."}'
```

For Sora video generation through the v1 gateway:

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/v1/videos" \
  -H "api-key: <apim-subscription-key>" \
  -H "Content-Type: application/json" \
  -d '{"model":"sora-2","prompt":"A blue dot on a white background.","seconds":"4","size":"1280x720"}'
```

For image generation through the gateway:

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/deployments/gpt-image-2/images/generations?api-version=<api-version>" \
  -H "api-key: <apim-subscription-key>" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"A clean technical architecture diagram"}'
```

For `FLUX.2-flex`, use the Black Forest Labs provider-specific route on the Foundry services endpoint. The deployment-scoped Azure OpenAI image route returned `404` for FLUX, while this route returned base64 image data:

```bash
TOKEN=$(az account get-access-token --resource https://ai.azure.com --query accessToken -o tsv)

curl -X POST "https://admin-m8fg494d-eastus2.services.ai.azure.com/providers/blackforestlabs/v1/flux-2-flex?api-version=preview" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
        "model": "FLUX.2-flex",
        "prompt": "A photograph of a red fox in an autumn forest",
        "width": 1024,
        "height": 1024,
        "n": 1,
        "output_format": "png"
      }' | jq -r '.data[0].b64_json' | base64 --decode > generated_image.png
```

`FLUX.2-flex` provider-route output formats validated here are `jpeg` and `png`. Omitting `output_format` defaults to JPEG. `webp` and MIME values like `image/jpeg`, `image/png`, and `image/webp` were rejected with `422`.

For consumers using only the provided APIM key, call the same provider path through the Foundry pass-through gateway instead of using a bearer token:

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/admin-m8fg494d-eastus2/providers/blackforestlabs/v1/flux-2-flex?api-version=preview" \
  -H "api-key: <apim-subscription-key>" \
  -H "Content-Type: application/json" \
  -d '{
        "model": "FLUX.2-flex",
        "prompt": "A photograph of a red fox in an autumn forest",
        "width": 1024,
        "height": 1024,
        "n": 1,
        "output_format": "png"
      }' | jq -r '.data[0].b64_json' | base64 --decode > generated_image.png
```

Use `/providers/blackforestlabs/v1/flux-2-pro?api-version=preview` with `model: "FLUX.2-pro"` for `FLUX.2-pro`.

For text-to-speech through the gateway:

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/deployments/gpt-audio/audio/speech?api-version=<api-version>" \
  -H "api-key: <apim-subscription-key>" \
  -H "Content-Type: application/json" \
  -d '{"input":"Hello from Azure AI Foundry.","voice":"alloy"}'
```

### Gateway Foundry Pass-Through Calls

The Foundry pass-through API is mounted at:

```text
https://ai-gateway-eastus2.azure-api.net/admin-m8fg494d-eastus2/*
```

This API has wildcard operations for `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS`, and `TRACE`.

This surface is required for provider-specific routes such as Black Forest Labs FLUX. Consumers should still authenticate only with the APIM subscription key in `api-key`.

### Direct Azure OpenAI Calls

Direct calls bypass APIM and require Microsoft Entra ID because local key auth is disabled.

```bash
TOKEN=$(az account get-access-token --resource https://cognitiveservices.azure.com --query accessToken -o tsv)

curl -X POST "https://admin-m8fg494d-eastus2.openai.azure.com/openai/deployments/<deployment-id>/chat/completions?api-version=<api-version>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'
```

### Direct Foundry / Model Inference Calls

Use the Foundry endpoint for MaaS and model inference APIs:

```text
https://admin-m8fg494d-eastus2.services.ai.azure.com/
```

Use Microsoft Entra ID bearer tokens for direct access:

```bash
TOKEN=$(az account get-access-token --resource https://cognitiveservices.azure.com --query accessToken -o tsv)
```

## Gateway OpenAI API Operations

The APIM `azure-openai-api` has explicit operations for these Azure OpenAI paths:

| Operation | Method | Path template |
|---|---|---|
| Chat completions | `POST` | `/deployments/{deployment-id}/chat/completions?api-version={api-version}` |
| Completions | `POST` | `/deployments/{deployment-id}/completions?api-version={api-version}` |
| Responses | `POST` | `/responses?api-version={api-version}` |
| Get response | `GET` | `/responses/{response_id}?api-version={api-version}` |
| Delete response | `DELETE` | `/responses/{response_id}?api-version={api-version}` |
| Image generations | `POST` | `/deployments/{deployment-id}/images/generations?api-version={api-version}` |
| Speech | `POST` | `/deployments/{deployment-id}/audio/speech?api-version={api-version}` |
| Embeddings | `POST` | `/deployments/{deployment-id}/embeddings?api-version={api-version}` |
| Audio transcriptions | `POST` | `/deployments/{deployment-id}/audio/transcriptions?api-version={api-version}` |
| Audio translations | `POST` | `/deployments/{deployment-id}/audio/translations?api-version={api-version}` |
| v1 wildcard POST | `POST` | `/v1/*` |
| v1 wildcard GET | `GET` | `/v1/*` |
| v1 wildcard DELETE | `DELETE` | `/v1/*` |
| List models | `GET` | `/models?api-version={api-version}` |
| List deployments | `GET` | `/models/deployments?api-version={api-version}` |
| Assistants | multiple | `/assistants...` |
| Threads | multiple | `/threads...` |
| Vector stores | multiple | `/vector_stores...` |

## Deployment Limits

Capacity values are the deployed `GlobalStandard` capacities. Token limits shown in the table are effective rate-limit counts returned by Azure. For most text models, the token limit equals capacity x 1,000 tokens per minute.

| Deployment ID | Model | Version | Format | Capacity | Request limit | Token limit | Status |
|---|---|---:|---|---:|---:|---:|---|
| `gpt-4o` | `gpt-4o` | `2024-11-20` | OpenAI | 450 | 450 / 10 sec | 450,000 / min | Succeeded |
| `gpt-4.1` | `gpt-4.1` | `2025-04-14` | OpenAI | 1000 | 1,000 / min | 1,000,000 / min | Succeeded |
| `gpt-4o-mini-tts` | `gpt-4o-mini-tts` | `2025-03-20` | OpenAI | 600 | 60,000 / min | 600,000 / min | Succeeded |
| `gpt-5-chat` | `gpt-5-chat` | `2025-08-07` | OpenAI | 1000 | 1,000 / min | 1,000,000 / min | Succeeded |
| `gpt-5-mini` | `gpt-5-mini` | `2025-08-07` | OpenAI | 1000 | 1,000 / min | 1,000,000 / min | Succeeded |
| `gpt-5` | `gpt-5` | `2025-08-07` | OpenAI | 1000 | 10,000 / min | 1,000,000 / min | Succeeded |
| `gpt-audio` | `gpt-audio` | `2025-08-28` | OpenAI | 30000 | 30,000 / 10 sec | 30,000,000 / min | Succeeded |
| `gpt-5.2` | `gpt-5.2` | `2025-12-11` | OpenAI | 1000 | 10,000 / min | 1,000,000 / min | Succeeded |
| `gpt-oss-120b` | `gpt-oss-120b` | `1` | OpenAI-OSS | 5000 | 5,000 / min | 5,000,000 / min | Succeeded |
| `Phi-4-reasoning` | `Phi-4-reasoning` | `1` | Microsoft | 1 | not returned | not returned | Succeeded |
| `gpt-5.1-codex-mini` | `gpt-5.1-codex-mini` | `2025-11-13` | OpenAI | 1000 | 1,000 / min | 1,000,000 / min | Succeeded |
| `gpt-image-1.5` | `gpt-image-1.5` | `2025-12-16` | OpenAI | 9 | 9 / min | not applicable | Succeeded |
| `FLUX.2-flex` | `FLUX.2-flex` | `1` | Black Forest Labs | 4 | 4 / min | not applicable | Succeeded |
| `gpt-5.4` | `gpt-5.4` | `2026-03-05` | OpenAI | 1000 | 10,000 / min | 1,000,000 / min | Succeeded |
| `gpt-audio-1.5` | `gpt-audio-1.5` | `2026-02-23` | OpenAI | 30000 | 30,000 / 10 sec | 30,000,000 / min | Succeeded |
| `gpt-5.4-nano` | `gpt-5.4-nano` | `2026-03-17` | OpenAI | 5000 | 5,000 / min | 5,000,000 / min | Succeeded |
| `grok-4-fast-reasoning` | `grok-4-fast-reasoning` | `1` | xAI | 150 | 150 / min | 150,000 / min | Succeeded |
| `FLUX.2-pro` | `FLUX.2-pro` | `1` | Black Forest Labs | 4 | 4 / min | not applicable | Succeeded |
| `sora-2` | `sora-2` | `2025-10-06` | OpenAI | 9 | 9 / min | not applicable | Succeeded |
| `Cohere-rerank-v4.0-fast` | `Cohere-rerank-v4.0-fast` | `1` | Cohere | 300 | 300 / min | 300,000 / min | Succeeded |
| `gpt-image-2` | `gpt-image-2` | `2026-04-21` | OpenAI | 2 | 2 / min | not applicable | Succeeded |
| `ModelRouter` | `model-router` | `2025-11-18` | OpenAI | 250 | 250 / min | 250,000 / min | Succeeded |
| `gpt-5.4-pro` | `gpt-5.4-pro` | `2026-03-05` | OpenAI | 160 | 160 / min | 160,000 / min | Succeeded |
| `grok-4-20-reasoning` | `grok-4-20-reasoning` | `1` | xAI | 1000 | 1,000 / min | 1,000,000 / min | Succeeded |
| `Mistral-Large-3` | `Mistral-Large-3` | `1` | Mistral AI | 1000 | 1,000 / min | 1,000,000 / min | Succeeded |
| `grok-4-1-fast-reasoning` | `grok-4-1-fast-reasoning` | `1` | xAI | 1000 | 1,000 / min | 1,000,000 / min | Succeeded |
| `gpt-5.4-mini` | `gpt-5.4-mini` | `2026-03-17` | OpenAI | 1000 | 1,000 / min | 1,000,000 / min | Succeeded |

## Quota Summary

All deployed model-specific `GlobalStandard` quotas are fully allocated except `grok-4-fast-reasoning`, which Azure now rejects for updates because model version `1` is deprecated.

| Quota name | Current | Limit | Notes |
|---|---:|---:|---|
| `OpenAI.GlobalStandard.gpt-4o` | 450 | 450 | fully allocated |
| `OpenAI.GlobalStandard.gpt-4o-mini-tts` | 600 | 600 | fully allocated |
| `OpenAI.GlobalStandard.ModelRouter` | 250 | 250 | fully allocated |
| `OpenAI.GlobalStandard.sora-2` | 9 | 9 | fully allocated |
| `OpenAI.GlobalStandard.gpt4.1` | 1000 | 1000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-5` | 1000 | 1000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-5-chat` | 1000 | 1000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-5-mini` | 1000 | 1000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-audio` | 30000 | 30000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-5.1-codex-mini` | 1000 | 1000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-5.2` | 1000 | 1000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-image-1.5` | 9 | 9 | fully allocated |
| `OpenAI.GlobalStandard.gpt-audio-1.5` | 30000 | 30000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-5.4` | 1000 | 1000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-5.4-pro` | 160 | 160 | fully allocated |
| `OpenAI.GlobalStandard.gpt-5.4-mini` | 1000 | 1000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-5.4-nano` | 5000 | 5000 | fully allocated |
| `OpenAI.GlobalStandard.gpt-image-2` | 2 | 2 | fully allocated |
| `AIServices.GlobalStandard.Mistral-Large-3` | 1000 | 1000 | fully allocated |
| `AIServices.GlobalStandard.gpt-oss-120b` | 5000 | 5000 | fully allocated |
| `AIServices.GlobalStandard.grok-4-fast-reasoning` | 150 | 1000 | not updated; deprecated model version |
| `AIServices.GlobalStandard.Cohere-Rerank-V4-Fast` | 300 | 300 | fully allocated |
| `AIServices.GlobalStandard.FLUX.2-pro` | 4 | 4 | fully allocated |
| `AIServices.GlobalStandard.FLUX.2-flex` | 4 | 4 | fully allocated |
| `AIServices.GlobalStandard.grok-4-1-fast-reasoning` | 1000 | 1000 | fully allocated |
| `AIServices.GlobalStandard.grok-4-20-reasoning` | 1000 | 1000 | fully allocated |
| `AIServices.GlobalStandard.MaaS` | 1 | 600 | `Phi-4-reasoning` has SKU max `1`, so it cannot consume the full shared MaaS quota alone |

## Important Notes

| Topic | Note |
|---|---|
| Secrets | Do not commit APIM subscription keys, Azure access tokens, or Foundry keys. This account has local key auth disabled. |
| Gateway auth | Gateway clients need an APIM subscription key. For this gateway, `/openai` expects header `api-key` or query `api-key`; `/admin-m8fg494d-eastus2` expects header `api-key` or query `subscription-key`. |
| Backend auth | APIM authenticates to Azure Cognitive Services using its system-assigned managed identity for the OpenAI API. |
| Direct auth | Direct calls need a Microsoft Entra ID token for `https://cognitiveservices.azure.com`. |
| APIM v1 routes | `/openai/v1/*` is exposed through APIM wildcard operations for `GET`, `POST`, and `DELETE`; responses, chat completions, and Sora video job creation have been validated through this path. |
| FLUX routes | Use `/providers/blackforestlabs/v1/flux-2-flex?api-version=preview` or `/providers/blackforestlabs/v1/flux-2-pro?api-version=preview`. Consumers should call these through `/admin-m8fg494d-eastus2/...` with the APIM key; owner diagnostics can call the direct services endpoint with an Entra token for `https://ai.azure.com`. |
| Image model examples | Large verified artifacts are saved under `tests/generated-assets/images/*large-realistic-observatory*`, including `gpt-image-2` at `3840x2160` and both FLUX models at `2304x1728`. |
| Deprecated model | `grok-4-fast-reasoning` version `1` is deprecated as of `2026-05-01`; Azure rejected scaling it to full quota. Prefer `grok-4-1-fast-reasoning` or `grok-4-20-reasoning`. |
| APIM direct role lookup | `az role assignment list` returned no visible role assignments for the APIM principal in the current CLI context, although the APIM policy is configured to use managed identity. |
