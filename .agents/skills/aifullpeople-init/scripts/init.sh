#!/usr/bin/env sh
# init.sh - scaffold .aifullpeople/ and context_project.md in the current project.
# See architecture.md §5 for why this is a script (bulk filesystem write, wants to be
# idempotent, must not leave the project half-scaffolded if it fails midway).
#
# Usage:
#   init.sh [--language en|pt-BR] [--stack <primary_language>] [--force]
#
# Defaults: --language en --stack go
# --force overwrites an existing .aifullpeople/ (asks nothing; the caller — the model
# running this skill — is responsible for confirming with the user first).

set -eu

LANGUAGE="en"
STACK="go"
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --language) LANGUAGE="$2"; shift 2 ;;
    --stack) STACK="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    *) echo "init.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done

case "$LANGUAGE" in
  en|pt-BR) ;;
  *) echo "init.sh: --language must be 'en' or 'pt-BR', got '$LANGUAGE'" >&2; exit 2 ;;
esac

ROOT_DIR="$(pwd)"
STATE_DIR="$ROOT_DIR/.aifullpeople"
CONTEXT_FILE="$ROOT_DIR/context_project.md"

if [ -d "$STATE_DIR" ] && [ "$FORCE" -ne 1 ]; then
  echo "init.sh: $STATE_DIR already exists. Re-run with --force to overwrite, or use" >&2
  echo "aifullpeople-status to inspect the current state instead." >&2
  exit 1
fi

mkdir -p "$STATE_DIR/pm" "$STATE_DIR/features"

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cat > "$STATE_DIR/config.yaml" <<EOF
language: $LANGUAGE
methodology: aifullpeople     # default for NEW features — see architecture.md §9
human_in_the_loop: true       # required approval at every stage transition — see architecture.md §15
                               # set false only to opt into fully autonomous runs
stack:
  primary_language: $STACK
  # guidance_skill: golang-pro    # optional — override the "<primary_language>-pro" convention
  # guidance_source: skill        # "skill" (default) | "guidelines" — see architecture.md §5
  # guidelines_exclude: [naming-conventions]   # optional — turn off a shared root category
gates:
  compile: true
  lint: true
  dependency_boundary: true
  custom: false          # true once the project has a Gate 4 custom script
  tests: true
  dead_code: true
  security: false        # 7th gate, opt-in — see architecture.md §8
EOF

cat > "$STATE_DIR/state.json" <<EOF
{
  "language": "$LANGUAGE",
  "default_methodology": "aifullpeople",
  "context_project": { "path": "context_project.md", "last_updated": "$NOW" },
  "artifacts": {},
  "features": [],
  "history": [
    { "at": "$NOW", "event": "project_initialized", "role": "pm" }
  ]
}
EOF

if [ ! -f "$CONTEXT_FILE" ]; then
  cat > "$CONTEXT_FILE" <<EOF
# Project context

*Living document. pm/tech-lead/developer/evaluator append to it; nobody rewrites it wholesale
(architecture.md §11). Not tied to any one methodology — shared by whatever methodology
touches this repo.*

## Priority rule

If this file has content under "Architecture" or "Discovered patterns" below, that
content is authoritative — no role should override it with a generic default. Only
while this file is genuinely empty (true greenfield) does the user's stated
preference take priority; once they answer, the answer is written here and becomes
authoritative from then on (architecture.md §11).

## Stack

- Primary language: $STACK (see \`.aifullpeople/config.yaml\`)
- (fill in as the codebase grows: framework, database, auth strategy, API style,
  validation approach, testing framework, error handling, folder structure)

## Architecture

(empty — greenfield as of $NOW. First feature's tech-lead pass asks for the
architecture style explicitly — Clean Architecture, hexagonal, simple layered,
whatever the user names — before anything else, and writes the answer here)

## Discovered patterns

(empty — this is a greenfield project as of $NOW; the first feature's tech-lead pass
will run pattern discovery once real code exists and append findings here)

## Gate commands

(empty — developer fills this in the first time each Gate's command is discovered,
so it is never rediscovered per task; see architecture.md §7/§8)
EOF
fi

# .lock files are per-machine, per-process state (a PID meaningless to anyone
# else) — they must never be committed, even though the rest of .aifullpeople/
# is versioned by design (architecture.md §13). Add the ignore rule once,
# without clobbering an existing .gitignore.
GITIGNORE="$ROOT_DIR/.gitignore"
if [ ! -f "$GITIGNORE" ] || ! grep -qF ".aifullpeople/**/.lock" "$GITIGNORE" 2>/dev/null; then
  {
    echo ""
    echo "# aifullpeople execution locks (architecture.md §18) — per-machine, never versioned"
    echo ".aifullpeople/.lock"
    echo ".aifullpeople/**/.lock"
  } >> "$GITIGNORE"
fi

# Ensure there's a git baseline BEFORE any aifullpeople artifact is committed.
# Without this, aifullpeople-developer's estimate_tokens.sh has no HEAD to diff
# against on the first task, and every doc produced by pm/tech-lead up to that
# point (PRD, design, tasks, contract) gets counted as "written" by task 1 —
# discovered by actually running the pipeline end-to-end, not a hypothetical.
if git rev-parse --git-dir >/dev/null 2>&1; then
  if ! git rev-parse HEAD >/dev/null 2>&1; then
    git add -- "$STATE_DIR" "$CONTEXT_FILE" "$GITIGNORE" >/dev/null 2>&1 || true
    git commit -q -m "chore: bootstrap aifullpeople" >/dev/null 2>&1 || true
  fi
fi

echo "Initialized .aifullpeople/ (language=$LANGUAGE, stack=$STACK) and context_project.md"
