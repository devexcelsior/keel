**Date**: 2026-05-01
**Mode**: focused (step 4)
**Step doc**: docs/roadmap/keel-harness/step-4-add-headers.md

## 1. Files to touch — existence verified

| File | Status | Notes |
|---|---|---|
| `packages/ai/src/` | ✅ Exists | 67 `.ts`/`.tsx`/`.js` source files |
| `packages/ai/test/` | ✅ Exists | 57 test files |
| `packages/ai/scripts/generate-models.ts` | ✅ Exists | Line 1607-1616: `output` template string |
| `packages/agent/src/` | ✅ Exists | 5 source files |
| `packages/agent/test/` | ✅ Exists | 5 test files |
| `packages/agent/vitest.config.ts` | ✅ Exists | Agent package config |
| `packages/ai/vitest.config.ts` | ✅ Exists | AI package config |
| `packages/ai/bedrock-provider.d.ts` | ✅ Exists | Declaration file |
| `packages/ai/bedrock-provider.js` | ✅ Exists | JS declaration stub |

Total files to receive headers: **124** (not ~118 as estimated in step doc). Verified via:
```bash
$ find packages/ai packages/agent \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" \) | grep -v node_modules | wc -l
124
```

## 2. Functions / APIs to call — existence verified

| API | Source | Status | Evidence |
|---|---|---|---|
| `grep -rL` | GNU grep | ✅ | `grep (GNU grep) 3.11` — recursive, files-without-match mode available |
| `sed -i` | GNU sed | ✅ | `sed (GNU sed) 4.9` — in-place editing confirmed on Linux |
| `find` | GNU findutils | ✅ | `find (GNU findutils) 4.9.0` |
| `npm run build` | root package.json:14 | ✅ | `"build": "npm run build --workspaces"` |
| `tsgo` | packages/ai/package.json:64 | ✅ | `Version 7.0.0-dev.20260120.1` |

## 3. Imports to add — package availability verified

No new imports or dependencies. Step is pure bash/file operations and one string edit in `generate-models.ts`.

## 4. Project constraints affecting implementation

| Setting | Value | Impact |
|---|---|---|
| `.gitattributes` `* text=auto eol=lf` | LF enforcement | `sed -i` safe — won't introduce CRLF |
| `tsgo` compiler | v7.0.0-dev | Comment additions won't break build; TS comments stripped at compile |
| `packages/ai/tsconfig.build.json` | exists | Build path for `npm run build` in AC-4.3 |
| `packages/agent/tsconfig.build.json` | exists | Build path for `npm run build` in AC-4.3 |

## 5. Critical caveat — node_modules traversal

The step doc's implementation commands and mechanical checks use `grep -rL` and `find` **without `--exclude-dir=node_modules`**. Both `packages/ai/node_modules/` and `packages/agent/node_modules/` exist and contain `.ts`/`.js` files (e.g., `@types`, `undici-types`).

**Impact**: 
- `grep -rL "Mozilla Public License" packages/ai packages/agent --include="*.ts" --include="*.tsx" --include="*.js"` returns **352 files** (vs 124 source files), because it traverses `node_modules`.
- Without exclusion, the implementation will attempt to prepend headers to `node_modules/@types/**/*.d.ts` files.
- Mechanical check #1 will **fail** (returns non-zero count from `node_modules`).
- Mechanical check #2's `find` will scan `node_modules` and check those files for double headers.

**Fix required in implementation**: Add `--exclude-dir=node_modules` to all `grep -rL` and `find` commands, or scope to `src/` and `test/` subdirectories explicitly.

## Verdict

**Conditional Pass** — implementation ready with caveat.

The `generate-models.ts` edit is straightforward (replace lines 1607-1609 with MPL-2.0 header). The bulk header insertion is mechanically simple. However, **all file-enumeration commands must exclude `node_modules`** or the step will corrupt dependency files and mechanical checks will fail.

Recommendation: implement with `--exclude-dir=node_modules` on every `grep`/`find` invocation, or explicitly target `packages/*/src/` and `packages/*/test/` instead of top-level package directories.
