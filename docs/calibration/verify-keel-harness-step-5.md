# Verify output: keel-harness step 5

**Date**: 2026-05-01
**Step**: step-5-write-readme

## Mechanical constraint checks

| # | Check command | Exit code | Verdict | Notes |
|---|---|---|---|---|
| 1 | `head -1 README.md \| grep -q "Keel"` | 0 | **Pass** | First heading contains "Keel" |
| 2 | `grep -q "hull\|helm" README.md` | 0 | **Pass** | References hull and helm repos |
| 3 | `! grep -q "coding-agent\|tui\|web-ui" README.md` | 0 | **Pass** | No removed package references |
| 4 | `test "$(wc -l < README.md)" -le 80` | 0 | **Pass** | 22 lines, well under 80 limit |

## Constraint gate

| # | Constraint | Satisfied? | Evidence |
|---|---|---|---|
| 1 | Must not exceed 80 lines | Yes | `wc -l README.md` → 22 lines |
| 2 | Must not describe removed packages | Yes | No `coding-agent`, `tui`, or `web-ui` found |

## Invariant gate

| # | Invariant | How verified | Evidence |
|---|---|---|---|
| 1 | `README.md` must exist | `ls README.md` | File exists |

## Verification commands

- `head -1 README.md | grep -q "Keel"`: exit 0 ✓
- `grep -q "hull\|helm" README.md`: exit 0 ✓
- `! grep -q "coding-agent\|tui\|web-ui" README.md`: exit 0 ✓
- `test "$(wc -l < README.md)" -le 80`: exit 0 ✓

## Overall verdict

**PASS** — All mechanical checks pass, all constraints satisfied, all invariants preserved.
