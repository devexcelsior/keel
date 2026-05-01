# Step 1: Strip non-harness files and packages

Remove everything not in the harness keep-list.

---

## Context

The repo currently contains 5 workspace packages (`packages/ai`, `packages/agent`, `packages/coding-agent`, `packages/tui`, `packages/web-ui`) plus monorepo-specific root files (`scripts/`, `.husky/`, `.pi/`, `AGENTS.md`, `CONTRIBUTING.md`, `pi-test.ps1`, `pi-test.sh`, `test.sh`). The harness layer is only `packages/ai` and `packages/agent`. Everything else must be removed.

## Decision

Delete all packages, directories, and files not in the KEEP list: `packages/ai`, `packages/agent`, `.git`, `.gitignore`, `.github`, `README.md`, `LICENSE`, `package.json`, `package-lock.json`, `tsconfig.base.json`, `tsconfig.json`, `biome.json`.

## Constraints

- No source code changes in `packages/ai/src/**` or `packages/agent/src/**`. Only deletions outside the harness.
- Git history must remain intact (no `git filter-branch`).

## Second-order effects

- `package-lock.json` will still reference removed workspace packages until `npm install` rewrites it in Step 2.
- `.github/workflows/ci.yml` references generic `npm run build` / `npm test` which will still work after Step 2 rewrites the scripts.

## Failure modes

- *Deceptively obvious wrong answer*: "Keep `scripts/` — they might be useful later." Wrong: they reference removed packages and would fail. They can be re-added if needed.
- *Silent breakage*: Deleting `packages/coding-agent` without also removing its references in `package.json` workspaces causes `npm install` to fail. Fix: Step 2 rewrites `package.json` before `npm install`.

## Alternatives considered

- Keep removed packages but mark them as deprecated. **Rejected**: Bloats the repo; the harness philosophy is minimal. Dead code accumulates.
- Move removed packages to a separate branch. **Rejected**: Unnecessary complexity; the fork relationship to `badlogic/pi-mono` preserves the full history upstream.

## Self-consistency check

No contradictions. Decision 1 (strip files) and Decision 2 (rewrite config) are sequential: strip first, then fix config. The order matters — you can't rewrite `package.json` workspaces before the packages are removed, but the inverse (remove packages, then fix references) works.

## Files touched

- `rm -rf packages/coding-agent packages/tui packages/web-ui`
- `rm -rf scripts/ .husky/ .pi/`
- `rm -f AGENTS.md CONTRIBUTING.md pi-test.ps1 pi-test.sh test.sh`
- Remove `.github/workflows/build-binaries.yml`
- Remove `.github/workflows/openclaw-gate.yml`
- Remove `.github/workflows/issue-gate.yml`
- Remove `.github/workflows/pr-gate.yml`
- Remove `.github/workflows/approve-contributor.yml`
- Edit `.github/workflows/ci.yml` — remove dead system dependency installs
- Edit `.gitignore` — remove dead entries

## Acceptance criteria

- AC-1.1: `ls packages/` shows exactly `ai` and `agent`
- AC-1.2: `ls` at root shows no `scripts/`, `.husky/`, `.pi/`, `AGENTS.md`, `CONTRIBUTING.md`, `pi-test.ps1`, `pi-test.sh`, `test.sh`
- AC-1.3: `.github/workflows/build-binaries.yml` does not exist
- AC-1.4: `.github/workflows/openclaw-gate.yml`, `issue-gate.yml`, `pr-gate.yml`, `approve-contributor.yml` do not exist
- AC-1.5: `.github/workflows/ci.yml` does not install `libcairo2-dev`, `libpango1.0-dev`, `libjpeg-dev`, `libgif-dev`, `librsvg2-dev`, `fd-find`, `ripgrep`, or symlink `fdfind`
- AC-1.6: `.gitignore` does not contain `packages/coding-agent/binaries/`, `tui-debug.log`, `.pi/`, `plans/`, `pi-*.html`, `compaction-results/`, `.opencode/`, `.pi/hf-sessions/`, `.pi/hf-sessions-backup/`, `SETUP.md`
- AC-1.7: `git status --short` lists only deletions, no unexpected modifications

## Mechanical constraint checks

| # | Constraint | Verification command | Expected exit |
|---|---|---|---|
| 1 | Only ai and agent packages remain | `test "$(ls packages/ \| sort \| tr '\n' ' ' \| xargs)" = "agent ai"` | 0 |
| 2 | Removed root directories absent | `test ! -d scripts && test ! -d .husky && test ! -d .pi` | 0 |
| 3 | Removed root files absent | `test ! -f AGENTS.md && test ! -f CONTRIBUTING.md && test ! -f pi-test.ps1 && test ! -f pi-test.sh && test ! -f test.sh` | 0 |
| 4 | Dead workflows removed | `test ! -f .github/workflows/build-binaries.yml && test ! -f .github/workflows/openclaw-gate.yml && test ! -f .github/workflows/issue-gate.yml && test ! -f .github/workflows/pr-gate.yml && test ! -f .github/workflows/approve-contributor.yml` | 0 |
| 5 | ci.yml system deps removed | `! grep -E 'libcairo2-dev\|libpango\|libjpeg\|libgif\|librsvg\|fd-find\|ripgrep\|fdfind' .github/workflows/ci.yml` | 0 |
| 6 | .gitignore dead entries removed | `! grep -E 'packages/coding-agent/binaries/\|tui-debug.log\|^.pi/$\|plans/\|pi-\*\.html\|compaction-results/\|\.opencode/\|\.pi/hf-sessions/\|SETUP\.md' .gitignore` | 0 |

## Test mapping

No runtime code — test mapping N/A.

## Invariants to preserve

1. Git history: all upstream commits remain. Do not run `git filter-branch`.
2. `packages/ai/src/**` and `packages/agent/src/**`: zero source code changes.

## Verification commands

```bash
# AC-1.1
test "$(ls packages/ | sort | tr '\n' ' ' | xargs)" = "agent ai"
# AC-1.2
test ! -d scripts && test ! -d .husky && test ! -d .pi
test ! -f AGENTS.md && test ! -f CONTRIBUTING.md && test ! -f pi-test.ps1 && test ! -f pi-test.sh && test ! -f test.sh
# AC-1.3-1.4
test ! -f .github/workflows/build-binaries.yml
test ! -f .github/workflows/openclaw-gate.yml
test ! -f .github/workflows/issue-gate.yml
test ! -f .github/workflows/pr-gate.yml
test ! -f .github/workflows/approve-contributor.yml
# AC-1.5
! grep -E 'libcairo2-dev|libpango|libjpeg|libgif|librsvg|fd-find|ripgrep|fdfind' .github/workflows/ci.yml
# AC-1.6
! grep -E 'packages/coding-agent/binaries/|tui-debug.log|^\.pi/$|plans/|pi-\*\.html|compaction-results/|\.opencode/|\.pi/hf-sessions/|SETUP\.md' .gitignore
# AC-1.7
git status --short | grep -v '^D' | wc -l | grep -q '^0$'
```
