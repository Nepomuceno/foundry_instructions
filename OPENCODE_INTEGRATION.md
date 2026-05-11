# OpenCode + the AI Gateway

You like OpenCode. You have an API key. You want `gpt-5.4` to write code in your terminal. Let's wire it up.

This takes about 2 minutes if your config file already exists. About 3 minutes if it doesn't and you also have to remember where `~/.config` is.

> **Official OpenCode docs you should bookmark:**
> - Install: <https://opencode.ai/docs/> · <https://opencode.ai/docs/install>
> - Config file reference: <https://opencode.ai/docs/config>
> - Providers (this is the important one): <https://opencode.ai/docs/providers>
> - Models & variants: <https://opencode.ai/docs/models>
> - Agents: <https://opencode.ai/docs/agents>
> - Custom commands: <https://opencode.ai/docs/commands>
> - Keybinds (for `variant_cycle`): <https://opencode.ai/docs/keybinds>
>
> This guide is the gateway-flavored shortcut. The pages above are the source of truth.

---

## Step 0: Install OpenCode

If you don't have it yet, pick the row that matches your OS (full list at <https://opencode.ai/docs/install>):

### macOS / Linux

```bash
# Recommended installer
curl -fsSL https://opencode.ai/install | bash

# Homebrew (macOS / Linuxbrew)
brew install sst/tap/opencode

# npm (cross-platform, requires Node 18+)
npm install -g opencode-ai
```

### Windows

You have three good options. Pick **one**.

```powershell
# 1. PowerShell installer (run in a normal PowerShell, not "as Admin")
irm https://opencode.ai/install.ps1 | iex
```

```powershell
# 2. Scoop (https://scoop.sh)
scoop bucket add extras
scoop install opencode
```

```powershell
# 3. npm (works inside PowerShell, cmd, or Git Bash)
npm install -g opencode-ai
```

**Windows-specific notes:**

- Run PowerShell as your **regular user**, not Administrator. The installer writes to `%LOCALAPPDATA%`.
- If `irm | iex` is blocked by execution policy, run this once in the same PowerShell session: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`.
- After install, **close and reopen** your terminal so the new PATH entry is picked up. If `opencode` still isn't found, add the install dir (printed by the installer, typically `%LOCALAPPDATA%\Programs\opencode`) to your user PATH via `System Properties → Environment Variables`.
- **WSL counts as Linux**, not Windows. Use the macOS/Linux installer inside your WSL distro.
- The TUI works in **Windows Terminal**, **PowerShell 7**, **VS Code's integrated terminal**, and **Git Bash**. The legacy `cmd.exe` console works but renders worse — use Windows Terminal if you can.

### Verify (all platforms)

```bash
opencode --version
```

If `opencode` isn't on your PATH, the installer prints a one-line fix at the end — re-read it.

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

### macOS / Linux

```bash
# Just for this terminal session
export AI_GATEWAY_API_KEY="<your-api-key>"

# Or persistent (recommended once you trust it)
echo 'export AI_GATEWAY_API_KEY="<your-api-key>"' >> ~/.zshrc
source ~/.zshrc
```

(Use `~/.bashrc` if you're on bash instead of zsh.)

### Windows — PowerShell

```powershell
# Just for this terminal session
$env:AI_GATEWAY_API_KEY = "<your-api-key>"

# Persistent for your user (survives reboots, all future shells see it)
[Environment]::SetEnvironmentVariable("AI_GATEWAY_API_KEY", "<your-api-key>", "User")
```

After the persistent version, **close and reopen** PowerShell so new shells inherit the variable. To verify: `echo $env:AI_GATEWAY_API_KEY`.

### Windows — cmd.exe

```bat
:: Just for this terminal session
set AI_GATEWAY_API_KEY=<your-api-key>

