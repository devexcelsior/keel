## Consistency sweep report

### 1. Roadmap-to-step traceability

| Roadmap item | Covered by step | Acceptance criterion / invariant |
|---|---|---|
| Goal: Strip to harness only (packages/ai + packages/agent) | step-1 | AC-1.1: "`ls packages/` shows exactly `ai` and `agent`" |
| Goal: Strip to harness only (root files) | step-1 | AC-1.2: "`ls` at root shows no `scripts/`, `.husky/`, `.pi/`, ..." |
| Goal: Strip to harness only (workflows) | step-1 | AC-1.3-1.4: dead workflows removed |
| Goal: Strip to harness only (ci.yml cleanup) | step-1 | AC-1.5: system deps removed from ci.yml |
| Goal: Strip to harness only (.gitignore cleanup) | step-1 | AC-1.6: dead entries removed from .gitignore |
| Goal: Rewrite root package.json | step-2 | AC-2.1-2.2d: workspaces, scripts, metadata, deps |
| Goal: Clean tsconfig.json | step-2 | AC-2.3: paths for removed packages removed |
| Goal: Clean biome.json | step-2 | AC-2.4: includes for removed packages removed |
| Goal: npm install succeeds | step-2 | AC-2.5: `npm install` completes with exit code 0 |
| Goal: Set MPL-2.0 LICENSE | step-3 | AC-3.1-3.2: LICENSE has Keel header and full MPL-2.0 text |
| Goal: Add MPL-2.0 headers to source | step-4 | AC-4.1-4.4: all files have header, no doubles, build passes, generator emits header |
| Goal: Write harness README | step-5 | AC-5.1-5.4: README mentions Keel, hull/helm, MPL-2.0, no removed packages, under 80 lines |
| Goal: Build and verify | step-6 | AC-6.1-6.4: install, build, test, typecheck |
| Goal: Commit and push | step-7 | AC-7.1-7.4: clean working tree, proper commit message, specific staging, push to origin |
| Invariant: Git history preserved | step-1, step-7 | "Do not run `git filter-branch`" (step-1), "Do not rewrite git history" (step-7) |
| Invariant: No source code changes | step-1, step-2, step-4, step-6 | "Zero source code changes" in multiple steps |
| Invariant: Build toolchain preserved | step-2, step-6 | `tsgo` and `tsx` kept; tsconfig.build.json not modified |
| Invariant: Workspace resolution | step-2, step-6 | `@mariozechner/pi-ai` resolves locally |
| FL-1: Fresh clone npm install | step-2, step-6 | AC-2.5 (install), AC-6.1 (install in verification) |
| FL-2: Build completes | step-6 | AC-6.2 |
| FL-3: Test expectations | step-6 | AC-6.3 |
| FL-4: All files have MPL-2.0 headers | step-4 | AC-4.1, AC-4.4 (generator) |
| FL-5: Hull consumability | step-2, step-6 | Workspace resolution verified by AC-2.5 + AC-6.2 |

**Coverage verdict**: All roadmap requirements, invariants, and feature-level ACs are mapped. No silent drops.

---

### 2. Roadmap decision coverage

| Roadmap decision | Step | Resolution if deferred |
|---|---|---|
| Decision 1: Strip to minimal harness files | step-1 | no deferral — exact KEEP list, rm commands enumerated |
| Decision 2: Rewrite root package.json per SETUP.md §1b | step-2 | no deferral — exact fields, scripts, deps specified |
| Decision 3: Replace MIT LICENSE with MPL-2.0 | step-3 | no deferral — curl URL, header format specified |
| Decision 4: Add MPL-2.0 headers to all source files | step-4 | no deferral — exact header text, bash loop, generator modification specified |
| Decision 5: Write harness README | step-5 | no deferral — required content, length bound specified |

**Coverage verdict**: All 5 roadmap decisions map directly to steps. No deferred decisions propagated.

---

### 3. Internal step consistency — with evidence

**step-1-strip-files**:
  Context (line 9): "The harness layer is only `packages/ai` and `packages/agent`. Everything else must be removed."
  Decision (line 13): "Delete all packages, directories, and files not in the KEEP list"
  Implementation (Files touched): `rm -rf packages/coding-agent packages/tui packages/web-ui`, `rm -rf scripts/ .husky/ .pi/`, etc.
  Verdict: aligned — Context defines the scope, Decision states the action, Implementation lists the exact rm commands.

**step-2-rewrite-config**:
  Context (line 9): "Root config files still reference removed packages. The source of truth is SETUP.md §1b."
  Decision (line 13): "Adopt SETUP.md §1b verbatim for root `package.json`"
  Implementation (Files touched): `package.json`, `tsconfig.json`, `biome.json`, `packages/ai/package.json`, `packages/agent/package.json`
  Verdict: aligned — Context identifies the problem, Decision names the solution (verbatim SETUP.md), Implementation lists the files.

