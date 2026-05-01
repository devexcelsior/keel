# Calibration trace: keel-harness

## Step 1 — step-1-strip-files

**Verified**: 2026-05-01 18:01
**Phases run**: /preflight (focused), /implement
**Verdict**: IMPLEMENTED (mechanical checks pass retroactively; no verify output persisted)

### Anti-flattery scan

1. **Implementation drift**: No drift. The implementation matches the step doc exactly. Quoted evidence from step doc `Files touched`: `rm -rf packages/coding-agent packages/tui packages/web-ui`, `rm -rf scripts/ .husky/ .pi/`, `rm -f AGENTS.md CONTRIBUTING.md pi-test.ps1 pi-test.sh test.sh`, removal of 5 dead workflow files, edit of `.github/workflows/ci.yml`, edit of `.gitignore`. Git status confirms: all 3 removed packages absent (AC-1.1 PASS), all 3 removed directories and 5 removed files absent (AC-1.2 PASS), all 5 dead workflows absent (AC-1.3/1.4 PASS), ci.yml system deps block removed (AC-1.5 PASS), .gitignore dead entries removed (AC-1.6 PASS). No extra files modified or added outside the step doc scope.

2. **Verify-gate evidence**: No `/verify` output file found (`docs/calibration/verify-keel-harness-step-1.md` does not exist). Terminal scrollback not available. This is a gap — unable to verify whether constraint gate, invariant gate, or acceptance criteria were checked with file:line evidence during the workflow. I ran the step doc's mechanical checks retroactively; they pass (with caveat on AC-1.7 command below), but retroactive checking is not substitute for per-verify evidence.

3. **Phase budget**: Preflight was focused and correct (18 items, ~1 tool call). Implementation was a single bulk deletion operation covering ~500 tracked files. This is appropriate for a structural strip step — no chunking needed. Verify phase appears to have been skipped or not persisted; if it was run, output should have been saved per §5 gate 6.

4. **Cross-step pattern**: First step — no prior step to compare against. However, a downstream pattern is already visible: the `.pi/active.md` state file was destroyed in Step 1, which will break `/preflight`, `/implement`, `/verify`, and `/assess` argument resolution for all subsequent steps unless the user passes explicit args.

5. **Surprise**: Two surprises. (a) `.pi/active.md` — the workflow's own state file — was deleted because `.pi/` is not in the step doc's KEEP list. This breaks the state management protocol described in AGENTS.md §Cross-cutting principles → State management. (b) Git staging inconsistency: the 5 workflow file deletions are staged (`D `), while all package/root deletions are unstaged (` D`). The step doc does not specify staging discipline, but AGENTS.md (which was deleted) required specific `git add <file>` commands.

6. **Test quality**: No tests added — step is N/A. Step doc `## Test mapping` section states "No runtime code — test mapping N/A." Confirmed.

### Findings (classified)

- F1 [harness-specific]: `.pi/active.md` deleted during Step 1 implementation, breaking state resolution for all downstream workflow commands. The state file either needs to be excluded from strip operations or stored outside the repo directory.
- F2 [portable]: Step 1 verification command for AC-1.7 (`git status --short | grep -v '^D' | wc -l | grep -q '^0$'`) produces false-fail against correct implementation because it does not filter unstaged deletions (` D`) or untracked files (`?? docs/`). The command tests for "lines not starting with D" but `git status --short` uses ` D` for unstaged deletions.
- F3 [harness-specific]: Git staging inconsistency — workflow file deletions are staged while package/root deletions are unstaged. Step doc lacks staging discipline; the deleted AGENTS.md file prescribed explicit per-file `git add` commands.
- F4 [portable]: No verify output persisted for Step 1. `docs/calibration/verify-keel-harness-step-1.md` does not exist, making retroactive assessment of gate evidence quality impossible. Per §5 gate 6, verify output should be written when `/assess` will be run.

## Step 2 — step-2-rewrite-config

**Verified**: 2026-05-01 18:20
**Phases run**: /preflight (mode), /implement, /verify
**Verdict**: PASS

### Anti-flattery scan

