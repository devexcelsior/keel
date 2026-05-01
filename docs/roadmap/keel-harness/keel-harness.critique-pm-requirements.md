---
reviewer: Moonshot Kimi K2.6 thinking
perspective: PM checking requirements coverage and acceptance criteria
plan: docs/roadmap/keel-harness/keel-harness.md
date: 2026-05-01
---

# Critique: keel-harness — pm-requirements

## Pass 1 — Six-field scoring per decision

### Decision 1: Strip to minimal harness files

| Field | Score | Evidence |
|---|---|---|
| Decision — clear? | ✓ | Explicit KEEP list enumerates every file/directory that survives. Quote: "Remove everything except packages/ai, packages/agent, .git, .gitignore, .github, README.md, LICENSE, package.json, package-lock.json, tsconfig.base.json, tsconfig.json, biome.json" |
| Constraints — specific, cited, complete? | ⚠ | "packages/ai and packages/agent must remain buildable after stripping" — but "buildable" is a technical constraint, not a user-observable requirement. The PM would ask: buildable by whom? With what command? Under what conditions? Step 6 eventually answers this, but the constraint itself is a hand-wave. |
| Second-order effects? | ✓ | Names downstream config files that need rewriting (package.json, tsconfig.json, biome.json, CI workflows). Good cross-referencing to Decisions 2-4. |
| Failure modes? | ✓ | Two named, both realistic: keeping non-harness artifacts ("they're useful"), and lock file breakage. |
| Alternatives? | ⚠ | "Keep scripts/ with harness-only scripts" rejected as "out of scope." The planner defined the scope and then used it to reject the alternative. There's a second, substantive reason ("the harness has no CLI entry point, no binaries to build, no profiling targets") which saves it from circularity. But from a PM perspective: if rewriting scripts is genuinely out of scope, why isn't rewriting package.json (Decision 2) also out of scope? Both are root config changes required by the strip. The boundary is inconsistent. |
| Self-consistency? | ✓ | Orthogonal dimensions claimed — correct: file set, license, headers, README are independent. |

**Overall**: The KEEP list is precise. The "buildable" constraint is vague at this level but resolved by Step 6. The alternatives rejection is borderline circular — the PM should verify the scope boundary is consistently applied.

---

### Decision 2: Rewrite root package.json for harness-only workspaces

| Field | Score | Evidence |
|---|---|---|
| Decision — clear? | ❌ | The decision states "Simplify scripts to npm run build --workspaces, npm run test --workspaces" but does not enumerate which scripts to keep, which to remove, or what positive content they should have. This is not a decision — it's an aspiration. Compare to SETUP.md §1b which specifies a complete package.json rewrite with exact name, version, description, repository, license, and exactly 3 scripts (build, test, lint). The plan deviates from SETUP.md without acknowledging the deviation. |
| Constraints — specific, cited, complete? | ❌ | Cites `tsgo` and `tsx` as must-stay devDependencies. Misses: `@mariozechner/jiti` and `get-east-asian-width` (root dependencies, unused by ai or agent — verified `grep -rn 'jiti\|get-east-asian-width' packages/ai/src/ packages/agent/src/` returns empty), `husky` (used by `.husky/` removed in Step 1), `concurrently` (used by `dev` script referencing all 5 packages), `shx` (used by version scripts). None are analyzed for removal. |
| Second-order effects? | ⚠ | Notes npm workspace build ordering, the `check` and `dev` scripts, and `build` script. But misses: the `prepublishOnly`/`publish`/`publish:dry` scripts, `version:*` scripts, `release:*` scripts, and `prepare: husky` — all reference removed packages or scripts/. |
| Failure modes? | ✓ | Names "use --workspaces everywhere" pitfall. But misses a more fundamental one: if the package.json rewrite doesn't match SETUP.md §1b (name: "keel", version: "0.1.0", license: "MPL-2.0", description, repository), the harness won't match what hull expects to consume. |
| Alternatives? | ⚠ | Two alternatives considered (manual cd chain, keep all scripts). But neither addresses the SETUP.md-specified alternative: a complete rewrite with specific fields. The planner chose a different approach than SETUP.md without acknowledging it as an alternative. |
| Self-consistency? | ⚠ | Claims consistency with Decision 1 ("if we strip packages, we must strip their scripts too"). But Decision 5 explicitly acknowledges and rejects SETUP.md's README content, while Decision 2 silently deviates from SETUP.md's package.json rewrite. This is an inconsistency in traceability discipline — the planner tracks deviations from SETUP.md in one decision but not another. |