:: Persistent (for your user)
setx AI_GATEWAY_API_KEY "<your-api-key>"
```

`setx` only affects **new** shells — your current `cmd` window won't see it until you reopen.

### Windows — Git Bash / WSL

Same as macOS/Linux: `export ...` and append to `~/.bashrc`.

Don't paste your key into a chat. Don't commit it. Don't print it on a t-shirt. Standard stuff.

---

## Step 2: Add the Provider

Open (or create) your OpenCode config file:

| OS | Path |
|---|---|
| macOS / Linux | `~/.config/opencode/opencode.json` |
| Windows (PowerShell / cmd) | `%USERPROFILE%\.config\opencode\opencode.json` — i.e. `C:\Users\<you>\.config\opencode\opencode.json` |
| Windows (Git Bash / WSL) | `~/.config/opencode/opencode.json` (resolves to the same place from a Bash shell) |

> OpenCode follows the XDG convention even on Windows — the config lives under `.config` in your home directory, **not** in `%APPDATA%`. If the folder doesn't exist, create it. Config schema reference: <https://opencode.ai/docs/config>. Provider shape (`npm`, `options`, `models`) is documented at <https://opencode.ai/docs/providers>.

Drop this in:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ai-gateway": {
      "npm": "@ai-sdk/openai",
      "name": "AI Gateway",
      "options": {
        "baseURL": "https://ai-gateway-eastus2.azure-api.net/openai/v1",
        "apiKey": "{env:AI_GATEWAY_API_KEY}",
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

> ⚠️ **Important — `npm` is `@ai-sdk/openai`, not `@ai-sdk/openai-compatible`.**
>
> The GPT-5 family (`gpt-5`, `gpt-5.x`, `gpt-5.4*`, etc.) **requires `max_completion_tokens` instead of `max_tokens`.** The plain `@ai-sdk/openai-compatible` package doesn't know this and sends `max_tokens`, which causes:
>
> ```
> Unsupported parameter: 'max_tokens' is not supported with this model.
> Use 'max_completion_tokens' instead.
> ```
>
> The official `@ai-sdk/openai` package handles this translation automatically for all GPT-5-family models. Since the gateway is OpenAI-shaped, you can point `@ai-sdk/openai` at our `baseURL` and everything works. See: [Vercel AI SDK — OpenAI provider](https://ai-sdk.dev/providers/ai-sdk-providers/openai) and [Vercel AI SDK — Custom providers](https://ai-sdk.dev/providers/openai-compatible-providers/custom-providers).
>
> Why two auth fields (`apiKey` **and** `headers.api-key`)? The `@ai-sdk/openai` package sends `Authorization: Bearer <apiKey>` by default, but our gateway expects the key in the `api-key` header. Setting both means the request works regardless of which header the gateway inspects first, and the SDK doesn't complain about a missing `apiKey`.

What this is doing:

- **`npm: "@ai-sdk/openai"`** uses Vercel's official OpenAI provider. It knows GPT-5-family models need `max_completion_tokens` and translates automatically. If you use `@ai-sdk/openai-compatible` instead, you'll get the `Unsupported parameter: 'max_tokens'` error.
- **`baseURL`** points at the gateway's v1 surface. The OpenAI SDK is happy with any OpenAI-shaped endpoint.
- **`apiKey`** is what `@ai-sdk/openai` uses internally — it ships the value as a Bearer token by default, which our gateway ignores.
- **`headers.api-key`** is the header our gateway actually authenticates on. Both fields point at the same env var.
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

> Variants reference: <https://opencode.ai/docs/models#variants>. Keybinds (incl. `variant_cycle`): <https://opencode.ai/docs/keybinds>.

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

> Agent config and the full tool-permission matrix: <https://opencode.ai/docs/agents>.

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

> Custom commands reference: <https://opencode.ai/docs/commands>.

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

**macOS / Linux / Git Bash / WSL:**

```bash
curl -X POST "https://ai-gateway-eastus2.azure-api.net/openai/v1/images/generations" \
  -H "api-key: $AI_GATEWAY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-image-2","prompt":"a teapot in space","size":"1024x1024","quality":"high","output_format":"png"}' \
  | jq -r '.data[0].b64_json' | base64 --decode > out.png
```

**Windows PowerShell** (no `jq`, no `base64` — but PowerShell has both built in):

```powershell
$body = @{
  model         = "gpt-image-2"
  prompt        = "a teapot in space"
  size          = "1024x1024"
  quality       = "high"
  output_format = "png"
} | ConvertTo-Json

