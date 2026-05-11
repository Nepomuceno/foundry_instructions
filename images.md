---
layout: doc
title: Image Models
eyebrow: 03 — Image Models
permalink: /images/
description: Pixel-pushing reference. Sizes, formats, and the difference between size and width/height.
---

{% capture _src %}{% include_relative IMAGE_MODEL_USAGE.md %}{% endcapture %}
{{ _src
   | replace: "AI_GATEWAY_CONSUMER_GUIDE.md", "/consumer-guide/"
   | replace: "OPENCODE_INTEGRATION.md", "/opencode/"
   | replace: "IMAGE_MODEL_USAGE.md", "/images/"
   | replace: "AZURE_AI_FOUNDRY_ACCESS.md", "/access/"
   | replace: "README.md", "/"
   | markdownify }}
