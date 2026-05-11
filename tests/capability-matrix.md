# Azure AI Foundry Model Capability Test Matrix

Generated: `2026-05-07T22:04:24Z`

Secrets are not saved. APIM keys and Entra bearer tokens were held only in shell variables.

## Summary

| Deployment | Capability | Transport | Status | HTTP | Response File |
|---|---|---|---|---:|---|
| `Cohere-rerank-v4.0-fast` | `chat-completions` | `direct-v1` | failed | 404 | `Cohere-rerank-v4_0-fast__chat-completions__direct-v1.response.txt` |
| `Cohere-rerank-v4.0-fast` | `responses` | `direct-v1` | failed | 400 | `Cohere-rerank-v4_0-fast__responses__direct-v1.response.json` |
| `FLUX.2-flex` | `image-generations` | `gateway-versioned` | failed | 404 | `FLUX_2-flex__image-generations__gateway-versioned.response.txt` |
| `FLUX.2-pro` | `image-generations` | `gateway-versioned` | failed | 404 | `FLUX_2-pro__image-generations__gateway-versioned.response.txt` |
| `gpt-4.1` | `chat-completions` | `direct-v1` | passed | 200 | `gpt-4_1__chat-completions__direct-v1.response.json` |
| `gpt-4.1` | `chat-completions` | `gateway-versioned` | passed | 200 | `gpt-4_1__chat-completions__gateway-versioned.response.json` |
| `gpt-4.1` | `responses` | `direct-v1` | passed | 200 | `gpt-4_1__responses__direct-v1.response.json` |
| `gpt-4.1` | `responses` | `gateway-versioned` | passed | 200 | `gpt-4_1__responses__gateway-versioned.response.json` |
| `gpt-4.1` | `tool-calling-chat` | `direct-v1` | passed | 200 | `gpt-4_1__tool-calling-chat__direct-v1.response.json` |
| `gpt-4.1` | `tool-calling-responses` | `direct-v1` | passed | 200 | `gpt-4_1__tool-calling-responses__direct-v1.response.json` |
| `gpt-4o` | `chat-completions` | `direct-v1` | passed | 200 | `gpt-4o__chat-completions__direct-v1.response.json` |
| `gpt-4o` | `chat-completions` | `gateway-versioned` | passed | 200 | `gpt-4o__chat-completions__gateway-versioned.response.json` |
| `gpt-4o` | `image-input-chat` | `direct-v1` | passed | 200 | `gpt-4o__image-input-chat__direct-v1.response.json` |
| `gpt-4o` | `image-input-responses` | `direct-v1` | passed | 200 | `gpt-4o__image-input-responses__direct-v1.response.json` |
| `gpt-4o` | `responses` | `direct-v1` | passed | 200 | `gpt-4o__responses__direct-v1.response.json` |
| `gpt-4o` | `responses` | `gateway-versioned` | passed | 200 | `gpt-4o__responses__gateway-versioned.response.json` |
| `gpt-4o-mini-tts` | `audio-speech` | `gateway-versioned` | passed | 200 | `gpt-4o-mini-tts__audio-speech__gateway-versioned.mp3` |
| `gpt-5` | `chat-completions` | `direct-v1` | passed | 200 | `gpt-5__chat-completions__direct-v1.response.json` |
| `gpt-5` | `chat-completions` | `gateway-versioned` | passed | 200 | `gpt-5__chat-completions__gateway-versioned.response.json` |
| `gpt-5` | `responses` | `direct-v1` | passed | 200 | `gpt-5__responses__direct-v1.response.json` |
| `gpt-5` | `responses` | `gateway-versioned` | passed | 200 | `gpt-5__responses__gateway-versioned.response.json` |
| `gpt-5` | `tool-calling-chat` | `direct-v1` | passed | 200 | `gpt-5__tool-calling-chat__direct-v1.response.json` |
| `gpt-5` | `tool-calling-responses` | `direct-v1` | passed | 200 | `gpt-5__tool-calling-responses__direct-v1.response.json` |
| `gpt-5.1-codex-mini` | `responses` | `direct-v1` | passed | 200 | `gpt-5_1-codex-mini__responses__direct-v1.response.json` |
| `gpt-5.1-codex-mini` | `responses` | `gateway-versioned` | passed | 200 | `gpt-5_1-codex-mini__responses__gateway-versioned.response.json` |
| `gpt-5.2` | `chat-completions` | `direct-v1` | passed | 200 | `gpt-5_2__chat-completions__direct-v1.response.json` |
| `gpt-5.2` | `chat-completions` | `gateway-versioned` | passed | 200 | `gpt-5_2__chat-completions__gateway-versioned.response.json` |
| `gpt-5.2` | `responses` | `direct-v1` | passed | 200 | `gpt-5_2__responses__direct-v1.response.json` |
| `gpt-5.2` | `responses` | `gateway-versioned` | passed | 200 | `gpt-5_2__responses__gateway-versioned.response.json` |
| `gpt-5.4` | `chat-completions` | `direct-v1` | passed | 200 | `gpt-5_4__chat-completions__direct-v1.response.json` |
| `gpt-5.4` | `chat-completions` | `gateway-versioned` | passed | 200 | `gpt-5_4__chat-completions__gateway-versioned.response.json` |
| `gpt-5.4` | `responses` | `direct-v1` | passed | 200 | `gpt-5_4__responses__direct-v1.response.json` |
| `gpt-5.4` | `responses` | `gateway-versioned` | passed | 200 | `gpt-5_4__responses__gateway-versioned.response.json` |
| `gpt-5.4-mini` | `chat-completions` | `direct-v1` | passed | 200 | `gpt-5_4-mini__chat-completions__direct-v1.response.json` |
| `gpt-5.4-mini` | `chat-completions` | `gateway-versioned` | passed | 200 | `gpt-5_4-mini__chat-completions__gateway-versioned.response.json` |
| `gpt-5.4-mini` | `responses` | `direct-v1` | passed | 200 | `gpt-5_4-mini__responses__direct-v1.response.json` |
| `gpt-5.4-mini` | `responses` | `gateway-versioned` | passed | 200 | `gpt-5_4-mini__responses__gateway-versioned.response.json` |
| `gpt-5.4-nano` | `chat-completions` | `direct-v1` | passed | 200 | `gpt-5_4-nano__chat-completions__direct-v1.response.json` |
| `gpt-5.4-nano` | `chat-completions` | `gateway-versioned` | passed | 200 | `gpt-5_4-nano__chat-completions__gateway-versioned.response.json` |
| `gpt-5.4-nano` | `image-input-chat` | `direct-v1` | failed | 400 | `gpt-5_4-nano__image-input-chat__direct-v1.response.json` |
| `gpt-5.4-nano` | `image-input-responses` | `direct-v1` | passed | 200 | `gpt-5_4-nano__image-input-responses__direct-v1.response.json` |
| `gpt-5.4-nano` | `responses` | `direct-v1` | passed | 200 | `gpt-5_4-nano__responses__direct-v1.response.json` |
| `gpt-5.4-nano` | `responses` | `gateway-versioned` | passed | 200 | `gpt-5_4-nano__responses__gateway-versioned.response.json` |
| `gpt-5.4-nano` | `tool-calling-chat` | `direct-v1` | passed | 200 | `gpt-5_4-nano__tool-calling-chat__direct-v1.response.json` |
| `gpt-5.4-nano` | `tool-calling-responses` | `direct-v1` | passed | 200 | `gpt-5_4-nano__tool-calling-responses__direct-v1.response.json` |
| `gpt-5.4-pro` | `responses` | `direct-v1` | passed | 200 | `gpt-5_4-pro__responses__direct-v1.response.json` |
| `gpt-5.4-pro` | `responses` | `gateway-versioned` | passed | 200 | `gpt-5_4-pro__responses__gateway-versioned.response.json` |
| `gpt-5-chat` | `chat-completions` | `direct-v1` | passed | 200 | `gpt-5-chat__chat-completions__direct-v1.response.json` |
| `gpt-5-chat` | `chat-completions` | `gateway-versioned` | passed | 200 | `gpt-5-chat__chat-completions__gateway-versioned.response.json` |
| `gpt-5-chat` | `responses` | `direct-v1` | passed | 200 | `gpt-5-chat__responses__direct-v1.response.json` |
| `gpt-5-chat` | `responses` | `gateway-versioned` | passed | 200 | `gpt-5-chat__responses__gateway-versioned.response.json` |
| `gpt-5-mini` | `chat-completions` | `direct-v1` | passed | 200 | `gpt-5-mini__chat-completions__direct-v1.response.json` |
| `gpt-5-mini` | `chat-completions` | `gateway-versioned` | passed | 200 | `gpt-5-mini__chat-completions__gateway-versioned.response.json` |
| `gpt-5-mini` | `responses` | `direct-v1` | passed | 200 | `gpt-5-mini__responses__direct-v1.response.json` |
| `gpt-5-mini` | `responses` | `gateway-versioned` | passed | 200 | `gpt-5-mini__responses__gateway-versioned.response.json` |
| `gpt-audio` | `audio-chat` | `direct-v1` | passed | 200 | `gpt-audio__audio-chat__direct-v1.response.json` |
| `gpt-audio` | `audio-chat` | `gateway-versioned` | passed | 200 | `gpt-audio__audio-chat__gateway-versioned.response.json` |
| `gpt-audio-1.5` | `audio-chat` | `direct-v1` | passed | 200 | `gpt-audio-1_5__audio-chat__direct-v1.response.json` |
| `gpt-audio-1.5` | `audio-chat` | `gateway-versioned` | passed | 200 | `gpt-audio-1_5__audio-chat__gateway-versioned.response.json` |
| `gpt-image-1.5` | `image-generations` | `gateway-versioned` | passed | 200 | `gpt-image-1_5__image-generations__gateway-versioned.response.json` |
| `gpt-image-2` | `image-generations` | `gateway-versioned` | passed | 200 | `gpt-image-2__image-generations__gateway-versioned.response.json` |
| `gpt-oss-120b` | `chat-completions` | `direct-v1` | passed | 200 | `gpt-oss-120b__chat-completions__direct-v1.response.json` |
| `gpt-oss-120b` | `chat-completions` | `gateway-versioned` | passed | 200 | `gpt-oss-120b__chat-completions__gateway-versioned.response.json` |
| `grok-4-1-fast-reasoning` | `chat-completions` | `direct-v1` | passed | 200 | `grok-4-1-fast-reasoning__chat-completions__direct-v1.response.json` |
| `grok-4-1-fast-reasoning` | `chat-completions` | `gateway-versioned` | passed | 200 | `grok-4-1-fast-reasoning__chat-completions__gateway-versioned.response.json` |
| `grok-4-20-reasoning` | `chat-completions` | `direct-v1` | passed | 200 | `grok-4-20-reasoning__chat-completions__direct-v1.response.json` |
| `grok-4-20-reasoning` | `chat-completions` | `gateway-versioned` | passed | 200 | `grok-4-20-reasoning__chat-completions__gateway-versioned.response.json` |
| `grok-4-fast-reasoning` | `chat-completions` | `direct-v1` | failed | 400 | `grok-4-fast-reasoning__chat-completions__direct-v1.response.json` |
| `grok-4-fast-reasoning` | `chat-completions` | `gateway-versioned` | failed | 400 | `grok-4-fast-reasoning__chat-completions__gateway-versioned.response.json` |
| `Mistral-Large-3` | `chat-completions` | `direct-v1` | passed | 200 | `Mistral-Large-3__chat-completions__direct-v1.response.json` |
| `Mistral-Large-3` | `chat-completions` | `gateway-versioned` | passed | 200 | `Mistral-Large-3__chat-completions__gateway-versioned.response.json` |
| `Mistral-Large-3` | `tool-calling-chat` | `direct-v1` | passed | 200 | `Mistral-Large-3__tool-calling-chat__direct-v1.response.json` |
| `Mistral-Large-3` | `tool-calling-responses` | `direct-v1` | failed | 400 | `Mistral-Large-3__tool-calling-responses__direct-v1.response.json` |
| `ModelRouter` | `chat-completions` | `direct-v1` | passed | 200 | `ModelRouter__chat-completions__direct-v1.response.json` |
| `ModelRouter` | `chat-completions` | `gateway-versioned` | passed | 200 | `ModelRouter__chat-completions__gateway-versioned.response.json` |
| `Phi-4-reasoning` | `chat-completions` | `direct-v1` | passed | 200 | `Phi-4-reasoning__chat-completions__direct-v1.response.json` |
| `Phi-4-reasoning` | `responses` | `direct-v1` | failed | 400 | `Phi-4-reasoning__responses__direct-v1.response.json` |
| `sora-2` | `video-generation-job` | `direct-v1` | passed | 200 | `sora-2__video-generation-job__direct-v1.response.json` |
| `sora-2` | `video-generation-job` | `gateway-v1` | failed | 404 | `sora-2__video-generation-job__gateway-v1.response.json` |