1. **Implementation drift**: Two categories of drift found.
   - (a) `tsconfig.json` edits extended beyond explicit step-doc scope. Step doc says "remove paths for removed packages" and lists only `paths` mappings. Implementation also removed `packages/coding-agent/examples/**/*` from `include` array (line 17 of diff) and `packages/web-ui/**/*` from `exclude` array (line 20 of diff). Both are necessary correctness fixes — those directories no longer exist after Step 1 — but were not in the step doc's `Files touched` or acceptance criteria.
   - (b) Root `package.json` `overrides` block (`rimraf`, `gaxios` transitive deps) was removed but not mentioned in step doc. The overrides only served removed packages' dependency trees. Benign drift.
   Quoted evidence from step doc `Files touched`: `package.json — complete rewrite`, `tsconfig.json — remove paths for removed packages`. No mention of `include`/`exclude` arrays or `overrides` block.

2. **Verify-gate evidence**: All gates were well-evidenced.
   - Mechanical checks: each has command + exit code + verdict (pass/fail with notes).
   - Constraint gate: cites `package.json:21`, `:22`, `:19-23` for each constraint.
   - Invariant gate: cites `package.json:21-22`, `:19`, `ls -la` output for each invariant.
   - Acceptance criteria: each AC has explicit PASS/FAIL with check details.
   No vibe-checking detected.

3. **Phase budget**: Verify timestamp 18:20, ~19 minutes after Step 1's 18:01. Implementation was 5 config file edits (all `write` or `edit` ops). Preflight would have been minimal since all files exist and APIs are just JSON fields. Verify ran 10 mechanical checks, constraint/invariant gates, and `npm install`. Budget is appropriate for a config-only step. Improvement over Step 1: verify output was properly persisted to `docs/calibration/verify-keel-harness-step-2.md`, satisfying §5 gate 6.

4. **Cross-step pattern**: Two patterns from Step 1 repeated:
   - (a) Git staging discipline still absent. All Step 2 modifications (` M package.json`, ` M tsconfig.json`, ` M biome.json`, ` M packages/*/package.json`) are unstaged. Combined with Step 1's hundreds of unstaged deletions, the working tree is a large uncommitted delta. Risk of accidental destruction via `git checkout .` remains.
   - (b) `.pi/active.md` state file is again in a precarious position. Step 1 deleted `.pi/`; the file was recreated by the harness but is untracked (`?? .pi/active.md`). If the repo is reset, downstream workflow commands break.
   New positive pattern: verify output was persisted this time, unlike Step 1.

5. **Surprise**: The verify phase caught and documented a defect in the step doc's own mechanical check command. Check #2 (`grep '"scripts"' -A 10 package.json | grep -c 'browser-smoke\|profile\|dev\|version\|release\|prepublish\|publish\|prepare'`) falsely matches "dev" in `devDependencies` and "version" in `7.0.0-dev.20260120.1`. Instead of reporting a FAIL, the verify phase correctly identified the false-positive, manually verified the actual scripts via Python `json.load`, and proposed a corrected command. This is the anti-flattery behavior the verify gate is supposed to exhibit — it didn't rubber-stamp its own check.

6. **Test quality**: No tests added — step is N/A. Step doc `## Test mapping` section states "No runtime code — test mapping N/A." Confirmed.

### Findings (classified)

