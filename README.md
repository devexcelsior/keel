# Keel — AI/Agent Harness

Keel is the core AI and agent runtime extracted from [pi-mono](https://github.com/badlogic/pi-mono).
It contains the packages you can't remove: the multi-provider LLM API and the agent loop.
Everything else is hull (the coding agent CLI) and helm (the web interface).

Keel is the first piece of the three-repo architecture:

- **[devexcelsior/keel](https://github.com/devexcelsior/keel)** (this repo) — AI/Agent harness
- **[devexcelsior/hull](https://github.com/devexcelsior/hull)** — Coding agent CLI and extensions
- **[devexcelsior/helm](https://github.com/devexcelsior/helm)** — Web UI and chat interfaces

## Packages

| Package | Description |
|---------|-------------|
| **[@mariozechner/pi-ai](packages/ai)** | Unified multi-provider LLM API (OpenAI, Anthropic, Google, etc.) |
| **[@mariozechner/pi-agent-core](packages/agent)** | Agent runtime with tool calling and state management |

## License

This project is licensed under the [Mozilla Public License 2.0](LICENSE).
