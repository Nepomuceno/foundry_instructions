---
layout: doc
title: GitHub Copilot Integration
eyebrow: 06 — GitHub Copilot
permalink: /copilot/
description: Wire the AI Gateway into the GitHub Copilot CLI (first-class env-var support) and, where possible, into Copilot Chat in VS Code.
---

{% capture _src %}{% include_relative GITHUB_COPILOT_INTEGRATION.md %}{% endcapture %}
{{ _src
   | replace: "AI_GATEWAY_CONSUMER_GUIDE.md", "/consumer-guide/"
   | replace: "OPENCODE_INTEGRATION.md", "/opencode/"
   | replace: "GITHUB_COPILOT_INTEGRATION.md", "/copilot/"
   | replace: "IMAGE_MODEL_USAGE.md", "/images/"
   | replace: "AZURE_AI_FOUNDRY_ACCESS.md", "/access/"
   | replace: "models.md", "/models/"
   | replace: "README.md", "/"
   | markdownify }}