**Overall**: This is the weakest decision in the plan and the highest-severity PM finding. SETUP.md §1b specifies a complete rewrite with specific fields; the plan provides only negative constraints. The implementer will make field-level decisions (name, version, license, description, repository, script list) that SETUP.md already decided. This is not "underspecification" — it's a deviation from the source of truth that the plan doesn't acknowledge.

---

### Decision 3: Replace MIT LICENSE with MPL-2.0

| Field | Score | Evidence |
|---|---|---|
| Decision — clear? | ✓ | "Download MPL-2.0 text from Mozilla, prepend Keel attribution header." Clear action. |
| Constraints — specific, cited, complete? | ⚠ | AC-3.1: "LICENSE starts with 'Keel — https://github.com/devexcelsior/keel' followed by 'Mozilla Public License 2.0'." Good. AC-3.3: "package.json license field reads 'MPL-2.0'." But Step 3 lists only `LICENSE` as a touched file. Root `package.json` has no `license` field at all; `packages/ai/package.json` and `packages/agent/package.json` both have `"license": "MIT"`. AC-3.3 won't pass unless the step touches these files, but they're not listed. The senior-engineer critique (R3) already caught this — unresolved. |
| Second-order effects? | ✓ | Headers (Decision 4), README (Decision 5), hull build script preservation. |
| Failure modes? | ✓ | Two named: (1) "Just write SPDX identifier and skip the file" and (2) "curl fails." Both realistic. |
| Alternatives? | ✓ | MIT (rejected: proprietary enclosure), AGPL (rejected: viral scope). Both reasoned from SETUP.md requirements — genuinely independent constraints. |
| Self-consistency? | ✓ | Independent of file strip strategy. |

**Overall**: The AC-3.3 touch-list mismatch is a process gap carried forward from the prior critique. It should have been resolved before this pass.

---

### Decision 4: Add MPL-2.0 headers to all harness source files

| Field | Score | Evidence |
|---|---|---|
| Decision — clear? | ⚠ | "Find every .ts, .tsx, .js file ... prepend MPL-2.0 header." The exact header text is unspecified. SETUP.md §1d specifies the exact header: `/* This Source Code Form is subject to the terms of the Mozilla Public\n * License, v. 2.0. If a copy of the MPL was not distributed with this\n * file, You can obtain one at https://mozilla.org/MPL/2.0/. */`. The plan's grep patterns reference substrings of this header, so the implementer can infer it. But from a PM perspective: an acceptance criterion should not require the implementer to infer the target state from verification commands. The desired state (the header text) should be stated directly. |
| Constraints — specific, cited, complete? | ✓ | Three clear constraints: no double-headers, no binary corruption, no encoding breakage. Implementation-level handling described for each. |
| Second-order effects? | ❌ | The senior-engineer critique (R1) caught that `packages/ai/src/models.generated.ts` is generated by `npm run build` (via `packages/ai/scripts/generate-models.ts`) and won't inherit a header. But there's a MORE fundamental sequencing issue neither critique has identified: SETUP.md's 1d header loop includes all `.ts` files, so `models.generated.ts` WOULD get a header initially. But then Step 6 runs `npm run build`, which regenerates `models.generated.ts`, **wiping the header**. The header must be added AFTER `npm run build` (which puts an uncommitted header-only change in a generated file), OR the generator must be modified to emit the header. Neither plan addresses this sequencing dependency. |
| Failure modes? | ⚠ | Names sed corruption and double-headering. Misses the sequencing issue above and a related edge case: if `npm run build` in Step 6 regenerates `models.generated.ts` with a different model list (because upstream model definitions changed between strip and build), the post-build header insertion creates a content change that should be committed. The plan's Step 7 just commits everything — but the PM should flag that a generated file with both model changes AND header insertion conflates two separate changes in one commit. |
| Alternatives? | ✓ | Two: entry-points only (rejected: legal defensibility), npm package (rejected: dependency bloat). Both with substantive reasons. |
| Self-consistency? | ✓ | Consistent with Decision 3 — headers are the mechanical follow-up to MPL-2.0 adoption. |

