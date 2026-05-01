# Step 2: Clean root configuration files

Rewrite `package.json`, `tsconfig.json`, `biome.json`, and package-level `package.json` files for harness-only workspaces.

---

## Context

After Step 1, only `packages/ai` and `packages/agent` remain. Root config files still reference removed packages. The source of truth for the target state is `SETUP.md` §1b. Root `package.json` must be rewritten completely; `tsconfig.json` paths and `biome.json` includes must be pruned. Package-level `package.json` files for `ai` and `agent` must have their `license` fields updated from `"MIT"` to `"MPL-2.0"`.

## Decision

Adopt `SETUP.md` §1b verbatim for root `package.json`: `name: "keel"`, `version: "0.1.0"`, `private: true`, `description: "The harness coding agents are built on. Can't be removed."`, `repository: "https://github.com/devexcelsior/keel"`, `license: "MPL-2.0"`, workspaces `["packages/ai", "packages/agent"]`, scripts `build`, `test`, `lint` (each as `npm run <script> --workspaces`). Remove dead root dependencies (`@mariozechner/jiti`, `get-east-asian-width`, `@mariozechner/pi-coding-agent`) and dead devDependencies (`concurrently`, `husky`, `shx`). Keep `tsgo` (`@typescript/native-preview`) and `tsx`.

## Constraints

- `agent` uses `tsgo` (from `@typescript/native-preview` devDependency at root) which must remain available.
- `ai` needs its `generate-models` script which uses `tsx` (also root devDependency).
- `@biomejs/biome`, `@types/node`, `typescript` are required by both packages.

## Second-order effects

- `npm install` will prune removed workspace references from `package-lock.json` automatically.
- `tsconfig.json` paths for `@mariozechner/pi-coding-agent`, `@mariozechner/pi-tui`, `@mariozechner/pi-web-ui`, `@mariozechner/pi-agent-old` must be removed to prevent TypeScript resolution errors.
- `biome.json` explicit includes for `coding-agent/examples` and `web-ui` must be removed to prevent biome warnings on missing directories.
- `packages/ai/package.json` and `packages/agent/package.json` `license` fields change from `"MIT"` to `"MPL-2.0"`.

## Failure modes

- *Deceptively obvious wrong answer*: "Keep all root scripts and only change workspaces." Wrong: `npm run build` would fail trying to cd to `packages/tui` which no longer exists. `npm run check` would invoke `check:browser-smoke` which references removed `scripts/`. Dead scripts must be pruned.
- *Silent breakage*: Removing `husky` without removing the `prepare` script leaves a `husky install` command that fails on `npm install`. Fix: remove `prepare` script alongside `.husky/` (already done in Step 1, but script also removed here).

## Alternatives considered

- Minimal edit (only workspaces + removed package deps). **Rejected**: Leaves dead scripts, dead devDependencies, and misleading metadata (`pi-monorepo` name). A complete rewrite per SETUP.md §1b is cleaner.
- Keep manual cd chain for build but only cd to ai and agent. **Rejected**: The manual chain is fragile. `npm run build --workspaces` is cleaner and npm handles dependency ordering.

## Self-consistency check

Consistent with Decision 1 (strip files): if packages are removed, their workspace entries, script references, and dependencies must also be removed. The `license: "MPL-2.0"` field here is consistent with Decision 3 (MPL-2.0 LICENSE file).

## Files touched

- `package.json` — complete rewrite
- `tsconfig.json` — remove paths for removed packages
- `biome.json` — remove explicit includes for removed packages
- `packages/ai/package.json` — update `license` field to `"MPL-2.0"`
- `packages/agent/package.json` — update `license` field to `"MPL-2.0"`

## Acceptance criteria

