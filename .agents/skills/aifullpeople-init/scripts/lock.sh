#!/usr/bin/env sh
# lock.sh - prevent two agents/sessions from working on the same project or
# feature scope at once (architecture.md §18). Not a script for style reasons —
# it's a script because it does a liveness check (kill -0) that's easy to get
# wrong by hand, and a stale/corrupted lock is worse than no lock at all.
#
# Usage:
#   lock.sh acquire <lockfile> <role>
#   lock.sh release <lockfile>
#
# acquire:
#   - lockfile doesn't exist -> create it as "<PID> <role> <ISO-timestamp>", exit 0.
#   - lockfile exists, owning PID is alive (kill -0 succeeds) -> exit 1, print who
#     holds it and since when. Caller must abort — do not proceed with the role's
#     work while this prints a failure.
#   - lockfile exists, owning PID is dead -> stale lock from a crashed run.
#     Overwrite it, print a one-line note (caller should log it as a soft-fail,
#     not silently ignore it), exit 0.
#
# release:
#   - delete the lockfile. Idempotent — exit 0 even if it's already gone.
#   - call this on EVERY termination path of the role's work, success or abort.
#     A lock only survives across runs if the process holding it actually
#     crashed (no chance to run its own cleanup) — that's the one case
#     "acquire" already handles by treating a dead PID as stale.
#
# Portability note: kill -0 is POSIX, works in any Unix-like sandbox (Claude
# Code, Codex, Copilot's typical Linux/macOS environments). Native Windows
# without a POSIX layer is unverified — flag it if you hit that combination.

set -eu

cmd="${1:-}"
lockfile="${2:-}"

case "$cmd" in
  acquire)
    role="${3:-}"
    if [ -z "$lockfile" ] || [ -z "$role" ]; then
      echo "lock.sh: usage: lock.sh acquire <lockfile> <role>" >&2
      exit 2
    fi
    if [ -f "$lockfile" ]; then
      owner_pid=$(awk '{print $1}' "$lockfile" 2>/dev/null || echo "")
      if [ -n "$owner_pid" ] && kill -0 "$owner_pid" 2>/dev/null; then
        echo "lock.sh: locked — $(cat "$lockfile")" >&2
        echo "lock.sh: another run is in progress on this scope. Wait for it to finish, or confirm it's actually dead before removing $lockfile by hand." >&2
        exit 1
      fi
      echo "lock.sh: stale lock from PID ${owner_pid:-unknown} (not alive) — overwriting" >&2
    fi
    mkdir -p "$(dirname "$lockfile")"
    echo "$$ $role $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$lockfile"
    exit 0
    ;;
  release)
    if [ -z "$lockfile" ]; then
      echo "lock.sh: usage: lock.sh release <lockfile>" >&2
      exit 2
    fi
    rm -f "$lockfile"
    exit 0
    ;;
  *)
    echo "lock.sh: usage: lock.sh acquire|release <lockfile> [role]" >&2
    exit 2
    ;;
esac
