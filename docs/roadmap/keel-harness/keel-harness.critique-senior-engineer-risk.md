---
reviewer: Moonshot Kimi K2.6 thinking
perspective: senior engineer reviewing for risk and edge cases
plan: docs/roadmap/keel-harness/keel-harness.md
date: 2026-05-01
---

# Critique: keel-harness — senior-engineer-risk

## Pass 1 — Six-field scoring per decision

### Decision 1: Strip to minimal harness files

| Field | Score | Evidence |
|---|---|---|
| Decision — clear? | ✓ | Explicit KEEP list: "Remove everything except packages/ai, packages/agent, .git, .gitignore, .github, README.md, LICENSE, package.json, package-lock.json, tsconfig.base.json, tsconfig.json, biome.json" |
| Constraints — specific, cited, complete? | ⚠ | "packages/ai and packages/agent must remain buildable after stripping" is stated, but buildability requires: zero test failures (not stated), TypeScript compilation (not stated), and CI pipeline validity (not stated). The evidence cites `packages/agent/package.json:10` for the dep graph — good. |
| Second-order effects? | ✓ | Thorough: root package.json scripts, tsconfig.json paths, biome.json includes, CI workflows (build-binaries.yml). Each with specific examples. |
| Failure modes? | ✓ | Two named: (1) "Keep .pi/, AGENTS.md, and scripts/" — deceptively obvious wrong answer, explained why wrong. (2) "Silent breakage: npm install fails because package-lock.json still references removed workspace packages" — real risk. |
| Alternatives? | ✓ | Three: keep scripts/ (rejected: references removed packages), keep build-binaries.yml (rejected: no binaries in harness), delete lock file (rejected: risks pulling new dependency versions). All with substantive rejection reasons. |
| Self-consistency? | ✓ | States no contradictions; orthogonal dimensions. Independent from license, headers, README — correct. |

**Overall**: Solid. The constraint gap (not specifying test/CI/build success as part of "buildable") is minor — Step 6 covers it implicitly.

---

### Decision 2: Rewrite root package.json for harness-only workspaces

| Field | Score | Evidence |
|---|---|---|
| Decision — clear? | ⚠ | Goal is clear: "Reduce workspaces to packages/ai and packages/agent. Remove @mariozechner/pi-coding-agent." But the ACTUAL scripts that will replace the originals are not enumerated. The plan only says what must NOT be there (AC-2.2: "scripts do not reference coding-agent, tui, web-ui, browser-smoke, profile"). Positive script content is deferred to implementation. |
| Constraints — specific, cited, complete? | ⚠ | Names `tsgo` and `tsx` as must-stay devDependencies. But misses analysis of root dependencies: `@mariozechner/jiti` and `get-east-asian-width` are NOT used by ai or agent (verified: `grep -rn 'jiti\|get-east-asian-width' packages/ai/src packages/agent/src` returns empty). Should be removed. Also misses `husky` (used by `.husky/` which is removed in Step 1), `concurrently` (used by `dev` script referencing all 5 packages), `shx` (used by version scripts). None are analyzed. |
| Second-order effects? | ✓ | Good analysis of npm workspace build ordering, including self-correction mid-analysis ("Wait — let me verify this"). Names AC for check script and dev script. |
| Failure modes? | ✓ | Names "use `--workspaces` everywhere" pitfall; explains npm ordering behavior. |
| Alternatives? | ✓ | Two: manual cd chain vs `--workspaces`, keep all scripts vs prune. |
| Self-consistency? | ✓ | Consistent with Decision 1 — stripping workspaces requires stripping their scripts. |

**Overall**: The decision is under-specified. The implementation sketch (Step 2) only provides negative grep checks — no positive specification of what scripts should exist, what dependencies should remain, or what the `name`/`version` fields should become. This pushes substantial design work into `/implement` time, where the implementer will need to make decisions the planner deferred.

---

### Decision 3: Replace MIT LICENSE with MPL-2.0

| Field | Score | Evidence |
|---|---|---|
| Decision — clear? | ✓ | "Download MPL-2.0 text from Mozilla, prepend Keel attribution header." |
| Constraints — specific, cited, complete? | ⚠ | AC-3.3: "package.json license field reads 'MPL-2.0'." But Step 3 lists only `LICENSE` as the touched file. Root `package.json` has no `license` field at all (verified). `packages/ai/package.json:94` has `"license": "MIT"` and `packages/agent/package.json:31` has `"license": "MIT"`. These need updating but the step doesn't list them as touched files. A gap: the AC says what but the step doesn't cover it. |
| Second-order effects? | ✓ | Headers (Decision 4), README (Decision 5), hull build script preservation. |
| Failure modes? | ✓ | Two named: (1) "Just write SPDX identifier and skip the file" — why it's wrong. (2) "curl fails" — fallback described. |
| Alternatives? | ✓ | MIT (rejected: proprietary enclosure), AGPL (rejected: viral scope). Reasoned from SETUP.md requirements — independent constraints. |
| Self-consistency? | ✓ | License choice independent of file strip strategy. |

