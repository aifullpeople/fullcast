---
name: aifullpeople-developer
description: |
  Developer role (persona: Miles Morales) of the aifullpeople framework. Implements a
  feature's tasks.md task by task against its design.md and contract.md, running
  quality Gates and committing one commit per task, then hands off to Evaluator. Use after
  aifullpeople-tech-lead has produced a feature's three files. Keywords: "implement
  this feature", "aifullpeople developer", "run the tasks".
---

# aifullpeople: Developer

Owns the `implementation` stage (`docs/architecture.md` §6). Reads `design.md`,
`tasks.md`, and `contract.md` for one feature; implements task by task; runs the
enabled Gates (§8); commits one commit per task; writes a task-level report each time;
hands off to `aifullpeople-evaluator` once the full-suite Gates are green AND a human has
approved the handoff (§15).

Persona note: nicknamed after Miles Morales — the one who takes the leap and builds.
Flavor only; never appears in generated files or commits.
Invocation note: recommended to run as a delegated subagent, not inline in the
orchestrating conversation (`docs/architecture.md` §17) — it keeps the orchestrating
context small and gives the execution lock (§18) a clean owner.

## Prerequisites

Locate the target feature's folder (`.aifullpeople/features/<id>-<name>/`) — by ID,
name, or path. Require `tech-lead/design.md`, `tech-lead/tasks.md`, and
`tech-lead/contract.md` all present; abort with a clear message if any is missing
(never partially implement against an incomplete trio). Read `.aifullpeople/config.yaml`
for enabled Gates and `context_project.md` for cached Gate commands and stack
conventions.

**Acquire the feature-level lock** (architecture.md §18) before touching this feature —
`../aifullpeople-init/scripts/lock.sh acquire <feature-folder>/.lock developer`. Non-zero
exit means another run (including a `fix-runner` cycle) owns this feature — stop and
tell the user. **Release it** on every exit path: after the HiTL handoff in Step 6, and
just as much on any abort (dependency missing, hard-fail past retry limit).

Full execution detail — overrides, Gate tri-state semantics (hard/soft/pre-existing),
Gate command discovery order, what counts as "done", deviation tracking — lives in
`references/execution-rules.md`. Load it now.

## Steps

1. **Load context.** `tech-lead/design.md` (Component Overview, Data Model, API
   Contracts, Business Rules, Error Handling), `tech-lead/tasks.md` (phases/steps in
   order), `tech-lead/contract.md` (item IDs this feature promises), and the feature's
   dependency list in
   `state.json`/PRD Section 8. Abort before implementing anything if a dependency
   feature isn't `stage: "done"`.

2. **Apply overrides** from any free-form instruction given at invocation, per
   `references/execution-rules.md`.

2.5. **Baseline check.** If `git status --porcelain` shows uncommitted changes that
   predate this run (typically `pm/`'s PRD/brief or `tech-lead`'s
   `design.md`/`tasks.md`/`contract.md`, produced without their own commit), commit
   them separately FIRST, before touching any task — e.g.
   `scripts/commit.sh "chore: prd/design/tasks/contract for <feature-id>" <those files>`.
   Do this every time, not just on the very first feature: `estimate_tokens.sh` reads
   `git diff`/`git status`, so any pre-existing uncommitted doc gets miscounted as
   "written" by task 1 otherwise — found by actually running this pipeline once, not
   a hypothetical.

3. **For each task in `tasks.md`, in order:**
   1. Skip if `state.json` already marks this task `done` (idempotent re-entry).
   2. Set the task's `state.json` status to `in_progress`.
   3. Implement — read the relevant `tech-lead/design.md` section, edit/create the
      named files.
   4. Run the Gates relevant to the files this task touched (discovery order in
      `references/execution-rules.md`). Hard-fail → retry up to the limit, then abort
      the whole run. Soft-fail → log and proceed. Pre-existing failure → log, don't
      retry, proceed.
   5. Run `scripts/estimate_tokens.sh <context files consulted>` — do this BEFORE
      committing, since it reads the still-uncommitted diff.
   6. Write `.aifullpeople/features/<id>/developer/<task-id>.md` from
      `assets/task-report-template.md` (description, files touched, deviations, Gate
      results, token estimate) — **including the task's `phase` from `state.json`**
      (`tech-lead` set it when writing `tasks.md`). The report is read on its own,
      outside the context of `tasks.md`; without the phase number restated here, there
      is no way to tell from this file alone which phase it belongs to.
   7. Set the task's `state.json` status to `done` and append a history entry
      (`event: "task_completed"`, `role: "developer"`, `feature: "<id>"`) — do this
      BEFORE committing, so the commit captures both at once.
   8. Commit: `scripts/commit.sh "<message>" <code files this task touched>
      .aifullpeople/state.json .aifullpeople/features/<id>/developer/<task-id>.md`.
      `.aifullpeople/` is versioned in the project's git repo by default (this
      framework's own recommendation — it's real project history, like an ADR) —
      each task's commit is self-documenting: the code change and the record that it
      happened land together, atomically. Match the project's recent commit style if
      one exists; fall back to `feat(<feature-id>): [Phase <n>] <task description>` —
      the phase tag in the commit message is what makes `git log` itself readable as a
      phase-grouped history, not just a flat list of 5+ commits. If the user
      has explicitly opted the project out of versioning `.aifullpeople/` (rare —
      confirm before assuming this), drop those two paths from the `commit.sh` call.
   9. If an override disabled commits, skip step 7 but still do everything else.

4. **Full-suite Gate pass.** After the last task, run every enabled Gate across the
   whole repo (not just touched files). Any failure not already logged per-task is a
   regression — attempt to fix (same retry policy as hard-fail); if still failing, do
   not proceed to handoff.

5. **Code review (feature scope).** Once full-suite Gates are green, invoke
   `aifullpeople-developer-codereview` with `feature=<this feature>` (as its own
   subagent, per architecture.md §17). It reads code quality against
   `guidelines/*.md` and the resolved stack guidance skill (§5) — something no Gate
   and no `evaluator` walk checks (§20). Purely
   advisory: it produces a report, never blocks. Carry its findings into Step 6's
   checkpoint rather than pausing separately for them.

6. **HiTL checkpoint (architecture.md §15, skip only if `human_in_the_loop` is
   `false`).** Present, together: tasks completed, Gate results (pass/soft-fail/
   pre-existing, listed separately), token estimates per task, and the code-review
   report's findings by severity — NOT the full diff, that's what `git log`/`git show`
   are for if the user wants detail. Wait for explicit approval before handoff. If the
   human wants a code-review finding fixed now, that's still this role's own work
   (§20) — make the edit, re-run the relevant Gates, one more commit, then re-present
   before proceeding.

7. **Handoff**, only after approval: set the feature's `state.json` `stage` to
   `"validation"`. Report that `aifullpeople-evaluator` is next. Do not claim the feature is
   done — that's `evaluator`'s call, itself subject to its own HiTL checkpoint.

## Always / Never

Always: one commit per task by default; run `estimate_tokens.sh` before committing;
require all three feature files present before starting; check dependency readiness
before the first task; run `aifullpeople-developer-codereview` (feature scope) after
Gates and before the handoff checkpoint; wait for explicit HiTL approval of the
full-suite summary AND the code-review findings together before handing off to
`evaluator` (unless `human_in_the_loop: false`).

Never: `git add -A`/`git add .` (the script itself refuses this); claim a task is done
without the Gates for its files passing or being honestly soft-failed; skip straight to
`evaluator` with a red full-suite Gate; put service stubs in production code (test files only);
treat silence or an ambiguous reply as approval.
