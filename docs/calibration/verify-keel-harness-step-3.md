# Verify output: keel-harness step 3

**Date**: 2026-05-01
**Step**: step-3-set-license

## Mechanical constraint checks

| # | Check command | Exit code | Verdict |
|---|---|---|---|
| 1 | `head -5 LICENSE \| grep -q "Keel"` | 0 | Pass |
| 2 | `head -5 LICENSE \| grep -q "MPL-2.0\|Mozilla Public License"` | 0 | Pass |
| 3 | `grep -q "Mozilla Public License, version 2.0" LICENSE` | 1 | **Fail — pattern mismatch** |
| 3-corrected | `grep -q "Mozilla Public License Version 2.0" LICENSE` | 0 | Pass |

**Note**: Mechanical check #3 used incorrect grep pattern. Canonical MPL-2.0 text from `https://www.mozilla.org/media/MPL/2.0/index.txt` uses "Version" (capital V). Step doc updated to correct pattern.

## Constraint gate

| # | Constraint | Satisfied? | Evidence |
|---|---|---|---|
| 1 | "The file must contain valid MPL-2.0 text. The prepend header must not alter the legal meaning of the license." | Yes | `LICENSE:1-3` plain-text attribution; `LICENSE:4-376` verbatim Mozilla text |
| 2 | "If curl fails, fall back to writing a short SPDX header..." | N/A | curl succeeded |

## Invariant gate

| # | Invariant | How verified | Evidence |
|---|---|---|---|
| 1 | "If curl fails, do not leave a broken LICENSE file." | N/A | curl succeeded; no broken file created |

## Verification commands

- AC-3.1 (`head -5 LICENSE | grep -q "Keel"`): exit 0 ✓
- AC-3.2 (`grep -q "Mozilla Public License Version 2.0" LICENSE`): exit 0 ✓

## Overall verdict

PASS — step doc mechanical check pattern corrected to match canonical MPL-2.0 text.
