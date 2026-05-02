#!/usr/bin/env bash
set -euo pipefail

# sync-upstream — cherry-pick upstream pi-mono commits touching harness packages
# Run from keel/ root.
# Usage: ./scripts/sync-upstream.sh

UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"

if ! git remote get-url "$UPSTREAM_REMOTE" &>/dev/null; then
  echo "Add upstream: git remote add upstream https://github.com/badlogic/pi-mono.git"
  exit 1
fi

git fetch "$UPSTREAM_REMOTE"

LAST_SYNC=$(git rev-parse refs/heads/sync-marker 2>/dev/null || git merge-base HEAD "$UPSTREAM_REMOTE/main")

COMMITS=$(git log --reverse --format="%H" "$LAST_SYNC..$UPSTREAM_REMOTE/main" 2>/dev/null || echo "")

if [[ -z "$COMMITS" ]]; then
  echo "Up to date."
  exit 0
fi

HARNESS_PKGS=("packages/ai" "packages/agent")
APPLIED=0
SKIPPED=0
MANUAL=()

for commit in $COMMITS; do
  FILES=$(git diff-tree --no-commit-id --name-only -r "$commit" 2>/dev/null || echo "")
  MSG=$(git log --format="%s" -1 "$commit" 2>/dev/null)

  TOUCHES_HARNESS=false
  TOUCHES_OTHER=false

  for f in $FILES; do
    matched=false
    for pkg in "${HARNESS_PKGS[@]}"; do
      [[ "$f" == "$pkg"/* || "$f" == "$pkg" ]] && matched=true
    done
    if $matched; then
      TOUCHES_HARNESS=true
    else
      TOUCHES_OTHER=true
    fi
  done

  if $TOUCHES_HARNESS && ! $TOUCHES_OTHER; then
    echo "[$commit] APPLY : $MSG"
    git cherry-pick "$commit" --strategy-option=theirs 2>&1 || {
      echo "CONFLICT — aborting cherry-pick"
      MANUAL+=("CONFLICT:$commit:$MSG")
      git cherry-pick --abort 2>/dev/null || true
    }
    ((APPLIED++)) || true
  elif $TOUCHES_HARNESS && $TOUCHES_OTHER; then
    echo "[$commit] MANUAL: $MSG (touches harness + other files)"
    MANUAL+=("CROSS:$commit:$MSG")
  else
    echo "[$commit] SKIP  : $MSG (harness not touched)"
    ((SKIPPED++)) || true
  fi
done

git branch -f sync-marker "$UPSTREAM_REMOTE/main"

echo ""
echo "Applied: $APPLIED  Skipped: $SKIPPED  Manual: ${#MANUAL[@]}"
for entry in "${MANUAL[@]}"; do
  echo "  $entry"
done
