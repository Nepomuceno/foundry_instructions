---
layout: default
title: Models
description: Every model exposed through the gateway — what it is, what it does, and when to reach for it.
permalink: /models/
---

<article class="doc">
  <div class="wrap">
    <header class="doc-header">
      <p class="eyebrow">05 — Model Catalog</p>
      <h1>Models</h1>
      <p class="lede">
        Every model exposed through the gateway. Grouped by what they're for.
        Each entry tells you the route, the headline capability, and a short
        opinion on when to use it.
      </p>
    </header>

    <div class="legend">
      <span class="cap cap-chat">chat</span>
      <span class="cap cap-resp">responses</span>
      <span class="cap cap-tool">tools</span>
      <span class="cap cap-vision">vision</span>
      <span class="cap cap-image">image-gen</span>
      <span class="cap cap-audio">audio</span>
      <span class="cap cap-video">video</span>
      <span class="cap cap-dep">deprecated</span>
    </div>

    <!-- ============== TEXT / REASONING ============== -->
    <section class="models-section">
      <h2 class="section-title">Text & Reasoning</h2>
      <p class="section-lede">Workhorse chat brains. Most coding, planning, and Q&amp;A lives here. <strong>Start with <code>gpt-5.4-mini</code></strong> if you can't decide — it's the sweet spot of cost, speed, and smarts.</p>

      <div class="model-grid">
        <article class="model recommended">
          <header>
            <h3>gpt-5.4</h3>
            <span class="model-tag">recommended</span>
          </header>
          <p>The flagship. Best at hard reasoning, long instructions, and code refactors that span many files. Use when correctness matters more than latency.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
            <span class="cap cap-resp">responses</span>
          </div>
          <p class="note">Requires <code>max_completion_tokens</code> for chat.</p>
        </article>

        <article class="model">
          <header><h3>gpt-5.4-mini</h3><span class="model-tag accent">daily driver</span></header>
          <p>The "good enough at almost everything, fast enough that you keep iterating" pick. Default model in the OpenCode config.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
            <span class="cap cap-resp">responses</span>
          </div>
          <p class="note">Requires <code>max_completion_tokens</code> for chat.</p>
        </article>

        <article class="model">
          <header><h3>gpt-5.4-nano</h3><span class="model-tag">fast</span></header>
          <p>Tiny + fast variant. Great for autocomplete-style usage, quick classification, and the <code>small_model</code> slot. Supports vision via Responses.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
            <span class="cap cap-resp">responses</span>
            <span class="cap cap-tool">tools</span>
            <span class="cap cap-vision">vision</span>
          </div>
        </article>

        <article class="model">
          <header><h3>gpt-5.4-pro</h3></header>
          <p>The thinking tier of 5.4. Responses-only — use for long-horizon reasoning, agents, and tasks where you want it to deliberate.</p>
          <div class="caps">
            <span class="cap cap-resp">responses</span>
          </div>
          <p class="note">Chat completions disabled. Responses API only.</p>
        </article>

        <article class="model">
          <header><h3>gpt-5</h3></header>
          <p>Previous-gen flagship. Still strong; tool-calling is rock-solid via both chat and responses. Pick if you've already tuned prompts against it.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
            <span class="cap cap-resp">responses</span>
            <span class="cap cap-tool">tools</span>
          </div>
        </article>

        <article class="model">
          <header><h3>gpt-5-mini</h3></header>
          <p>Smaller, cheaper 5-series. Solid for bulk transforms and structured-output tasks.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
            <span class="cap cap-resp">responses</span>
          </div>
          <p class="note">Requires <code>max_completion_tokens</code>.</p>
        </article>

        <article class="model">
          <header><h3>gpt-5-chat</h3></header>
          <p>Chat-tuned variant of GPT-5. Use when you want conversational behavior without configuring the responses API.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
            <span class="cap cap-resp">responses</span>
          </div>
        </article>

        <article class="model">
          <header><h3>gpt-5.2</h3></header>
          <p>Interim 5-series checkpoint. Good general-purpose pick if you want something between 5 and 5.4.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
            <span class="cap cap-resp">responses</span>
          </div>
        </article>

        <article class="model">
          <header><h3>gpt-5.1-codex-mini</h3><span class="model-tag">code</span></header>
          <p>Code-specialized variant. Reach for it when you're doing pure code edits, completions, or refactors and want a smaller, faster model than full 5.4.</p>
          <div class="caps">
            <span class="cap cap-resp">responses</span>
          </div>
          <p class="note">Responses API only — no chat completions.</p>
        </article>

        <article class="model">
          <header><h3>gpt-4.1</h3></header>
          <p>The reliable previous generation. Cheap, fast, predictable. Excellent at tool-calling.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
            <span class="cap cap-resp">responses</span>
            <span class="cap cap-tool">tools</span>
          </div>
        </article>

        <article class="model">
          <header><h3>gpt-4o</h3></header>
          <p>Multimodal classic. Vision works through both chat and responses with remote PNG URLs. Solid baseline.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
            <span class="cap cap-resp">responses</span>
            <span class="cap cap-vision">vision</span>
          </div>
        </article>

        <article class="model">
          <header><h3>gpt-oss-120b</h3></header>
          <p>Open-source 120B parameter model exposed through the gateway. Use when you want OSS provenance or to compare against the proprietary lineup.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
          </div>
        </article>

        <article class="model">
          <header><h3>Mistral-Large-3</h3></header>
          <p>Mistral's flagship. Strong tool-calling via chat completions. Pick if you want non-OpenAI lineage with comparable quality.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
            <span class="cap cap-tool">tools</span>
          </div>
          <p class="note">Responses API is not supported.</p>
        </article>

        <article class="model">
          <header><h3>grok-4-20-reasoning</h3></header>
          <p>xAI's Grok 4.20 reasoning variant. Long context, opinionated voice, good at problem-solving prompts.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
          </div>
        </article>

        <article class="model">
          <header><h3>grok-4-1-fast-reasoning</h3></header>
          <p>Faster Grok 4.1 reasoning variant. Use when you want Grok-style answers but care about latency.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
          </div>
        </article>

        <article class="model">
          <header><h3>Phi-4-reasoning</h3></header>
          <p>Microsoft Phi-4 reasoning. Compact, surprisingly capable for its size, good for edge-style workloads.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
          </div>
          <p class="note">Responses API returns unsupported.</p>
        </article>

        <article class="model">
          <header><h3>DeepSeek-V3.2</h3></header>
          <p>DeepSeek's latest. Strong reasoning at a competitive price point. Pick for math-heavy or analytic tasks.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
          </div>
        </article>

        <article class="model">
          <header><h3>Kimi-K2.5</h3></header>
          <p>Moonshot AI's Kimi K2.5. Long-context champion — great for digesting entire codebases or long documents in one shot.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
          </div>
        </article>
      </div>
    </section>

    <!-- ============== ROUTER ============== -->
    <section class="models-section">
      <h2 class="section-title">Auto-Router</h2>
      <p class="section-lede">Let the gateway pick a model for you based on the prompt.</p>
      <div class="model-grid">
        <article class="model">
          <header><h3>ModelRouter</h3><span class="model-tag">auto</span></header>
          <p>Routes each request to whichever model the router thinks fits best. Use when you want one endpoint and don't care about determinism. Don't use it when you need reproducibility — pick a concrete model instead.</p>
          <div class="caps">
            <span class="cap cap-chat">chat</span>
          </div>
        </article>
      </div>
    </section>

    <!-- ============== IMAGES ============== -->
    <section class="models-section">
      <h2 class="section-title">Image Generation</h2>
      <p class="section-lede">Two families. <code>gpt-image-*</code> uses OpenAI's <code>size: "WIDTHxHEIGHT"</code> shape. FLUX uses separate <code>width</code> and <code>height</code> integers and lives on a Black Forest Labs provider route. They are <strong>not</strong> drop-in compatible.</p>

      <div class="model-grid">
        <article class="model">
          <header><h3>gpt-image-2</h3><span class="model-tag accent">flagship</span></header>
          <p>OpenAI's current image model through the gateway. Goes up to 4K (<code>3840x2160</code>). Realistic prompts look great.</p>
          <div class="caps">
            <span class="cap cap-image">image-gen</span>
          </div>
          <p class="note"><code>output_format</code> accepts <code>png</code> and <code>jpeg</code>; webp is rejected. Transparent background is not supported. ~2 RPM rate limit.</p>
        </article>

        <article class="model">
          <header><h3>gpt-image-1.5</h3></header>
          <p>Previous generation. Cheaper and faster. Use when you don't need 4K or photoreal fidelity.</p>
          <div class="caps">
            <span class="cap cap-image">image-gen</span>
          </div>
        </article>

        <article class="model">
          <header><h3>FLUX.2-pro</h3><span class="model-tag">artistic</span></header>
          <p>Black Forest Labs' top tier. Excellent at painterly, cinematic, and stylized outputs. Validated up to <code>2304x1728</code> PNG with <code>steps: 50</code>, <code>guidance: 5</code>.</p>
          <div class="caps">
            <span class="cap cap-image">image-gen</span>
          </div>
          <p class="note">Provider route: <code>/providers/blackforestlabs/v1/flux-2-pro</code>. Returns base64.</p>
        </article>

        <article class="model">
          <header><h3>FLUX.2-flex</h3></header>
          <p>The flexible FLUX variant. Supports text-to-image plus reference images (<code>input_image</code> through <code>input_image_8</code>). <code>steps</code> up to 50, <code>guidance</code> 1.5–10.</p>
          <div class="caps">
            <span class="cap cap-image">image-gen</span>
            <span class="cap cap-vision">ref-image</span>
          </div>
          <p class="note">Output formats: <code>png</code>, <code>jpeg</code>. ~4 RPM.</p>
        </article>
      </div>
    </section>

    <!-- ============== VIDEO ============== -->
    <section class="models-section">
      <h2 class="section-title">Video</h2>
      <p class="section-lede">Async job model. Submit, poll, download.</p>
      <div class="model-grid">
        <article class="model">
          <header><h3>sora-2</h3><span class="model-tag accent">video</span></header>
          <p>OpenAI Sora 2. Creates short video clips from a text prompt. Job-based: <code>POST /openai/v1/videos</code> kicks off, then poll status until done, then download.</p>
          <div class="caps">
            <span class="cap cap-video">video</span>
          </div>
          <p class="note"><code>seconds</code> accepts string enums like <code>"4"</code>, <code>"8"</code>, <code>"12"</code>. Sizes: <code>720x1280</code>, <code>1280x720</code>, <code>1024x1792</code>, <code>1792x1024</code>.</p>
        </article>
      </div>
    </section>

    <!-- ============== AUDIO ============== -->
    <section class="models-section">
      <h2 class="section-title">Audio</h2>
      <p class="section-lede">Two shapes: <strong>audio-chat</strong> (you talk, it talks back) and <strong>TTS</strong> (text in, MP3 out).</p>

      <div class="model-grid">
        <article class="model">
          <header><h3>gpt-audio</h3></header>
          <p>Audio-in / audio-out chat. Send a message with an audio modality and it replies in audio. Plain text-only chat is rejected by design.</p>
          <div class="caps">
            <span class="cap cap-audio">audio-chat</span>
          </div>
        </article>

        <article class="model">
          <header><h3>gpt-audio-1.5</h3></header>
          <p>Newer audio chat variant. Same shape as <code>gpt-audio</code>; better quality.</p>
          <div class="caps">
            <span class="cap cap-audio">audio-chat</span>
          </div>
        </article>

        <article class="model">
          <header><h3>gpt-4o-mini-tts</h3><span class="model-tag">tts</span></header>
          <p>Text-to-speech only. Hit <code>/audio/speech</code> with text and get back an MP3 stream. Great for narration, alerts, voice UI.</p>
          <div class="caps">
            <span class="cap cap-audio">tts</span>
          </div>
        </article>
      </div>
    </section>

    <!-- ============== NOT EXPOSED / DEPRECATED ============== -->
    <section class="models-section">
      <h2 class="section-title">Not Available (Yet)</h2>
      <p class="section-lede">These deployments exist but aren't usable through the current routes. Listed for transparency.</p>

      <div class="model-grid">
        <article class="model disabled">
          <header><h3>Cohere-rerank-v4.0-fast</h3><span class="model-tag warn">not exposed</span></header>
          <p>Rerank model. The provider-specific rerank route isn't imported into APIM yet — chat and responses both fail. Ping the owner if you need it.</p>
        </article>

        <article class="model disabled">
          <header><h3>grok-4-fast-reasoning</h3><span class="model-tag warn">deprecated</span></header>
          <p>Returns <code>unknown_model</code>. Use <code>grok-4-1-fast-reasoning</code> or <code>grok-4-20-reasoning</code> instead.</p>
          <div class="caps">
            <span class="cap cap-dep">deprecated</span>
          </div>
        </article>
      </div>
    </section>

    <nav class="doc-foot" aria-label="Section">
      <a href="{{ '/' | relative_url }}">← Back to overview</a>
    </nav>
  </div>
</article>
