# Keel

The harness coding agents are built on. Can't be removed.

## What

Keel is the stripped-down harness of [pi](https://github.com/badlogic/pi-mono) — just the agent engine (`packages/agent`) and LLM API layer (`packages/ai`). Nothing else.

It's MPL-2.0. Modify it, redistribute it, build proprietary products on it — but the harness itself stays open. Permanently.

## Why

Because a foundation that can be owned will eventually be owned.

## Architecture

Keel is the harness. [hull](https://github.com/devexcelsior/hull) is the TUI, web UI, plugins, and CLI built on top. [helm](https://github.com/devexcelsior/helm) is the methodology — AGENTS.md, prompt templates, orchestration. Together they form the full pi experience.

```
helm (MIT)         ← methodology, prompts, orchestration
hull (MIT)         ← TUI, web UI, plugins, CLI
keel (MPL-2.0)     ← agent engine + LLM API — can't be removed
```

## Packages

| Package | Description |
|---------|-------------|
| **[@mariozechner/pi-ai](packages/ai)** | Unified multi-provider LLM API (OpenAI, Anthropic, Google, etc.) |
| **[@mariozechner/pi-agent-core](packages/agent)** | Agent runtime with tool calling and state management |

## Staying current with upstream pi

```bash
./scripts/sync-upstream.sh
```

Cherry-picks upstream pi-mono commits that touch `packages/ai` or `packages/agent`.

## License

MPL-2.0. See [LICENSE](LICENSE).
