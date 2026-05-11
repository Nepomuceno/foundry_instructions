# Model Support Summary

Generated from live tests against `admin-m8fg494d-eastus2` on 2026-05-07.

Secrets were not written to disk. APIM keys and Entra tokens were held only in shell variables during test execution.

## Access Surfaces Tested

| Surface | Base URL | Auth | Result |
|---|---|---|---|
| APIM versioned OpenAI API | `https://ai-gateway-eastus2.azure-api.net/openai/...?...api-version=2025-04-01-preview` | APIM subscription key in `api-key` header | Works for most chat, responses, image, and audio routes imported into APIM |
| Direct Azure OpenAI v1 API | `https://admin-m8fg494d-eastus2.openai.azure.com/openai/v1/...` | Entra token for `https://ai.azure.com` | Works for newer v1 chat, responses, audio-chat, and Sora video job routes |
| APIM v1 API | `https://ai-gateway-eastus2.azure-api.net/openai/v1/...` | APIM subscription key in `api-key` header | Works after adding `GET`, `POST`, and `DELETE` wildcard operations for `/v1/*` |

## Per-Model Results

| Deployment | Chat | Responses | Image Input | Tool Calling | Image Generation | Audio | Video | Notes |
|---|---|---|---|---|---|---|---|---|
| `gpt-4o` | yes | yes | yes, chat and responses | not tested | no | no | no | Vision passed with remote PNG URL |
| `gpt-4.1` | yes | yes | not tested | yes, chat and responses | no | no | no | Tool call returned a function call |
| `gpt-4o-mini-tts` | no | no | no | no | no | yes, `/audio/speech` | no | Saved MP3 artifact |
| `gpt-5-chat` | yes | yes | not tested | not tested | no | no | no | Works through direct v1 and APIM versioned routes |
| `gpt-5-mini` | yes | yes | not tested | not tested | no | no | no | Requires `max_completion_tokens` for chat |
| `gpt-5` | yes | yes | not tested | yes, chat and responses | no | no | no | Requires larger token budget for tool/reasoning calls |
| `gpt-audio` | yes, audio-chat | not tested | not tested | not tested | no | yes, chat with audio output | no | Plain text-only chat fails; must request audio modality |
| `gpt-5.2` | yes | yes | not tested | not tested | no | no | no | Requires `max_completion_tokens` for chat |
| `gpt-oss-120b` | yes | not tested | not tested | not tested | no | no | no | Chat works direct and via APIM |
| `Phi-4-reasoning` | yes | no | not tested | not tested | no | no | no | Responses API returned unsupported |
| `gpt-5.1-codex-mini` | no | yes | not tested | not tested | no | no | no | Deployment metadata says `chatCompletion=false`, `responses=true` |
| `gpt-image-1.5` | no | no | no | no | yes | no | no | Image generation works through APIM versioned route |
| `FLUX.2-flex` | no | no | yes, provider route supports reference-image fields by docs | no | yes, provider-specific route | no | no | Use `/providers/blackforestlabs/v1/flux-2-flex?api-version=preview`; returns base64 image data |
| `gpt-5.4` | yes | yes | not tested | not tested | no | no | no | Requires `max_completion_tokens` for chat |
| `gpt-audio-1.5` | yes, audio-chat | not tested | not tested | not tested | no | yes, chat with audio output | no | Plain text-only chat fails; must request audio modality |
| `gpt-5.4-nano` | yes | yes | yes via responses | yes, chat and responses | no | no | no | Catalog confirms text+image input; responses image-input passed |
| `grok-4-fast-reasoning` | no | not tested | not tested | not tested | no | no | no | Deprecated deployment returns `unknown_model` on current chat routes |
| `FLUX.2-pro` | no | no | not tested | no | yes, provider-specific route | no | no | Use `/providers/blackforestlabs/v1/flux-2-pro?api-version=preview`; returns base64 image data |
| `sora-2` | no | no | no | no | no | no | yes direct v1 and APIM v1 | Direct v1 and APIM v1 job creation work; completed MP4 artifact saved under `generated-assets/videos/` |
| `Cohere-rerank-v4.0-fast` | no | no | no | no | no | no | no | Rerank route was not exposed by tested OpenAI/v1 routes; chat/responses failed |
| `gpt-image-2` | no | no | image-to-image likely by catalog, not tested | no | yes | no | no | Text-to-image generation works through APIM versioned route; PNG artifact saved under `generated-assets/images/` |
| `ModelRouter` | yes | not tested | not tested | not tested | no | no | no | Chat works direct and via APIM |
| `gpt-5.4-pro` | no | yes | not tested | not tested | no | no | no | Deployment metadata says `chatCompletion=false`, `responses=true` |
| `grok-4-20-reasoning` | yes | not tested | not tested | not tested | no | no | no | Chat works direct and via APIM |
| `Mistral-Large-3` | yes | no | not tested | yes via chat, no via responses | no | no | no | Direct v1 chat and tool-calling chat passed |
| `grok-4-1-fast-reasoning` | yes | not tested | not tested | not tested | no | no | no | Chat works direct and via APIM |
| `gpt-5.4-mini` | yes | yes | not tested | not tested | no | no | no | Requires `max_completion_tokens` for chat |