**Overall**: The header text gap is minor (SETUP.md resolves it). The `models.generated.ts` sequencing issue is the real finding — the prior critique identified the static gap (file lacks header) but missed the dynamic one (build regenerates it).

---

### Decision 5: Write harness README.md

| Field | Score | Evidence |
|---|---|---|
| Decision — clear? | ✓ | "Replace pi-mono README with minimal Keel harness README." |
| Constraints — specific, cited, complete? | ✓ | Must reference hull/helm, communicate philosophy, must not describe removed packages. However: SETUP.md §1e provides exact README content. The plan explicitly acknowledges and rejects this ("Use SETUP.md §1e verbatim. Rejected: It's a good starting point but should be tightened for brevity"). This is a legitimate deviation with acknowledgment — good traceability. |
| Second-order effects? | ✓ | "Sets the tone for the repo. Links to hull and helm establish the three-repo architecture." |
| Failure modes? | ✓ | Two named: "Keep original README" and "Too verbose and preachy." |
| Alternatives? | ✓ | Auto-generate (rejected: needs architecture explanation), SETUP.md verbatim (rejected: too long). Both with substantive reasons. |
| Self-consistency? | ⚠ | Decision 5 explicitly acknowledges and rejects SETUP.md content. Decision 2 silently deviates from SETUP.md content. This is inconsistent traceability discipline. From a PM perspective: either all SETUP.md deviations should be explicit or none should. |

**Overall**: Well-specified but the traceability inconsistency with Decision 2 is noteworthy.

---

## Pass 2 — Discipline-axis findings

### 1. Deferred decisions

**D-PM-1: Root package.json is rewritten differently than SETUP.md specifies (Critical)**

SETUP.md §1b specifies a complete package.json rewrite:

```json
{
  "name": "keel",
  "version": "0.1.0",
  "private": true,
  "description": "The harness coding agents are built on. Can't be removed.",
  "repository": "https://github.com/devexcelsior/keel",
  "license": "MPL-2.0",
  "workspaces": ["packages/ai", "packages/agent"],
  "scripts": {
    "build": "npm run build --workspaces",
    "test": "npm run test --workspaces",
    "lint": "npm run lint --workspaces"
  }
}
```

The plan's Decision 2 says "Simplify scripts to npm run build --workspaces, npm run test --workspaces" but never enumerates:
- The `name` field (SETUP.md says `"keel"`, current is `"pi-monorepo"`)
- The `version` field (SETUP.md says `"0.1.0"`, current is `"0.0.3"`)
- The `description` field (SETUP.md provides one, plan never mentions it)
- The `repository` field (SETUP.md provides one, plan never mentions it)
- The `license` field (SETUP.md says `"MPL-2.0"`, plan only addresses this in Decision 3/Step 3)
- The `lint` script (SETUP.md includes it, plan never mentions it)
- Which devDependencies to remove

The senior-engineer critique (R2) flagged scripts as underspecified, but the PM finding goes further: the plan isn't just underspecified — it's on a different trajectory than SETUP.md. The implementer cannot reconstruct SETUP.md's package.json from the plan alone.

**D-PM-2: models.generated.ts header sequencing is unaddressed**

Step 4 adds MPL-2.0 headers to all `.ts` files. Step 6 runs `npm run build`, which executes `packages/ai/scripts/generate-models.ts`, regenerating `packages/ai/src/models.generated.ts` without an MPL-2.0 header. The header is added in Step 4 and wiped in Step 6. Resolution options:
- (a) Move header insertion to AFTER build (Step 4.5 or post-Step-6), committing a generated file change
- (b) Modify `generate-models.ts` to emit the MPL-2.0 header in its output
- (c) Accept that `models.generated.ts` won't have a header (contrary to Decision 4's "every file" principle)

None of these is in the plan. The senior-engineer critique (R1) caught that the file lacks a header statically but missed the dynamic wipe.

**D-PM-3: Contribution gating workflows are unaddressed**

`.github/workflows/` contains `issue-gate.yml`, `pr-gate.yml`, `approve-contributor.yml`, and `openclaw-gate.yml`. These implement pi-mono's contribution gating policy. For the keel harness, does this gating still apply? The plan never decides. The senior-engineer critique (R4) flagged `openclaw-gate.yml` but not the full set of gating workflows.

