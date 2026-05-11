---
layout: doc
title: OpenCode Integration
eyebrow: 02 — OpenCode
permalink: /opencode/
description: Drop the gateway into OpenCode. Variants, agents, project configs, common errors.
---

{% capture _src %}{% include_relative OPENCODE_INTEGRATION.md %}{% endcapture %}
{{ _src
   | replace: "AI_GATEWAY_CONSUMER_GUIDE.md", "/consumer-guide/"
   | replace: "OPENCODE_INTEGRATION.md", "/opencode/"
   | replace: "IMAGE_MODEL_USAGE.md", "/images/"
   | replace: "AZURE_AI_FOUNDRY_ACCESS.md", "/access/"
   | replace: "README.md", "/"
   | markdownify }}