## Important Findings

| Finding | Detail |
|---|---|
| APIM key header | The gateway expects the APIM subscription key in `api-key`, not `Ocp-Apim-Subscription-Key`. |
| APIM v1 wildcard | `/openai/v1/*` now has APIM wildcard operations for `GET`, `POST`, and `DELETE`. Responses, chat completions, and Sora video job creation passed through APIM v1 after this fix. |
| GPT-5-family chat | Use `max_completion_tokens`, not `max_tokens`. Reasoning/tool probes need a larger budget than 2 tokens. |
| Audio chat models | `gpt-audio` and `gpt-audio-1.5` require audio input or audio output modality; text-only chat fails by design. |
| Sora | Direct v1 and APIM v1 `/openai/v1/videos` create async jobs. A completed job was downloaded as `generated-assets/videos/sora-2_video_69fd0c5f14d8819085679673ec41d6eb.mp4`. |
| FLUX | `FLUX.2-flex` and `FLUX.2-pro` work through Black Forest Labs provider routes, not the deployment-scoped Azure OpenAI image route. Consumers can call these through the `/admin-m8fg494d-eastus2` APIM pass-through path with the provided APIM key. |
| Cohere rerank | The deployment is not usable via chat or responses; a provider-specific rerank route still needs to be identified/imported. |
| Deprecated Grok | `grok-4-fast-reasoning` is deployed but current routes return `unknown_model`; use `grok-4-1-fast-reasoning` or `grok-4-20-reasoning`. |

## Generated Artifacts

| Artifact | Source | Notes |
|---|---|---|
| `generated-assets/images/gpt-image-1.5-blue-dot.png` | `gpt-image-1.5` image generation | Decoded PNG, `1024 x 1024`; manifest saved beside image |
| `generated-assets/images/gpt-image-2-blue-dot.png` | `gpt-image-2` image generation | Decoded PNG, `1024 x 1024`; manifest saved beside image |
| `generated-assets/images/FLUX.2-flex-blue-dot-default.jpg` | `FLUX.2-flex` image generation | Default output decoded as JPEG, `1024 x 1024`; manifest saved beside image |
| `generated-assets/images/FLUX.2-flex-blue-dot.jpeg` | `FLUX.2-flex` image generation | Explicit `output_format: "jpeg"`, `1024 x 1024`; manifest saved beside image |
| `generated-assets/images/FLUX.2-flex-blue-dot.png` | `FLUX.2-flex` image generation | Explicit `output_format: "png"`, `1024 x 1024`; manifest saved beside image |
| `generated-assets/images/gpt-image-2-large-realistic-observatory.png` | `gpt-image-2` image generation | Explicit `size: "3840x2160"`, decoded PNG; manifest saved beside image |
| `generated-assets/images/FLUX.2-flex-large-realistic-observatory.png` | `FLUX.2-flex` image generation | Explicit `2304 x 1728`, decoded PNG; manifest saved beside image |
| `generated-assets/images/FLUX.2-pro-large-realistic-observatory.png` | `FLUX.2-pro` image generation | Explicit `2304 x 1728`, decoded PNG; manifest saved beside image |
| `generated-assets/videos/sora-2_video_69fd0c5f14d8819085679673ec41d6eb.mp4` | `sora-2` video generation | Completed Sora video job downloaded from direct v1 |
| `generated-assets/videos/sora-2_video_69fd4e6ce3e8819098307c957a1aab7b.mp4` | `sora-2` video generation | Completed Sora video job created and downloaded through APIM v1 |

