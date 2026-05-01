---
calibration-date: 2026-05-01
feature-slug: keel-harness
adr: 0001-restructured-to-harness-only-and-relicensed-mpl-2-0
model: Moonshot Kimi K2.6 thinking (Fireworks-hosted)
---

# Calibration: keel-harness (ADR-0001)

## 1. Summary

### Earn-its-weight verdict

The workflow **pulled** on planning and verification, **dragged** on decomposition scope completeness and git mechanics.

- **Planning (§1)**: Two perspective-rotation critiques (senior-eng → PM) found genuinely non-overlapping issues. Senior-eng caught MPL-2.0 header text unspecified, README line limit arbitrary, and `models.generated.ts` gap. PM caught test exit-code conflict, staging discipline conflict, feature-level ACs absent, and devDependency cleanup unspecified. The revision produced a comprehensive response table with 14 incorporated points. The six-field reasoning template produced substantive entries for all 5 decisions. **Verdict: earned weight.**
- **Decomposition (§2)**: Step docs were self-contained and the consistency sweep produced a thorough traceability table. However, step docs systematically under-specified scope: tsconfig `include`/`exclude` arrays (F6), root `overrides` block (F7), shebang-file handling (F16), worktree merge mechanics (F31), and generated-file edge cases (F25). Mechanical constraint checks were defective in 5 of 7 steps (F5, F11, F15, F33). **Verdict: dragged — step docs required on-the-fly correction during implementation.**
- **Implementation**: Zero API invention, zero refactoring of earlier code, zero repetition. Scope drift was limited to necessary correctness fixes not anticipated in planning. **Verdict: earned weight.**
- **Verification**: Verify phases systematically diagnosed their own step-doc mechanical-check defects across Steps 2–7 rather than rubber-stamping FAIL (F8, F14, F19, F24, F28, F36). Step 1 verify output was not persisted (F4). **Verdict: earned weight, but Step 1 persistence gap is a process defect.**
- **Distillation**: ADR is decision-dense, strips scaffolding, and is readable cold. **Verdict: earned weight.**
- **Git / worktree mechanics**: Git staging discipline was absent in all 7 steps until Step 7 commit (C2). `.pi/active.md` was accidentally deleted in Step 1 (C1). Step 7 omitted the `git merge --ff-only` required by §8's worktree workflow (C10). GitHub PAT `workflow` scope blocked push (C11). **Verdict: dragged — persistent blind spot for mechanical operations outside source code.**

### Comparison to baseline

No baseline available — first run on this stack/harness. Calibration is establishing the reference, not measuring against one.

### Auto-pilot trigger status

This is **calibration run #1** for keel-harness. The doctrine requires ≥3 features with ≥95% bucket-classification accuracy before auto-pilot trigger evaluation. **Estimated runs remaining before trigger**: 2 features (need n=3 total). Current bucket-classification confidence: **medium** — most clusters were unambiguous, but C10 (worktree merge gap) straddles portable vs harness-specific, and C4 (verify self-correction) is model-specific but could be portable if the prompt scaffold is the driver.

---

## 2. Finding map

