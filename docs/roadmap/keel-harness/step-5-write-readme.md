# Step 5: Write harness README

Replace `README.md` with minimal Keel harness README.

---

## Context

Current `README.md` describes the full pi monorepo with 5 packages, TUI features, web-ui, and CLI usage. After stripping, this is misleading. A new README must explain what Keel is, reference the three-repo architecture (keel/hull/helm), and mention MPL-2.0.

## Decision

Overwrite `README.md` with a concise harness README. Target length ~40 lines (per SETUP.md §1e) with a generous upper bound of 80 lines.

Required content:
- First heading contains "Keel"
- References `devexcelsior/hull` and `devexcelsior/helm`
- Mentions MPL-2.0 license
- Does not reference `coding-agent`, `tui`, or `web-ui`
- Communicates the "can't be removed" philosophy briefly

## Constraints

- Must not exceed 80 lines (generous upper bound; SETUP.md §1e is ~40 lines).
- Must not describe removed packages.

## Second-order effects

- Sets the tone for the repo. First impression matters for licensing intent.
- Links to hull and helm establish the three-repo architecture.

## Failure modes

- *Deceptively obvious wrong answer*: "Keep the original README and add a note." Wrong: The original describes removed packages and would confuse readers.
- Too verbose and preachy. Fix: keep it practical, under 80 lines.

## Alternatives considered

- Auto-generate from `package.json` metadata. **Rejected**: README needs architecture explanation (keel/hull/helm) not in package.json.
- Use SETUP.md §1e verbatim. **Rejected**: Good starting point but can be tightened.

## Self-consistency check

No contradictions. README is orthogonal to code and license decisions.

## Files touched

- `README.md` — overwrite

## Acceptance criteria

- AC-5.1: `README.md` contains "Keel" in the first heading
- AC-5.2: `README.md` references MPL-2.0 and links to hull/helm repos
- AC-5.3: `README.md` does not contain references to `coding-agent`, `tui`, or `web-ui`
- AC-5.4: `README.md` does not exceed 80 lines

## Mechanical constraint checks

| # | Constraint | Verification command | Expected exit |
|---|---|---|---|
| 1 | First heading mentions Keel | `head -1 README.md \| grep -q "Keel"` | 0 |
| 2 | References hull and helm | `grep -c "hull\|helm" README.md` output is >= 1 | 0 |
| 3 | No removed package references | `grep -c "coding-agent\|tui\|web-ui" README.md` output is 0 | 0 |
| 4 | Line count under 80 | `test "$(wc -l < README.md)" -le 80` | 0 |

## Test mapping

No runtime code — test mapping N/A.

## Invariants to preserve

1. `README.md` must exist (GitHub renders it as the repo landing page).

## Verification commands

```bash
# AC-5.1
head -1 README.md | grep -q "Keel"
# AC-5.2
grep -q "hull\|helm" README.md
# AC-5.3
! grep -q "coding-agent\|tui\|web-ui" README.md
# AC-5.4
test "$(wc -l < README.md)" -le 80
```
