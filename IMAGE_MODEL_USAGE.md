# Image Model Reference

Pixels. We make them. Here's how.

This is the reference doc for image generation through the gateway. If you just want to copy-paste a curl command and move on, [the consumer guide](AI_GATEWAY_CONSUMER_GUIDE.md) is the right doc. If you want to know exactly which sizes are legal, what formats work, and why FLUX is its own special snowflake, this is your stop.

---

## TL;DR

| Model | Best for | Max verified resolution | Format(s) |
|---|---|---|---|
| `gpt-image-2` | Big, sharp, custom aspect ratios, 4K | `3840x2160` | `png`, `jpeg` |
| `gpt-image-1.5` | Reliable square/landscape, more requests/min | `1536x1024` | `png`, `jpeg` |
| `FLUX.2-flex` | Realism + flexible sizes + reference-image editing | `2304x1728` | `png`, `jpeg` |
| `FLUX.2-pro` | Same shape as flex, but pro vibes | `2304x1728` | `png`, `jpeg` |

When in doubt, **`FLUX.2-flex`** for general use and **`gpt-image-2`** for photorealism or editing existing images.

---

## Routes

| Model | Route |
|---|---|
| `gpt-image-2` | `POST https://ai-gateway-eastus2.azure-api.net/openai/v1/images/generations` |
| `gpt-image-1.5` | `POST https://ai-gateway-eastus2.azure-api.net/openai/deployments/gpt-image-1.5/images/generations?api-version=2025-04-01-preview` |
| `FLUX.2-flex` | `POST https://ai-gateway-eastus2.azure-api.net/admin-m8fg494d-eastus2/providers/blackforestlabs/v1/flux-2-flex?api-version=preview` |
| `FLUX.2-pro` | `POST https://ai-gateway-eastus2.azure-api.net/admin-m8fg494d-eastus2/providers/blackforestlabs/v1/flux-2-pro?api-version=preview` |

Auth header is always `api-key: <your-api-key>`. No bearer tokens. No subscription headers. No drama.

---

## The One Confusing Thing

**GPT image models use `size`. FLUX uses `width` and `height`.** They are not the same. They will not be the same. Don't try to make them the same.

```jsonc
// gpt-image-2 — correct
{ "model": "gpt-image-2", "prompt": "...", "size": "1536x1024" }

// FLUX.2-flex — correct
{ "model": "FLUX.2-flex", "prompt": "...", "width": 1536, "height": 1024 }
```

If you mix these up, the API tells you. Politely. Eventually.

---

## `gpt-image-2` Deep Dive

The headline model. Big, modern, supports custom sizes.

### Working request

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/v1/images/generations" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "An ultra-realistic cinematic photograph of a futuristic alpine observatory at sunrise.",
    "size": "3840x2160",
    "n": 1,
    "quality": "high",
    "output_format": "png"
  }' | jq -r '.data[0].b64_json' | base64 --decode > out.png
```

### Resolution rules

| Rule | Detail |
|---|---|
| Both edges must be multiples of 16 | `1024x1024` ✅, `1023x1024` ❌ |
| Long edge ≤ 3840 | `3840x2160` ✅, `4096x4096` ❌ |
| Aspect ratio ≤ 3:1 | `3000x1000` ✅, `3000x500` ❌ |
| Total pixels between ~655,360 and ~8,294,400 | `512x512` ❌ (too few), `4000x4000` ❌ (too many) |

### Verified working sizes

`1024x1024`, `1024x1536`, `1536x1024`, `1280x720`, `1920x1088`, `2880x2880`, `3840x2160`.

### Other options

| Field | Values | Notes |
|---|---|---|
| `quality` | `low`, `medium`, `high` | `high` is the default sweet spot |
| `output_format` | `png`, `jpeg` | `webp` is rejected. `image/png` etc are also rejected. |
| `background` | (transparent not supported on this model) | If you want transparent PNGs, use `gpt-image-1` series |
| `n` | 1–10 | More than 1 = more wait, more usage |

### Things that fail (so you don't waste a request finding out)

| Tried | Got | Why |
|---|---|---|
| `width: 1024, height: 1024` | `400 unknown_parameter` | Use `size`, not separate dims |
| `size: "512x512"` | `400 below minimum pixel budget` | Below ~655,360 pixels |
| `output_format: "webp"` | `400` | Only `png`/`jpeg` |
| `background: "transparent"` | `400` | Not supported on `gpt-image-2` |

### Rate limit

**2 requests/minute.** This is not a typo. Two. Plan your demos accordingly. If you need more throughput, use `gpt-image-1.5` (9/min) for smaller stuff and reserve `gpt-image-2` for the hero shots.

---

## `gpt-image-1.5`

Older but still fun. Fixed sizes only, but you get more requests per minute.

### Working request

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/deployments/gpt-image-1.5/images/generations?api-version=2025-04-01-preview" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Editorial photo of a handmade ceramic mug on a walnut table.",
    "size": "1536x1024",
    "n": 1,
    "quality": "high",
    "output_format": "png"
  }' | jq -r '.data[0].b64_json' | base64 --decode > out.png
```

### Sizes

