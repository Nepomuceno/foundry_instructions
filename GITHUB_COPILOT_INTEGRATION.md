# GitHub Copilot + the AI Gateway

You want a GitHub Copilot client — the **Copilot CLI** in your terminal, or **Copilot Chat** in your IDE — to send its requests to this gateway instead of (or alongside) GitHub's default models. The honest answer: how well that works depends on the client, because GitHub ships *different* "bring your own provider" stories for each.

This guide covers the two that are actually documented today:

1. **GitHub Copilot CLI** — first-class support for any OpenAI-compatible / Azure OpenAI / Anthropic endpoint via four environment variables. **This is the cleanest path** and it's what most people landing here want.
2. **GitHub Copilot Chat in VS Code** — supports adding extra *provider-branded* models (OpenAI, Anthropic, Gemini, Groq, Ollama, AI Toolkit, …) through *Manage Models*. There is **no generic "OpenAI-compatible base URL" option** in the model picker today, despite what older blog posts and a previously-published GitHub doc page suggested. If you want VS Code Chat to use the gateway, the supported route is the **AI Toolkit** extension or pointing the **OpenAI provider** at the gateway URL — both with caveats noted below.

> **Official references — read these too:**
> - GitHub Docs · *About GitHub Copilot CLI*: <https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli>
> - GitHub Docs · *Installing GitHub Copilot CLI*: <https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli>
> - GitHub Docs · *Using GitHub Copilot CLI*: <https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli>
> - GitHub Docs · *Changing the AI model for Copilot Chat* (incl. *Adding more models* in VS Code): <https://docs.github.com/en/copilot/how-tos/use-ai-models/change-the-chat-model>
> - VS Code Docs · *Language Models* (BYO key): <https://code.visualstudio.com/docs/copilot/language-models>
> - Copilot CLI repo (releases & issues): <https://github.com/github/copilot-cli>
>
> If anything below ever drifts from the GitHub docs, **trust GitHub**. They ship faster than this README. (Concretely: the old `…/use-ai-models/use-models-from-other-providers` URL that earlier versions of this file linked to now 404s — GitHub re-shaped that page.)

---

## Before You Start

You need all of these:

1. **An active Copilot subscription** (Free, Pro, Pro+, Business, or Enterprise). Free works for trying the CLI.
2. **The gateway API key** — same `AI_GATEWAY_API_KEY` you use everywhere else.
3. **Org permission**, if you're on Copilot Business / Enterprise. Admins control whether the CLI is enabled and whether members can switch models in Chat. See *Managing policies for Copilot in your organization* in the GitHub docs.

---

# Part 1 — Copilot CLI (recommended path)

The Copilot CLI is GitHub's official terminal agent (`copilot`). It's a separate product from Copilot Chat in your IDE, and it has **explicit, documented support** for replacing GitHub-hosted models with your own OpenAI-compatible / Azure OpenAI / Anthropic endpoint.

## 1.1 Install

Node.js 22 or later is required for the npm install. Pick whichever installer you prefer:

```bash
# npm (all platforms)
npm install -g @github/copilot

# Homebrew (macOS / Linux)
brew install copilot-cli

# Install script (macOS / Linux)
curl -fsSL https://gh.io/copilot-install | bash
```

```powershell
# WinGet (Windows; requires PowerShell 6+)
winget install GitHub.Copilot
```

Source: <https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli>

## 1.2 Authenticate to GitHub

Run `copilot` the first time. If you're not signed in, it'll prompt you:

```text
/login
```

Follow the device-flow link. Alternatively, set a fine-grained PAT with the **Copilot Requests** permission and export it as `COPILOT_GITHUB_TOKEN` (or `GH_TOKEN` / `GITHUB_TOKEN`, in that order of precedence). Source: install doc, *Authenticating with a personal access token*.

> You **still need this GitHub auth** even when you're routing inference to the gateway. The GitHub token gates *access to the CLI binary's features*; the gateway key gates *who pays for the tokens*.

## 1.3 Point the CLI at the gateway

The CLI reads four environment variables:

