**Date**: 2026-05-01
**Mode**: focused (step 2)
**Step doc**: docs/roadmap/keel-harness/step-2-rewrite-config.md

## 1. Files to touch — existence verified

| File | Status | Notes |
|---|---|---|
| `package.json` | ✅ Exists | 3031 bytes; current name `"pi-monorepo"`, version `"0.0.3"`, license absent from top-level |
| `tsconfig.json` | ✅ Exists | 1342 bytes; contains paths for `pi-coding-agent`, `pi-tui`, `pi-web-ui`, `pi-agent-old` at lines 13–21 |
| `biome.json` | ✅ Exists | 895 bytes; includes `coding-agent/examples`, `web-ui/src`, `web-ui/example`, `mom/data` at lines 27–37 |
| `packages/ai/package.json` | ✅ Exists | 2822 bytes; `"license": "MIT"` at line 94 |
| `packages/agent/package.json` | ✅ Exists | 1010 bytes; `"license": "MIT"` at line 31 |

## 2. Functions / APIs to call — existence verified

N/A — this step is configuration file rewriting. No code APIs called.

## 3. Imports to add — package availability verified

N/A — no new packages imported. Step removes dead dependencies (`@mariozechner/jiti`, `get-east-asian-width`, `@mariozechner/pi-coding-agent`, `concurrently`, `husky`, `shx`) and keeps existing ones (`@typescript/native-preview` for `tsgo`, `tsx`, `@biomejs/biome`, `@types/node`, `typescript`).

Evidence of packages to keep:
- `"@typescript/native-preview": "7.0.0-dev.20260120.1"` at `package.json:38`
- `"tsx": "^4.20.3"` at `package.json:41`
- `"@biomejs/biome": "2.3.5"` at `package.json:36`
- `"typescript": "^5.9.2"` at `package.json:42`

Evidence of packages to remove:
- `"@mariozechner/jiti": "^2.6.5"` at `package.json:50`
- `"@mariozechner/pi-coding-agent": "^0.30.2"` at `package.json:51`
- `"get-east-asian-width": "^1.4.0"` at `package.json:52`
- `"concurrently": "^9.2.1"` at `package.json:39`
- `"husky": "^9.1.7"` at `package.json:40`
- `"shx": "^0.4.0"` at `package.json:43`

## 4. Project constraints affecting implementation

| Setting | Value | Impact |
|---|---|---|
| `tsconfig.json` `include` | `["packages/*/src/**/*", "packages/*/test/**/*", "packages/coding-agent/examples/**/*"]` | Must prune the `coding-agent/examples` entry or biome will warn on missing dir |
| `tsconfig.json` `exclude` | `["packages/web-ui/**/*", "**/dist/**"]` | Must prune the `web-ui` entry |
| `biome.json` `includes` | contains `coding-agent/examples/**/*.ts`, `web-ui/src/**/*.ts`, `web-ui/example/**/*.ts`, `!packages/web-ui/src/app.css`, `!packages/mom/data/**/*` | Must prune all removed-package references |
| No eslint config | N/A | Biome is the sole linter; keep `@biomejs/biome` devDependency |
| `tsconfig.base.json` `strict: true` | enforced | No type loosening permitted in any package tsconfig |

## 5. Verdict

Pass: ready to `/implement`

All five target files exist and are readable. The current content exactly matches the step doc's description of what needs changing (workspaces, scripts, deps, tsconfig paths, biome includes, package-level license fields). No missing files, no missing APIs, no missing imports. No caveats.

---
**✅ Preflight Pass — ready for /implement**

| Phase | Command | Thinking |
|---|---|---|
| **Now** | `/implement` | **medium** — Shift+Tab up from minimal |
| Then | `/verify` | **minimal** |
| Then (calibration mode) | `/assess` | **medium** |