$resp = Invoke-RestMethod `
  -Method Post `
  -Uri "https://ai-gateway-eastus2.azure-api.net/openai/v1/images/generations" `
  -Headers @{ "api-key" = $env:AI_GATEWAY_API_KEY; "Content-Type" = "application/json" } `
  -Body $body

[IO.File]::WriteAllBytes("out.png", [Convert]::FromBase64String($resp.data[0].b64_json))
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
| `Unsupported parameter: 'max_tokens' is not supported with this model. Use 'max_completion_tokens' instead.` | Your provider is `@ai-sdk/openai-compatible`, which sends `max_tokens`. GPT-5-family models reject it. | Change `npm` to `@ai-sdk/openai` in your `opencode.json` (see [Step 2](#step-2-add-the-provider)). The official OpenAI provider translates `max_tokens` → `max_completion_tokens` automatically. Then restart OpenCode. |
| Streaming feels slow | First token latency on big reasoning models | Try a smaller variant: `gpt-5.4-mini` instead of `gpt-5.4-pro` |
| FLUX models don't show up | They aren't on the OpenAI-shaped path | They live on `/admin-m8fg494d-eastus2/providers/blackforestlabs/...`; call them via curl, not via OpenCode's chat |
| **Windows:** `opencode: command not found` | Installer ran but PATH not refreshed | Close and reopen the terminal. If still broken, add `%LOCALAPPDATA%\Programs\opencode` to user PATH |
| **Windows:** Key set with `setx` but OpenCode says 401 | `setx` only affects **new** shells | Open a fresh PowerShell / cmd window and re-run OpenCode |
| **Windows:** Config file "not found" even though it exists | Saved it to `%APPDATA%` instead of `~/.config` | Move it to `%USERPROFILE%\.config\opencode\opencode.json` |
| **Windows:** Garbled box-drawing characters in the TUI | Legacy `cmd.exe` console | Use Windows Terminal or PowerShell 7 |
| **Windows:** `irm | iex` blocked | Execution policy too strict | `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` and retry in the same session |

---

## House Rules

1. The `api-key` is the whole keys-to-the-kingdom thing. Don't share it. Don't commit it. Don't email it.
2. The gateway has rate limits per model. They're not your enemy, they're your bumpers.
3. If something is broken or weird, the [README](README.md) and the [consumer guide](AI_GATEWAY_CONSUMER_GUIDE.md) probably already mention it. Ctrl+F first, panic second.
4. Have fun. Build the weird thing. The hack is short, and these models can do a lot.

---

## See Also

**In this repo:**

- [README](README.md) — entrance + architecture diagrams
- [`AI_GATEWAY_CONSUMER_GUIDE.md`](AI_GATEWAY_CONSUMER_GUIDE.md) — raw curl examples for everything
- [`IMAGE_MODEL_USAGE.md`](IMAGE_MODEL_USAGE.md) — image-specific reference
- [`GITHUB_COPILOT_INTEGRATION.md`](GITHUB_COPILOT_INTEGRATION.md) — same gateway, but for GitHub Copilot Chat

**Official OpenCode documentation:**

- Home & install: <https://opencode.ai/docs/>
- Config schema: <https://opencode.ai/docs/config>
- Providers: <https://opencode.ai/docs/providers>
- Models & variants: <https://opencode.ai/docs/models>
- Agents: <https://opencode.ai/docs/agents>
- Custom commands: <https://opencode.ai/docs/commands>
- Keybinds: <https://opencode.ai/docs/keybinds>
- GitHub repo (source / issues): <https://github.com/sst/opencode>

**Upstream SDK this guide relies on:**

- `@ai-sdk/openai` — Vercel AI SDK's official OpenAI provider (handles `max_completion_tokens` for GPT-5 family automatically): <https://ai-sdk.dev/providers/ai-sdk-providers/openai>
- `@ai-sdk/openai-compatible` — generic OpenAI-shaped provider, useful for non-OpenAI APIs but **does not** translate `max_tokens` for GPT-5: <https://ai-sdk.dev/providers/openai-compatible-providers>

