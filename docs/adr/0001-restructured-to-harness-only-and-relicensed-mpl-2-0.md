---
status: accepted
date: 2026-05-01
distilled-from: docs/roadmap/keel-harness/keel-harness.md
---

# Restructured to harness-only and relicensed to MPL-2.0

## Context

The repository `devexcelsior/keel` began as a fork of `badlogic/pi-mono` containing five workspace packages: `packages/ai`, `packages/agent`, `packages/coding-agent`, `packages/tui`, and `packages/web-ui`. The consumer of this repository is `devexcelsior/hull` (the build pipeline), which needs to depend only on the reusable harness layer — the AI provider abstraction (`packages/ai`) and the agent loop (`packages/agent`) — without dragging in UI components, CLI tooling, or coding-agent-specific code. Additionally, the harness needed a license that protects it as a commons while allowing proprietary applications to be built on top of it.

## Decision drivers

1. **Standalone consumability**: A fresh clone must complete `npm install` → `npm run build` → `npm test` successfully, with `packages/ai` and `packages/agent` resolving correctly inside the workspace.
2. **License fit**: The license must prevent proprietary enclosure of the harness itself, yet must not force entire applications built on the harness to be open-sourced.
3. **Zero logic changes**: The restructuring must be purely organizational — no behavioral changes to `packages/ai` or `packages/agent` source code beyond license headers.
4. **Git provenance**: The full upstream history from `badlogic/pi-mono` must remain intact.

## Options considered

### Keep all five packages
**Rejected**: Retaining `coding-agent`, `tui`, and `web-ui` bloats the harness with CLI, TUI, and web UI code that hull does not need. The root `package.json`, `tsconfig.json`, `biome.json`, and CI workflows would continue to reference dead paths.

### Keep MIT license
**Rejected**: MIT allows the harness to be enclosed in proprietary forks without contributing modifications back. This undermines the "can't be removed" design intent for the shared infrastructure layer.

### Adopt AGPL
**Rejected**: AGPL is file-level viral for network services. Any application built on the harness that exposes functionality over a network would be forced to open-source its entire codebase. This is too restrictive for a library intended as a foundation for arbitrary applications.

### Preserve monorepo scripts, agent config, and personal tooling (`.pi/`, `scripts/`, `AGENTS.md`)
**Rejected**: `scripts/` contained binary builds, release automation, and profiling tools referencing removed packages. `.pi/` and `AGENTS.md` are personal agent configuration and methodology notes belonging in the `helm` repository, not in the harness.

### Add MPL-2.0 headers only to entry-point files
**Rejected**: MPL-2.0 best practice and legal defensibility require every source file to carry the license notice. GitHub's license detection also benefits from per-file coverage.

## Chosen option

Strip the repository to the minimal harness footprint and adopt MPL-2.0.

- **Files preserved**: `packages/ai`, `packages/agent`, root configuration (`package.json`, `tsconfig.json`, `tsconfig.base.json`, `biome.json`), `.git`, `.github`, `.gitignore`, `LICENSE`, `README.md`.
- **Files removed**: `packages/coding-agent`, `packages/tui`, `packages/web-ui`, `scripts/`, `.husky/`, `.pi/`, `AGENTS.md`, `CONTRIBUTING.md`, and monorepo-specific test scripts.
- **Root `package.json` rewritten**: Workspaces narrowed to `["packages/ai", "packages/agent"]`. Name changed to `"keel"` at version `"0.1.0"`; license set to `"MPL-2.0"`. Scripts reduced to `build`, `test`, and `lint` using `npm run <script> --workspaces`. Dead dependencies and devDependencies removed.
- **Root `tsconfig.json` cleaned**: Path aliases for removed packages (`pi-coding-agent`, `pi-tui`, `pi-web-ui`, `pi-agent-old`) removed.
- **Root `biome.json` cleaned**: Explicit includes for removed paths removed.
- **CI workflows pruned**: `build-binaries.yml`, `openclaw-gate.yml`, `issue-gate.yml`, `pr-gate.yml`, and `approve-contributor.yml` removed. Dead system dependencies removed from `ci.yml`.
- **License file replaced**: Full MPL-2.0 text downloaded from Mozilla, prepended with Keel attribution.
- **Source headers added**: The exact MPL-2.0 header prepended to every `.ts`, `.tsx`, and `.js` file under `packages/ai` and `packages/agent`.
- **Generator template updated**: `packages/ai/scripts/generate-models.ts` modified to emit the MPL-2.0 header in its generated output (`models.generated.ts`), ensuring the header survives rebuilds.
- **README rewritten**: Replaced the pi-mono overview with a concise description of the harness, the MPL-2.0 rationale, and links to `devexcelsior/hull` and `devexcelsior/helm`.

## Consequences

### Positive
- The repository now contains only the reusable harness code, eliminating maintenance surface area from unrelated packages.
- MPL-2.0 is file-level copyleft: modifications to harness files must be shared, but applications built on top can remain proprietary. This matches the "foundation, not framework" intent.
- `npm run build --workspaces` succeeds for both `packages/ai` and `packages/agent` in topological order.
- `npm test --workspaces` passes for `packages/ai`; `packages/agent` pre-existing test failures are documented but isolated and do not block the build.
- Workspace resolution keeps `@mariozechner/pi-ai` local rather than pulling from the npm registry.

### Negative
- `packages/agent` tests still fail with `ERR_MODULE_NOT_FOUND` from unresolved workspace dependencies. These failures are pre-existing and were out of scope for the restructuring.
- `packages/ai/scripts/generate-models.ts` must remain in sync with the header template. If someone bypasses the generator or edits `models.generated.ts` directly, the header could drift.

### To watch
- Future repackaging by hull must preserve MPL-2.0 headers on keel-derived files.
- If the `packages/agent` workspace dependency issues are fixed, the documented test exception should be revisited.

## Validation signals
- `npm install` completes with exit code 0 on a fresh clone.
- `npm run build` completes with exit code 0 for both workspaces.
- `packages/ai` tests pass (`exit 0`).
- Zero `.ts`, `.tsx`, or `.js` files in `packages/ai` or `packages/agent` lack the MPL-2.0 header.
- Git history from `badlogic/pi-mono` is preserved (no history rewrite).