| Source ID | Canonical cluster | Underlying observation |
|---|---|---|
| trace-F1 | **C1** | `.pi/active.md` state file deleted during Step 1 strip, breaking downstream workflow argument resolution |
| trace-F10 | **C1** | `.pi/active.md` recreated untracked after deletion; `git clean -fd` would destroy it |
| trace-F3 | **C2** | Git staging discipline absent — workflow deletions staged, package/root deletions unstaged |
| trace-F9 | **C2** | Step 2 modifications unstaged (` M`) |
| trace-F13 | **C2** | Step 3 LICENSE modification unstaged |
| trace-F20 | **C2** | Step 4 126 modifications unstaged |
| trace-F21 | **C2** | Step 5 README modification unstaged; cumulative delta grows across all steps |
| trace-F27 | **C2** | Step 6 modifications unstaged; 6 steps of cumulative unstaged delta |
| trace-F2 | **C3** | Step 1 AC-1.7 `git status` mechanical check false-fails on unstaged deletions/untracked files |
| trace-F5 | **C3** | Step 2 mechanical check #2 false-positive — grep over-captures into `devDependencies` and version strings |
| trace-F11 | **C3** | Step 3 mechanical check #3 lowercase "version" vs canonical MPL-2.0 "Version" |
| trace-F15 | **C3** | Step 4 mechanical checks: multi-line header breaks `grep -rL`, missing `--exclude-dir`, `find -exec` exit-code fragility |
| trace-F33 | **C3** | Step 7 mechanical check #1 false-fails on pre-existing untracked `SETUP.md` |
| trace-F8 | **C4** | Step 2 verify diagnoses its own false-positive rather than rubber-stamping FAIL |
| trace-F14 | **C4** | Step 3 verify documents its own mechanical-check correction |
| trace-F19 | **C4** | Step 4 verify systematically diagnoses and corrects step-doc mechanical-check defects |
| trace-F24 | **C4** | Step 5 verify demonstrates consistent high-quality self-review |
| trace-F28 | **C4** | Step 6 verify diagnoses pre-existing failures and recommends step-doc updates |
| trace-F36 | **C4** | Step 7 verify STOP-and-report on auth failure rather than bypassing |
| trace-F6 | **C5** | Step 2 tsconfig.json `include`/`exclude` arrays cleaned beyond step-doc scope |
| trace-F7 | **C5** | Step 2 root package.json `overrides` block removed without step-doc mention |
| trace-F16 | **C5** | Step 4 shebang files handled specially (header after shebang) not in step doc |
| trace-F17 | **C5** | Step 4 package.json license fields changed not in step doc |
| trace-F18 | **C5** | Step 4 root-level tracked files (`bedrock-provider.d.ts/.js`) received headers — step-doc scope ambiguity |
| trace-F31 | **C5** | Step 7 omits `git merge --ff-only` required by §8 worktree workflow |
| trace-F22 | **C6** | Step 5 verify lacks separate "Acceptance criteria" gate table |
| trace-F26 | **C6** | Step 6 verify lacks separate AC gate table |
| trace-F34 | **C6** | Step 7 verify lacks separate AC gate table |
| trace-F4 | **C7** | Step 1 verify output not persisted to `docs/calibration/` |
| trace-F25 | **C8** | `models.generated.ts` upstream data drift (`contextWindow` change) between Step 4 and Step 6 |
| trace-F30 | **C8** | Upstream model registry data changed, making build non-deterministic across time |
| trace-F29 | **C9** | `packages/agent` tests unexpectedly passed completely (42/42), contradicting step-doc expectation of pre-existing failures |
| trace-F32 | **C11** | GitHub PAT `workflow` scope required when pushing `.github/workflows/ci.yml` changes |
| trace-F23 | **C12** | Step 5 (single-file overwrite, trivial checks) had zero drift and zero defective checks — simplicity correlates with fidelity |
| trace-F35 | **C12** | Single 789-file commit is large but appropriate per step doc's own rationale |

---

## 3. Per-phase scoring

### §1 Planning

**Observed**: The six-field reasoning template produced non-strawman "deceptively obvious wrong answers" for all 5 decisions (e.g., Decision 1: "Keep .pi/, AGENTS.md, and scripts/ — they're useful"; Decision 4: "Use a single sed command on all files"). Alternatives were real options with substantive rejections (3+ per decision). Self-consistency checks all returned "no contradictions" with orthogonality sentences — which was correct for this feature (file set, license, documentation are independent). Cross-cutting concerns table correctly scoped testing and CI/CD in-scope, marked 5 others N/A with rationale.

**Doctrine claim** (AGENTS.md §1 Reasoning template): "For each major decision in the plan, output: 1. Decision, 2. Constraints, 3. Second-order effects, 4. Failure modes (name the deceptively obvious wrong answer), 5. Alternatives considered (at least 2), 6. Self-consistency check."

**Gap**: The self-consistency check never caught a real contradiction — but the decisions genuinely were orthogonal. For structurally decoupled features (strip + relicense + rewrite README), this is expected. On tightly-coupled features, the field would face a real test. The "deceptively obvious wrong answer" field was consistently well-used.

**Recommended edit**: No change. The template performed as designed. Add calibration note: "On structurally orthogonal features (file strip + license + docs), self-consistency checks may legitimately return no contradictions. Do not force synthetic tension."

### §1 Discipline-axis check

**Observed**: Both critique passes (senior-eng and PM) surfaced discipline-axis findings. Senior-eng flagged "buildable" as vague (deferred-decision axis, though minor). PM flagged "out of scope" circular rejection reasoning in Decision 1 alternative. Both flagged missing cross-cutting concerns (testing, feature-level ACs). All 14 findings were incorporated in revision with explicit response-table entries. The revised plan's discipline-axis self-check claims "None found" for deferred decisions, and the response table confirms all axes were addressed.

**Doctrine claim** (AGENTS.md §1 Discipline-axis check): "Every critique pass must explicitly scan for these four discipline-axis failures regardless of perspective applied. Each surfaced finding is a critique gap."

