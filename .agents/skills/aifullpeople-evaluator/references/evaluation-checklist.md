# AC re-check checklist

Detail for `aifullpeople-evaluator`'s validation pass. This is "how to interpret and execute a
`contract.md` item" — see `docs/architecture.md` §7 for why the re-check is contract-
driven instead of free judgment, and §8 for why Gates are a precondition, not part of
this checklist.

## Precondition: Gates must already be green

Do not start walking `contract.md` until `aifullpeople-developer`'s full-suite Gates
passed. If they didn't, bounce the feature back immediately — Gates are engineering
correctness, this checklist is product correctness, and there is no reason to spend a
review pass on code that doesn't even build/lint/test clean.

## Walking the contract

For each surface in `contract.md`, for each item:

1. Read the item's `given`/`when`/`then` and the surface's `Verification mode` line.
2. Set up `given` (using the feature's Prerequisites section for anything not already
   satisfied by the implementation itself — e.g. seed the persistent-state accounts it
   declares).
3. Perform `when` — exactly the one action described, through the mechanism the
   `Verification mode` line names (HTTP request, CLI invocation, rendered UI
   interaction, etc.).
4. Check every bullet in `then` actually holds. All bullets must hold for the item to
   pass — a partial match is a fail, not a "mostly pass".
5. An item with `notes: subjective; manual review only` — use judgment against the
   PRD's acceptance criterion this item covers (see the Coverage Manifest); this is the
   one case where the checklist explicitly asks for human/agent judgment instead of a
   mechanical check.
6. Record ✓ or ✗ per item id, with a one-line reason for any ✗ (what `then` bullet
   failed and what was observed instead — this is the evidence the fix-runner will
   need if the feature is rejected; write it now, not from memory later).

**Persist the walk, every run, before deciding:** write
`.aifullpeople/features/<id>/evaluator/eval-report-<ISO-timestamp>.md` — one row per
item (✓/✗ + reason), regardless of the final verdict. This is what makes the walk
readable outside this run's own context — `aifullpeople-developer-fix-runner`
(architecture.md §19) runs in its own subagent and has no access to this
conversation's chat history; the eval-report is its only source of evidence.

## Decision

- **All items ✓** → approve. Proceed to "On approval" below.
- **Any item ✗** → reject. Proceed to "On rejection" below. Do not partially approve —
  the feature either reaches `done` as a whole or it doesn't.

## On rejection

1. Set the feature's `state.json` `stage` back to `"implementation"`.
2. List every failing item id + a one-line reason, and which `tasks.md` task most
   plausibly owns the gap (match by the capability/surface the item belongs to).
3. Do NOT reopen already-`done` tasks and do NOT invent new task entries yourself —
   that distinction (original task vs. corrective pass) is exactly what
   `aifullpeople-developer-fix-runner` (architecture.md §19) exists to preserve.
   Point the user at it, naming the `eval-report-<ts>.md` path and the failing item
   IDs — it reads the report directly, targets only those items, and never touches
   `tasks.md`.
4. Append a history entry (`event: "validation_rejected"`, `role: "evaluator"`,
   `feature: "<id>"`).

## On approval — build the three feature-level reports

**`summary.md`** — what was implemented (from the task reports' "What was done"
sections), decisions worth surfacing, and the full contract item checklist (✓ per item,
grouped by surface/capability — this replaces free-form AC prose with the concrete
list).

**`difficulty.md`** — two lines:
- Estimated (from `tasks.md`/`state.json.estimated_difficulty`, set by `tech-lead`).
- Real — derive from the task reports: count deviations, hard-fail retries, and any
  redesign noted across `developer/*.md`. Zero or one minor deviation and no retries
  → real difficulty matches estimated. Several deviations, or hard-fail retries against
  the retry limit, or a redesign mid-feature → bump one level (trivial→simple→
  medium→complex). Write the reasoning, not just the label.

**`tokens.md`** — sum the token estimate printed at the end of each
`developer/*.md` task report. State the total, then the per-task breakdown. Include the
same disclaimer as the task-level estimates: floor, not the session total; run `/cost`
for the real figure.

Then:
1. Write all three files to `.aifullpeople/features/<id>/evaluator/`.
2. Update `state.json`: `features[].stage` → `"done"`; `features[].real_difficulty` →
   the value from `difficulty.md`; `features[].tokens_estimated` → the total from
   `tokens.md`.
3. Update `.aifullpeople/report.md` (project-level rollup) — add or refresh this
   feature's row: name, estimated/real difficulty, tokens estimated, completion date.
   This file is a rendering of `state.json`, never a second source of truth — if it
   ever disagrees with `state.json`, `state.json` is right and `report.md` needs
   regenerating, not the other way around.
4. Append a history entry (`event: "feature_done"`, `role: "evaluator"`, `feature: "<id>"`).
5. **Commit the approval.** `aifullpeople-evaluator` has no `scripts/` of its own — reuse
   `aifullpeople-developer`'s `commit.sh` (they're always installed side by side;
   found needed the first time this framework was run end-to-end):
   ```
   ../aifullpeople-developer/scripts/commit.sh "chore(<id>): Evaluator approval — feature done" \
     .aifullpeople/state.json .aifullpeople/report.md \
     .aifullpeople/features/<id>/evaluator/{summary,difficulty,tokens}.md
   ```
   Same rule as every other commit in this framework: `.aifullpeople/` is versioned,
   never `git add -A`.
