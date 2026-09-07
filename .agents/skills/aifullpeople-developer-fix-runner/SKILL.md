---
name: aifullpeople-developer-fix-runner
description: |
  Targeted corrective pass for a feature aifullpeople-evaluator rejected. Reads
  only the failing contract.md items + their eval-report evidence and makes the
  minimal edit to satisfy them — never re-walks tasks.md, never adds or reopens
  tasks. One commit per cycle, gated by explicit human approval before it lands.
  Use after aifullpeople-evaluator rejects a feature. Keywords: "fix the failing
  items", "aifullpeople fix-runner", "address evaluator rejection".
---

# aifullpeople: Developer Fix Runner

Not a 5th pipeline stage — this only runs when `aifullpeople-evaluator` rejected a
feature (`docs/architecture.md` §19). Adapted, heavily trimmed, from a template the
project owner brought in; PR/merge handling, automated retry loops, and multi-field
progress tracking are deliberately left out — this framework has no branch/PR model
yet, and every retry decision here is a human's, not a circuit-breaker's.

Persona note: no persona of its own — it's `aifullpeople-developer` (Miles Morales)
doing a different kind of pass, not a new character.

## Prerequisites

- Locate the feature folder and its latest
  `evaluator/eval-report-<ISO-timestamp>.md` — by explicit path, or the newest one
  if several exist. Require it to exist; abort with a clear message if not (nothing
  to fix without a report naming what failed).
- Require the feature's `state.json` `stage` to be `"implementation"` (evaluator sets
  this on rejection). If it's anything else, stop — this isn't the right moment.
- **Acquire the feature-level lock** (architecture.md §18) —
  `../aifullpeople-init/scripts/lock.sh acquire <feature-folder>/.lock developer-fix-runner`.
  Non-zero exit means another run owns this feature — stop and tell the user.
  **Release it** on every exit path.
- Read `.aifullpeople/config.yaml` for enabled Gates and `context_project.md` for
  cached Gate commands — same as `aifullpeople-developer`.

Full execution detail — diagnosis-by-surface heuristics, the edit precedence rule,
validation budget, HiTL wording — lives in `references/fix-rules.md`. Load it now.

## Steps

1. **Read the failing items.** From the eval-report: which item IDs failed, and the
   one-line reason recorded for each. From `tech-lead/contract.md`: the full body of
   just those items (`given`/`when`/`then`, the surface's `Verification mode`, the
   relevant `Common given`). From `tech-lead/design.md`: only the sections those items'
   surfaces map to (Component Overview entries, matching API Contracts/Data
   Model/Error Handling slices) — not the whole file. Do NOT read `tech-lead/tasks.md`
   — this is a corrective pass, not a re-plan.

2. **Diagnose.** Per `references/fix-rules.md`'s surface → likely-fix-site table.
   Classify each failing item by its surface heading in the eval-report.

3. **Edit the minimum** that would plausibly satisfy the failing items.
   `contract.md` items are canonical for observable behavior; `design.md` is canonical
   for internal structure. If satisfying an item would require changing `contract.md`,
   `design.md`, or `tasks.md` themselves — stop. That means the gap is in the design,
   not the implementation; report it and point back to `aifullpeople-tech-lead` to
   regenerate the three-file bundle, per its own hard-coverage-gate discipline.

4. **Validate.** Run the Gates relevant to files touched, same tri-state semantics as
   `aifullpeople-developer` (hard-fail retry ≤ 3, soft-fail logged, pre-existing
   failure logged and not retried). Budget exhausted with something still red → stop,
   status `gates-failed`, no commit, working tree left dirty for inspection.

5. **HiTL checkpoint (architecture.md §15 and §19 — mandatory, no
   `human_in_the_loop: false` bypass for this skill specifically).** Present: which
   items were targeted, what changed (file list, not full diff), and the Gate result.
   Wait for explicit approval before committing. This is the framework's
   circuit-breaker for repeated fix cycles — a human decides whether cycle N+1 is
   worth running, not an automatic counter.

6. **On approval:**
   - Write `.aifullpeople/features/<id>/developer/fix-<n>.md` (n = this feature's
     `fix_cycles` + 1) from `assets/fix-report-template.md` — items targeted, what
     changed, Gate results, token estimate (`../aifullpeople-developer/scripts/
     estimate_tokens.sh`, same as any other task-shaped unit of work).
   - Commit via `../aifullpeople-developer/scripts/commit.sh
     "fix(<feature-id>): cycle <n> — address items <list>" <files touched>
     .aifullpeople/state.json <the fix report>`.
   - Update `state.json`: `features[].fix_cycles` += 1; `features[].stage` →
     `"validation"` (ready for `evaluator` to walk again). Append a history entry
     (`event: "fix_cycle_completed"`, `role: "developer-fix-runner"`,
     `feature: "<id>"`).

7. **Report** the outcome (`fixed` / `gates-failed` / `aborted`) and, on `fixed`, that
   `aifullpeople-evaluator` is next.

## Always / Never

Always: read only the failing items' bodies plus their design.md sections; require an
eval-report to exist before starting; validate via the same Gate semantics as
`aifullpeople-developer`; get explicit HiTL approval before every commit; increment
`fix_cycles`, never fold a fix into `tasks[]`.

Never: read or edit `tasks.md`; edit `contract.md` or `design.md` (abort and defer to
`tech-lead` instead); reopen an already-`done` task; add a new task entry; skip the
HiTL checkpoint under any override; commit with a red Gate.
