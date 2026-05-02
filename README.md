# Keel

The harness coding agents are built on.

## What

Keel is the stripped-down harness of [pi](https://github.com/badlogic/pi-mono) — just the agent engine (`packages/agent`) and LLM API layer (`packages/ai`). Nothing else.

New code is MPL-2.0 — the harness stays open. The original pi-mono code remains MIT.

## Architecture

Keel is the harness. [hull](https://github.com/devexcelsior/hull) is the TUI, web UI, plugins, and CLI built on top. [helm](https://github.com/devexcelsior/helm) is the methodology — AGENTS.md, prompt templates, orchestration. Together they form the full pi experience.

```
helm (MIT)         ← methodology, prompts, orchestration
hull (MIT)         ← TUI, web UI, plugins, CLI
keel (MPL-2.0)     ← agent engine + LLM API
```

## Packages

| Package | Description |
|---------|-------------|
| **[@mariozechner/pi-ai](packages/ai)** | Unified multi-provider LLM API (OpenAI, Anthropic, Google, etc.) |
| **[@mariozechner/pi-agent-core](packages/agent)** | Agent runtime with tool calling and state management |

## License

New code: MPL-2.0. Upstream code from [pi-mono](https://github.com/badlogic/pi-mono) by Mario Zechner: MIT.

See [LICENSE](LICENSE) for full terms.
