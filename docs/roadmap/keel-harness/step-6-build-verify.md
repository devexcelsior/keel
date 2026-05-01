# Step 6: Build and verify

Install dependencies, build both packages, run tests, and typecheck.

---

## Context

After Steps 1-5, the repo has been stripped to harness-only packages, config files rewritten, MPL-2.0 LICENSE set, headers added, and README updated. This step verifies everything works: `npm install` resolves dependencies, `npm run build` compiles both packages, tests run, and TypeScript typechecks cleanly.

## Decision

Run `npm install`, `npm run build`, `npm run test`, and `npx tsgo --noEmit` (or `tsc --noEmit` if `tsgo` is unavailable). Document any pre-existing test failures in `packages/agent` without blocking verification.

## Constraints

- `npm install` must complete with exit code 0.
- `npm run build` must complete with exit code 0 (both `packages/ai` and `packages/agent`).
- `packages/ai` tests must pass (exit 0).
- `packages/agent` tests may have pre-existing failures (e.g., `ERR_MODULE_NOT_FOUND` from unresolved workspace deps); these are documented but do not block verification.
- TypeScript must report zero errors (`tsgo --noEmit` or equivalent).

## Second-order effects

- `npm run build` in `packages/ai` regenerates `models.generated.ts` — this verifies the generator template change from Step 4 produces a correctly-headered file.
- Build success confirms workspace resolution works (`@mariozechner/pi-ai` resolves locally for `agent`).

## Failure modes

- *Deceptively obvious wrong answer*: "If tests fail, fix the source code." Wrong: "No source code changes" is an invariant (only license headers and `generate-models.ts` template string). Pre-existing failures must be documented, not fixed.
- `npm run build` fails because `package.json` scripts reference removed packages. Fix: must have been caught in Step 2 verification.
- `tsgo` is not available (e.g., `npm install` didn't install it). Fix: `tsgo` is from `@typescript/native-preview` which is a devDependency; if missing, use `npx tsc --noEmit` as fallback.

## Alternatives considered

- Fix pre-existing `agent` test failures. **Rejected**: Out of scope for this structural feature. Agent test failures are a separate issue.
- Skip tests entirely. **Rejected**: Need to verify `packages/ai` tests pass and document `agent` state.

## Self-consistency check

Consistent with all prior steps. Build is the natural verification after configuration and header changes. The relaxed `agent` test requirement is consistent with the "no source code changes" invariant.

## Files touched

- None (verification step)
- Potentially `packages/ai/src/models.generated.ts` (regenerated during build — header should be present per Step 4)

## Acceptance criteria

- AC-6.1: `npm install` completes with exit code 0
- AC-6.2: `npm run build` completes with exit code 0 (both ai and agent build successfully)
- AC-6.3: `npm run test` completes; `packages/ai` tests pass (exit 0). `packages/agent` pre-existing failures are documented
- AC-6.4: `npx tsgo --noEmit` reports zero TypeScript errors (or `npx tsc --noEmit` fallback)

## Mechanical constraint checks

| # | Constraint | Verification command | Expected exit |
|---|---|---|---|
| 1 | npm install succeeds | `npm install` | 0 |
| 2 | Build succeeds | `npm run build` | 0 |
| 3 | ai tests pass | `cd packages/ai && npm run test` | 0 |
| 4 | TypeScript clean | `npx tsgo --noEmit 2>&1 \| grep -c "error TS" \| grep -q '^0$'` (or `npx tsc --noEmit` fallback) | 0 |
| 5 | Generated file has header | `grep -q "This Source Code Form is subject to the terms of the Mozilla Public" packages/ai/src/models.generated.ts` | 0 |

## Test mapping

No runtime code changes — test mapping N/A. Verification relies on existing test suites in `packages/ai` and `packages/agent`.

## Invariants to preserve

1. No source code changes beyond license headers and `generate-models.ts` template string.
2. `packages/ai/tsconfig.build.json` and `packages/agent/tsconfig.build.json` must not be modified.

## Verification commands

```bash
# AC-6.1
npm install
# AC-6.2
npm run build
# AC-6.3
cd packages/ai && npm run test && cd ../..
cd packages/agent && npm run test 2>&1 | tee agent-test.log
# Document exit code in step output; non-zero is acceptable if pre-existing
cd ../..
# AC-6.4
npx tsgo --noEmit 2>&1 | grep -c "error TS" | grep -q '^0$' || npx tsc --noEmit
# AC-6.5 (post-build header verification)
grep -q "This Source Code Form is subject to the terms of the Mozilla Public" packages/ai/src/models.generated.ts
```