**Gap**: None. The discipline-axis check worked — all four axes surfaced findings that were incorporated.

**Recommended edit**: No change.

### §1 Cross-model vs perspective rotation

**Observed**: **Cross-model critique was not used** on this feature. Only K2.6 perspective rotation (senior-eng → PM) was employed. Senior-eng caught: models.generated.ts header gap, package.json underspecification, AC-3.3 touch-list mismatch, ci.yml dead deps, .gitignore dead entries, package.json name/version gap, MPL-2.0 header text unspecified, README line limit arbitrary. PM caught: package.json rewrite deviation from SETUP.md, test exit-code conflict, models.generated.ts header wipe, staging discipline conflict, inconsistent traceability, contribution gating workflows unaddressed, devDependencies cleanup unspecified, no feature-level ACs, .gitignore dead entries, AC-3.3 touch-list mismatch.

**Non-overlapping findings**: Senior-eng uniquely caught "MPL-2.0 header text unspecified" and "README line limit arbitrary." PM uniquely caught "test exit-code conflict," "staging discipline conflict," "inconsistent traceability," "no feature-level ACs," and "devDependencies cleanup unspecified." This validates the "near-zero overlap" claim for non-obvious issues, though surface-level structural issues (CI cleanup, .gitignore, models.generated.ts, AC-3.3) were caught by both.

**Doctrine claim**: "Cross-model critique is high-value when available... Treat cross-model as recommended (not optional polish), pending n=2-3 cross-feature confirmation."

**Gap**: Cross-model was not attempted. No data on whether DSV4 would have caught anything K2.6 perspective rotation missed. The feature was structural (no algorithmic or API-design complexity) — cross-model value would likely be low.

**Recommended edit**: No change for this run. Note in calibration: "On simple structural features (file strip, config rewrite, bulk header insertion), perspective rotation alone may suffice. Cross-model value is higher for features with algorithmic or API-design complexity."

### §2 Decomposition

**Observed**: Step docs were self-contained with Context/Decision/Constraints/Files touched/AC/Mechanical checks. Step-list shape matched roadmap exactly (7 steps, no merges/splits). Consistency sweep produced a thorough roadmap-to-step traceability table with 25 mapped items. However, the sweep did **not** quote a Context/Decision/Implementation triplet per step as required by §2 rule 2. Also, step docs systematically under-specified scope: tsconfig `include`/`exclude` arrays, root `overrides` block, shebang handling, worktree merge mechanics, package.json license fields, and root-level tracked files outside `src/`/`test/`.

**Doctrine claim** (§2 rule 2): "the sweep must quote one Context/Decision/Implementation triplet per step as proof the check happened, even when no contradiction is found. 'No contradictions found' with no quoted text is rubber-stamping; reject the sweep and re-run."

**Gap**: The consistency sweep (`_consistency.md`) has traceability but no per-step triplet quotes. Also, step docs had systematic scope gaps that caused implementation drift.

**Recommended edit**:
- Section: §2 Cross-step consistency contract, rule 2
- Current: "the sweep must quote one Context/Decision/Implementation triplet per step as proof the check happened, even when no contradiction is found"
- Proposed: "The consistency sweep output must contain a section titled **'Per-step triplet verification'** with one quoted Context/Decision/Implementation triplet per step, labeled with the step file name. Missing section = sweep failure. Additionally, the sweep must produce a **'Scope boundary audit'** section that checks: (a) for config-file rewrites, whether ALL arrays/blocks referencing removed packages were enumerated (paths, include, exclude, overrides, workspaces); (b) for bulk file operations, whether edge cases were enumerated (shebang files, generated files, root-level tracked files outside src/test)."
- Reason: C5 (scope drift in Steps 2, 4, 7) + missing triplet quotes in consistency sweep
- Evidence strength: n=1
- Confidence: medium

Also:
- Section: §2 Cross-step consistency contract, rule 6
- Current: "The implementation sketch in the step doc must itself pass every mechanical check — validated as part of the consistency sweep"
- Proposed: Add sentence: "Additionally, the consistency sweep must run each mechanical check command against a deliberately-broken permutation of the sketch (e.g., remove the try/catch, change a grep pattern to a known false-positive variant) and confirm it exits non-zero. If the check passes against both correct and broken sketches, it is defective and must be rewritten before the step doc ships."
- Reason: C3 — 5/7 step docs had defective mechanical checks that would have been caught by this self-validation
- Evidence strength: n=1 (but pattern across 5 steps)
- Confidence: high — mechanically forced (the validation procedure is a binary pass/fail)

### §3 Implementation chunks

