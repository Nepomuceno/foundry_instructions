---
layout: doc
title: Azure AI Foundry Access
eyebrow: 04 — Foundry Access
permalink: /access/
description: Owner-side overview. How the Foundry account, APIM gateway, and routing fit together.
---

{% capture url_consumer %}{{ site.baseurl }}/consumer-guide/{% endcapture %}
{% capture url_opencode %}{{ site.baseurl }}/opencode/{% endcapture %}
{% capture url_copilot %}{{ site.baseurl }}/copilot/{% endcapture %}
{% capture url_images %}{{ site.baseurl }}/images/{% endcapture %}
{% capture url_access %}{{ site.baseurl }}/access/{% endcapture %}
{% capture url_models %}{{ site.baseurl }}/models/{% endcapture %}
{% capture url_home %}{{ site.baseurl }}/{% endcapture %}

{% capture _src %}{% include_relative AZURE_AI_FOUNDRY_ACCESS.md %}{% endcapture %}
{{ _src
   | replace: "AI_GATEWAY_CONSUMER_GUIDE.md", url_consumer
   | replace: "OPENCODE_INTEGRATION.md", url_opencode
   | replace: "GITHUB_COPILOT_INTEGRATION.md", url_copilot
   | replace: "IMAGE_MODEL_USAGE.md", url_images
   | replace: "AZURE_AI_FOUNDRY_ACCESS.md", url_access
   | replace: "models.md", url_models
   | replace: "README.md", url_home
   | markdownify }}