| Variable | Set it to | Notes |
|---|---|---|
| `COPILOT_PROVIDER_BASE_URL` | `https://ai-gateway-eastus2.azure-api.net/openai/v1` | The gateway's OpenAI-compatible base URL. |
| `COPILOT_PROVIDER_TYPE` | `openai` | The `openai` type works for any OpenAI-compatible endpoint (the gateway included). Alternatives: `azure`, `anthropic`. |
| `COPILOT_PROVIDER_API_KEY` | `$AI_GATEWAY_API_KEY` | Your gateway key. |
| `COPILOT_MODEL` | e.g. `gpt-5.4-mini` | Required when using a custom provider. Must be a model the gateway exposes and that supports **tool calling + streaming** — those are CLI hard requirements. |

Source for these four envs, verbatim: *About GitHub Copilot CLI → Using your own model provider* (URL above).

### macOS / Linux

```bash
export AI_GATEWAY_API_KEY="<your-api-key>"

export COPILOT_PROVIDER_BASE_URL="https://ai-gateway-eastus2.azure-api.net/openai/v1"
export COPILOT_PROVIDER_TYPE="openai"
export COPILOT_PROVIDER_API_KEY="$AI_GATEWAY_API_KEY"
export COPILOT_MODEL="gpt-5.4-mini"

copilot
```

Put those `export`s in `~/.zshrc` / `~/.bashrc` if you want them sticky.

### Windows (PowerShell)

```powershell
$env:AI_GATEWAY_API_KEY = "<your-api-key>"

$env:COPILOT_PROVIDER_BASE_URL = "https://ai-gateway-eastus2.azure-api.net/openai/v1"
$env:COPILOT_PROVIDER_TYPE     = "openai"
$env:COPILOT_PROVIDER_API_KEY  = $env:AI_GATEWAY_API_KEY
$env:COPILOT_MODEL             = "gpt-5.4-mini"

copilot
```

For persistence across sessions, use `[Environment]::SetEnvironmentVariable("NAME","VALUE","User")` or set them in your PowerShell `$PROFILE`.

### Verify

Inside an interactive `copilot` session:

```text
/model
```

The currently active model should be the one you set in `COPILOT_MODEL`. Send a quick prompt; you should get a response and **no premium-request multiplier shown in the model list**, because billing for the call goes to the gateway, not your Copilot quota.

For more on configuration: `copilot help providers`, `copilot help config`, `copilot help environment`.

## 1.4 Picking a model from the CLI

Same opinions as the [model catalog](models.md), abridged. Remember the CLI requires the model to support **tool calling + streaming** and recommends a ≥128k context window.

| Task | Pick |
|---|---|
| Default agent loop | `gpt-5.4-mini` |
| Hard reasoning, big refactors | `gpt-5.4` or `gpt-5.4-pro` |
| Fast inline-style replies | `gpt-5.4-nano` |
| Code-specialized | `gpt-5.1-codex-mini` |
| Comparing against non-OpenAI | `Mistral-Large-3`, `grok-4-20-reasoning` |
| You don't want to choose | `ModelRouter` |

## 1.5 CLI troubleshooting

| Symptom | Real cause | Fix |
|---|---|---|
| `copilot` falls back to Claude Sonnet 4.5 | One of `COPILOT_PROVIDER_*` isn't set, or `COPILOT_MODEL` is empty | Re-export all four envs **in the same shell** that runs `copilot` |
| `401 Unauthorized` | Wrong gateway key, or the key was set after `copilot` started | Restart the shell session; re-check `echo $COPILOT_PROVIDER_API_KEY` |
| `404 model_not_found` | Typo in `COPILOT_MODEL` (case-sensitive: `gpt-5.4-mini`, not `GPT-5.4-Mini`) | Copy names from the [model catalog](models.md) |
| `429 RateLimitReached` | Burned the per-minute budget on the gateway for that model | Wait, or switch model |
| CLI errors "model does not support tool calling" / "streaming required" | The gateway model you picked can't do tools or streaming | Pick a model with the **tools** badge in the [catalog](models.md) — e.g. `gpt-5`, `gpt-4.1`, `gpt-5.4-nano`, `Mistral-Large-3` |
| GitHub auth fails | PAT missing **Copilot Requests** permission, or it's an org PAT (not user) | Re-generate as a **user-owned** fine-grained PAT with that permission |

---

# Part 2 — Copilot Chat in VS Code

This is where the BYOK story is **messier than it looks online**. As of today:

