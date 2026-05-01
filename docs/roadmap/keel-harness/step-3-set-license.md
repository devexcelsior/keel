# Step 3: Set MPL-2.0 LICENSE

Download MPL-2.0 text and prepend Keel attribution header.

---

## Context

The repo currently has an MIT `LICENSE` file. The harness must be MPL-2.0 to prevent proprietary enclosure while allowing applications built on top to remain closed. The canonical MPL-2.0 text is available from Mozilla.

## Decision

Download the MPL-2.0 license text from `https://www.mozilla.org/media/MPL/2.0/index.txt` via curl, prepend a Keel attribution header, and overwrite the existing `LICENSE` file.

## Constraints

- The file must contain valid MPL-2.0 text. The prepend header must not alter the legal meaning of the license.
- If curl fails, fall back to writing a short SPDX header referencing `https://mozilla.org/MPL/2.0/`.

## Second-order effects

- Source file headers (Step 4) reference this license.
- README.md (Step 5) must reference MPL-2.0.
- Hull build scripts must preserve these headers when repackaging.

## Failure modes

- *Deceptively obvious wrong answer*: "Just write `'MPL-2.0'` in `package.json` and skip the file." Wrong: GitHub and license scanners need the full text file.
- curl fails and we have a broken LICENSE file. Fix: write a short SPDX header file referencing the canonical URL.

## Alternatives considered

- Keep MIT. **Rejected**: MIT allows proprietary enclosure of the harness. MPL-2.0 preserves the harness as a commons.
- Use AGPL. **Rejected**: AGPL would force any network service using the harness to open-source their entire application. MPL-2.0 is file-level — modifications to harness files must be shared, but the application built on top can remain proprietary.

## Self-consistency check

License choice is independent of file strip strategy (Decision 1) and README content (Decision 5). No contradictions.

## Files touched

- `LICENSE` — overwrite with MPL-2.0 + Keel header

## Acceptance criteria

- AC-3.1: `LICENSE` starts with "Keel — https://github.com/devexcelsior/keel" followed by "Mozilla Public License 2.0"
- AC-3.2: `LICENSE` contains the full MPL-2.0 text (verified by grep for "Mozilla Public License, version 2.0" or similar)

## Mechanical constraint checks

| # | Constraint | Verification command | Expected exit |
|---|---|---|---|
| 1 | LICENSE starts with Keel attribution | `head -5 LICENSE \| grep -q "Keel"` | 0 |
| 2 | LICENSE references MPL-2.0 | `head -5 LICENSE \| grep -q "MPL-2.0\|Mozilla Public License"` | 0 |
| 3 | Full MPL-2.0 text present | `grep -q "Mozilla Public License Version 2.0" LICENSE` | 0 |

## Test mapping

No runtime code — test mapping N/A.

## Invariants to preserve

1. If curl fails, do not leave a broken LICENSE file. Write a valid SPDX reference instead.

## Verification commands

```bash
# AC-3.1
head -5 LICENSE | grep -q "Keel"
# AC-3.2
grep -q "Mozilla Public License Version 2.0" LICENSE
```