**Observed**: This feature decomposed into naturally small steps; no chunking was needed. Step 4 (bulk header insertion, 124+ files) and Step 7 (git staging + commit + push, 789 files) were the largest. Step 7 consumed ~20 tool calls (including auth retry), slightly above the 15-20 cap. No repetition, no API invention, no refactoring of earlier code was observed in any step.

**Doctrine claim**: "Starting target: 15-20 tool calls per chunk... Retain 15-20 as the default; raise to 30-40 only after n≥2 features confirm."

**Gap**: The cap wasn't stress-tested because the feature decomposed into small steps. Step 7 exceeded the cap due to external auth friction, not model drift. Model behavior was stable across all steps.

**Recommended edit**: No change. Add calibration note for keel-harness: "Feature decomposed into 7 naturally small steps; no chunking required. Step 7 hit ~20 tool calls due to GitHub PAT scope retry (external friction, not model drift). Model showed zero repetition/API invention across all steps."

### §4 Cold starts

**Observed**: The trace file does not record explicit `/new` between steps. The same session carried context across all 7 steps. No repetition, no API invention, no refactoring of earlier code resulted.

**Doctrine claim**: "Every chunk starts in a fresh context. Don't carry conversation state. The file system is the memory."

**Gap**: Cold starts were not used, and nothing went wrong. However, this feature had no complex logic or stateful implementation — each step was mechanically simple.

**Recommended edit**: No change. Add note: "On this feature, cold starts were not used between steps and no drift resulted. Feature was mechanically simple (file deletion, config rewrite, bulk sed, git ops). Cold-start value is higher for features with complex stateful logic where session context might cause 'helpful' refactoring of earlier work."

### §5 Verification gates / §6 Pre-flight

**Observed**: `/verify` systematically caught step-doc mechanical-check defects in Steps 2–7 (C3/C4). `/verify` did NOT catch invariant violations because no invariants were violated. `/verify` correctly documented pre-existing test failures in Step 6 without attempting fixes (F28). `/preflight` was skipped for Steps 3, 4, 5; focused preflight for Steps 2, 6, 7. Step 4 touched 124+ files and used only bulk `sed` — no new APIs, no new files, no complex logic. No harm resulted from skipping preflight. Step 1 verify output was NOT persisted (F4/C7); Steps 2–7 were persisted.

**Doctrine claim** (§5 gate 6): "before claiming PASS, `/verify` must write its full output... to `docs/calibration/verify-<slug>-step-<N>.md` when `/assess` will be run on the same step."

**Gap**: Step 1 verify output missing. Pre-flight was skipped for a >1-file step (Step 4), which technically violates the doctrine exemption criteria.

**Recommended edit**:
- Section: §6 Hallucination defense, last paragraph
- Current: "For integration steps that touch only one existing file, use only previously-verified APIs, and create no new files, `/preflight` may be skipped... `/preflight` remains mandatory for steps creating new files, using new APIs, or touching >1 file."
- Proposed: Add: "**Exception for bulk mechanical operations**: a step that touches >1 file but performs only a single, well-understood bulk operation (e.g., `find ... -exec sed -i ...` on all `.ts` files under a known directory, or `grep -rL ... | xargs ...`) may skip `/preflight` if the operation uses no new APIs and no new files. The step doc must still list the exact command pattern."
- Reason: Step 4 (124+ files, bulk sed for headers) skipped preflight without issues; the operation was a single bash loop using only `grep`, `sed`, and `find`
- Evidence strength: n=1
- Confidence: low — defer to n=2 confirmation

Also:
- Section: §5 Verification gates, gate 6
- Current: "`/verify` must write its full output... to `docs/calibration/verify-<slug>-step-<N>.md` when `/assess` will be run on the same step"
- Proposed: Add explicit hook: "If `/assess` will be run, the verify phase must create the output file BEFORE running mechanical checks, and append results incrementally. If the verify phase crashes or is interrupted, the partial file serves as evidence that the phase was attempted."
- Reason: C7 — Step 1 verify output missing, likely because verify was skipped or the file was not written
- Evidence strength: n=1
- Confidence: low — defer

### §7 Distillation

**Observed**: ADR-0001 is readable cold. It contains: context (fork of pi-mono, 5 packages, consumer is hull), 4 decision drivers, 5 real options with rejection reasons, chosen option with 10 bullet points of concrete changes, consequences (positive/negative/to-watch), and 5 validation signals. It does not contain step lists, chunk caps, model assignments, or response tables.

**Doctrine claim** (§7 Distillation contract): "Keep: context/problem, decision drivers, options considered with rejection reasons, chosen option, consequences (+/−/to-watch), validation signals. Drop: Step lists, chunk-size plans, in-progress notes, 'TODO' markers, agent harness mechanics."