**D-PM-4: DevDependencies cleanup is deferred**

Root `package.json` devDependencies include `husky` (used by removed `.husky/`), `concurrently` (used by scripts referencing removed packages), `shx` (used by version scripts referencing removed `scripts/`). Root dependencies include `@mariozechner/jiti` and `get-east-asian-width` (unused by ai or agent). The plan's Decision 2 mentions `tsgo` and `tsx` must stay but never lists what to remove. This is a completeness gap — the implementer must audit 8 dependencies themselves.

**D-PM-5: .gitignore cleanup is deferred**

`.gitignore` contains dead entries for removed packages: `packages/coding-agent/binaries/`, `tui-debug.log`, `.pi/`, `plans/`, `pi-*.html`, `compaction-results/`, `.opencode/`, `.pi/hf-sessions/`, `.pi/hf-sessions-backup/`, `SETUP.md`. They don't cause failures but will confuse future contributors. The plan doesn't address them. The senior-engineer critique (R5) already flagged this — unresolved.

---

### 2. Unjustified specifics

**U-PM-1: README line limit of 60 has no justification (same as prior U-1)**

AC-5.4: `wc -l README.md | awk '{print $1}' | xargs test -le 60`. SETUP.md's README is ~40 lines, so 60 is generous. But without justification for the exact number, it reads as a guess that won't survive contact with the actual content. Either remove the numeric constraint or cite the reason (e.g., "SETUP.md's README is 40 lines; 60 gives headroom").

**U-PM-2: MPL-2.0 curl URL references a content hash**

The plan cites `https://www.mozilla.org/media/MPL/2.0/index.815ca599c9df.txt`. The `815ca599c9df` is a content hash that could change if Mozilla updates the page. The canonical URL `https://www.mozilla.org/media/MPL/2.0/index.txt` is more stable (and is what SETUP.md uses — `curl -sL https://www.mozilla.org/media/MPL/2.0/index.815ca599c9df.txt`). Wait — SETUP.md also uses the hashed URL. So both plan and SETUP.md have this. Still, it's brittle. Justify the hashed URL or switch to the canonical one.

---

### 3. Circular rejection reasoning

**C-PM-1: Decision 1 — "Keep scripts/ ... Rejected: Rewriting them for the harness is out of scope"**

The planner defined the scope (harness only = ai + agent + config files) and then used it to reject rewriting scripts. However, there's a second, non-circular reason: "the harness has no CLI entry point, no binaries to build, no profiling targets." The substantive reason saves it from pure circularity, but the phrase "out of scope" is a smell. From a PM perspective: why is rewriting scripts "out of scope" when rewriting package.json (also a root file full of references to removed packages) IS in scope? The boundary is arbitrary. Either both should be in scope (rewrite scripts/ for harness tools) or the rejection should drop "out of scope" and rely solely on the substantive reason.

---

### 4. Missing decisions on cross-cutting concerns

The plan's cross-cutting concerns table marks accessibility, error handling, observability, deployment, security, and performance as N/A — reasonable for a structural-only change. But the following are missing:

**M-PM-1: Test pass/fail expectations**

The plan (AC-6.3) requires `npm run test` exit code 0. SETUP.md §1f explicitly expects tests may not pass: `npm test 2>&1 || echo "Tests not fully configured — expected"`. Current state (verified): `packages/agent` tests fail with `ERR_MODULE_NOT_FOUND` (unresolved workspace dependency). The plan's strict exit-code requirement may be unachievable without fixing pre-existing test failures — which falls outside "structural reorganization only, no source code changes."

The plan must decide: (a) fix pre-existing test failures (expands scope), (b) relax the test AC to match SETUP.md's "expected" pattern, or (c) verify why agent tests fail and document it.

**M-PM-2: Feature-level acceptance criteria**

The plan defines step-level ACs but no feature-level success criteria. A PM would ask:
- What does "the harness is ready" look like?
- Can hull consume this harness? (The ultimate consumer test)
- Can a fresh clone → `npm install` → `npm run build` → `npm test` succeed end-to-end?

Step 6 partially covers this with build/install/test verification, but it's not framed as feature-level criteria and doesn't include the hull-consumability test.

**M-PM-3: Commit message conformance**