**Overall**: The AC-3.3 / Step 3 touch-list mismatch is a process gap — a criterion that claims a file change but the step doesn't list the file. The plan should either add `packages/ai/package.json` and `packages/agent/package.json` to Step 3's touched files, or move the license-field update to Step 2 (which already touches root `package.json`).

---

### Decision 4: Add MPL-2.0 headers to all harness source files

| Field | Score | Evidence |
|---|---|---|
| Decision — clear? | ⚠ | "Find every .ts, .tsx, .js file ... prepend MPL-2.0 header." But the exact header text is never specified. The grep patterns reference substrings ("Mozilla Public License", "This Source Code Form is subject to the terms of the Mozilla Public") but no complete header template is given. The implementer must choose the header text — this is a deferred detail. |
| Constraints — specific, cited, complete? | ✓ | Three clear constraints: no double-headers, no binary corruption, no encoding breakage. Each with implementation-level handling described. |
| Second-order effects? | ⚠ | Misses a material edge case: `packages/ai/scripts/generate-models.ts` generates `packages/ai/src/models.generated.ts` at build time. Adding an MPL header to `generate-models.ts` does NOT add a header to the generated output. `models.generated.ts` currently has no MPL header (the generation template at the bottom of the script writes "// This file is auto-generated..."). Either the generator must be modified to include the header, or a second pass must add it to the generated file. Neither is in the plan. |
| Failure modes? | ✓ | Two named: (1) "Use a single sed command" — encoding risk explained. (2) Double-headering — mitigation via `grep -rL`. |
| Alternatives? | ✓ | Two: entry-points only (rejected: legal defensibility), npm package (rejected: one-time operation, dependency bloat). |
| Self-consistency? | ✓ | Consistent with Decision 3 — headers are the mechanical follow-up to MPL-2.0 adoption. |

