# Fix rules

Detail for `aifullpeople-developer-fix-runner`. Adapted and heavily trimmed from a
`fix-runner` template the project owner brought in — see that skill's Mode A
(evaluation-driven fixing) for the original shape; Mode B (merge-conflict resolution)
and the PR/progress-JSON machinery around it are not adapted here, this framework has
no branch/PR model yet.

## Surface → likely fix site

Classify each failing item by the surface heading it appeared under in the
eval-report. The classification points at where the bug most likely lives — not a
guarantee, a starting point:

| Surface | Most likely fix site |
|---|---|
| Service | domain/use-case logic |
| HTTP API | route handler, request/response mapping, validation |
| CLI | command entry point, argument parsing |
| Worker | queue handler, job runner |
| Event | listener, dispatcher |
| UI | component, page, client-side logic |
| E2E | composition spanning multiple surfaces — check each one individually first |

A failure with `then` expecting success and observing a 5xx/exception usually means a
runtime error — read the eval-report's recorded observation and trace it into the
implementation. A failure expecting one status/shape and observing a different
one (e.g., expected 404, got 200) usually means a logic/routing bug, not a crash.

## Edit precedence

Same rule `aifullpeople-tech-lead` and `aifullpeople-developer` already use:
**`contract.md` items are canonical for observable behavior** (status codes, response
shape, persisted side-effects, error codes) — **`design.md` is canonical for internal
structure** (file paths, decomposition, naming). When a fix requires choosing between
what an item says and what `design.md` implies, follow the item; if the discrepancy
is large enough that following the item would mean `design.md` is now wrong on paper,
still make the code fix, but flag the drift in the fix report — regenerating
`design.md` itself is a `tech-lead` action, not this skill's.

## What's out of bounds

If the diagnosis leads to "the failing item's expectation is wrong" or "this needs a
new endpoint/field/table not in `design.md`" — that is not a fix-runner job. Stop,
report why, and point back to `aifullpeople-tech-lead` to regenerate the three-file
bundle (which re-runs the hard coverage gate). Never patch around a design gap by
inventing structure `design.md` never described.

## Validation

Discover Gate commands the same way `aifullpeople-developer` does — check
`context_project.md`'s "Gate commands" section first, then `contract.md`'s "Quality
gates" section, then `guidelines/<stack>/gates.md`, only falling back to fresh
discovery (and caching what's found) as a last resort. Retry budget: 3 attempts on a
red Gate, same tri-state semantics as `aifullpeople-developer/references/
execution-rules.md` (hard-fail/soft-fail/pre-existing).

## HiTL wording

Present, at minimum: the item IDs targeted, the files touched (not the full diff —
`git diff`/`git show` after commit is what shows the full picture if the user wants
it), and the Gate result. This mirrors `aifullpeople-developer`'s own handoff
checkpoint in shape, but the content is a delta (what changed this cycle), not a
whole-feature summary.

## `fix_cycles` vs. `tasks[]`

`state.json`'s `features[].tasks[]` is the original plan `tech-lead` wrote — it never
grows or shrinks after `tasks` stage. `fix_cycles` is a separate counter,
incremented once per successful fix-runner run. A task report
(`developer/<task-id>.md`) and a fix report (`developer/fix-<n>.md`) are both under
`developer/`, but the naming keeps them visually distinct — anyone reading the folder
sees at a glance how many corrective passes a feature needed on top of its original
plan.
