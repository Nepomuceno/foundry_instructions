# GitHub Copilot + the AI Gateway

You have GitHub Copilot. You have a gateway key. You want Copilot Chat to ask `gpt-5.4` (not just OpenAI's default lineup) the next time you hit ⌘+I. Here's how.

This is the **"Bring Your Own Key" (BYOK)** path. Copilot ships with a built-in set of models from OpenAI, Anthropic, Google, etc.; BYOK lets you add an **OpenAI-compatible** provider like this gateway and use those models inside Copilot Chat in VS Code, Visual Studio, and JetBrains IDEs.

> **Official references — read these too:**
> - GitHub Docs · *Using models from other providers* (the BYOK doc): <https://docs.github.com/en/copilot/how-tos/use-ai-models/use-models-from-other-providers>
> - GitHub Docs · *Changing the AI model for Copilot Chat*: <https://docs.github.com/en/copilot/how-tos/use-ai-models/change-the-chat-model>
> - GitHub Docs · *About AI models for Copilot Chat*: <https://docs.github.com/en/copilot/concepts/ai-models/ai-models-for-copilot-chat>
> - Copilot in VS Code · *Manage Models*: <https://code.visualstudio.com/docs/copilot/customization/language-models>
>
> If anything below ever drifts from the GitHub docs, **trust GitHub**. They ship faster than this README.

---

## Before You Start

You need all of these:

1. **A Copilot subscription** (Free, Pro, Pro+, Business, or Enterprise). Free works for trying it out.
2. **Latest GitHub Copilot Chat extension** in your IDE. In VS Code: search `GitHub.copilot-chat` in Extensions, click Update.
3. **The gateway API key** — same `AI_GATEWAY_API_KEY` you use everywhere else.
4. **Org permission**, if you're on Copilot Business / Enterprise. Your admin has to enable *"Editor preview features"* (Business) or the relevant BYOK policy (Enterprise). See the GitHub doc linked above for the exact policy names.

If you're on personal Copilot (Free / Pro / Pro+), you can just do this yourself.

---

## What "BYOK" Actually Does

You give the Copilot extension:

- A **provider type** (`OpenAI-compatible` — that's us)
- A **base URL** (the gateway's `/openai/v1`)
- An **API key** (yours)
- A **list of model IDs** you want to expose

Copilot Chat then shows those models in its model picker alongside its built-in ones. When you select one, Chat sends requests directly from your editor to the gateway. **GitHub does not proxy or store those requests** — keys live in your IDE's secret storage.

This means:

- **Latency is yours.** No Copilot routing layer in the middle.
- **Quotas are yours.** Hitting the gateway's rate limits doesn't touch your Copilot quota; hitting Copilot's premium-request quota doesn't apply to BYOK calls.
- **Privacy posture is yours.** Treat traffic the same way you treat any other call to the gateway.

---

## Step 1: Save the Key (Optional but Tidy)

The IDE will ask for the key interactively, so you don't *need* it in your shell. But it's nice to have one source of truth:

```bash
export AI_GATEWAY_API_KEY="<your-api-key>"
```

Add to `~/.zshrc` / `~/.bashrc` if you want it persistent.

---

## Step 2: Add the Gateway as a Custom Provider (VS Code)

The fastest path is the in-IDE UI. Both routes work:

### Option A — From the Chat model picker

1. Open Copilot Chat (`Ctrl+Alt+I` / `⌃⌘I`).
2. Click the **model picker** in the chat input (shows the current model name).
3. Choose **Manage Models…** at the bottom of the list.
4. Pick **OpenAI Compatible** as the provider.
5. Fill in the fields:

   | Field | Value |
   |---|---|
   | **Base URL** | `https://ai-gateway-eastus2.azure-api.net/openai/v1` |
   | **API key** | your `AI_GATEWAY_API_KEY` |
   | **Header name** *(if asked)* | `api-key` |
   | **Header value** *(if asked)* | the key |

6. Add the model IDs you want exposed. One per line — exact, case-sensitive names from the gateway:

   ```
   gpt-5.4
   gpt-5.4-mini
   gpt-5.4-nano
   gpt-5.4-pro
   gpt-5
   gpt-5-mini
   gpt-5.2
   gpt-5.1-codex-mini
   gpt-4.1
   gpt-4o
   gpt-oss-120b
   Mistral-Large-3
   grok-4-1-fast-reasoning
   grok-4-20-reasoning
   ModelRouter
   ```

7. Save. Reopen the model picker — your gateway models should appear under an **OpenAI Compatible** section.

### Option B — From the Command Palette

`Ctrl+Shift+P` / `⌘⇧P` → `GitHub Copilot: Manage Models` → same flow as above.

> The exact wording of menu items moves around between Copilot Chat versions. If a label isn't where this doc says, the GitHub doc is canonical: <https://docs.github.com/en/copilot/how-tos/use-ai-models/use-models-from-other-providers>.

---

## Step 3: Use a Gateway Model

In Copilot Chat:

1. Open the model picker.
2. Pick e.g. **`gpt-5.4-mini`** under your custom provider.
3. Type a prompt. Send.

You should get a response in the chat panel. If you see `401`, the key is wrong. If you see `404`, the model name is wrong (case-sensitive). If you see `429`, you hit the per-model RPM limit on the gateway.

---

## Picking a Model From Copilot Chat

Same opinions as the [model catalog](models.md), abridged:

| Task | Pick |
|---|---|
| Default chat | `gpt-5.4-mini` |
| Hard reasoning, big refactors | `gpt-5.4` or `gpt-5.4-pro` |
| Fast inline-style replies | `gpt-5.4-nano` |
| Code-specialized | `gpt-5.1-codex-mini` |
| Comparing against non-OpenAI | `Mistral-Large-3`, `grok-4-20-reasoning` |
| You don't want to choose | `ModelRouter` |

---

## VS Code: Other Places You Can Use BYOK Models

Once Copilot Chat has the gateway wired up, the same models are available in:

- **Inline Chat** (`Ctrl+I` / `⌘I`) — pick the model from the inline picker.
- **Quick Chat** (`Ctrl+Alt+/`).
- **Edit / agent mode** (the multi-file editor). Note: tool-calling reliability varies by model; `gpt-5`, `gpt-5.4-nano`, `gpt-4.1`, and `Mistral-Large-3` are confirmed to handle tools through the gateway. See the [model catalog](models.md) for the badge.
- **Workspace / commit message generation** — uses whichever model is currently selected.

> Code completion (the grey ghost-text) currently uses Copilot's built-in completion model. BYOK models do not replace completions. Source: GitHub Docs · *AI models for Copilot Chat*.

---

## JetBrains, Visual Studio, Eclipse, Xcode

The BYOK flow exists in all officially supported Copilot IDEs, but the **menu names differ**. The conceptual steps are identical:

1. Open the Copilot Chat tool window.
2. Find "Manage models" / "Add model provider" / similar.
3. Pick **OpenAI-compatible** and provide base URL + key + model IDs.

Authoritative per-IDE walkthroughs:

- VS Code: <https://code.visualstudio.com/docs/copilot/customization/language-models>
- All IDEs (GitHub canonical): <https://docs.github.com/en/copilot/how-tos/use-ai-models/use-models-from-other-providers>

---

## Org Admins: Enabling BYOK

If you administer a Copilot **Business** or **Enterprise** org and your users can't see the *Manage Models* option:

1. Go to your org → **Settings** → **Copilot** → **Policies**.
2. Enable the policy that grants access to non-default models / editor preview features. The exact name changes occasionally; the GitHub doc has the current label: <https://docs.github.com/en/copilot/how-tos/administer/enable-features/manage-policies-for-copilot-in-your-organization>.
3. Save. Users may need to restart their IDE.

For Enterprise, the same setting lives under **Enterprise → Policies → Copilot**.

---

## When Things Go Sideways

| Symptom | Real cause | Fix |
|---|---|---|
| No **Manage Models** entry | Copilot Chat extension too old, or org policy blocks BYOK | Update the extension; ask your admin to enable the policy |
| Custom provider doesn't appear in picker | Saved provider but didn't add any model IDs, or all model IDs are invalid | Re-open the provider settings; add at least one valid model name |
| `401 Unauthorized` | Wrong key, or you pasted it into the wrong field | Re-check; the gateway expects the key in the `api-key` header, which the OpenAI-compatible provider sends automatically |
| `404 model_not_found` | Typo in model ID (they're case-sensitive — `gpt-5.4-mini`, not `GPT-5.4-Mini`) | Copy names from the [model catalog](models.md) |
| `429 RateLimitReached` | You burned through the per-minute budget for that model | Wait a minute or pick a different model |
| Streaming feels weirdly chunky | Some Copilot Chat versions buffer streamed deltas before render | Update the extension; if it persists, file an issue at <https://github.com/microsoft/vscode-copilot-release/issues> |
| Tool calls don't fire in agent mode | Model not great at tools, or extension version doesn't pass tool defs to BYOK providers | Try `gpt-5`, `gpt-4.1`, or `gpt-5.4-nano`; update the extension; check the GitHub Copilot release notes |

---

## Security Notes

- The key lives in your IDE's encrypted secret store (VS Code uses the OS keychain). It is not synced via Settings Sync by default.
- Requests go **directly** from your editor to `ai-gateway-eastus2.azure-api.net`. GitHub's servers are not in the path for BYOK chat traffic.
- **Do not** commit a workspace `.vscode/settings.json` that contains the key. Use the *Manage Models* UI; it stores secrets, not settings.

---

## See Also

**In this repo:**

- [README](README.md) — what the gateway is, with diagrams
- [Model catalog](models.md) — every model, with capability tags
- [`OPENCODE_INTEGRATION.md`](OPENCODE_INTEGRATION.md) — same gateway, but for the OpenCode terminal UI
- [`AI_GATEWAY_CONSUMER_GUIDE.md`](AI_GATEWAY_CONSUMER_GUIDE.md) — raw curl examples for everything

**Official GitHub Copilot documentation:**

- *Use models from other providers* (BYOK): <https://docs.github.com/en/copilot/how-tos/use-ai-models/use-models-from-other-providers>
- *Change the chat model*: <https://docs.github.com/en/copilot/how-tos/use-ai-models/change-the-chat-model>
- *AI models for Copilot Chat* (concepts): <https://docs.github.com/en/copilot/concepts/ai-models/ai-models-for-copilot-chat>
- *Manage policies for Copilot in your org*: <https://docs.github.com/en/copilot/how-tos/administer/enable-features/manage-policies-for-copilot-in-your-organization>
- VS Code · *Language Models*: <https://code.visualstudio.com/docs/copilot/customization/language-models>
- Copilot Chat extension repo (issues / release notes): <https://github.com/microsoft/vscode-copilot-release>