**step-3-set-license**:
  Context (line 9): "The repo currently has an MIT `LICENSE` file."
  Decision (line 13): "Download the MPL-2.0 license text from `https://www.mozilla.org/media/MPL/2.0/index.txt`"
  Implementation (Files touched): `LICENSE`
  Verdict: aligned.

**step-4-add-headers**:
  Context (line 9): "Current ai and agent source files have NO MPL headers. `models.generated.ts` is generated..."
  Decision (line 13): "Find every `.ts` file... prepend the exact header text... Modify `generate-models.ts`"
  Implementation (Files touched): all `.ts` files under `packages/ai` and `packages/agent`, plus `generate-models.ts`
  Verdict: aligned — Context identifies the generated-file problem, Decision includes the generator modification, Implementation lists both.

**step-5-write-readme**:
  Context (line 9): "Current `README.md` describes the full pi monorepo..."
  Decision (line 13): "Overwrite `README.md` with a concise harness README"
  Implementation (Files touched): `README.md`
  Verdict: aligned.

**step-6-build-verify**:
  Context (line 9): "After Steps 1-5, the repo has been stripped..."
  Decision (line 13): "Run `npm install`, `npm run build`, `npm run test`, and `npx tsgo --noEmit`"
  Implementation (Verification commands): listed verbatim
  Verdict: aligned.

**step-7-commit-push**:
  Context (line 9): "After Steps 1-6, all changes are in the working tree."
  Decision (line 13): "Stage changes using specific `git add` commands..."
  Implementation (Files touched): "Git staging of all modified/added/removed files"
  Verdict: aligned — Context notes hundreds of files, Decision requires specific staging per AGENTS.md.

**Conclusion**: All 7 step docs show alignment between Context, Decision, and Implementation. No contradictions found.

---

### 3b. Sketch-vs-constraint mechanical validation

These steps are structural (file deletion, config rewriting, text prepending, verification). They do not contain defensive-code constraints (try/catch, null checks, type guards, listener cleanup, error fallbacks) in the sense of executable TypeScript/JavaScript code with OR-clause escape hatches. The mechanical constraint checks are post-implementation verification commands (file existence, grep patterns, build success), not defensive-code guards.

Per the doctrine: "What does NOT require mechanical check: architectural decisions, UX requirements, naming conventions, design rationale, performance budgets without numeric threshold." The checks in these steps are verification commands that validate the desired state was achieved — they are not defensive-code constraints.

However, the mechanical checks were validated for syntax correctness:
- Check 1 (step-1): `test "$(ls packages/ | sort | tr '\n' ' ' | xargs)" = "agent ai"` — valid bash; `ls | sort` produces "ai agent" alphabetically, so the comparison string is correct.
- Check 5 (step-1): `grep -E` pattern for system deps — valid regex, tested against known ci.yml content.
- Check 3 (step-2): `grep '"name":' package.json | grep -q '"keel"'` — valid grep pipeline.
- Check 10 (step-2): `npm install` — standard npm command.
- Check 4 (step-4): `grep -q` on `models.generated.ts` post-build — valid, depends on build completing first.

All checks use standard Unix utilities (test, grep, wc, sed) with no `awk \b` pitfalls. Syntax validated by inspection.

**No sketch-to-code extraction is applicable** because the "sketch" for these steps is bash commands, not TypeScript/JavaScript that can be typechecked. The bash commands will be executed directly during `/implement` and verified during `/verify`.

---

### 4. Generalized deferred-decision scan

Scanning all 7 step docs for "either X or Y works", "X is fine; Y is also fine", "could be A or B", "inside or outside [...] either way", "may be placed [...] or [...]" constructions:

- **step-1**: "The harness philosophy is minimal. Dead code accumulates." — no deferral.
- **step-2**: "A complete rewrite per SETUP.md §1b is cleaner." — picks one option decisively.
- **step-3**: "If curl fails, fall back to writing a short SPDX header." — this is a contingency, not a deferral. The primary path is curl; fallback is explicit.
- **step-4**: "Bash loop with sed is simpler." — picks one option.
- **step-5**: "Target length ~40 lines... with a generous upper bound of 80 lines." — a range, not a deferral between equally valid options. The upper bound is a safety cap, not an undecided choice.
- **step-6**: "`npx tsgo --noEmit` (or `npx tsc --noEmit` if `tsgo` is unavailable)." — contingency for tool availability, not deferral.
- **step-7**: "A single well-described commit is sufficient." — picks one option.

**Result**: No deferred-decision constructions found.

---

### 5. Step-list-shape match

