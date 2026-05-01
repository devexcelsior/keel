**Date**: 2026-05-01
**Mode**: focused (step 1)
**Step doc**: docs/roadmap/keel-harness/step-1-strip-files.md

## 1. Files to touch — existence verified

| File | Status | Notes |
|---|---|---|
| `packages/coding-agent/` | ✅ Exists | Directory to remove |
| `packages/tui/` | ✅ Exists | Directory to remove |
| `packages/web-ui/` | ✅ Exists | Directory to remove |
| `scripts/` | ✅ Exists | Directory to remove |
| `.husky/` | ✅ Exists | Directory to remove |
| `.pi/` | ✅ Exists | Directory to remove |
| `AGENTS.md` | ✅ Exists | File to remove |
| `CONTRIBUTING.md` | ✅ Exists | File to remove |
| `pi-test.ps1` | ✅ Exists | File to remove |
| `pi-test.sh` | ✅ Exists | File to remove |
| `test.sh` | ✅ Exists | File to remove |
| `.github/workflows/build-binaries.yml` | ✅ Exists | File to remove |
| `.github/workflows/openclaw-gate.yml` | ✅ Exists | File to remove |
| `.github/workflows/issue-gate.yml` | ✅ Exists | File to remove |
| `.github/workflows/pr-gate.yml` | ✅ Exists | File to remove |
| `.github/workflows/approve-contributor.yml` | ✅ Exists | File to remove |
| `.github/workflows/ci.yml` | ✅ Exists | Edit: remove system deps block |
| `.gitignore` | ✅ Exists | Edit: remove dead entries |

## 2. Functions / APIs to call — existence verified

N/A — this step is file deletion and text editing. No code APIs called.

## 3. Imports to add — package availability verified

N/A — no new packages imported.

## 4. Project constraints affecting implementation

N/A — this step is structural file operations. No tsconfig/eslint/code constraints apply.

## 5. Verdict

Pass: ready to `/implement`.

All 18 files/directories to touch exist. `ci.yml` contains the expected system deps block (lines 25-28) to remove. `.gitignore` contains all listed dead entries to remove. No APIs, imports, or project constraints to verify.
