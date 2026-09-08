#!/usr/bin/env sh
# commit.sh - stage specific files and commit. Never `git add -A` / `git add .`.
# See architecture.md §5: git is external and permanent, so this stays a script
# instead of relying on the model to remember not to stage everything.
#
# Usage:
#   commit.sh "<commit message>" <file1> [<file2> ...]
#
# One commit per task (architecture.md §6/§7) — call this once per completed task,
# passing exactly the files that task touched.

set -eu

if [ $# -lt 2 ]; then
  echo "commit.sh: usage: commit.sh \"<message>\" <file1> [<file2> ...]" >&2
  exit 2
fi

MESSAGE="$1"
shift

for f in "$@"; do
  case "$f" in
    -A|--all|.|"*") echo "commit.sh: refusing broad add pattern '$f' — pass explicit file paths" >&2; exit 2 ;;
  esac
  if [ ! -e "$f" ]; then
    echo "commit.sh: file does not exist: $f" >&2
    exit 2
  fi
done

git add -- "$@"
git commit -m "$MESSAGE"