**Gap**: The `generate-models.ts` template modification (to emit MPL-2.0 headers in generated output) is mentioned in the ADR but framed as an implementation detail rather than a decision. This is acceptable for a minor mechanical fix.

**Recommended edit**: No change.

### /assess phase

**Observed**: `/assess` (trace file) ran on all 7 steps and produced 3–6 substantive findings per step. Many findings were NOT derivable from `/verify` output:
- Step 1: `.pi/active.md` deletion (F1), git staging inconsistency (F3) — verify did not catch
- Step 2: tsconfig include/exclude drift (F6), verify self-diagnosis meta-pattern (F8) — verify documented changes but not as "drift"
- Step 4: shebang handling drift (F16) — verify didn't flag as drift
- Step 6: upstream data drift in `models.generated.ts` (F25), packages/agent unexpectedly passing (F29) — verify documented but didn't label as expectation mismatch
- Step 7: worktree merge gap (F31) — verify didn't catch because it wasn't in step doc

No step produced "looks good across the board, no findings."

**Doctrine claim** (§5 gate 7): "`/assess` is the primary capture channel for calibration findings and the highest-density observation surface; skipping it loses per-step anti-flattery review that surfaces process friction (sketch drift, harness defects, silent improvements) that `/verify` gates do not catch."

**Gap**: None — `/assess` is earning its keep on this feature.

**Recommended edit**:
- Section: §5 Verification gates, gate 7
- Current: "If `/assess` is consistently skipped, the calibration corpus becomes thin and `/calibrate` degrades to post-hoc guesswork."
- Proposed: Append: "On keel-harness (7 steps), `/assess` produced 3–6 substantive findings per step, many not derivable from `/verify` (e.g., state-file destruction, git staging discipline, upstream data drift, worktree merge gaps). This validates `/assess`'s value as an anti-flattery layer. If `/assess` consistently produces ≥3 findings per step, retain as required phase; if it drops to <2 for 2+ consecutive steps, tighten anti-flattery prompts."
- Reason: C1, C2, C5, C8, C10 — all assess-only or assess-primary findings
- Evidence strength: n=1
- Confidence: medium

---

## 4. Concern verdicts

No `docs/workflow/workflow-concerns.md` file exists for this feature. No open concerns to adjudicate.

---

## 5. Recommended doctrine edits — Portable

### Edit 5.1: Consistency sweep — per-step triplet verification + scope boundary audit

- **Section**: §2 Cross-step consistency contract, after rule 2
- **Current**: "Internal step consistency, with evidence: each step doc must not contradict itself between Context, Decision, Constraints, and Implementation sections. Per Cross-cutting principles → Evidence over claims, the sweep must quote one Context/Decision/Implementation triplet per step as proof the check happened, even when no contradiction is found. 'No contradictions found' with no quoted text is rubber-stamping; reject the sweep and re-run."
- **Proposed**: "Internal step consistency, with evidence: each step doc must not contradict itself between Context, Decision, Constraints, and Implementation sections. The sweep output must contain a section titled **'Per-step triplet verification'** with one quoted Context/Decision/Implementation triplet per step, labeled with the step file name. Missing section = sweep failure. Additionally, the sweep must produce a **'Scope boundary audit'** section that verifies: (a) for config-file rewrites, ALL arrays/blocks referencing removed/added packages were enumerated (paths, include, exclude, overrides, workspaces, scripts); (b) for bulk file operations, edge cases were enumerated (shebang files, generated files, root-level tracked files outside src/test, dotfiles); (c) for git operations, whether worktree merge mechanics (§8) are addressed if the repo uses per-feature worktrees."
- **Reason**: C5 — scope drift in Steps 2 (tsconfig include/exclude, overrides), 4 (shebangs, root-level files, package.json licenses), and 7 (worktree merge gap). Consistency sweep had traceability but no per-step triplet quotes.
- **Evidence strength**: n=1 (pattern across 3 steps)
- **Confidence**: medium

### Edit 5.2: Mechanical check self-validation in consistency sweep

