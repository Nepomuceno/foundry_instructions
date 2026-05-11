---
layout: doc
title: Consumer Guide
eyebrow: 01 — Consumer Guide
permalink: /consumer-guide/
description: The "I just want to call stuff" guide. Curl examples for every model class.
---

{% capture _src %}{% include_relative AI_GATEWAY_CONSUMER_GUIDE.md %}{% endcapture %}
{{ _src
   | replace: "AI_GATEWAY_CONSUMER_GUIDE.md", "/consumer-guide/"
   | replace: "OPENCODE_INTEGRATION.md", "/opencode/"
   | replace: "IMAGE_MODEL_USAGE.md", "/images/"
   | replace: "AZURE_AI_FOUNDRY_ACCESS.md", "/access/"
   | replace: "README.md", "/"
   | markdownify }}
