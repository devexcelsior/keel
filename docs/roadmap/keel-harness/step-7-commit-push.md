# Step 7: Commit and push

Stage all changes with specific `git add` commands, commit with a descriptive message, and push to `origin/main`.

---

## Context

After Steps 1-6, all changes are in the working tree. This is the final step: stage, commit, and push. The commit must reference both the harness restructuring and the MPL-2.0 relicense. AGENTS.md git rules forbid `git add -A`; specific file paths must be used.

## Decision

Stage changes using specific `git add <file>` commands (per AGENTS.md). Commit with a message matching SETUP.md §1g format: summary line contains "Keel harness" and "MPL-2.0". Push to `origin/main`.

## Constraints

- Only stage files modified in this session.
- Do not use `git add -A` or `git add .` (per AGENTS.md).
- Commit message must reference "Keel harness" and "MPL-2.0".
- Verify push succeeded by checking `git ls-remote origin main` matches local HEAD.

## Second-order effects

- Commit becomes the new HEAD of `main` on origin.
- GitHub displays the LICENSE and README changes immediately.

## Failure modes

- *Deceptively obvious wrong answer*: "Run `git add -A` because there are hundreds of files." Wrong: AGENTS.md explicitly forbids this to avoid staging unrelated changes from other agents.
- Staging only some files and missing others. Fix: `git status --short` before committing to verify all expected changes are staged.

## Alternatives considered

- Use `git add -A` for efficiency. **Rejected**: AGENTS.md git rules forbid it. The file count is large but manageable via specific paths or `git add packages/ai/src/ packages/ai/test/ ...`.
- Split into multiple commits (one per step). **Rejected**: Adds complexity. A single well-described commit is sufficient for this structural change.

## Self-consistency check

Consistent with all prior steps. No contradictions.

## Files touched

- Git staging of all modified/added/removed files

## Acceptance criteria

- AC-7.1: `git status --short` shows no uncommitted changes
- AC-7.2: Commit message summary line contains "Keel harness" and "MPL-2.0" (matching SETUP.md §1g format)
- AC-7.2b: Staging uses specific `git add <file>` or `git add <directory>` commands, not `git add -A`
- AC-7.3: Push succeeds without error (`git push origin main` exit code 0)
- AC-7.4: GitHub shows the commit on `main` branch (`git ls-remote origin main` matches local HEAD)

## Mechanical constraint checks

| # | Constraint | Verification command | Expected exit |
|---|---|---|---|
| 1 | Working tree clean | `test "$(git status --short \| wc -l)" -eq 0` | 0 |
| 2 | Commit message references harness and MPL-2.0 | `git log -1 --format="%s" \| grep -qi "harness" && git log -1 --format="%s" \| grep -qi "MPL-2.0"` | 0 |
| 3 | Push succeeded | `git ls-remote origin main \| grep -q "$(git rev-parse HEAD)"` | 0 |

## Test mapping

No runtime code — test mapping N/A.

## Invariants to preserve

1. Do not rewrite git history.
2. Do not stage files not modified in this feature.

## Verification commands

```bash
# AC-7.1
git status --short | wc -l | grep -q '^0$'
# AC-7.2
git log -1 --format="%s" | grep -qi "harness"
git log -1 --format="%s" | grep -qi "MPL-2.0"
# AC-7.3
git push origin main
# AC-7.4
git ls-remote origin main | grep -q "$(git rev-parse HEAD)"
```