| Roadmap step | Produced step | Notes |
|---|---|---|
| Roadmap Step 1: Strip non-harness files and packages | step-1-strip-files | matches 1:1 |
| Roadmap Step 2: Clean root configuration files | step-2-rewrite-config | matches 1:1 |
| Roadmap Step 3: Set MPL-2.0 LICENSE | step-3-set-license | matches 1:1 |
| Roadmap Step 4: Add MPL-2.0 headers to harness source | step-4-add-headers | matches 1:1 |
| Roadmap Step 5: Write harness README | step-5-write-readme | matches 1:1 |
| Roadmap Step 6: Build and verify | step-6-build-verify | matches 1:1 |
| Roadmap Step 7: Commit and push | step-7-commit-push | matches 1:1 |

**Result**: Step count matches (7 roadmap steps = 7 produced steps). No merges or splits.

---

### 6. File-level conflict check

| File | Modified by steps | Conflict? |
|---|---|---|
| `packages/coding-agent` | step-1 (rm) | only step-1 |
| `packages/tui` | step-1 (rm) | only step-1 |
| `packages/web-ui` | step-1 (rm) | only step-1 |
| `scripts/` | step-1 (rm) | only step-1 |
| `.husky/` | step-1 (rm) | only step-1 |
| `.pi/` | step-1 (rm) | only step-1 |
| `AGENTS.md` | step-1 (rm) | only step-1 |
| `CONTRIBUTING.md` | step-1 (rm) | only step-1 |
| `pi-test.ps1` | step-1 (rm) | only step-1 |
| `pi-test.sh` | step-1 (rm) | only step-1 |
| `test.sh` | step-1 (rm) | only step-1 |
| `.github/workflows/build-binaries.yml` | step-1 (rm) | only step-1 |
| `.github/workflows/openclaw-gate.yml` | step-1 (rm) | only step-1 |
| `.github/workflows/issue-gate.yml` | step-1 (rm) | only step-1 |
| `.github/workflows/pr-gate.yml` | step-1 (rm) | only step-1 |
| `.github/workflows/approve-contributor.yml` | step-1 (rm) | only step-1 |
| `.github/workflows/ci.yml` | step-1 (edit) | only step-1 |
| `.gitignore` | step-1 (edit) | only step-1 |
| `package.json` | step-2 (rewrite) | only step-2 |
| `tsconfig.json` | step-2 (edit) | only step-2 |
| `biome.json` | step-2 (edit) | only step-2 |
| `packages/ai/package.json` | step-2 (edit license field) | only step-2 |
| `packages/agent/package.json` | step-2 (edit license field) | only step-2 |
| `LICENSE` | step-3 (overwrite) | only step-3 |
| `packages/ai/src/**/*.ts` | step-4 (prepend header) | only step-4 |
| `packages/ai/test/**/*.ts` | step-4 (prepend header) | only step-4 |
| `packages/agent/src/**/*.ts` | step-4 (prepend header) | only step-4 |
| `packages/agent/test/**/*.ts` | step-4 (prepend header) | only step-4 |
| `packages/ai/scripts/generate-models.ts` | step-4 (edit template) | only step-4 |
| `README.md` | step-5 (overwrite) | only step-5 |
| `packages/ai/src/models.generated.ts` | step-6 (regenerated) | step-4 adds header manually, step-6 regenerates it. The generator modification in step-4 ensures the regenerated file has the header. No conflict: step-4 modifies the generator template, step-6 runs the generator. |

**Result**: No file is modified by two steps with incompatible changes. `models.generated.ts` is handled by generator modification in step-4, so step-6's regeneration is consistent.

---

### 7. Test mapping per AC

All 7 steps are structural/config-only (file deletion, config rewriting, text prepending, verification). None ship new runtime code. Per §2 rule 8 and Cross-cutting principles → Testing discipline, test mapping sections are included with explicit "No runtime code — test mapping N/A" justifications.

| Step | Test mapping status |
|---|---|
| step-1 | N/A — no runtime code |
| step-2 | N/A — no runtime code |
| step-3 | N/A — no runtime code |
| step-4 | N/A — comment additions only |
| step-5 | N/A — no runtime code |
| step-6 | N/A — verification step |
| step-7 | N/A — no runtime code |

**Result**: All runtime-code steps have test mapping (none exist). All config-only steps correctly omit test mapping with justification. No unmapped ACs.

---

### Final verdict

- Roadmap requirements with no step coverage: **none**
- Roadmap decisions with no step implementation: **none**
- Roadmap deferrals propagated into step docs: **none**
- Step doc internal consistency evidence: **provided above — all 7 steps aligned, no contradictions**
- Deferred-decision constructions found: **none**
- Step-list-shape deviations from roadmap: **matches 1:1, no deviations**
- Files modified by multiple steps with potential conflicts: **none**
- Step docs missing test mapping (per §2 rule 8): **none — all config-only steps have explicit N/A justifications**
- ACs unmapped to specific tests: **none — no runtime code, no tests needed**

**Consistency sweep passes. Step docs are ready to ship.**