- The VS Code Copilot Chat *Manage Models* flow lists *provider-branded* options (Anthropic, Azure, Gemini, Groq, Ollama, OpenAI, OpenRouter, AI Toolkit, …). The exact list is in the screenshots on <https://docs.github.com/en/copilot/how-tos/use-ai-models/change-the-chat-model>.
- It does **not**, today, expose a generic "OpenAI-compatible — paste any base URL" provider in the documented UI. Older versions of this guide claimed it did; that was wrong.
- You can still get gateway models into VS Code Chat — there are just **two real routes**, not one.

## Route A — Use the **OpenAI** provider and point it at the gateway

The gateway speaks the OpenAI wire format on `/openai/v1`. The VS Code Copilot Chat "OpenAI" provider expects an OpenAI API key — but in practice the request it makes is just `POST /v1/chat/completions` with a `Bearer` token. If your VS Code Copilot Chat extension version supports specifying a custom base URL for the OpenAI provider (some recent builds do, behind the *AI language models* settings in the VS Code Copilot docs: <https://code.visualstudio.com/docs/copilot/language-models>), you can:

1. `Ctrl+Shift+P` / `⌘⇧P` → `GitHub Copilot: Manage Models`.
2. Pick **OpenAI**.
3. When prompted for a key, paste your `AI_GATEWAY_API_KEY`.
4. If a *Base URL* field is available, set it to `https://ai-gateway-eastus2.azure-api.net/openai/v1`. If it isn't, this route won't work in your build — use Route B.
5. Enter the gateway model ID (e.g. `gpt-5.4-mini`).

Caveats:
- The gateway authenticates by `api-key` header **and** accepts `Authorization: Bearer …`. If the extension only sends `Bearer`, it'll still work.
- Tool-call reliability through this path varies by model. `gpt-5`, `gpt-4.1`, `gpt-5.4-nano`, and `Mistral-Large-3` are the ones we've seen behave in agent mode.

## Route B — Use the **AI Toolkit** extension

The AI Toolkit for VS Code (`ms-windows-ai-studio.windows-ai-studio`) lets you register arbitrary OpenAI-compatible endpoints as models and exposes them into Copilot Chat. This is the **officially documented** path for "add a custom OpenAI-compatible provider to Copilot Chat" today.

1. Install **AI Toolkit for Visual Studio Code** from the Marketplace.
2. In the AI Toolkit panel, **Catalog → Custom models → Add custom model**.
3. Provider type: *OpenAI-compatible*. Base URL: `https://ai-gateway-eastus2.azure-api.net/openai/v1`. API key: your `AI_GATEWAY_API_KEY`. Model: e.g. `gpt-5.4-mini`.
4. Open Copilot Chat → model picker → **Manage Models** → pick the AI Toolkit provider → tick the model(s) you added.

Authoritative steps (GitHub side): <https://docs.github.com/en/copilot/how-tos/use-ai-models/change-the-chat-model#adding-models> (look for the *Adding more models* section, specifically the AI Toolkit tab).

## Where you can use gateway models in VS Code, once they're wired in

- **Copilot Chat** panel (`Ctrl+Alt+I` / `⌃⌘I`).
- **Inline Chat** (`Ctrl+I` / `⌘I`).
- **Edit / agent mode** — tool-calling reliability varies; see the badge in the [model catalog](models.md).

> **Code completion (ghost text) still uses Copilot's built-in completion model.** BYO models do not replace completions. Source: GitHub Docs · *Change the chat model* + *Change the completion model*.

---

# Part 3 — Other IDEs

Copilot Chat in Visual Studio, JetBrains, Eclipse, and Xcode also supports model switching, but **the "add a custom provider" UI is currently a VS Code thing**. In the other IDEs, the model dropdown is limited to what GitHub ships server-side. If you need gateway models in those IDEs today, your options are:

- Use the **Copilot CLI** in the IDE's terminal pane (Part 1). This works everywhere.
- Use **OpenCode** in the IDE's terminal — see [`OPENCODE_INTEGRATION.md`](OPENCODE_INTEGRATION.md).
- Wait for the BYO-provider UI to land in your IDE; track <https://github.com/microsoft/vscode-copilot-release> and the GitHub Copilot release notes.

---

# Part 4 — Org Admins

If you administer a Copilot **Business** or **Enterprise** org and your users can't use the CLI, or can't switch models in Chat:

1. Go to your org → **Settings** → **Copilot** → **Policies**.
2. Enable **GitHub Copilot CLI** (if you want users to use the terminal agent at all).
3. Enable the policy that grants access to non-default models in Chat. The exact label changes occasionally; canonical reference: <https://docs.github.com/en/copilot/how-tos/administer/enable-features/manage-policies-for-copilot-in-your-organization>.
4. Save. Users may need to restart their IDE / shell.

For Enterprise, the same settings live under **Enterprise → Policies → Copilot**.

---

# Security Notes

- For the CLI, the gateway key lives in **your shell environment**. Don't commit `.env` files. On Windows, prefer `SetEnvironmentVariable(…, "User")` over plaintext in scripts.
- For VS Code routes, the key lives in the IDE's encrypted secret store (the OS keychain on macOS, Credential Manager on Windows, libsecret on Linux). It is **not** synced via Settings Sync.
- Requests go **directly** from your editor or terminal to `ai-gateway-eastus2.azure-api.net`. GitHub's servers are not in the path for inference traffic when you're using a custom provider.
- **Never** commit a workspace `.vscode/settings.json` containing the key. The *Manage Models* / AI Toolkit UIs store secrets, not settings.

---

# When Things Go Sideways

Aggregate table covering both clients:

| Symptom | Where | Real cause | Fix |
|---|---|---|---|
| `copilot` keeps using Claude Sonnet 4.5 | CLI | `COPILOT_PROVIDER_*` envs not visible to the shell that launched it | Re-export in the same shell; verify with `env \| grep COPILOT_` |
| `copilot` errors "model does not support tool calling" | CLI | Picked a gateway model without tools | Switch to a model with the **tools** badge in [models.md](models.md) |
| `401 Unauthorized` | Either | Wrong / pasted-into-wrong-field gateway key | Re-check; for CLI the env is `COPILOT_PROVIDER_API_KEY` |
| `404 model_not_found` | Either | Typo / wrong case in model ID | Copy from [models.md](models.md) — IDs are case-sensitive |
| `429 RateLimitReached` | Either | Per-minute gateway budget exhausted | Wait a minute or pick a different model |
| No **Manage Models** in VS Code | Chat | Copilot Chat extension too old, or org policy blocks model switching | Update the extension; ask your admin to enable the policy |
| OpenAI provider in VS Code won't let you set a base URL | Chat | Your extension build doesn't expose that field | Use Route B (AI Toolkit) instead |
| Tool calls don't fire in VS Code agent mode | Chat | Model not great at tools, or extension version doesn't pass tool defs to BYO providers | Try `gpt-5`, `gpt-4.1`, or `gpt-5.4-nano`; update the extension |
| Streaming feels chunky | Chat | Some Copilot Chat versions buffer streamed deltas before render | Update the extension; if it persists, file an issue at <https://github.com/microsoft/vscode-copilot-release/issues> |

---

# See Also

**In this repo:**

- [README](README.md) — what the gateway is, with diagrams
- [Model catalog](models.md) — every model, with capability tags
- [`OPENCODE_INTEGRATION.md`](OPENCODE_INTEGRATION.md) — same gateway, but for the OpenCode terminal UI
- [`AI_GATEWAY_CONSUMER_GUIDE.md`](AI_GATEWAY_CONSUMER_GUIDE.md) — raw curl examples for everything

**Official GitHub Copilot documentation:**

- *About GitHub Copilot CLI*: <https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli>
- *Installing GitHub Copilot CLI*: <https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli>
- *Using GitHub Copilot CLI*: <https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli>
- *Change the chat model*: <https://docs.github.com/en/copilot/how-tos/use-ai-models/change-the-chat-model>
- *Manage policies for Copilot in your org*: <https://docs.github.com/en/copilot/how-tos/administer/enable-features/manage-policies-for-copilot-in-your-organization>
- VS Code · *Language Models* (BYO key): <https://code.visualstudio.com/docs/copilot/language-models>
- Copilot CLI repo (issues / release notes): <https://github.com/github/copilot-cli>
- Copilot Chat (VS Code) repo: <https://github.com/microsoft/vscode-copilot-release>
