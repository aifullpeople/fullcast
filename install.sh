#!/usr/bin/env sh
# install.sh - copy the fullcast framework's skills/guidelines into a target project.
# See docs/architecture.md §2.1 — this replaces the manual 5-step process documented
# there. Safe to re-run (overwrites only the framework's own files under
# .agents/skills/, .claude/skills/, guidelines/, schema/; never touches the target
# project's own .fullcast/ state, context_project.md, or code).
#
# Usage:
#   ./install.sh <path-to-target-project>
#
# <path-to-target-project> can be a brand-new/empty directory (created if it doesn't
# exist yet) or an existing project. After this script finishes, run `fullcast-init`
# (via Claude Code, inside that project) to scaffold .fullcast/ and context_project.md.

set -eu

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "install.sh: usage: install.sh <path-to-target-project>" >&2
  exit 2
fi

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$TARGET"
TARGET_DIR="$(cd "$TARGET" && pwd)"

if [ "$SOURCE_DIR" = "$TARGET_DIR" ]; then
  echo "install.sh: target is this framework's own repo — nothing to do." >&2
  exit 1
fi

echo "Installing fullcast into: $TARGET_DIR"

mkdir -p "$TARGET_DIR/.agents/skills" "$TARGET_DIR/.claude/skills" \
         "$TARGET_DIR/guidelines" "$TARGET_DIR/schema"

# 1. Framework skills (fullcast-*), read as-is from this repo.
for d in "$SOURCE_DIR"/.agents/skills/fullcast-*; do
  name="$(basename "$d")"
  rm -rf "$TARGET_DIR/.agents/skills/$name"
  cp -R "$d" "$TARGET_DIR/.agents/skills/$name"
done

# 2. Stack guidance skills (golang-pro, etc. — architecture.md §5.2), same layout:
#    real content in stack/, flat reference symlink alongside it.
rm -rf "$TARGET_DIR/.agents/skills/stack"
cp -R "$SOURCE_DIR/.agents/skills/stack" "$TARGET_DIR/.agents/skills/stack"
for d in "$TARGET_DIR"/.agents/skills/stack/*/; do
  name="$(basename "$d")"
  rm -f "$TARGET_DIR/.agents/skills/$name"
  ln -s "stack/$name" "$TARGET_DIR/.agents/skills/$name"
done

# 3. Shared guidelines — the 5 root files only. Per-stack guidelines/<stack>/ is the
#    opt-in custom path (config.yaml: stack.guidance_source: guidelines) — not shipped,
#    add it by hand in the target project if you actually want that path instead of a
#    stack skill.
cp "$SOURCE_DIR"/guidelines/*.md "$TARGET_DIR/guidelines/"

# 4. Schema docs — reference only, read by the model before hand-editing config/state,
#    never enforced by a script. Small, safe to always include.
cp "$SOURCE_DIR"/schema/*.json "$TARGET_DIR/schema/"

# 5. .claude/skills symlinks — this is what Claude Code actually scans for skill
#    discovery; one flat entry per item installed above.
for d in "$TARGET_DIR"/.agents/skills/fullcast-* "$TARGET_DIR"/.agents/skills/stack/*/ "$TARGET_DIR/.agents/skills/stack"; do
  name="$(basename "$d")"
  rm -f "$TARGET_DIR/.claude/skills/$name"
  ln -s "../../.agents/skills/$name" "$TARGET_DIR/.claude/skills/$name"
done

echo ""
echo "Done. Installed under:"
echo "  $TARGET_DIR/.agents/skills/  (fullcast-*, stack/)"
echo "  $TARGET_DIR/.claude/skills/  (symlinks, for Claude Code discovery)"
echo "  $TARGET_DIR/guidelines/      (5 shared files)"
echo "  $TARGET_DIR/schema/          (reference docs)"
echo ""
echo "Next: open \"$TARGET_DIR\" in Claude Code and run fullcast-init."
