---
name: aifullpeople-status
description: |
  Reports current project state under the aifullpeople framework: which stage each
  feature is in, task progress, and pointers to reports. Use when the user asks
  "where are we", "what's the status", "show me the board", or similar. Keywords:
  "aifullpeople status", "project status", "feature board".
---

# aifullpeople: Status

Read-only. Renders `.aifullpeople/state.json` for a human — no script needed, the file
is small and this is direct reading, not a mechanical algorithm (see the framework's
`docs/architecture.md` §5 for why this stayed with the model instead of becoming a
script).

## Steps

1. If `.aifullpeople/state.json` doesn't exist, tell the user to run `aifullpeople-init`
   first. Stop.

2. Read `.aifullpeople/state.json`.

3. Render, in this order:

   **Project-level:**
   - `default_methodology`, `language`, `human_in_the_loop` (call it out only when
     `false` — that's the unusual state worth flagging).
   - Status of `artifacts.brief` and `artifacts.prd` (missing / pending / done). A
     status of `pending_approval` is the one to surface prominently — it means
     something is sitting in the HiTL queue (architecture.md §15) waiting on the user,
     not on any role.

   **Awaiting approval** (own small section, right after project-level, only rendered
   when non-empty): every artifact across the whole project currently
   `pending_approval` — brief/PRD, any feature's design+tasks+contract bundle, or a
   `evaluator` verdict awaiting ratification. This is the queue a human actually needs to act
   on; put it where it can't be missed.

   **Per feature**, sorted by `id`:
   - `<id> — <name>` — `stage` — `methodology` (only show methodology if it differs
     from `default_methodology`, to avoid noise in the common case).
   - Task counts: `<done>/<total> tasks done` (count `status == "done"` vs. length of
     the `tasks` array). If any task has `status: "blocked"`, call it out explicitly.
   - If `stage == "done"`: `estimated_difficulty → real_difficulty`, `tokens_estimated`.

   **Pointers:**
   - If `.aifullpeople/report.md` exists, mention it as the project-level rollup.
   - If any feature is `done`, mention its `features/<id>/evaluator/summary.md`.

4. If the user asked about one specific feature, skip the project-level summary and go
   straight into that feature's detail, including its individual task list with
   statuses (not just the count) **grouped by `phase`**, in phase order — this is what
   makes the plan `tech-lead` wrote in `tasks.md` still legible from `state.json` alone,
   instead of a flat list that hides which tasks belong together.

## Notes

- This skill never writes anything. If the user wants to change a task's status, that
  happens as part of `aifullpeople-developer`'s normal flow, not here.
- Keep the render terse — this is meant to be glanced at, not read like a report.
