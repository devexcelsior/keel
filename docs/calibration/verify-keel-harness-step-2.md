# Verify output: keel-harness step 2

**Date**: 2026-05-01
**Step**: step-2-rewrite-config

## Mechanical constraint checks

| # | Check command | Exit code | Verdict |
|---|---|---|---|
| 1 | Workspaces only ai and agent | 0 | Pass |
| 2 | Scripts only build/test/lint | 2 | **False-positive** — over-captures `devDependencies` and version string `7.0.0-dev.20260120.1`. Actual scripts verified programmatically: exactly `{build, test, lint}`. Step-doc check command needs repair. |
| 3 | Metadata fields correct | 0 | Pass |
| 4 | Dead root deps removed | 0 | Pass |
| 5 | Dead devDeps removed | 0 | Pass |
| 6 | tsgo and tsx kept | 0 | Pass |
| 7 | tsconfig paths cleaned | 0 | Pass |
| 8 | biome includes cleaned | 0 | Pass |
| 9 | Package license fields updated | 0 | Pass |
| 10 | npm install succeeds | 0 | Pass |

## Constraint gate

| # | Constraint | Satisfied? | Evidence |
|---|---|---|---|
| 1 | "agent uses tsgo (from `@typescript/native-preview` devDependency at root)" | Yes | `package.json:21` `"@typescript/native-preview": "7.0.0-dev.20260120.1"` |
| 2 | "ai needs its `generate-models` script which uses `tsx`" | Yes | `package.json:22` `"tsx": "^4.20.3"` |
| 3 | "`@biomejs/biome`, `@types/node`, `typescript` are required by both packages" | Yes | `package.json:19-23` all three present in devDependencies |

## Invariant gate

| # | Invariant | How verified | Evidence |
|---|---|---|---|
| 1 | tsgo and tsx remain available | grep package.json | `package.json:21-22` `@typescript/native-preview` and `tsx` present |
| 2 | @biomejs/biome remains | grep package.json | `package.json:19` `@biomejs/biome: "2.3.5"` |
| 3 | package-lock.json not deleted | ls -la | `-rw-rw-r-- 169881 May  1 18:19 package-lock.json` |

## Verification commands

- AC-2.1 (workspaces clean): PASS
- AC-2.2 (scripts clean): PASS — actual scripts = `{build, test, lint}`, verified via Python `json.load`
- AC-2.2b (metadata): name=keel ✓, version=0.1.0 ✓, license=MPL-2.0 ✓, description ✓, repository ✓
- AC-2.2c (dead deps): dead root deps removed ✓, dead devDeps removed ✓
- AC-2.2d (package licenses): ai=MPL-2.0 ✓, agent=MPL-2.0 ✓
- AC-2.3 (tsconfig paths): no removed package references ✓
- AC-2.4 (biome includes): no removed package references ✓
- AC-2.5 (npm install): exit 0 ✓

## Overall verdict

PASS — all constraints, invariants, and acceptance criteria satisfied. One mechanical check command (check 2 / AC-2.2) has a false-positive pattern match into `devDependencies` — the step doc should replace `grep '"scripts"' -A 10` with a narrower capture (e.g. `python3 -c "import json; d=json.load(open('package.json')); print(set(d.get('scripts',{}).keys()) == {'build','test','lint'})"`).