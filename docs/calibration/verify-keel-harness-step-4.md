# Verify output: keel-harness step 4

**Date**: 2026-05-01
**Step**: step-4-add-headers

## Mechanical constraint checks

| # | Check command | Exit code | Verdict | Notes |
|---|---|---|---|---|
| 1 | `test "$(grep -rL "Mozilla Public License" packages/ai packages/agent --include="*.ts" --include="*.tsx" --include="*.js" \| wc -l)" -eq 0` | 1 | **Fail — step-doc bug** | Grep pattern "Mozilla Public License" does not match the header text (split across lines: "Mozilla Public" / "* License"). Also missing `--exclude-dir=node_modules --exclude-dir=dist`. Returns 446 false-positives from dist/ and node_modules/. |
| 1-corrected | `test "$(grep -rL "This Source Code Form is subject to the terms of the Mozilla Public" packages/ai packages/agent --include="*.ts" --include="*.tsx" --include="*.js" --exclude-dir=node_modules --exclude-dir=dist \| wc -l)" -eq 0` | 0 | **Pass** | 0 files lack header in source directories. |
| 2 | `find packages/ai packages/agent -name "*.ts" -exec sh -c 'test "$(grep -c "This Source Code Form..." "$1")" -le 1' _ {} \;` | 0 | **Pass (fragile)** | `find ... -exec ... \;` only returns exit code of last file processed. Does not catch `generate-models.ts` (count=2: own header + template string) because it wasn't the last file. Also scans `dist/` and `node_modules/`. |
| 2-corrected | `find ... -not -path "*/node_modules/*" -not -path "*/dist/*" -not -name "generate-models.ts" ...` | 0 | **Pass** | No double headers in source files. `generate-models.ts` intentionally has 2 occurrences (own header + AC-4.4 template). |
| 3 | `grep -q "This Source Code Form..." packages/ai/scripts/generate-models.ts` | 0 | **Pass** | Header present in generator template. |
| 4 | `npm run build` | 0 | **Pass** | Build succeeded; generated `models.generated.ts` includes MPL-2.0 header. |

## Constraint gate

| # | Constraint | Satisfied? | Evidence |
|---|---|---|---|
| 1 | "Must not double-header files that already have it." | Yes | `grep -rL` used to find files without header; all 124 source files now have exactly one header. Corrected check #2 confirms zero double headers in source files. |
| 2 | "Must not corrupt binary files (filtered to text extensions only: .ts, .tsx, .js)." | Yes | Only `.ts`/`.tsx`/`.js` files processed; `find`/`grep` `--include` filters to text extensions. No binary files touched. |
| 3 | "Must not break file encoding (sed handles UTF-8/LF correctly; .gitattributes enforces LF)." | Yes | All files remain UTF-8/LF; `.gitattributes:1` enforces `* text=auto eol=lf`. Shebang files (`cli.ts`, `generate-models.ts`, `generate-test-image.ts`, `codex-websocket-cached-probe.ts`) had shebang moved back to line 1 to prevent esbuild syntax error. |

## Invariant gate

| # | Invariant | How verified | Evidence |
|---|---|---|---|
| 1 | "Zero logic changes in any .ts file. Only comment additions." | Git diff analysis of all modified source files. Non-comment additions: only `generate-models.ts:1609` template string replacement (old `// This file is auto-generated...` → MPL header). Non-comment removals: only same line. All other changes are comment-only. | `git diff -- packages/ai/src packages/ai/test packages/ai/scripts packages/agent/src packages/agent/test` — all `+` lines are header comments except one template string line; all `-` lines are old auto-gen comment. |
| 2 | "generate-models.ts logic must not change — only the header string in the template." | Read diff of generate-models.ts. Only lines 1607-1609 changed: old `// This file is auto-generated...` comment block replaced with MPL-2.0 header string. All model fetching, parsing, sorting, and output formatting logic unchanged. | `generate-models.ts:1607-1609` shows template string change only. Build output confirms identical model data. |

## Verification commands

- AC-4.1 (`grep -rL "Mozilla Public License" ... | wc -l | grep -q '^0$'`): exit 1 — **step-doc pattern bug** (see mechanical check #1)
- AC-4.1-corrected (`grep -rL "This Source Code Form..." ... --exclude-dir=node_modules --exclude-dir=dist | wc -l | grep -q '^0$'`): exit 0 ✓
- AC-4.2 (`find packages/ai packages/agent -name "*.ts" | while read f; do count=$(grep -c ...); test "$count" -le 1 || ... done`): exit 1 — **fails on generate-models.ts** (intentional template double) and scans dist/node_modules
- AC-4.2-corrected (excluding dist, node_modules, generate-models.ts): exit 0 ✓
- AC-4.3 (`npm run build`): exit 0 ✓ — both packages build successfully
- AC-4.4 (`grep -q "This Source Code Form..." packages/ai/scripts/generate-models.ts`): exit 0 ✓
- Generated `models.generated.ts` contains header: verified via `grep -q` — exit 0 ✓

## Step-doc mechanical check defects (3rd consecutive step)

1. **Check #1 grep pattern**: Uses "Mozilla Public License" but the header text splits this across lines. Must use "This Source Code Form is subject to the terms of the Mozilla Public" (a single contiguous phrase from the header).
2. **Missing exclusions**: All `grep`/`find` commands must include `--exclude-dir=node_modules --exclude-dir=dist` or they process dependency files and build outputs.
3. **Check #2 / AC-4.2**: Does not account for `generate-models.ts` which legitimately contains the header twice (once as its own license, once in the template string for generated output).

## Overall verdict

**PASS** — Implementation satisfies all constraints and acceptance criteria. Step-doc mechanical check commands contain defects (wrong grep pattern, missing exclusions, not accounting for generator template). Corrected verification commands confirm zero implementation defects.
