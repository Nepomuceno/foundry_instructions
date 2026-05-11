# OpenCode + the AI Gateway

You like OpenCode. You have an API key. You want `gpt-5.4` to write code in your terminal. Let's wire it up.

This takes about 2 minutes if your config file already exists. About 3 minutes if it doesn't and you also have to remember where `~/.config` is.

---

## What You Get

After this guide, OpenCode will list these as available models (and many more if you want):

- `gpt-5.4`, `gpt-5.4-mini`, `gpt-5.4-nano`, `gpt-5.4-pro`
- `gpt-5`, `gpt-5-mini`, `gpt-5.2`
- `gpt-5.1-codex-mini` (good name for a model, also good at coding)
- `gpt-4.1`, `gpt-4o`, `gpt-oss-120b`
- `Mistral-Large-3`
- `grok-4-1-fast-reasoning`, `grok-4-20-reasoning`
- `ModelRouter` (let the gateway pick)

All of them through one provider entry, one base URL, one key.

---

## Step 1: Save the Key

```bash
# Just for this terminal session
export AI_GATEWAY_API_KEY="<your-api-key>"

# Or persistent (recommended once you trust it)
echo 'export AI_GATEWAY_API_KEY="<your-api-key>"' >> ~/.zshrc
source ~/.zshrc
```

Don't paste your key into a chat. Don't commit it. Don't print it on a t-shirt. Standard stuff.

---

## Step 2: Add the Provider

Open (or create) `~/.config/opencode/opencode.json` and drop this in:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ai-gateway": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "AI Gateway",
      "options": {
        "baseURL": "https://ai-gateway-eastus2.azure-api.net/openai/v1",
        "headers": {
          "api-key": "{env:AI_GATEWAY_API_KEY}"
        }
      },
      "models": {
        "gpt-5.4":            { "name": "GPT-5.4" },
        "gpt-5.4-mini":       { "name": "GPT-5.4 Mini" },
        "gpt-5.4-nano":       { "name": "GPT-5.4 Nano" },
        "gpt-5.4-pro":        { "name": "GPT-5.4 Pro" },
        "gpt-5":              { "name": "GPT-5" },
        "gpt-5-mini":         { "name": "GPT-5 Mini" },
        "gpt-5.2":            { "name": "GPT-5.2" },
        "gpt-5.1-codex-mini": { "name": "GPT-5.1 Codex Mini" },
        "gpt-4.1":            { "name": "GPT-4.1" },
        "gpt-4o":             { "name": "GPT-4o" },
        "gpt-oss-120b":       { "name": "GPT-OSS 120B" },
        "Mistral-Large-3":    { "name": "Mistral Large 3" },
        "grok-4-1-fast-reasoning": { "name": "Grok 4.1 Fast Reasoning" },
        "grok-4-20-reasoning":     { "name": "Grok 4.20 Reasoning" },
        "ModelRouter":        { "name": "Model Router" }
      }
    }
  },
  "model": "ai-gateway/gpt-5.4-mini",
  "small_model": "ai-gateway/gpt-5.4-nano"
}
```

What this is doing:

- **`npm: "@ai-sdk/openai-compatible"`** tells OpenCode "this is OpenAI-shaped, please don't be weird about it."
- **`baseURL`** points at the gateway's v1 surface.
- **`headers.api-key`** injects your key on every request. The `{env:...}` syntax pulls from your shell, so the key never lives in the file.
- **`model`** is your default for chats.
- **`small_model`** is what OpenCode uses for cheap stuff like generating session titles.

---

## Step 3: Test It

In OpenCode TUI:

```text
/models
```

You should see "AI Gateway" with all the models listed. Pick one, send a message. If words come back, you're done.

From the CLI:

```bash
opencode run --model ai-gateway/gpt-5.4-mini "Reply with: gateway works."
```

If it doesn't work, scroll to the [error decoder](#when-things-go-sideways) below.

---

## Picking a Model

| What you're doing | Use this |
|---|---|
| General coding / "just be helpful" | `ai-gateway/gpt-5.4-mini` (fast and good) |
| Quick title generation, classification, tiny tasks | `ai-gateway/gpt-5.4-nano` (cheap and fast) |
| Hard problem, take your time | `ai-gateway/gpt-5.4` |
| Really hard problem | `ai-gateway/gpt-5.4-pro` |
| Tool calling / agent loops | `ai-gateway/gpt-5` |
| Code-specific / Codex-tuned | `ai-gateway/gpt-5.1-codex-mini` |
| You want to compare against Mistral | `ai-gateway/Mistral-Large-3` |
| You want it to argue with itself before answering | `ai-gateway/grok-4-1-fast-reasoning` |
| You don't want to choose | `ai-gateway/ModelRouter` |

When in doubt: `gpt-5.4-mini`.

---

## Reasoning Variants (Fancy Mode)

GPT-5-family models support different reasoning effort levels. Expose them as OpenCode variants and cycle with one keypress:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ai-gateway": {
      "models": {
        "gpt-5.4": {
          "variants": {
            "low":    { "reasoningEffort": "low" },
            "medium": { "reasoningEffort": "medium" },
            "high":   { "reasoningEffort": "high" }
          }
        },
        "gpt-5": {
          "variants": {
            "minimal": { "reasoningEffort": "minimal" },
            "low":     { "reasoningEffort": "low" },
            "high":    { "reasoningEffort": "high" }
          }
        }
      }
    }
  }
}
```