- **Section**: §2 Cross-step consistency contract, rule 6
- **Current**: "The implementation sketch in the step doc must itself pass every mechanical check — validated as part of the consistency sweep, not deferred to `/verify`."
- **Proposed**: "The implementation sketch in the step doc must itself pass every mechanical check — validated as part of the consistency sweep. **Additionally, for each mechanical check, the consistency sweep must run it against a deliberately-broken permutation of the sketch** (e.g., remove the constraint the check is verifying, or alter a grep pattern to a known false-positive variant) and confirm it exits non-zero. If the check passes against both correct and broken permutations, it is defective and must be rewritten before the step doc ships. This applies to hand-written and model-generated checks equally."
- **Reason**: C3 — 5/7 step docs had defective mechanical checks (grep over-capture, case mismatch, multi-line pattern, exit-code fragility, untracked file false-fail). Self-validation would have caught all 5 before ship.
- **Evidence strength**: n=1 (but pattern across 5 steps, and the doctrine already documents a similar gawk `\b` false-fail from dark-mode-toggle)
- **Confidence**: high — mechanically forced (binary pass/fail on deliberately-broken permutation)

### Edit 5.3: `/assess` promotion threshold

- **Section**: §5 Verification gates, gate 7
- **Current**: "`/assess` is the primary capture channel for calibration findings and the highest-density observation surface; skipping it loses per-step anti-flattery review..."
- **Proposed**: Append paragraph: "**Promotion threshold**: On keel-harness (7 steps), `/assess` produced 3–6 substantive findings per step, many not derivable from `/verify` output (e.g., state-file destruction, git staging discipline, upstream data drift, worktree merge gaps). If `/assess` consistently produces ≥3 substantive findings per step across 2+ features, promote from optional to required phase. If it drops to <2 findings for 2+ consecutive steps, tighten anti-flattery prompts before relaxing the phase requirement."
- **Reason**: C1, C2, C5, C8, C10 — assess-only or assess-primary findings on every step
- **Evidence strength**: n=1
- **Confidence**: medium

### Edit 5.4: Verify output template compliance

- **Section**: §5 Verification gates
- **Current**: No explicit rule about the verify output template structure beyond gate 6 (persistence)
- **Proposed**: Add as gate 5b: "**Verify output template compliance**: The verify output must contain separate, explicitly titled sections for: (1) Mechanical constraint checks, (2) Constraint gate table, (3) Invariant gate table, (4) Verification commands, (5) Acceptance criteria checklist. Steps 5–7 of keel-harness merged ACs into mechanical checks and verification commands without a separate AC section. For simple static-file steps this is low-severity; for complex steps it masks AC coverage gaps."
- **Reason**: C6 — Steps 5, 6, 7 lacked separate AC gate tables
- **Evidence strength**: n=1
- **Confidence**: low — defer to n=2 confirmation on a complex feature

---

## 6. Recommended doctrine edits — Model-specific

### Edit 6.1: K2.6 verify-phase self-correction pattern

- **Section**: Calibration notes
- **Current**: "K2.6 silent-improvement-mid-write tendency — validated on dark-mode-toggle Step 6..."
- **Proposed**: Append: "**K2.6 verify-phase self-correction pattern** — validated on keel-harness Steps 2–7: when a mechanical check is defective (false-positive grep, case mismatch, multi-line pattern), K2.6 in thinking mode systematically diagnoses the defect, provides a corrected command, and passes the implementation on the corrected check rather than rubber-stamping FAIL. This validates the mechanical-first doctrine but also reveals a systematic failure mode: step-doc mechanical checks are being written defectively and then corrected at verify time. The fix is not model behavior change but stricter step-doc mechanical-check validation at decompose time (§2 rule 6 self-validation)."
- **Reason**: C4 — systematic high-quality self-correction across 6 steps
- **Evidence strength**: n=1
- **Confidence**: medium

---

## 7. Recommended doctrine edits — Harness-specific

### Edit 7.1: State file exclusion from strip operations

- **Section**: Cross-cutting principles → State management
- **Current**: No explicit rule about protecting `.pi/active.md` from repository-wide strip/delete operations
- **Proposed**: Add to State management protocol: "**State file protection**: `.pi/active.md` is the workflow's own state file and must be excluded from any repository-wide strip, delete, or `git clean` operations. If `.pi/` is in the removal list (e.g., because it is agent personal configuration), the state file must be backed up before `.pi/` deletion and restored immediately after. Alternatively, store `.pi/active.md` outside the repository directory."
- **Reason**: C1 — `.pi/active.md` deleted in Step 1, breaking downstream argument resolution for all subsequent steps
- **Evidence strength**: n=1
- **Confidence**: high — mechanically forced (deleting the state file breaks the workflow protocol)

### Edit 7.2: Git staging discipline in step docs