SETUP.md §1g specifies an exact commit message. The plan's AC-7.2 only checks for the presence of "harness" and "MPL-2.0" in the message via `git log -1 --format="%s" | grep -qi "harness\|MPL-2.0"`. SETUP.md's message is more specific ("initialize: Keel harness — MPL-2.0" with a body). The plan's AC is looser — should it match SETUP.md exactly, or is the looser check intentional?

**M-PM-4: Staging discipline (git add -A vs specific files)**

SETUP.md §1g uses `git add -A`. The plan's AGENTS.md (harness-level instructions) and this repo's AGENTS.md both forbid `git add -A` and require specific file staging. These conflict. The plan doesn't decide which policy applies. From a PM perspective: when the source of truth (SETUP.md) conflicts with project guidelines (AGENTS.md), the plan should resolve the conflict, not leave it for the implementer.

**M-PM-5: No user persona or success scenario**

The plan describes technical changes but never describes the end user or the success scenario. Who consumes this harness? Answer (from SETUP.md): hull, the build pipeline. What does success look like? Answer: hull can `npm install` the keel harness and build features on top. The plan should state this explicitly — it's the "why" that justifies every decision.

---

### 5. OR clauses in defensive-code constraints

No instances found. The plan is structural (file removal, config editing, text prepending). No try/catch, null check, type guard, or listener cleanup constraints exist to check. Same conclusion as the prior critique.

---

## Requirements traceability: SETUP.md §1 vs plan

| SETUP.md § | Requirement | Plan coverage | Gap? |
|---|---|---|---|
| 1a | Strip to harness only (shell loop, ls verify) | Step 1 + AC-1.1-1.4 | ✅ |
| 1b | Complete package.json rewrite (name, version, description, repository, license, 3 scripts) | Decision 2 + Step 2 — only negative constraints, no positive specification | ❌ Critical: deviates from SETUP.md without acknowledgment |
| 1c | LICENSE MPL-2.0 (curl + prepend header) | Decision 3 + Step 3 | ✅ (AC-3.3 touch-list mismatch noted) |
| 1d | MPL-2.0 headers (find + grep + sed, exact header text) | Decision 4 + Step 4 — header text unspecified | ⚠ Minor: header text from SETUP.md resolves it |
| 1e | README (cat heredoc, specific content) | Decision 5 + Step 5 — explicit deviation acknowledged | ✅ |
| 1f | Build and verify (npm install, build, test with failure tolerance) | Step 6 — AC-6.3 requires exit 0, SETUP.md expects failures | ❌ Conflict: test exit code expectation |
| 1g | Commit and push (git add -A, specific commit message) | Step 7 — looser message check, AGENTS.md forbids -A | ⚠ Conflict: staging discipline |

**Two critical traceability gaps** (1b and 1f) where the plan either deviates from or directly conflicts with SETUP.md. One minor gap (1g) where two policies collide.

---

## Acceptance criteria quality assessment

| Step | ACs | Quality issues |
|---|---|---|
| 1 | 4 | AC-1.4 (`git status --short` lists only deletions) conflates the expected state with the verification mechanism. A better criterion: "No files are modified; only files not in the KEEP list are deleted." |
| 2 | 5 | All ACs use negative checks (grep -c → must be 0). Zero positive criteria for what the new package.json SHOULD contain. This is the root cause of the SETUP.md deviation — you can't verify the right state if you only verify the wrong state is absent. |
| 3 | 3 | AC-3.3 targets files not in Step 3's touch list (carried forward from prior critique R3). |
| 4 | 3 | AC-4.2 (no double headers) is checked by the mechanical constraint bash loop, but the loop iterates over all `.ts` files and exits on first double — it won't report all doubles. Minor. |
| 5 | 4 | AC-5.4 (≤60 lines) is arbitrary. |
| 6 | 4 | AC-6.3 requires test exit 0 — conflicts with SETUP.md. AC-6.1 and 6.2 are verification commands masquerading as criteria. |
| 7 | 4 | AC-7.4 (`git ls-remote origin main | grep -q "$(git rev-parse HEAD)"`) conflates push verification with the acceptance criterion. The criterion is "the commit is on origin/main"; the mechanical check verifies it. |

---

## Risk summary

