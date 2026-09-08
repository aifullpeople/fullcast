---
name: fullcast-changes
description: |
  Generates the closing summary for a finished initiative — every feature under it is
  `done`, and this writes changesfullcast/<date>-<id>-<slug>.md at the project root
  rolling up what was built, decisions worth keeping, and difficulty/token numbers per
  feature. Not a pipeline stage of its own: fullcast-evaluator (Gwen Stacy) offers to
  run this the moment it approves an initiative's last feature (architecture.md §21); can
  also be run by hand later for an initiative already marked "features_done". Keywords:
  "generate changesfullcast", "close this initiative", "initiative summary",
  "fullcast changesfullcast".
---

# fullcast: changesfullcast

Not a 5th role — same logic as `fullcast-developer-codereview` (§20) and
`fullcast-developer-fix-runner` (§19): a focused pass invoked at a specific moment,
not a new persona. This one belongs to no single role in particular (it reads across
every feature `evaluator` already closed), so it stands as its own skill instead of
living inside `fullcast-evaluator`'s already-long `SKILL.md`.

Invocation note: run as a delegated subagent (architecture.md §17) when invoked from
`fullcast-evaluator`'s Step 6.5, same as any other role pass. When the orchestrating
tool supports isolated subagent worktrees (Claude Code's Agent tool: `isolation:
"worktree"`), **always** use it (§17, §21).

## Prerequisites

- Resolve the initiative from the input (`initiative=<id>` or a bare id/name/path) —
  `.fullcast/<id>-<slug>/`.
- Require every id in the initiative's `feature_ids` to be `stage: "done"` in
  `state.json`. If any isn't, stop and say which — this skill never runs on a partial
  initiative (that's exactly what `status: "features_done"` vs. `"archived"` exists to
  distinguish, architecture.md §21).
- **Acquire the project-level lock** (architecture.md §18, same scope `pm` uses — this
  writes to `state.json` at the project level, not just one feature):
  `../fullcast-init/scripts/lock.sh acquire .fullcast/.lock changesfullcast`.
  Non-zero exit means another run holds it — stop and tell the user. **Release it** on
  every exit path.

## Steps

1. **Gather.** For every feature in `feature_ids`, read its
   `evaluator/{summary,difficulty,tokens}.md` (the source of truth for what shipped —
   never re-derive from raw task reports when the evaluator summary already exists) and
   `tech-lead/design.md`'s Component Overview (one line on what the feature actually
   is, for readers who never open the initiative folder). If the initiative has
   `artifacts.brief`/`artifacts.prd`, note their paths too.

2. **Write** `changesfullcast/<YYYY-MM-DD>-<initiative-id>-<slug>.md` (today's date, at
   the **project root** — sibling to `.fullcast/`, never inside it: this is meant to
   be readable without knowing the framework's internal layout) from
   `assets/changesfullcast-template.md`. Content:
   - Initiative name, id, dates (`created_at` → today), branch (if one was created).
   - One entry per feature: id, name, one-line what-it-is, real difficulty, tokens,
     link to its `evaluator/summary.md` for full detail.
   - Aggregate: feature count, total tokens, difficulty distribution.
   - Decisions worth keeping — pull from each feature's `summary.md` "decisions worth
     surfacing" if that pattern was used; skip this block if none exist, don't invent
     content to fill it.

3. **Update `state.json`:**
   - This initiative's `status` → `"archived"`.
   - `changesfullcast` → `{path, status: "done"}`.
   - Append a history entry (`event: "changesfullcast_generated"`, `role: "evaluator"`,
     initiative id noted in the entry — reuses the `evaluator` role tag, same
     not-a-new-persona logic as the invocation note above).

4. **Commit.** Reuse `fullcast-developer`'s `commit.sh` (same pattern
   `fullcast-evaluator` already uses):
   ```
   ../fullcast-developer/scripts/commit.sh "chore(<initiative-id>): changesfullcast — initiative closed" \
     .fullcast/state.json changesfullcast/<date>-<initiative-id>-<slug>.md
   ```

5. **Report** the changesfullcast file path and a one-line confirmation the initiative
   is now `archived`.

## Always / Never

Always: require every feature in the initiative `done` before starting; pull content
from the evaluator summaries that already exist rather than re-deriving it; write to
`changesfullcast/` at the project root, never under `.fullcast/`.

Never: run on an initiative with any feature not yet `done`; invent a "decisions" entry
when the source summaries don't have one; treat this as a verdict or gate — it's a
rollup, nothing here can reopen or fail a feature.