- **Section**: §8 Post-ship git operations (or add to §2 Step decomposition)
- **Current**: §8 focuses on `/finalize` merge sequence. No rule about per-step staging.
- **Proposed**: Add to §2 Step decomposition (new bullet): "**Git staging discipline**: For steps that modify or delete tracked files, the step doc must specify whether changes should be staged (`git add ...`) or left unstaged. If unstaged is the default, the step doc must explicitly state: 'Changes remain unstaged; staging deferred to final commit step.' Leaving modifications unstaged across multiple steps creates cumulative delta risk (accidental `git checkout .` or `git clean -fd` destroys work)."
- **Reason**: C2 — all 7 steps left modifications unstaged until Step 7 commit; 6 steps of cumulative delta
- **Evidence strength**: n=1
- **Confidence**: medium

### Edit 7.3: Worktree merge mechanics in step docs

- **Section**: §8 Post-ship git operations, `/finalize merge sequence`
- **Current**: "`/finalize <slug>`... ships a feature branch back to main: 1. Pre-flight gates... 2. Rebase... 3. Merge... 4. Cleanup..."
- **Proposed**: Add to §8: "**Step-doc awareness**: When the workflow uses per-feature worktrees (§8 Branch + worktree at /plan time), the final commit/push step doc must explicitly include the `git merge --ff-only feature/<slug>` operation in the main worktree, not assume the commit is already on `main`. Step 7 of keel-harness omitted this merge step, requiring on-the-fly discovery during implementation."
- **Reason**: C10 — Step 7 omitted `git merge --ff-only` required by worktree workflow
- **Evidence strength**: n=1
- **Confidence**: high — the §8 workflow protocol is mechanically required; omitting it causes implementation halt

---

## 8. Recommended doctrine relaxations (anti-accumulation)

### 8.1 Portable — Self-consistency check on orthogonal decisions

- **Section**: §1 Reasoning template, field 6
- **Current**: "Self-consistency check: does this contradict any earlier decision in this plan? Quote the prior decision before answering. If contradictions exist, resolve them here — don't defer. If all decisions return 'no contradictions,' require a one-sentence explicit statement that the decisions are genuinely orthogonal."
- **Proposed**: "Self-consistency check: does this contradict any earlier decision in this plan? Quote the prior decision before answering. If contradictions exist, resolve them here — don't defer. **If all decisions return 'no contradictions,' require a one-sentence explicit statement that the decisions are genuinely orthogonal (e.g., 'CSS strategy, storage strategy, and API shape are independent dimensions'). On structurally decoupled features (e.g., file strip + license change + documentation rewrite), 'no contradictions' is expected and does not require synthetic tension.**"
- **Reason**: On keel-harness, all 5 decisions were genuinely orthogonal (file set, package.json, license, headers, README). The self-consistency check produced correct "no contradictions" results every time. Forcing synthetic tension would be ceremony.
- **Evidence strength**: n=1
- **Confidence**: low — defer to n=2 on a structurally coupled feature to confirm the relaxation doesn't miss real contradictions

### 8.2 Portable — Mechanical checks on static-only steps

- **Section**: §2 Cross-step consistency contract, rule 6
- **Current**: "When a step doc lists zero mechanical checks AND modifies executable code, runtime APIs, or error paths, require an explicit one-line justification... Steps that modify only static configuration (CSS directives, HTML markup without script logic, JSON/YAML values) may omit both mechanical checks and their justification — the absence is implicitly trivial."
- **Proposed**: No change needed — the existing exemption for static-only steps was correctly applied on Steps 3 (LICENSE overwrite) and 5 (README overwrite), which had no mechanical-check justification sections and no issues. The exemption is earning its keep.
- **Reason**: Steps 3 and 5 were static-only and omitted mechanical-check justifications correctly. No relaxation needed — the rule is already appropriately scoped.
- **Evidence strength**: n=1
- **Confidence**: high — the exemption worked correctly

### 8.3 Model-specific — Chunk cap for small steps

- **Section**: §3 Implementation chunks
- **Current**: "Starting target: 15-20 tool calls per chunk"
- **Proposed**: No relaxation. The cap was not stress-tested on this feature because steps were naturally small. Step 7 hit ~20 tool calls due to external auth friction, not model drift. The default remains a safe guardrail for features requiring true chunking.
- **Reason**: No model drift observed, but cap wasn't tested under chunking conditions
- **Evidence strength**: n=1
- **Confidence**: low — defer

### 8.4 Harness-specific — `/preflight` for bulk mechanical operations

- **Section**: §6 Hallucination defense
- **Current**: "/preflight remains mandatory for steps creating new files, using new APIs, or touching >1 file."
- **Proposed**: Add explicit exception (as in Edit 5.2 above). Until confirmed on n=2, this stays as a **deferred relaxation** rather than an immediate edit.
- **Reason**: Step 4 (124+ files, bulk sed) skipped preflight without issues
- **Evidence strength**: n=1
- **Confidence**: low — defer to section 10