## Model-Specific Parameter Findings

| Model | Finding |
|---|---|
| `gpt-image-2` | `output_format` supports `png` and `jpeg`; `webp` was rejected. |
| `gpt-image-2` | `background: transparent` was rejected; transparent background is not supported. |
| `gpt-image-2` | `512x512` was rejected as below the minimum pixel budget. Further size probing hit the deployment's `2 RPM` rate limit. |
| `sora-2` | `/openai/v1/videos` accepts `seconds` as string enum values such as `"4"`, `"8"`, and `"12"`. Valid sizes include `720x1280`, `1280x720`, `1024x1792`, and `1792x1024`. |
| `FLUX.2-flex` | Working route: `POST https://admin-m8fg494d-eastus2.services.ai.azure.com/providers/blackforestlabs/v1/flux-2-flex?api-version=preview` with Entra bearer token and JSON body containing `prompt`, `width`, `height`, `n`, and `model`. |
| `FLUX.2-flex` | Supported output formats on the provider route are `jpeg` and `png`. Omitting `output_format` defaults to JPEG. `webp` and MIME values such as `image/jpeg`, `image/png`, and `image/webp` returned `422`; the error says `Input should be 'png' or 'jpeg'`. |
| `FLUX.2-flex` | Provider docs/API schema support text-to-image and editing/reference-image fields: `input_image` through `input_image_8`; catalog says up to 10 reference images in playground and up to 8-10 depending doc surface. |
| `FLUX.2-flex` | Provider docs list `steps` up to `50`, `guidance` from `1.5` to `10`, optional `seed`, `prompt_upsampling`, `safety_tolerance`, `webhook_url`, and `webhook_secret`. Deployment metadata reports `4 RPM`. |
| `FLUX.2-pro` | Working route: `POST https://admin-m8fg494d-eastus2.services.ai.azure.com/providers/blackforestlabs/v1/flux-2-pro?api-version=preview` with Entra bearer token and JSON body containing `prompt`, `width`, `height`, `n`, `model`, `steps`, `guidance`, and `output_format`. |
| `FLUX.2-pro` | `2304x1728`, `steps: 50`, `guidance: 5`, and `output_format: "png"` were validated. |
| `Cohere-rerank-v4.0-fast` | Catalog/docs confirm rerank behavior, but the Azure Foundry/APIM provider-specific route remains unresolved in these tests. |

## Evidence Files

| File | Purpose |
|---|---|
| `capability-matrix.md` | Full attempt-by-attempt matrix with status and response file names |
| `capability-summary.json` | Machine-readable summary of all attempts |
| `capability-summary.tsv` | Tabular summary of all attempts |
| `results/*.json` | Sanitized metadata for each request, including URL, request body, status, and response file |
| `responses/*` | Raw JSON/text/binary response artifacts |
| `generated-assets/images/*` | Decoded generated image artifacts and manifests |
| `generated-assets/videos/*` | Downloaded generated video artifacts |
| `run_capability_matrix.sh` | Re-runnable test harness; retrieves secrets into variables only |
