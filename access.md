---
layout: doc
title: Azure AI Foundry Access
eyebrow: 04 — Foundry Access
permalink: /access/
description: Owner-side overview. How the Foundry account, APIM gateway, and routing fit together.
---

{% capture _src %}{% include_relative AZURE_AI_FOUNDRY_ACCESS.md %}{% endcapture %}
{{ _src
   | replace: "AI_GATEWAY_CONSUMER_GUIDE.md", "/consumer-guide/"
   | replace: "OPENCODE_INTEGRATION.md", "/opencode/"
   | replace: "IMAGE_MODEL_USAGE.md", "/images/"
   | replace: "AZURE_AI_FOUNDRY_ACCESS.md", "/access/"
   | replace: "README.md", "/"
   | markdownify }}
