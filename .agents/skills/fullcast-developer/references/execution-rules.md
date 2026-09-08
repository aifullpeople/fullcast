# Execution rules

Detail for `fullcast-developer`'s task loop. Adapted from the exemplogs
`implement-feature` skill, re-scoped to task granularity (one commit per task, not per
phase — architecture.md §6/§7) and to running the 6+1 Gates (architecture.md §8) instead
of an ad-hoc "lint/typecheck/tests".

## Overrides

Free-form instructions at invocation time override these defaults:

| Default | Example override |
|---|---|
| Hard-fail retry limit = 3 | "no retry limit", "max 5 tries" |
| Fully autonomous | "pause between tasks" — wait in chat for `ok`/`continue`/`segue`/`yes` |
| 1 commit per task | "single commit at the end", "no commits, just implement" |
| Run all enabled Gates | "skip lint", "skip tests" (still logged under Overrides applied) |
| Implement all tasks | "only tasks 1-3", "skip task 5" |
| Abort tests on missing external dep | "stub missing services" — test code only, never production modules |

**Immutable core (cannot be overridden):** the final Gates result and its handoff to
`evaluator` — an override cannot make the skill claim `validation`-ready when a Gate failed.
Ambiguous/contradictory instructions: default wins, logged under "Overrides ignored".

## Baseline commit before task 1

`fullcast-pm` and `fullcast-tech-lead` never commit — only `developer` does.
That means their output (PRD, `design.md`/`tasks.md`/`contract.md`) can sit uncommitted
when a `developer` run starts. Commit it separately, before task 1's diff-based token
estimate runs, or that estimate silently counts every prior doc as part of task 1's
"written" bytes (this is not hypothetical — it's exactly what happened the first time
this framework was run end-to-end, and is why this rule exists).

## Gate execution semantics

Reuse the same tri-state the exemplogs already used — this isn't a new mechanism:

- **Hard fail** — non-zero exit, attributable to code this run changed. Retry up to the
  limit; each retry reads the error and adjusts. Past the limit: abort the whole run.
- **Soft fail** — the Gate's tool can't run in this environment (missing binary, no
  browser, external credential absent). Skip, log under Soft-fails, proceed.
- **Pre-existing failure** — fails but isn't attributable to this run's changes
  (existed on the branch already). Log under Pre-existing failures, don't count against
  the retry budget, proceed.

Warnings without a non-zero exit code are never failures.

## Gate command discovery

For each enabled Gate in `.fullcast/config.yaml: gates`, resolve its command in this
order:
1. `context_project.md`'s "Gate commands" section — if the command is already cached
   there (written by a prior task or by `tech-lead` while drafting `contract.md`), use
   it. Don't rediscover.
2. `contract.md`'s "Quality gates" section for this feature, if more specific.
3. The resolved stack guidance skill (`.agents/skills/<guidance_skill or
   "<primary_language>-pro">/SKILL.md`, architecture.md §5) for any Gate command it
   states explicitly — e.g. golang-pro's Core Workflow names `go vet ./...`,
   `golangci-lint run`, and `-race` tests. Use `guidelines/<primary_language>/gates.md`
   instead only when `stack.guidance_source: guidelines` is configured. Skills rarely
   cover every Gate (dependency-boundary and dead-code commonly aren't named) —
   whatever isn't stated falls through to step 4.
4. Only if still unresolved: inspect the project directly (`Makefile`, `package.json`
   equivalent for the stack) — then **append the discovered command to
   `context_project.md`** so no later task repeats this discovery.

Gate 4 ("script próprio do projeto") only runs when `config.yaml: gates.custom` is
`true`; its exact discovery convention is still an open item
(`docs/architecture.md` §16) — until resolved, ask the user where it lives the first
time it's needed, then cache the answer the same way.

## What counts as "done" for a task

All of the following — not just "the code was written":
- Every file the task's `tasks.md` step named exists with the described content.
- Every contract item this task was meant to satisfy (per `contract.md`) matches what
  was written, to the extent it's checkable without running the full suite yet (full
  Gate + AC verification is `evaluator`'s job at `validation`; a task-level check here is a
  sanity pass, not the final word).
- The task-scoped Gates (the ones relevant to files this task touched) pass.
- If the task produces runtime behavior not covered by unit tests (a page, a route, a
  migration, a CLI command), actually exercise it if the environment allows; otherwise
  log the runtime check under Soft-fails — never silently claim it's done.

Adapt to minor divergence between `tasks.md`/`design.md` and reality (renamed column,
different file name, structurally compatible type) — log every adaptation under
Deviations in the task report. Never abort for a cosmetic divergence.

## Abort the whole run only on

- A dependency feature isn't `done` in `state.json` (should have been caught before
  starting; if discovered mid-run, abort here).
- A hard fail past the retry limit.

Missing external dependencies needed only by tests do not abort the run — soft-fail
that test, keep implementing.

## Deviation, soft-fail, and pre-existing tracking

Every task report (`assets/task-report-template.md`) carries its own Deviations/Gates
sections. When the feature reaches the full-suite Gate pass (before handoff to `evaluator`),
roll these up: a task-level soft-fail that's still unresolved at full-suite time stays a
soft-fail in the feature-level report; a pre-existing failure never becomes a
regression just because this feature's run touched nearby code.