| # | Finding | Severity | Likelihood | Mitigation |
|---|---|---|---|---|
| R-PM-1 | **Package.json rewrite deviates from SETUP.md §1b** — missing name, version, description, repository, license field, lint script, devDep cleanup | High | Certain (plan provides only negative constraints, no positive specification) | Adopt SETUP.md §1b's package.json verbatim, or explicitly document and justify each deviation |
| R-PM-2 | **Test exit code conflict** — plan AC-6.3 requires exit 0; SETUP.md §1f expects failures; agent tests fail with `ERR_MODULE_NOT_FOUND` today | High | Certain (agent tests fail now, will still fail after strip — no source code changes) | Either fix pre-existing agent test failures (scope expansion), relax AC, or document expected failures |
| R-PM-3 | **models.generated.ts header wipe** — Step 4 adds header, Step 6 `npm run build` regenerates file without header | Medium | Certain (generator doesn't emit MPL header) | Either move header insertion post-build, or modify generate-models.ts to emit header |
| R-PM-4 | **Staging discipline conflict** — SETUP.md says `git add -A`; AGENTS.md forbids it | Medium | Certain (both policies active) | Resolve in plan: which policy applies to this feature? |
| R-PM-5 | Inconsistent traceability discipline — Decision 5 acknowledges SETUP.md deviation; Decision 2 doesn't | Low | Medium (process smell, not build-breaking) | Standardize: all deviations from SETUP.md must be explicit with justification |
| R-PM-6 | Contribution gating workflows (issue-gate.yml, pr-gate.yml, openclaw-gate.yml) unaddressed | Low | Low (don't break build, may cause confusing automation) | Decide: keep, remove, or defer gating policy for keel |
| R-PM-7 | DevDependencies cleanup unspecified — husky, concurrently, shx, jiti, get-east-asian-width all unused after strip | Low | Medium (won't break build but adds dead weight) | List dependencies to remove in Step 2 |
| R-PM-8 | No feature-level success criteria — only step-level ACs | Low | Medium (makes "is the feature done?" hard to answer) | Add feature-level AC: "Fresh clone → npm install → npm run build → npm test succeeds (with documented test expectations)" |
| R-PM-9 | .gitignore dead entries unaddressed (carried forward from prior R5) | Low | Low | Clean dead entries or add decision to keep them |
| R-PM-10 | AC-3.3 touch-list mismatch (carried forward from prior R3) | Low | Certain | Either add package.json files to Step 3 touch list or move license-field update to Step 2 |

---

## Verdict

**10 findings**, of which 2 are **high severity**, 2 are **medium**, and 6 are low.

**Single most important to address: R-PM-1 — Package.json rewrite deviates from SETUP.md §1b.** This is the binding PM finding. The plan's current approach (negative-only grep checks against removed package references) cannot produce the required positive state (name "keel", version "0.1.0", description, repository, license "MPL-2.0", lint script). The implementer will make field-level decisions SETUP.md already decided. The fix is structural: either adopt SETUP.md's package.json verbatim, or explicitly document and justify each deviation from it.

**Second priority: R-PM-2 — Test exit code conflict.** The plan requires exit 0 for tests. SETUP.md expects failures. Current reality confirms failures exist. If the plan's AC-6.3 is enforced, Step 6 will never pass — the feature will be blocked on pre-existing test issues that are explicitly out of scope ("no source code changes"). This is a scope collision the plan must resolve.

**Critique quality self-assessment**: Every finding cites specific lines from the plan, SETUP.md, the codebase, or the prior critique. The PM perspective (requirements coverage, acceptance criteria quality, traceability to source of truth) is consistently applied. Three findings (R-PM-1, R-PM-2, R-PM-3) are unique to the PM lens — not surfaced by the senior-engineer pass. R-PM-1 goes beyond the senior-engineer's "scripts underspecified" (R2) to identify a fundamental deviation from SETUP.md. R-PM-3 extends the senior-engineer's static header gap (R1) to the dynamic sequencing issue. R-PM-2 is a scope collision the senior-engineer pass didn't detect because it focused on technical risk rather than requirement alignment.

---

**✅ Critique pass 2 complete (`pm-requirements`) — ready for /revise**

| Phase | Command | Thinking |
|---|---|---|
| **Now** | `/revise` | **high** |
| Then | `/decompose` | **medium** |