# Consumer Guide: Calling Stuff With Your Key

You got an API key. You want to call things. This is the doc for that.

No Azure portal. No `az login`. No `Authorization: Bearer ...`. Just one header, one base URL, and a list of models that actually work.

> Replace `<your-api-key>` everywhere below with the key you were given. If you're about to paste it into a public Slack channel, please don't.

---

## The Two URLs You Need

| When you want... | Use this base URL |
|---|---|
| GPT-style anything (chat, responses, images, video, audio) | `https://ai-gateway-eastus2.azure-api.net/openai` |
| FLUX image models (Black Forest Labs flavor) | `https://ai-gateway-eastus2.azure-api.net/admin-m8fg494d-eastus2` |

And one header to rule them all:

```http
api-key: <your-api-key>
```

That's it. That's the auth model. If anything asks you for `Authorization: Bearer`, you're on the wrong path. Back up.

---

## Smoke Test (Are You In?)

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/v1/responses" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-5.4-nano","input":"Reply with: OK, the gateway works."}'
```

If you got a JSON blob with words in it, congratulations, you've successfully spoken to a small but eager language model. Now do bigger things.

---

## Text and Reasoning

The Responses API is the modern OpenAI shape. Use it for most chat-like things.

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/v1/responses" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.4-mini",
    "input": "Explain APIM managed identity in two short paragraphs."
  }'
```

Need classic chat-completions instead? That works too:

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/v1/chat/completions" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Mistral-Large-3",
    "messages": [{"role":"user","content":"Give me three practical API design tips."}],
    "max_tokens": 300
  }'
```

**Things people forget:**
- For **GPT-5-family** models, use `max_completion_tokens` (not `max_tokens`). The API will yell at you otherwise.
- For **reasoning models**, give them more tokens than you think. They think a lot, then talk.

### Which model when?

| Vibe | Pick |
|---|---|
| Default coding sidekick | `gpt-5.4-mini` |
| You need it to actually think | `gpt-5.4` or `gpt-5.4-pro` |
| Cheap and fast for tons of small calls | `gpt-5.4-nano` |
| Tool calling / agent workflows | `gpt-5` |
| Big context, open-weight chat | `Mistral-Large-3` |
| You want it to argue with itself | `grok-4-1-fast-reasoning` or `grok-4-20-reasoning` |
| You want it to pick a model for you | `ModelRouter` |

---

## Images: The GPT Family

`gpt-image-2` is the headline image model. Big sizes, decent realism, low ceremony.

### Make a 4K image with `gpt-image-2`

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/v1/images/generations" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "A cinematic ultra-realistic photograph of a misty alpine observatory at sunrise, brass and glass architecture, wildflowers on stone terraces, turquoise glacial lake below, no text, no watermark.",
    "size": "3840x2160",
    "n": 1,
    "quality": "high",
    "output_format": "png"
  }' | jq -r '.data[0].b64_json' | base64 --decode > observatory.png
```

**`gpt-image-2` rules of the road:**

| Thing | Reality |
|---|---|
| Size parameter | Use `size: "WIDTHxHEIGHT"`. **Not** `width` and `height`. |
| Sizes that work | Both edges multiples of 16. Long edge up to 3840. Aspect ratio up to 3:1. Total pixels between ~655K and ~8.3M. |
| Sizes that won't | `512x512` (too small). It will tell you so, politely. |
| Output formats | `png`, `jpeg`. **Not** `webp`. |
| Transparent background | Not supported on this model. Sorry. |
| Rate limit | 2 requests/minute. Yes, two. Plan accordingly. |

### `gpt-image-1.5` (smaller, friendlier RPM)

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/deployments/gpt-image-1.5/images/generations?api-version=2025-04-01-preview" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Editorial photo of a handmade ceramic mug on a walnut table beside morning light.",
    "size": "1536x1024",
    "n": 1,
    "quality": "high",
    "output_format": "png"
  }' | jq -r '.data[0].b64_json' | base64 --decode > mug.png
```

`gpt-image-1.5`, `gpt-image-1`, and `gpt-image-1-mini` all stick to fixed sizes: `1024x1024`, `1024x1536`, `1536x1024`. Rate limit is 9/min, which feels luxurious after `gpt-image-2`.

---

## Images: The FLUX Family

FLUX is the Black Forest Labs flavor of image generation. Different API shape, different route, but the gateway hides most of that.

### `FLUX.2-flex`

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/admin-m8fg494d-eastus2/providers/blackforestlabs/v1/flux-2-flex?api-version=preview" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "FLUX.2-flex",
    "prompt": "A photograph of a red fox in an autumn forest, soft morning light, shallow depth of field.",
    "width": 2304,
    "height": 1728,
    "n": 1,
    "steps": 50,
    "guidance": 5,
    "output_format": "png"
  }' | jq -r '.data[0].b64_json' | base64 --decode > fox.png
```

### `FLUX.2-pro`

Same shape, different route, `model: "FLUX.2-pro"`:

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/admin-m8fg494d-eastus2/providers/blackforestlabs/v1/flux-2-pro?api-version=preview" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "FLUX.2-pro",
    "prompt": "A photograph of a red fox in an autumn forest, soft morning light.",
    "width": 2304,
    "height": 1728,
    "n": 1,
    "steps": 50,
    "guidance": 5,
    "output_format": "png"
  }' | jq -r '.data[0].b64_json' | base64 --decode > fox-pro.png
