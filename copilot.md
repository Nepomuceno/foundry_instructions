---
layout: doc
title: GitHub Copilot Integration
eyebrow: 06 — GitHub Copilot
permalink: /copilot/
description: Wire the AI Gateway into the GitHub Copilot CLI (first-class env-var support) and, where possible, into Copilot Chat in VS Code.
---

{% capture url_consumer %}{{ site.baseurl }}/consumer-guide/{% endcapture %}
{% capture url_opencode %}{{ site.baseurl }}/opencode/{% endcapture %}
{% capture url_copilot %}{{ site.baseurl }}/copilot/{% endcapture %}
{% capture url_images %}{{ site.baseurl }}/images/{% endcapture %}
{% capture url_access %}{{ site.baseurl }}/access/{% endcapture %}
{% capture url_models %}{{ site.baseurl }}/models/{% endcapture %}
{% capture url_home %}{{ site.baseurl }}/{% endcapture %}

{% capture _src %}{% include_relative GITHUB_COPILOT_INTEGRATION.md %}{% endcapture %}
{{ _src
   | replace: "AI_GATEWAY_CONSUMER_GUIDE.md", url_consumer
   | replace: "OPENCODE_INTEGRATION.md", url_opencode
   | replace: "GITHUB_COPILOT_INTEGRATION.md", url_copilot
   | replace: "IMAGE_MODEL_USAGE.md", url_images
   | replace: "AZURE_AI_FOUNDRY_ACCESS.md", url_access
   | replace: "models.md", url_models
   | replace: "README.md", url_home
   | markdownify }}