- F5 [portable]: Step-doc mechanical check #2 has a false-positive command pattern. `grep '"scripts"' -A 10` over-captures into `devDependencies` and version strings. Verify output proposed repair: use Python `json.load` to inspect keys precisely. The step doc's verification command is defective and should be updated.
- F6 [portable]: `tsconfig.json` implementation cleaned `include` and `exclude` arrays beyond explicit step-doc scope. Necessary for correctness (removed packages' directories no longer exist) but not anticipated in planning. Acceptable drift — the step doc's "remove paths" phrasing was ambiguous between `compilerOptions.paths` and `include`/`exclude` paths.
- F7 [portable]: Root `package.json` `overrides` block removed without step-doc mention. Benign drift — overrides only served removed packages' transitive dependencies.
- F8 [portable]: Verify phase demonstrated high quality by diagnosing its own false-positive mechanical check rather than rubber-stamping FAIL. Validates the mechanical-check self-review protocol.
- F9 [harness-specific]: Git staging discipline absent across both steps. Step 2 modifications are unstaged (` M`). Combined with Step 1 unstaged deletions, working tree carries a large uncommitted delta. Risk of data loss on accidental reset.
- F10 [harness-specific]: `.pi/active.md` is untracked (`??`) and the sole survivor of `.pi/` after Step 1's deletion. State management protocol depends on this file existing, but it is outside git. A `git clean -fd` would destroy it and break downstream workflow commands.

## Step 3 — step-3-set-license

**Verified**: 2026-05-01 18:40
**Phases run**: /preflight (skipped), /implement, /verify
**Verdict**: PASS

### Anti-flattery scan

1. **Implementation drift**: None. The step doc specifies: "Download the MPL-2.0 license text from `https://www.mozilla.org/media/MPL/2.0/index.txt` via curl, prepend a Keel attribution header, and overwrite the existing LICENSE file." The diff shows exactly `LICENSE:1` `Keel — https://github.com/devexcelsior/keel`, `LICENSE:2` `Mozilla Public License 2.0`, followed by verbatim MPL-2.0 text through `LICENSE:376`. No extra variables, no defensive checks, no helper functions, no comments beyond the attribution header. Quoted evidence from step doc `Files touched`: `LICENSE — overwrite with MPL-2.0 + Keel header`.

2. **Verify-gate evidence**: All gates had citations or command output.
   - Mechanical checks: each has command + exit code + verdict.
   - Constraint gate row 1: cites `LICENSE:1-3` plain-text attribution; `LICENSE:4-376` verbatim Mozilla text.
   - Constraint gate row 2: marked N/A with reason "curl succeeded".
   - Invariant gate row 1: marked N/A with reason "curl succeeded; no broken file created".
   - Acceptance criteria: cite command outputs (`exit 0`).
   No vibe-only passes detected.

3. **Phase budget**: Implementation was a single curl + file write (~1 tool call). Verify ran 3 mechanical checks, constraint/invariant gates, and 2 AC commands. Total effort minimal and appropriate for a static-file-only step. One extra cycle was consumed because mechanical check #3 initially failed due to a step-doc pattern typo; verify documented the correction. This is still sub-5 tool calls — well within budget.

4. **Cross-step pattern**:
   - Positive pattern from Step 2 repeated: verify output was persisted to `docs/calibration/verify-keel-harness-step-3.md`, satisfying §5 gate 6.
   - Negative pattern from Step 2 repeated: step-doc mechanical check contained a subtle textual defect. Step 2 had false-positive over-capture in grep; Step 3 had lowercase "version" vs canonical "Version". Verify caught both.
   - Git staging pattern from Steps 1-2 repeated: LICENSE modification is unstaged (` M`). Per workflow doctrine, uncommitted verified changes are default state, but cumulative working tree delta grows.

5. **Surprise**: The verify phase caught and documented a defect in the step doc's own mechanical-check pattern. The step doc wrote `grep -q "Mozilla Public License, version 2.0"` but the canonical Mozilla text uses `Version` (capital V). Verify output explicitly notes "pattern mismatch" and shows the corrected command passing. This is the second consecutive step where mechanical-first verification caught a specification drift in the pre-written step doc, validating the doctrine's mechanical-first gate design.

6. **Test quality**: No tests added — step is N/A. Step doc `## Test mapping` section states "No runtime code — test mapping N/A." Confirmed.

### Findings (classified)

- F11 [portable]: Step-doc mechanical check #3 had incorrect grep pattern (`Mozilla Public License, version 2.0` with lowercase v). Canonical MPL-2.0 text uses `Version` (capital V). Verify caught and corrected this. Second consecutive step with a defective mechanical-check command in the step doc.
- F12 [portable]: Zero implementation drift — implementation exactly matched step-doc specification. No extra files, variables, or defensive checks.
- F13 [harness-specific]: LICENSE modification is unstaged (` M`). Cumulative working tree now carries 3 steps of unstaged modifications plus hundreds of unstaged deletions from Step 1. Risk of accidental data loss on `git checkout .` or `git clean -fd` persists.
- F14 [portable]: Verify output persisted to `docs/calibration/verify-keel-harness-step-3.md` with high quality — it documented its own mechanical-check correction, satisfying §5 gate 6.

## Step 4 — step-4-add-headers

**Verified**: 2026-05-01 18:55
**Phases run**: /preflight (skipped), /implement, /verify
**Verdict**: PASS

### Anti-flattery scan

1. **Implementation drift**: Two categories of drift found.
   - (a) **Shebang handling**: Four files with shebangs (`cli.ts`, `generate-models.ts`, `generate-test-image.ts`, `codex-websocket-cached-probe.ts`) had the MPL-2.0 header inserted AFTER the shebang with a blank line separator. The step doc did not anticipate this; the verify output notes this was necessary to "prevent esbuild syntax error." Quoted evidence from step doc `Decision`: "Prepend the exact header text to each file via a bash loop with sed" — no shebang exception mentioned.
   - (b) **Package license fields**: Both `packages/ai/package.json` and `packages/agent/package.json` had `"license": "MIT"` changed to `"license": "MPL-2.0"`. Not in step doc `Files touched` (which only listed `.ts`/`.tsx`/`.js` files and `generate-models.ts`). Benign drift aligned with Decision 3 (MPL-2.0 adoption).
   - (c) **Root-level tracked files**: `packages/ai/bedrock-provider.d.ts` and `packages/ai/bedrock-provider.js` received headers. These are under `packages/ai` but outside `src/`/`test/`; step doc `Files touched` listed only `src/` and `test/` subdirectories, but `Decision 1` said "every .ts, .tsx, .js file under packages/ai". Correctly resolved ambiguity in favor of broader scope.

2. **Verify-gate evidence**: All gates were rigorously evidenced. The verify output is the highest-quality of the four steps so far:
   - Mechanical checks: each has command + exit code + verdict; additionally documents step-doc command defects with "step-doc bug" labels and provides corrected commands.
   - Constraint gate: cites `generate-models.ts:1607-1609` for template change, `LICENSE:1-3` for attribution.
   - Invariant gate: cites `git diff` analysis of all 126 modified files to confirm "all `+` lines are header comments except one template string line."
   - Acceptance criteria: each AC has explicit PASS/FAIL; AC-4.1/4.2 document the step-doc mechanical check defects rather than falsely claiming the broken commands passed.
   No vibe-only passes detected.

3. **Phase budget**: Implementation was a bulk bash loop touching 124 source files + 2 package.json files. Verify ran 4 mechanical checks (plus 3 corrected variants), constraint/invariant gates, and `npm run build`. The verify phase consumed more effort than typical because it had to diagnose and document step-doc mechanical check defects (wrong grep pattern, missing `--exclude-dir` flags, `find -exec` exit-code fragility). Budget is appropriate for the scale; verify output quality justifies the extra cycles.

4. **Cross-step pattern**: Third consecutive step with defective step-doc mechanical checks.
   - Step 2: false-positive grep over-capture into devDependencies.
   - Step 3: lowercase "version" vs canonical "Version".
   - Step 4: multi-line header breaks `grep -rL "Mozilla Public License"` pattern; missing `--exclude-dir` flags; `find -exec \;` only returns last-file exit code.
   The verify phases across all three steps demonstrated identical high-quality behavior: they diagnosed the defect, provided corrected commands, and passed the implementation on the corrected checks. This validates the mechanical-first verification doctrine (Cross-cutting principles §Mechanical verification), but also reveals a systematic failure mode in the step-doc writing phase.
   Git staging pattern from Steps 1-3 repeated: all 126 modifications are unstaged (` M`).

5. **Surprise**: The verify output explicitly labels itself as documenting "3rd consecutive step" with step-doc mechanical check defects. This is meta-quality — the verify phase not only caught its own check bugs, it aggregated the pattern across the feature's history. Also: the implementation handled shebang files correctly (kept `#!/usr/bin/env node`/`#!/usr/bin/env tsx` on line 1) without explicit step-doc instruction. This suggests the bash loop used by `/implement` included defensive logic not captured in the step doc.

6. **Test quality**: No tests added — step is N/A. Step doc `## Test mapping` section states "No runtime code — test mapping N/A." Confirmed.

### Findings (classified)

- F15 [portable]: Step-doc mechanical checks contain three defects in a single step: (a) `grep -rL "Mozilla Public License"` does not match multi-line header text; (b) all `grep`/`find` commands missing `--exclude-dir=node_modules --exclude-dir=dist`; (c) `find ... -exec ... \;` only returns exit code of last file processed, silently passing if a double-header occurs in any non-last file. Third consecutive step with defective mechanical checks (F5, F11, F15).
- F16 [portable]: Implementation drift — shebang files received special handling (header after shebang) not specified in step doc. Necessary correctness fix; absent this, esbuild would fail on shebang-not-first-line.
- F17 [portable]: Implementation drift — both `packages/ai/package.json` and `packages/agent/package.json` license fields changed MIT→MPL-2.0. Not in step doc scope but aligned with Decision 3.
- F18 [portable]: Root-level tracked files `packages/ai/bedrock-provider.d.ts` and `packages/ai/bedrock-provider.js` received headers. Step doc `Files touched` was ambiguous between `src/`/`test/` only vs all files under package. Implementation chose broader, correct interpretation.
- F19 [model-specific]: Verify phase demonstrated systematic high-quality self-review across Steps 2-4, diagnosing and correcting step-doc mechanical check defects rather than rubber-stamping FAIL. Suggests the model is applying the mechanical-first doctrine consistently when the prompt scaffold forces check-by-check reporting.
- F20 [harness-specific]: Git staging discipline still absent. 126 unstaged modifications from Step 4 add to the cumulative uncommitted delta across 4 steps.

## Step 5 — step-5-write-readme

**Verified**: 2026-05-01 19:05
**Phases run**: /preflight (skipped), /implement, /verify
**Verdict**: PASS

### Anti-flattery scan

1. **Implementation drift**: None. The implementation exactly matches the step doc specification. The produced `README.md` (22 lines) satisfies all required content items from the step doc `Decision` section: first heading contains "Keel" (`# Keel — AI/Agent Harness`), references `devexcelsior/hull` and `devexcelsior/helm` (three-repo architecture list), mentions MPL-2.0 license ("[Mozilla Public License 2.0](LICENSE)"), contains no references to `coding-agent`, `tui`, or `web-ui` (verified by `grep`), and communicates the "can't be removed" philosophy ("It contains the packages you can't remove: the multi-provider LLM API and the agent loop"). No extra variables, helper functions, defensive checks, or comments were added beyond the mandated content. Quoted evidence from step doc `Files touched`: `README.md — overwrite`.

2. **Verify-gate evidence**: All gates were rigorously evidenced.
   - Mechanical checks: each has command + exit code + verdict + notes (e.g., check #4 notes "22 lines, well under 80 limit").
   - Constraint gate: cites `wc -l README.md` → 22 lines for line-count constraint; cites "No `coding-agent`, `tui`, or `web-ui` found" for removed-package constraint.
   - Invariant gate: cites `ls README.md` for file existence.
   - Verification commands: four bash commands listed with exit-0 checkmarks, directly mapping to AC-5.1 through AC-5.4.
   Minor structural note: verify output does not contain a separate "Acceptance criteria" gate table (§5 gate 5); ACs are covered by the mechanical-checks table and verification-commands list instead. For a trivial static-file step this is functionally equivalent, but it deviates from the formal verify-output template.

3. **Phase budget**: Implementation was a single `write` to `README.md` (~1 tool call). Verify ran 4 mechanical checks, a 2-row constraint gate, a 1-row invariant gate, and 4 verification commands. Total effort minimal and appropriate. Time from Step 4 verify (18:55) to Step 5 verify (19:05) is ~10 minutes.

4. **Cross-step pattern**:
   - Positive pattern from Steps 2-5 repeated: verify output was persisted to `docs/calibration/verify-keel-harness-step-5.md`, satisfying §5 gate 6.
   - Positive pattern: first step since Step 3 with **zero implementation drift** and **zero defective mechanical checks**. Steps 2 and 4 both had drift and/or defective checks. Simplicity of the step doc (single file, 4 simple bash checks) correlates with high specification-to-execution fidelity.
   - Negative pattern from Steps 1-4 repeated: git staging discipline still absent. `README.md` modification is unstaged (` M`). Cumulative working tree now carries 5 steps of unstaged modifications plus hundreds of unstaged deletions from Step 1.

5. **Surprise**: The README quality is notably higher than typical auto-generated harness READMEs. The "can't be removed" philosophy is communicated in a single crisp sentence ("It contains the packages you can't remove: the multi-provider LLM API and the agent loop") rather than a preachy paragraph. The three-repo architecture is communicated with a clean bulleted list rather than a verbose narrative. The implementation achieved the step doc's "~40 lines" target by landing at 22 lines — shorter than target but more concise, and well within the 80-line upper bound. No defects in verify-phase mechanical checks for the first time since Step 1.

6. **Test quality**: No tests added — step is N/A. Step doc `## Test mapping` section states "No runtime code — test mapping N/A." Confirmed.

### Findings (classified)

- F21 [harness-specific]: Git staging discipline still absent across all 5 steps. `README.md` modification is unstaged (` M`). Cumulative working tree carries 5 steps of unstaged modifications plus hundreds of unstaged deletions from Step 1. Risk of accidental data loss on `git checkout .` or `git clean -fd` persists and grows with each step.
- F22 [portable]: Verify output lacks a separate "Acceptance criteria" gate table (§5 gate 5). AC-5.1 through AC-5.4 are covered by mechanical checks and verification commands, but the formal structure is not followed. For trivial static-file steps this is low-severity; for complex steps it would mask AC coverage gaps.
- F23 [portable]: First step since Step 1 with zero implementation drift AND zero defective mechanical checks. Correlation: simple step doc (single-file overwrite, 4 trivial bash checks) → high specification-to-execution fidelity. This validates the chunking guidance (§3) indirectly — small, well-bounded steps produce cleaner output.
- F24 [model-specific]: Consistent high-quality verify-phase behavior across Steps 2-5: mechanical checks are run first, evidence is quoted, and defects are documented rather than rubber-stamped. This suggests the model has internalized the mechanical-first verification doctrine when the prompt scaffold forces check-by-check reporting.

## Step 6 — step-6-build-verify

**Verified**: 2026-05-01 19:23
**Phases run**: /preflight (focused), /implement, /verify
**Verdict**: PASS

### Anti-flattery scan

1. **Implementation drift**: No manual file edits were made during this step (consistent with step doc "Files touched: None"). `packages/ai/src/models.generated.ts` was regenerated by `npm run build`, which is anticipated. However, the regeneration introduced an upstream data drift not explicitly scoped: `contextWindow` for an `openai-completions` model changed from `1000000` to `1048576` (visible in `git diff HEAD -- packages/ai/src/models.generated.ts` line `@@ -9185,7 +9186,7 @@`). Step 4's verify output invariant gate stated "Build output confirms identical model data," implying the model registry was unchanged after Step 4's build. The Step 6 build therefore introduced fresh upstream data. This is expected generated-file churn, not implementation drift, but it is content produced by this step outside the step doc's explicit scope (which only anticipated verifying the header presence). Quoted evidence from step doc `Files touched`: "None (verification step) — Potentially `packages/ai/src/models.generated.ts` (regenerated during build — header should be present per Step 4)."

2. **Verify-gate evidence**: All gates were rigorously evidenced. Mechanical checks have full command/exit/verdict/notes. Pre-existing failures are documented with specific file:line references (`test/lazy-module-load.test.ts`, `test/codex-websocket-cached-probe.ts(16,29)`). Constraint gate cites mechanical check numbers rather than file:lines — appropriate for a no-file-edit verification step. Invariant gate cites `git status` outputs. No vibe-only passes detected. Minor structural note: verify output does not contain a separate "Acceptance criteria" gate table (§5 gate 5); AC-6.1 through AC-6.5 are covered by the 5 mechanical checks and verification commands list instead. Same deviation as Step 5 (F22).

3. **Phase budget**: ~18 minutes from Step 5 verify (19:05) to Step 6 verify (19:23). Implementation was a series of shell command invocations (`npm install`, `npm run build`, `npm run test`, `npx tsgo`). Verify ran 5 mechanical checks, a 5-row constraint gate, a 2-row invariant gate, and extensive pre-existing failure documentation. Budget is appropriate for a build verification step involving two workspace packages.

4. **Cross-step pattern**:
   - Positive: verify output persisted to `docs/calibration/verify-keel-harness-step-6.md`, satisfying §5 gate 6 (consistent with Steps 2–5).
   - Positive: first step where mechanical checks intentionally failed (checks #3 and #4), and verify correctly classified failures as "pre-existing" rather than rubber-stamping PASS or attempting fixes. Validates the step doc's "document, don't fix" failure-mode guidance.
   - Negative: git staging discipline still absent across all 6 steps. All modifications and deletions remain unstaged. Cumulative working tree delta is now 6 steps of edits plus hundreds of Step 1 deletions.
   - Negative: no formal "Acceptance criteria" gate table (same structural deviation as Step 5).

5. **Surprise**: Three surprises.
   - (a) `packages/agent` tests passed completely (42 passed, 0 failures). The step doc anticipated possible pre-existing agent failures ("`packages/agent` tests may have pre-existing failures"), but none existed. The harness packages are in better test shape than estimated.
   - (b) Upstream model registry data drifted between Step 4 (19:05) and Step 6 (19:23), causing `contextWindow` drift in the regenerated file. This makes `npm run build` non-deterministic across time and could produce unexpected diffs in future CI runs.
   - (c) The verify output self-critiqued its own step doc: "The step doc's mechanical check #3 and #4 commands should be updated in a future `/decompose` consistency sweep to either exclude pre-existing failing files or adjust expected exit codes." This is the fourth consecutive step where the verify phase diagnosed specification defects in the pre-written step doc (Step 2: false-positive grep; Step 3: lowercase version; Step 4: multi-line grep/missing exclusions; Step 6: expected-exit-code mismatch for pre-existing failures).

6. **Test quality**: No tests added — step is N/A. Step doc `## Test mapping` states "No runtime code — test mapping N/A. Verification relies on existing test suites in `packages/ai` and `packages/agent`." Confirmed.

### Findings (classified)

- F25 [portable]: `models.generated.ts` regenerated with upstream data drift (`contextWindow` change) not explicitly anticipated in step doc scope. Step doc only mentioned "header should be present per Step 4". Generated-file churn from `generate-models.ts` is expected but makes the build non-deterministic across time.
- F26 [portable]: Verify output lacks separate "Acceptance criteria" gate table (§5 gate 5). AC-6.1 through AC-6.5 are covered by mechanical checks and verification commands, but formal structure is not followed. Same deviation as Step 5 (F22).
- F27 [harness-specific]: Git staging discipline still absent across all 6 steps. Cumulative working tree carries 6 steps of unstaged modifications plus hundreds of unstaged deletions from Step 1. Risk of accidental data loss on `git checkout .` or `git clean -fd` persists.
- F28 [model-specific]: Verify phase demonstrated systematic high-quality self-correction for the fourth consecutive step by diagnosing pre-existing failures and recommending step-doc mechanical-check updates. Also correctly handled intentional mechanical-check failures without attempting fixes.
- F29 [portable]: `packages/agent` tests unexpectedly passed completely (42/42), contradicting the step doc's expectation of pre-existing agent failures. Positive signal about harness package health.
- F30 [model-specific]: Upstream model registry data changed between Step 4 and Step 6, causing `contextWindow` drift in generated file. Build output is time-dependent and may produce spurious diffs in CI.

## Step 7 — step-7-commit-push

**Verified**: 2026-05-01 19:45
**Phases run**: /preflight (focused), /implement, /verify
**Verdict**: PASS

### Anti-flattery scan

1. **Implementation drift**: One significant drift and one implicit-but-correct action not in the step doc.
   - (a) **`git merge --ff-only feature/keel-harness` in the main worktree** (`/home/devex/Projects/keel`) was necessary for push but entirely absent from the step doc. The step doc says "Push to `origin/main`" as if the commit were already on `main`. Because the workflow uses per-feature git worktrees (§8 Post-ship git operations), the commit was created in `feature/keel-harness` worktree and had to be ff-merged to `main` in the sibling worktree before pushing. This is a workflow-mechanics gap in the step doc, not an implementation error — but it is unanticipated work the implementer had to perform.
   - (b) **Staging used directory-level `git add` commands** (e.g., `git add packages/coding-agent/`, `git add packages/ai/`) rather than per-file `git add <file>` calls. The step doc's AC-7.2b explicitly allows "`git add <directory>` commands" as an alternative to per-file, so this is within spec. Quoted evidence from step doc `Alternatives considered`: "The file count is large but manageable via specific paths or `git add packages/ai/src/ packages/ai/test/ ...`" — the implementation chose the directory-level variant.

2. **Verify-gate evidence**: All gates were well-evidenced. Mechanical checks have full command/exit/verdict/notes. Constraint gate lists every specific `git add` command executed. Invariant gate cites `git log --oneline -3` showing ff-only linear history. No vibe-only passes detected. Structural deviation persists: no separate "Acceptance criteria" gate table (same as Steps 5-6, F22/F26).

3. **Phase budget**: ~20 tool calls across implement + verify, slightly above the 15-20 cap. Justified by: (a) staging 789 files required multiple `git add` commands across directories; (b) initial push failed due to GitHub PAT scope, requiring user intervention + retry cycle; (c) verification had to check both feature worktree and main worktree state. The auth retry consumed ~5 extra tool calls.

4. **Cross-step pattern**:
   - Positive: git staging discipline finally happened — all 789 changes committed in one step, ending the 6-step cumulative unstaged delta (F27 resolved). This validates §8's worktree + ff-only merge pattern.
   - Positive: verify output persisted (consistent with Steps 2-7).
   - Negative: **fifth consecutive step** with defective step-doc mechanical check. Check #1 (`test "$(git status --short | wc -l)" -eq 0`) false-fails on pre-existing untracked `SETUP.md` in the main worktree (not created by this feature). Pattern established: Steps 2, 3, 4, 6, 7 all had broken mechanical checks. The verify phases correctly diagnosed and worked around each one.
   - Negative: no formal "Acceptance criteria" gate table (F22/F26 continues).

5. **Surprise**: Three surprises.
   - (a) **GitHub PAT `workflow` scope blocked push.** The `.github/workflows/ci.yml` modification (removing dead system deps) triggered GitHub's PAT scope gate. This is the first auth failure across all 7 steps. The implementation correctly STOPped, reported the exact error, and waited for user token update rather than attempting workarounds. Validates the "do not proceed if check fails" hard rule.
   - (b) **The main worktree was at `/home/devex/Projects/keel` (sibling directory), not in the current worktree.** This was discovered during the `git checkout main && git merge` step. The step doc's scope didn't account for §8's per-worktree state management, requiring on-the-fly `-C <path>` git operations.
   - (c) **A single commit for 789 files is large but appropriate.** The step doc correctly anticipated that splitting into multiple commits would "add complexity" and rejected it. The commit message is descriptive and references both structural changes (harness restructuring) and licensing (MPL-2.0).

6. **Test quality**: No tests added — step is N/A. Step doc `## Test mapping` states "No runtime code — test mapping N/A." Confirmed.

### Findings (classified)

- F31 [harness-specific]: Step doc omits the `git merge --ff-only` step required by §8's worktree-based workflow. The step doc assumes "push to origin/main" but the commit is created in a feature worktree and must be merged to `main` in the sibling worktree first.
- F32 [harness-specific]: GitHub PAT `workflow` scope is required when pushing changes to `.github/workflows/ci.yml` (even deletions/modifications). First auth failure across 7 steps; verify caught it and stopped correctly.
- F33 [portable]: Fifth consecutive step with defective step-doc mechanical check (Steps 2, 3, 4, 6, 7). Check #1 false-fails on pre-existing untracked `SETUP.md`. The verify phases have developed a pattern of diagnosing and documenting these defects rather than rubber-stamping FAIL.
- F34 [portable]: No separate "Acceptance criteria" gate table in verify output (F22/F26 continues across Steps 5-7). Low severity for static-file/commit steps but indicates a template drift.
- F35 [portable]: Single 789-file commit is large but appropriate per step doc's own "Alternatives considered" rejection of multi-commit splitting. Commit message quality is good.
- F36 [model-specific]: Auth-failure STOP-and-report behavior was correct — the model did not attempt to bypass the PAT scope requirement or invent credentials, instead stopping and asking the user. This validates the "do not proceed if check fails" hard rule under real external friction.

