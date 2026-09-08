---
name: fullcast-status
description: |
  Reports current project state under the fullcast framework: which stage each
  feature is in, task progress, and pointers to reports. Use when the user asks
  "where are we", "what's the status", "show me the board", or similar. Keywords:
  "fullcast status", "project status", "feature board".
---

# fullcast: Status

Read-only. Renders `.fullcast/state.json` for a human — no script needed, the file
is small and this is direct reading, not a mechanical algorithm (see the framework's
`docs/architecture.md` §5 for why this stayed with the model instead of becoming a
script).

## Steps

1. If `.fullcast/state.json` doesn't exist, tell the user to run `fullcast-init`
   first. Stop.

2. Read `.fullcast/state.json`.

3. Render, in this order:

   **Project-level:**
   - `default_methodology`, `language`, `human_in_the_loop` (call it out only when
     `false` — that's the unusual state worth flagging).

   **Awaiting approval** (own small section, right after project-level, only rendered
   when non-empty): every artifact across the whole project currently
   `pending_approval` — any initiative's brief/PRD, any feature's design+tasks+contract
   bundle, or a `evaluator` verdict awaiting ratification. This is the queue a human
   actually needs to act on; put it where it can't be missed.

   **Ready for changesfullcast** (own small section, only rendered when non-empty):
   every initiative with `status: "features_done"` — every feature is `done` but nobody
   said yes to generating the summary yet (architecture.md §21). Name the initiative and
   mention `fullcast-changes` as how to close it.

   **Per initiative**, sorted by `id` (architecture.md §21):
   - `<id> — <name>` — `status` — `branch` (only show branch if set).
   - Its features, same per-feature rendering as below, indented under it.
   - If `status == "archived"`: mention the `changesfullcast` path.

   **Per feature**, sorted by `id`:
   - `<id> — <name>` — `stage` — `methodology` (only show methodology if it differs
     from `default_methodology`, to avoid noise in the common case).
   - Task counts: `<done>/<total> tasks done` (count `status == "done"` vs. length of
     the `tasks` array). If any task has `status: "blocked"`, call it out explicitly.
   - If `stage == "done"`: `estimated_difficulty → real_difficulty`, `tokens_estimated`.

   **Pointers:**
   - If `.fullcast/report.md` exists, mention it as the project-level rollup.
   - If any feature is `done`, mention its `evaluator/summary.md` (under that feature's
     initiative folder).
   - If any initiative is `archived`, mention its `changesfullcast/` file.

4. If the user asked about one specific feature, skip the project-level summary and go
   straight into that feature's detail, including its individual task list with
   statuses (not just the count) **grouped by `phase`**, in phase order — this is what
   makes the plan `tech-lead` wrote in `tasks.md` still legible from `state.json` alone,
   instead of a flat list that hides which tasks belong together. If the user asked
   about one specific initiative instead, render just that initiative's block from
   Step 3, in full (don't summarize its features down to counts).

## Notes

- This skill never writes anything. If the user wants to change a task's status, that
  happens as part of `fullcast-developer`'s normal flow, not here.
- Keep the render terse — this is meant to be glanced at, not read like a report.