---

## 9. Validated doctrine claims

### Portable

| Claim | Evidence from this run | Bucket |
|---|---|---|
| "Evidence over claims: every assertion must cite file paths with line numbers, quoted text, command output, or grep results" | Verify outputs for Steps 2–7 consistently cite `file:line` (e.g., `generate-models.ts:1607-1609`, `LICENSE:1-3`) and command exit codes. Trace file quotes diff output and git status. | portable |
| "Perspective rotation produces near-zero overlap between critique passes on the same model" | Senior-eng uniquely caught "MPL-2.0 header text unspecified" and "README line limit arbitrary." PM uniquely caught "test exit-code conflict," "staging discipline conflict," and "no feature-level ACs." Surface-level issues (CI cleanup, .gitignore) were caught by both; non-obvious issues had ~zero overlap. | portable |
| "Mechanical checks are the binding answer for defensive-code constraints; model gates do not override" | Verify phases on Steps 2, 3, 4, 6, 7 all ran mechanical checks first, documented exit codes, and used them as binding evidence for constraint gate rows. No model-based override of a mechanical check failure was observed. | portable |
| "State management: explicit args, with state-file fallback" | State file resolved slug correctly for `/distill`. Explicit args override per AGENTS.md protocol. | portable |
| "Template tail format: Phase/Command/Thinking table with bare commands" | Roadmap tail and ADR tail both used canonical table format with bare commands (`/decompose`, `/calibrate`). | portable |

### Model-specific

| Claim | Evidence from this run | Bucket |
|---|---|---|
| "K2.6 thinking mode sustained 39 tool calls without drift" (dark-mode-toggle data) | On keel-harness, K2.6 showed zero repetition, zero API invention, zero refactoring of earlier code across all 7 steps. Step 7 consumed ~20 tool calls (auth retry) with no drift. | model-specific |
| "K2.6 silent-improvement-mid-write tendency" | Not observed on this feature — all implementation matched step docs except necessary scope drift (shebangs, worktree merge). No parameter removal or import reorder drift. | model-specific |
| "K2.6 verify-phase self-correction pattern" | Steps 2–7: systematically diagnosed defective mechanical checks (false-positive grep, case mismatch, multi-line pattern, exit-code fragility) and provided corrected commands rather than rubber-stamping FAIL. | model-specific |

### Harness-specific

| Claim | Evidence from this run | Bucket |
|---|---|---|
| "Git worktree + rebase + ff-only merge is git semantics, not pi-specific" | Step 7 successfully used `git merge --ff-only feature/keel-harness` in the main worktree after commit in the feature worktree. Linear history preserved. | harness-specific |
| "Per-worktree state (parallel feature support)" | `.pi/active.md` existed only in the feature worktree; main worktree had no active.md. Step 7's merge to main did not touch the feature worktree's state file. | harness-specific |
| "No auto-push" | Step 7 stopped after local merge per §8 hard rules. User pushed manually. | harness-specific |

---

## 10. Findings to defer (low-confidence)

| Cluster | Bucket | Trigger condition | Rationale |
|---|---|---|---|
| **C8** — Build non-determinism from `models.generated.ts` | portable | Next feature that uses `generate-models.ts` or any generated file | n=1 observation; may be isolated to upstream model registry updates. If it recurs, add "generated-file determinism check" to verification gates. |
| **C9** — Test expectation mismatch (agent tests unexpectedly passed) | portable | Next feature where step docs anticipate pre-existing test failures | May have been a transient state or the agent tests were fixed upstream between plan time and verify time. If agent tests consistently pass on future features, remove the "pre-existing failures" exemption from step doc templates. |
| **C11** — GitHub PAT `workflow` scope friction | harness-specific | Next feature that modifies `.github/workflows/` | n=1 auth failure. May be a one-time PAT scope issue. If it recurs, add PAT scope check to `/preflight` for workflow-modifying features. |
| **Preflight exemption for bulk mechanical ops** | portable | n=2 feature with bulk mechanical step that skips preflight successfully | Edit 5.2 proposed an exception but confidence is low (n=1). Defer until a second bulk-mechanical step skips preflight without issues. |
| **Self-consistency check relaxation** | portable | n=2 structurally orthogonal feature where all decisions return "no contradictions" | Edit 8.1 proposed relaxing the synthetic-tension requirement for orthogonal features. Defer to confirm the relaxation doesn't miss real contradictions on a second feature. |

---

**End of calibration document.**