- AC-2.1: `package.json` workspaces list contains only `packages/ai` and `packages/agent`
- AC-2.2: `package.json` scripts contain only `build`, `test`, `lint` (each as `npm run <script> --workspaces`)
- AC-2.2b: `package.json` `name` is `"keel"`, `version` is `"0.1.0"`, `license` is `"MPL-2.0"`, `description` and `repository` are set per SETUP.md §1b
- AC-2.2c: `package.json` devDependencies do not contain `husky`, `concurrently`, `shx`; root dependencies do not contain `@mariozechner/jiti`, `get-east-asian-width`, `@mariozechner/pi-coding-agent`
- AC-2.2d: `packages/ai/package.json` and `packages/agent/package.json` license fields read `"MPL-2.0"`
- AC-2.3: `tsconfig.json` paths do not contain `pi-coding-agent`, `pi-tui`, `pi-web-ui`, `pi-agent-old`
- AC-2.4: `biome.json` includes do not contain `coding-agent`, `web-ui`, `mom`
- AC-2.5: `npm install` completes with exit code 0 (lock file auto-updates)

## Mechanical constraint checks

| # | Constraint | Verification command | Expected exit |
|---|---|---|---|
| 1 | Workspaces only ai and agent | `grep '"workspaces"' -A 5 package.json \| grep -c 'packages/coding-agent\|packages/tui\|packages/web-ui\|packages/web-ui/example'` output is 0 | 0 |
| 2 | Scripts only build/test/lint | `grep '"scripts"' -A 10 package.json \| grep -c 'browser-smoke\|profile\|dev\|version\|release\|prepublish\|publish\|prepare'` output is 0 | 0 |
| 3 | Metadata fields correct | `grep '"name":' package.json \| grep -q '"keel"' && grep '"version":' package.json \| grep -q '"0.1.0"' && grep '"license":' package.json \| grep -q '"MPL-2.0"'` | 0 |
| 4 | Dead root deps removed | `! grep -q '@mariozechner/jiti\|get-east-asian-width\|@mariozechner/pi-coding-agent' package.json` | 0 |
| 5 | Dead devDeps removed | `! grep -q '"husky"\|"concurrently"\|"shx"' package.json` | 0 |
| 6 | tsgo and tsx kept | `grep -q '@typescript/native-preview' package.json && grep -q '"tsx"' package.json` | 0 |
| 7 | tsconfig paths cleaned | `! grep -q 'pi-coding-agent\|pi-tui\|pi-web-ui\|pi-agent-old' tsconfig.json` | 0 |
| 8 | biome includes cleaned | `! grep -q 'coding-agent\|web-ui\|mom' biome.json` | 0 |
| 9 | Package license fields updated | `grep '"license":' packages/ai/package.json \| grep -q '"MPL-2.0"' && grep '"license":' packages/agent/package.json \| grep -q '"MPL-2.0"'` | 0 |
| 10 | npm install succeeds | `npm install` | 0 |

## Test mapping

No runtime code — test mapping N/A.

## Invariants to preserve

1. `tsgo` and `tsx` must remain available — they are required by `ai` and `agent` builds.
2. `@biomejs/biome` must remain — used for linting.
3. `package-lock.json` must not be deleted — preserve exact dependency pins where possible.

## Verification commands

```bash
# AC-2.1
! grep '"workspaces"' -A 5 package.json | grep -q 'packages/coding-agent\|packages/tui\|packages/web-ui'
# AC-2.2
! grep '"scripts"' -A 10 package.json | grep -q 'browser-smoke\|profile\|dev\|version\|release\|prepublish\|publish\|prepare'
# AC-2.2b
grep '"name":' package.json | grep -q '"keel"'
grep '"version":' package.json | grep -q '"0.1.0"'
grep '"license":' package.json | grep -q '"MPL-2.0"'
# AC-2.2c
! grep -q '@mariozechner/jiti\|get-east-asian-width\|@mariozechner/pi-coding-agent' package.json
! grep -q '"husky"\|"concurrently"\|"shx"' package.json
# AC-2.2d
grep '"license":' packages/ai/package.json | grep -q '"MPL-2.0"'
grep '"license":' packages/agent/package.json | grep -q '"MPL-2.0"'
# AC-2.3
! grep -q 'pi-coding-agent\|pi-tui\|pi-web-ui\|pi-agent-old' tsconfig.json
# AC-2.4
! grep -q 'coding-agent\|web-ui\|mom' biome.json
# AC-2.5
npm install
```