**Overall**: The generated-file gap is the highest-severity finding in this critique. `models.generated.ts` is part of the shipped package (it's imported by `packages/ai/src/index.ts`). Without a header, it's the one source file in the harness without MPL-2.0 coverage — a legal inconsistency the plan doesn't address.

---

### Decision 5: Write harness README.md

| Field | Score | Evidence |
|---|---|---|
| Decision — clear? | ✓ | "Replace pi-mono README with minimal Keel harness README." |
| Constraints — specific, cited, complete? | ✓ | Must reference hull/helm, communicate philosophy, must not describe removed packages — reasonable constraints. |
| Second-order effects? | ✓ | "Sets the tone for the repo. Links to hull and helm establish the three-repo architecture." |
| Failure modes? | ✓ | Two named: (1) "Keep original README and add a note" — confusing. (2) "Too verbose and preachy" — fix described. |
| Alternatives? | ✓ | Two: auto-generate (rejected: needs architecture explanation), SETUP.md verbatim (rejected: too long). |
| Self-consistency? | ✓ | Orthogonal to code and license decisions. |

**Overall**: Clean, well-specified.

---

## Pass 2 — Discipline-axis findings

### 1. Deferred decisions

**D-1: Root package.json script rewrite is underspecified** (Decision 2, Step 2)

Decision 2 says "Simplify scripts to npm run build --workspaces, npm run test --workspaces" but doesn't enumerate all root scripts or their final form. The AC-2.2 uses exclusively negative checks (what must NOT be there). The positive content — what scripts should remain and what they should contain — is deferred to implementation time.

Current root scripts that need explicit decisions (from `package.json:13-39`):
- `clean` — should stay, already uses `--workspaces` → no change needed
- `build` — must be rewritten from manual cd chain to `npm run build --workspaces`
- `dev` — references all 5 packages via concurrently; should be removed or rewritten for ai/agent only
- `dev:tsc` — references ai + web-ui; should be reduced to ai only
- `check` — includes `check:browser-smoke && cd packages/web-ui && npm run check`; must be rewritten
- `check:browser-smoke` — references removed scripts/; must be removed
- `profile:tui`, `profile:rpc` — reference removed scripts/; must be removed
- `test` — already uses `--workspaces`; no change needed
- `version:patch/minor/major/set` — use `shx` and `scripts/sync-versions.js`; scripts/ is removed. Must be removed or rewritten
- `prepublishOnly`, `publish`, `publish:dry` — use `--workspaces` with remaining packages; might work but should be verified
- `release:patch/minor/major` — reference `scripts/release.mjs`; scripts/ is removed. Must be removed
- `prepare: husky` — references removed .husky/; must be removed

This is not a trivial "the implementer can figure it out" situation — 11 of 18 root scripts need decisions. Each is a tiny decision individually, but the aggregate is a design task that belongs in planning, not implementation.

**D-2: MPL-2.0 header text is unspecified** (Decision 4)

The plan never states the exact header text to prepend. The standard MPL-2.0 source header is:

```
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
```

The grep patterns in Step 4's mechanical checks reference substrings of this header, so the implementer can infer it. But for reproducibility and legal clarity, the exact header should be stated in the plan.

**D-3: ci.yml system dependencies are unaddressed** (Step 1)

`.github/workflows/ci.yml:25-27` installs `libcairo2-dev libpango1-dev libjpeg-dev libgif-dev librsvg2-dev fd-find ripgrep`. After stripping tui and coding-agent:
- `libcairo2-dev`, `libpango1-dev`, `libjpeg-dev`, `libgif-dev`, `librsvg2-dev` — canvas/image rendering (tui)
- `fd-find`, `ripgrep` — file search (coding-agent)
- `sudo ln -s $(which fdfind) /usr/local/bin/fd` — coding-agent convenience symlink

None are needed for ai or agent. They won't break the build but waste CI time and confuse readers about what the harness requires. The plan doesn't decide whether to remove them.

---

### 2. Unjustified specifics

**U-1: README line limit of 60** (Step 5, AC-5.4)

`wc -l README.md | awk '{print $1}' | xargs test -le 60` — AC-5.4. Why 60? There's no justification for this specific number. It's an arbitrary threshold that could force the README to be shorter than useful or longer than ideal. Either drop the numeric constraint or justify it.

**U-2: MPL-2.0 curl URL stability assumption** (Decision 3)

The plan cites `https://www.mozilla.org/media/MPL/2.0/index.815ca599c9df.txt`. This URL contains a content hash (`815ca599c9df`) that suggests it could change if Mozilla updates the page. The canonical URL is `https://www.mozilla.org/media/MPL/2.0/index.txt` (tested during SETUP.md download per plan context). The plan should use the hashless URL or state why the hashed one is preferred.

---

### 3. Circular rejection reasoning

No instances found. Rejection reasoning in all decisions is grounded in independent constraints (SETUP.md goals, architectural concerns, tool chain requirements). The "Keep MIT. Rejected: MIT allows proprietary enclosure" rejection could appear circular (rejecting a license for not meeting the goal of switching licenses), but the goal originates from SETUP.md, not self-created — so it's genuinely independent.

---

### 4. Missing decisions on cross-cutting concerns

The plan's cross-cutting concerns table (`## Cross-cutting concerns`) correctly assesses accessibility, error handling, observability, deployment, security, and performance as N/A. Testing is addressed ("run existing tests"). But four concerns are missing:

**M-1: CI/CD pipeline configuration**

`ci.yml` is kept but not reviewed for harness compatibility:
- Line 19-20: `npm ci` — fine
- Line 22-23: `npm run build` — will call the new root `build` script. Works IF the build script is correctly rewritten.
- Line 25-26: `npm run check` — currently includes browser-smoke and web-ui. If the root check script is rewritten correctly, this works. If not, CI breaks silently.
- Line 28-29: `npm test` — uses `--workspaces`, works unchanged.

Additionally, `.github/workflows/openclaw-gate.yml` is not mentioned at all. It checks contributor activity on `openclaw/openclaw` and adds `possibly-openclaw-clanker` labels — pi-mono-specific contribution gating. Should this stay in the keel harness repository? No decision is made.

Similarly, `.github/workflows/issue-gate.yml` and `pr-gate.yml` implement pi-mono's contribution gating policy (`## Contribution Gate` in the pi-mono AGENTS.md). For keel, these may not apply. The plan doesn't decide.

**M-2: Root package.json metadata fields**

The root `package.json` has `"name": "pi-monorepo"` and `"version": "0.0.3"`. Should the name change to `keel-harness` or similar? Should the version reset or increment? The plan doesn't address these. While "no source code changes" covers code in `src/`, package.json metadata is arguably configuration, not source code. The name field in particular changes the npm package identity — keeping `pi-monorepo` would misrepresent the fork.

**M-3: `.gitignore` cleanup**

`.gitignore` contains entries for removed packages and tools:
- `packages/coding-agent/binaries/` — dead
- `tui-debug.log` — dead
- `.pi/` — dead
- `plans/` — dead
- `pi-*.html` — dead
- `compaction-results/` — dead (coding-agent)
- `.opencode/` — dead (coding-agent)
- `.pi/hf-sessions/`, `.pi/hf-sessions-backup/` — dead
- `SETUP.md` — dead

None cause failures, but they create confusion about what artifacts the project generates. The plan doesn't address .gitignore cleanup.

**M-4: Generated source file licensing**

`packages/ai/src/models.generated.ts` is generated by `packages/ai/scripts/generate-models.ts` and shipped as part of the ai package. After adding MPL-2.0 headers to all .ts files (Decision 4), this generated file will lack a header unless the generator is modified or a post-generation pass is added. The plan doesn't address this — neither in the cross-cutting concerns table nor in any decision.

---

### 5. OR clauses in defensive-code constraints

No instances found. The plan is structural (file deletion, config editing, text prepending), not runtime-code addition. There are no try/catch, null check, type guard, or listener cleanup constraints with OR clauses. The closest pattern is Decision 4's "Must not corrupt binary files (we filter to text extensions)" — but the parenthetical is implementation detail, not an OR-clause constraint escape hatch. The mechanical check properly filters to `.ts,.tsx,.js`.

---

## Risk summary

| # | Finding | Severity | Likelihood | Mitigation |
|---|---|---|---|---|
| R1 | `models.generated.ts` lacks MPL-2.0 header post-strip — one shipped source file without license coverage | Medium | Certain (generator doesn't emit header) | Either modify `generate-models.ts` to include header in output, or add post-generation header insertion step |
| R2 | Root package.json script rewrite is underspecified — 11 of 18 scripts need decisions deferred to implementation | Medium | High (implementer may miss scripts, introduce regressions) | Enumerate all root scripts and their final form in Decision 2 or Step 2 |
| R3 | AC-3.3 (package.json license field) targets files not listed in Step 3's touched-files — `packages/ai/package.json` and `packages/agent/package.json` both have `"license": "MIT"` | Low | Certain (AC won't pass if step doesn't update them) | Add `packages/ai/package.json` and `packages/agent/package.json` to Step 3 touched files, or move license-field update to Step 2 |
| R4 | ci.yml installs dead system dependencies (libcairo2-dev, etc.) and `openclaw-gate.yml` is unaddressed | Low | Medium (doesn't break build, wastes CI time) | Either update ci.yml to remove dead deps, or add explicit decision to keep them |
| R5 | `.gitignore` contains dead entries for removed packages | Low | Low (harmless but confusing) | Clean dead .gitignore entries, or add decision to keep them |
| R6 | Root package.json `name` field (`pi-monorepo`) and `version` (`0.0.3`) are not addressed | Low | Low (metadata only, doesn't affect build) | Decide: rename to keel-harness or keep, reset version or increment |
| R7 | MPL-2.0 header text is unspecified — implementer must infer from grep patterns | Low | Low (standard header well-known) | Include exact header text in Decision 4 |
| R8 | README line limit of 60 is arbitrary — no justification | Low | Low (not binding if README is good) | Drop numeric constraint or justify it |

---

## Verdict

**8 findings**, of which 2 are medium severity and 6 are low.

**Single most important to address**: **R1 — `models.generated.ts` lacks MPL-2.0 header.** This is the only finding with legal implications. Every other source file gets an MPL-2.0 header; leaving the generated model registry un-headered creates an inconsistent licensing picture that undermines the "every file" principle stated in Decision 4.

**Second priority**: **R2 — Script rewrite underspecification.** The plan pushes too much design into implementation time. The implementer needs to make 11 independent script decisions without guidance. This increases risk of regression (missed scripts, CI breakage) and makes the plan harder to verify — you can't check the script rewrite against a plan that doesn't say what the scripts should be.

**Critique quality self-assessment**: All findings cite specific lines from the plan or codebase. No fabricated gaps — each finding references a real file, line, or absence that can be independently verified. The perspective (senior engineer, risk/edge cases) is consistently applied: findings focus on build breakage, CI failure modes, legal coverage gaps, and specification completeness — not feature scope, UX, or acceptance criteria.

---

**✅ Critique pass 1 complete (`senior-engineer-risk`) — ready for pass 2**

| Phase | Command | Thinking |
|---|---|---|
| **Now** | `/critique pm-requirements` | **high** |
| Then | `/revise` | **high** |