`1024x1024`, `1024x1536`, `1536x1024`. That's the menu.

### Rate limit

**9 requests/minute.** Comfortable for iterative prompt-tuning sessions.

---

## FLUX.2-flex Deep Dive

The Black Forest Labs realism model. Different API shape, different route, but well worth it.

### Working request

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/admin-m8fg494d-eastus2/providers/blackforestlabs/v1/flux-2-flex?api-version=preview" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "FLUX.2-flex",
    "prompt": "A photograph of a red fox in an autumn forest, soft morning light.",
    "width": 2304,
    "height": 1728,
    "n": 1,
    "steps": 50,
    "guidance": 5,
    "output_format": "png"
  }' | jq -r '.data[0].b64_json' | base64 --decode > fox.png
```

### Resolution rules

| Rule | Detail |
|---|---|
| Min edge | 64 |
| Verified max | `2304x1728` |
| Catalog ceiling | ~4 megapixels total |

FLUX is more flexible than GPT image models on aspect ratios, but very large outputs eat your rate budget fast.

### Other options

| Field | Values | Notes |
|---|---|---|
| `output_format` | `png`, `jpeg` | Default is JPEG. `webp` is rejected. MIME types like `image/png` are rejected. |
| `steps` | 1–50 | More steps = nicer image, slower response. 50 is the verified sweet spot. |
| `guidance` | 1.5–10 | 5 is a great default. Higher = follows prompt more strictly, less natural. |
| `n` | 1+ | Most usage is 1; multi-image asks aren't common here. |
| `seed` | int | Optional reproducibility. |
| `prompt_upsampling` | bool | Optional automatic prompt enhancement. |
| `safety_tolerance` | 0–5 | 0 strictest, 5 most permissive. |

### Reference-image editing

FLUX.2-flex supports reference images via `input_image` through `input_image_8` (up to 8 reference images via the API; the playground says up to 10). Pass URLs or blob paths. This is the killer feature if you're doing image-to-image editing.

### Things that fail

| Tried | Got | Why |
|---|---|---|
| `size: "1024x1024"` | Validation error | FLUX uses `width`/`height` |
| `output_format: "webp"` | `422` | Only `png`/`jpeg` |
| `output_format: "image/png"` | `422` | Plain values only |
| FLUX via `/openai/deployments/.../images/generations` | `404` | Wrong route entirely |

### Rate limit

**4 requests/minute.**

---

## FLUX.2-pro

Same request shape as `FLUX.2-flex`, just a different route and `model` value:

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/admin-m8fg494d-eastus2/providers/blackforestlabs/v1/flux-2-pro?api-version=preview" \
  -H "api-key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "FLUX.2-pro",
    "prompt": "A photograph of a red fox in an autumn forest.",
    "width": 2304,
    "height": 1728,
    "n": 1,
    "steps": 50,
    "guidance": 5,
    "output_format": "png"
  }' | jq -r '.data[0].b64_json' | base64 --decode > fox-pro.png
```

Verified at `2304x1728`. Rate limit is **4/min**, like flex.

---

## Decoding The Response

All four image models return base64-encoded image data in `.data[0].b64_json`. Decode it and write the bytes to a file:

```bash
... | jq -r '.data[0].b64_json' | base64 --decode > out.png
```

If you're calling from code, do the equivalent: `Buffer.from(b64, 'base64')` in Node, `base64.b64decode(b64)` in Python.

---

## Verified Examples

These were generated through this gateway and saved under `tests/generated-assets/images/`:

| File | Model | Dimensions | Format |
|---|---|---|---|
| `gpt-image-2-large-realistic-observatory.png` | `gpt-image-2` | `3840x2160` | PNG |
| `FLUX.2-flex-large-realistic-observatory.png` | `FLUX.2-flex` | `2304x1728` | PNG |
| `FLUX.2-pro-large-realistic-observatory.png` | `FLUX.2-pro` | `2304x1728` | PNG |
| `gpt-image-2-blue-dot.png` | `gpt-image-2` | `1024x1024` | PNG |
| `gpt-image-1.5-blue-dot.png` | `gpt-image-1.5` | `1024x1024` | PNG |
| `FLUX.2-flex-blue-dot.png` | `FLUX.2-flex` | `1024x1024` | PNG |
| `FLUX.2-flex-blue-dot.jpeg` | `FLUX.2-flex` | `1024x1024` | JPEG |
| `FLUX.2-flex-blue-dot-default.jpg` | `FLUX.2-flex` | `1024x1024` | JPEG (default format) |

Each has a sidecar `.manifest.json` with the prompt and request used.

---

## Quick Decision Tree

- **Hero image, big and sharp, weird aspect ratio?** → `gpt-image-2`, max size, `quality: "high"`.
- **Lots of variations, fast iteration?** → `gpt-image-1.5` (9/min beats 2/min).
- **Photorealism or editing an existing image?** → `FLUX.2-flex`, with reference images if relevant.
- **Polished output for the demo?** → `FLUX.2-pro`.
- **Need transparent PNG?** → Not on these. Use `gpt-image-1` if available, or post-process with `rembg`.

Now make pretty pixels.