```

**FLUX rules of the road:**

| Thing | Reality |
|---|---|
| Size parameters | `width` and `height` (separate integers). **Not** `size`. |
| Resolution | Flexible. Min edge 64. Verified up to `2304x1728`. Catalog says ~4MP ceiling. |
| Output formats | `png`, `jpeg`. Default is JPEG. |
| Don't try | `webp`, `image/png`, `image/jpeg`, MIME-style values. They get rejected. |
| Steps | 1–50. Use 50 if you want it to look nice, less if you're in a hurry. |
| Guidance | 1.5–10. 5 is a good starting point. |
| Rate limit | 4 requests/minute per FLUX deployment. |

---

## Video: Sora

Sora is async. You create a job, you wait, you download. Like ordering coffee.

### 1. Create the job

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/v1/videos" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sora-2",
    "prompt": "A slow cinematic shot of morning mist drifting over a turquoise alpine lake.",
    "seconds": "4",
    "size": "1280x720"
  }'
```

Save the `id` it returns. That's your job.

### 2. Check on it

```bash
curl "https://ai-gateway-eastus2.azure-api.net/openai/v1/videos/<job-id>" \
  -H "api-key: <your-api-key>"
```

Status will be `queued`, `in_progress`, or `completed`. Keep polling, but be chill about it.

### 3. Get the file

```bash
curl -L "https://ai-gateway-eastus2.azure-api.net/openai/v1/videos/<job-id>/content" \
  -H "api-key: <your-api-key>" \
  -o sora-output.mp4
```

**Sora rules of the road:**

| Thing | Reality |
|---|---|
| `seconds` | Strings: `"4"`, `"8"`, `"12"`. Yes, strings. Quotes matter. |
| Sizes that work | `1280x720`, `720x1280`, `1792x1024`, `1024x1792` |
| Rate limit | 9 jobs/minute. Each job takes a while anyway. |

---

## Audio

### Text to speech (`gpt-4o-mini-tts`)

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/deployments/gpt-4o-mini-tts/audio/speech?api-version=2025-04-01-preview" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{"input":"Hello from the gateway, this is your AI speaking.","voice":"alloy"}' \
  --output speech.mp3
```

### Audio chat (`gpt-audio`, `gpt-audio-1.5`)

These models **require** audio in or audio out. Plain text-only chat will fail by design. If you want a text bot, use a text model. If you want a voice, use these and pass an `audio` modality. Their docs are deeper than this guide; ask in the hack channel if you go down that road.

---

## When Things Go Sideways

| Error | What it actually means | Fix |
|---|---|---|
| `401` / `403` | Your `api-key` header is missing, wrong, or has spaces | Re-export the variable, restart your terminal |
| `404` on a model | Wrong model name, or wrong route | Check spelling. Use the exact case (`FLUX.2-flex`, not `flux-2-flex` for the `model` field) |
| `404` on FLUX with `/openai/...` | Wrong base URL | FLUX lives at `/admin-m8fg494d-eastus2/providers/blackforestlabs/...` |
| `429 RateLimitReached` | You went too fast | Wait a minute. Image and video models have low RPM by design |
| `Unsupported parameter: max_tokens` | You used a GPT-5-family model | Send `max_completion_tokens` instead |
| `Unknown parameter: width` on `gpt-image-2` | You used FLUX shape on a GPT model | Use `size: "WIDTHxHEIGHT"` |
| `Invalid input` for FLUX `output_format` | You sent `webp` or a MIME type | Send `png` or `jpeg` |
| `Unknown model: grok-4-fast-reasoning` | That deployment is deprecated | Use `grok-4-1-fast-reasoning` or `grok-4-20-reasoning` |

---

## Cheat Sheet

```bash
# Reusable env so you stop typing the key
export AI_GATEWAY="https://ai-gateway-eastus2.azure-api.net"
export AI_GATEWAY_API_KEY="<your-api-key>"

# Quick text
curl -X POST "$AI_GATEWAY/openai/v1/responses" \
  -H "api-key: $AI_GATEWAY_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"gpt-5.4-mini","input":"What does CIDR mean? Two sentences."}'

# Quick image
curl -X POST "$AI_GATEWAY/openai/v1/images/generations" \
  -H "api-key: $AI_GATEWAY_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"gpt-image-2","prompt":"a teapot in space","size":"1024x1024"}' \
  | jq -r '.data[0].b64_json' | base64 --decode > teapot.png

# Quick FLUX
curl -X POST "$AI_GATEWAY/admin-m8fg494d-eastus2/providers/blackforestlabs/v1/flux-2-flex?api-version=preview" \
  -H "api-key: $AI_GATEWAY_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"FLUX.2-flex","prompt":"a teapot in space","width":1024,"height":1024,"output_format":"png"}' \
  | jq -r '.data[0].b64_json' | base64 --decode > teapot-flux.png
```

Now go build the cool thing. If something here is wrong or incomplete, ping the gateway owner. They like fixing docs more than they like fixing infra at 3 a.m.
