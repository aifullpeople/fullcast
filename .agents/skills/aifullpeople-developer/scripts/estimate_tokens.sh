#!/usr/bin/env sh
# estimate_tokens.sh - rough token estimate for the task just completed.
# Formula (architecture.md §10.1): tokens = round((bytes_read + bytes_written) / 4)
# Deliberately a floor, not the real session total — doesn't count conversation
# overhead, thinking, tool calls, or retries. Run this BEFORE commit.sh, while the
# task's changes are still uncommitted working-tree diffs.
#
# Usage:
#   estimate_tokens.sh [context-file ...]
#
#   <context-file>...  paths consulted for this task (design.md/tasks.md excerpts,
#                      guideline files) — their current byte size counts as "read".
#                      Files already edited by this task should NOT be passed here;
#                      their pre/post-edit bytes are captured via git diff instead.
#
# "Written" bytes come from the current uncommitted diff: `git diff HEAD` for tracked
# changes, plus the content of any new untracked files reported by `git status
# --porcelain`. Run outside a git repo (or before the first commit) still works —
# written bytes just come back as 0, logged as a warning on stderr.
#
# Output: prints the integer token estimate to stdout. Prints a byte breakdown to
# stderr for transparency.

set -eu

READ_BYTES=0
for f in "$@"; do
  if [ -f "$f" ]; then
    size=$(wc -c < "$f" | tr -d ' ')
    READ_BYTES=$((READ_BYTES + size))
  fi
done

WRITTEN_BYTES=0
if git rev-parse --git-dir >/dev/null 2>&1; then
  if git rev-parse HEAD >/dev/null 2>&1; then
    diff_bytes=$(git diff HEAD | wc -c | tr -d ' ')
    WRITTEN_BYTES=$((WRITTEN_BYTES + diff_bytes))
  else
    echo "estimate_tokens.sh: no HEAD commit yet — skipping tracked diff" >&2
  fi

  untracked_bytes=0
  while IFS= read -r line; do
    case "$line" in
      "?? "*)
        path="${line#\?\? }"
        [ -f "$path" ] && untracked_bytes=$((untracked_bytes + $(wc -c < "$path" | tr -d ' ')))
        ;;
    esac
  done <<EOF
$(git status --porcelain --untracked-files=all)
EOF
  WRITTEN_BYTES=$((WRITTEN_BYTES + untracked_bytes))
else
  echo "estimate_tokens.sh: not a git repository — written bytes reported as 0" >&2
fi

TOTAL_BYTES=$((READ_BYTES + WRITTEN_BYTES))
TOKENS=$(( (TOTAL_BYTES + 2) / 4 ))  # +2 for round-to-nearest instead of truncation

echo "estimate_tokens.sh: read=${READ_BYTES}B written=${WRITTEN_BYTES}B total=${TOTAL_BYTES}B -> ${TOKENS} tokens (floor estimate, not session total)" >&2
echo "$TOKENS"