Now use the `variant_cycle` keybind in TUI to flip between effort levels mid-task.

---

## Specialized Agents

OpenCode lets you wire different agents to different models. Plan with the smart slow one, build with the fast one:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "plan": {
      "description": "Reads code, makes a plan, never writes.",
      "model": "ai-gateway/gpt-5.4",
      "tools": { "edit": false, "write": false, "bash": false }
    },
    "build": {
      "description": "Implements the plan.",
      "model": "ai-gateway/gpt-5.4-mini"
    },
    "reviewer": {
      "description": "Read-only reviewer focused on correctness and security.",
      "model": "ai-gateway/gpt-5.4",
      "tools": { "edit": false, "write": false }
    }
  },
  "default_agent": "plan"
}
```

---

## Project-Level Config

If a specific repo should always use a specific model, drop a project-level `opencode.json` in the repo root:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "ai-gateway/gpt-5.4",
  "small_model": "ai-gateway/gpt-5.4-nano"
}
```

This is safe to commit. The key still lives in your environment, not in the file.

---

## Bonus: Image / Video / Audio From OpenCode

OpenCode is mostly about text and tools. For images, video, and TTS, the cleanest move is to expose a custom command that calls the gateway via `bash`. Example:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "command": {
    "image": {
      "description": "Generate a 1024x1024 image with gpt-image-2.",
      "template": "Run a bash command that POSTs to the AI gateway image generation endpoint with this prompt: $ARGUMENTS. Save the decoded PNG as out.png.",
      "agent": "build",
      "model": "ai-gateway/gpt-5.4-mini"
    }
  }
}
```

Then `/image a teapot in space` in the TUI and the agent will call something like:

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/v1/images/generations" \
  -H "api-key: $AI_GATEWAY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-image-2","prompt":"a teapot in space","size":"1024x1024","quality":"high","output_format":"png"}' \
  | jq -r '.data[0].b64_json' | base64 --decode > out.png
```

For full image/video/audio reference, see [`AI_GATEWAY_CONSUMER_GUIDE.md`](AI_GATEWAY_CONSUMER_GUIDE.md) and [`IMAGE_MODEL_USAGE.md`](IMAGE_MODEL_USAGE.md).

---

## When Things Go Sideways

| Symptom | Real cause | Fix |
|---|---|---|
| `401` / `403` | Key missing or wrong | Confirm `AI_GATEWAY_API_KEY` is exported, restart OpenCode |
| OpenCode shows zero models | Config file not loaded | Check the path; confirm valid JSON; check OpenCode logs |
| `404` on a model name | Typo, wrong case, or it's not on the gateway | Use names from the table above; case-sensitive |
| `429 RateLimitReached` | Per-model RPM exceeded | Wait a minute. Image/video are especially low. |
| `Unsupported parameter: max_tokens` | GPT-5-family chat completions | OpenCode usually handles this for you; if you hit it from a custom command, switch to `max_completion_tokens` |
| Streaming feels slow | First token latency on big reasoning models | Try a smaller variant: `gpt-5.4-mini` instead of `gpt-5.4-pro` |
| FLUX models don't show up | They aren't on the OpenAI-shaped path | They live on `/admin-m8fg494d-eastus2/providers/blackforestlabs/...`; call them via curl, not via OpenCode's chat |

---

## House Rules

1. The `api-key` is the whole keys-to-the-kingdom thing. Don't share it. Don't commit it. Don't email it.
2. The gateway has rate limits per model. They're not your enemy, they're your bumpers.
3. If something is broken or weird, the [README](README.md) and the [consumer guide](AI_GATEWAY_CONSUMER_GUIDE.md) probably already mention it. Ctrl+F first, panic second.
4. Have fun. Build the weird thing. The hack is short, and these models can do a lot.

---

## See Also

- [README](README.md) — entrance + architecture diagrams
- [`AI_GATEWAY_CONSUMER_GUIDE.md`](AI_GATEWAY_CONSUMER_GUIDE.md) — raw curl examples for everything
- [`IMAGE_MODEL_USAGE.md`](IMAGE_MODEL_USAGE.md) — image-specific reference
- OpenCode docs: <https://opencode.ai/docs/providers>, <https://opencode.ai/docs/models>, <https://opencode.ai/docs/config>
