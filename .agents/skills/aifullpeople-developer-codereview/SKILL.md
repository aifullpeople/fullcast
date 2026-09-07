---
name: aifullpeople-developer-codereview
description: |
  Code-quality review of a task's or a feature's diff, against this project's
  guidelines (SOLID, anti-patterns, error handling, naming, testing) and
  design.md's intended structure. Purely advisory — produces a severity-ranked
  report, never blocks, never decides; the human always triages findings.
  Distinct from aifullpeople-evaluator (behavior only, never reads source) and
  from the Gates (mechanical tools only). Use after aifullpeople-developer
  finishes a feature (feature scope, automatic) or on demand for one task
  (task scope). Keywords: "code review", "review this task", "review the
  diff", "aifullpeople codereview".
---

# aifullpeople: Developer Code Review

Not a pipeline stage of its own — a pass `aifullpeople-developer` runs on itself
(same persona, Miles Morales, no new character) before handing a feature to
`aifullpeople-evaluator`. See `docs/architecture.md` §20 for why this exists: Gates
(§8) only catch what a tool checks mechanically, and `evaluator` (§7) deliberately
never reads source code — it verifies behavior through `contract.md`'s surfaces. That
left every `guidelines/*.md` file this framework ships (SOLID, anti-patterns, error
handling, naming, testing) uncomsulted by anything. This skill is what actually reads
code against them.

Invocation note: run as a delegated subagent (architecture.md §17) even though it's
the same persona as `aifullpeople-developer` — a fresh subagent context is what gives
this pass real distance from the code, not a new character.

## Prerequisites

- Determine scope from the input: `feature=<id>` (or a bare feature reference — the
  default, whole-feature diff) vs. `task=<feature-id>-T<n>` (one task's diff only).
- **Feature scope:** diff range is every commit from the feature's `tech-lead`-bundle
  commit (the one that saved `design.md`/`tasks.md`/`contract.md`) through the latest
  commit touching this feature — `git log`/`git diff` scoped to files under this
  feature's own directories, not the whole repo.
- **Task scope:** diff is that one task's own commit (`developer/<task-id>.md`'s
  "Files touched" list narrows it further if the commit touched more than the task).
- Read `tech-lead/design.md` (Component Overview — this pass also checks structural
  fit, not just line-level quality) and `context_project.md` (existing conventions —
  review against what this codebase already does, not outside taste).
- Determine `stack.primary_language` (and `guidance_skill`/`guidance_source`) from
  `.aifullpeople/config.yaml` to resolve this stack's concrete guidance source
  (architecture.md §5): by default the installed `<primary_language>-pro` skill
  (e.g. `golang-pro` for Go) under `.agents/skills/`, read exactly as it ships —
  its `SKILL.md` plus whichever `references/*.md` bear on the category under
  review. Falls back to a project-authored `guidelines/<primary_language>/` only
  when `guidance_source: guidelines` is set. Always load alongside the 5 shared
  `guidelines/*.md` at the repo root (stack-agnostic).
- No lock acquisition of its own — it's read-only on everything except the report file
  it writes and (only with explicit approval, see Step 5) the same kind of edit
  `aifullpeople-developer` already makes under that role's own lock.

Full review criteria (the 8 categories, what "good" looks like per guideline file,
severity definitions): `references/review-criteria.md`. Load it now.

## Steps

1. **Get the diff** for the resolved scope (git, per Prerequisites).

2. **Review** the diff across the 8 categories in `references/review-criteria.md`:
   Design/Structure, Logic, Security, Performance, Tests, Naming, Error Handling,
   Documentation. Each category's "what to check" is grounded in this project's own
   `guidelines/*.md` — not generic advice. Note specific file:line locations.

3. **Classify each finding** Critical / Major / Minor per
   `references/review-criteria.md`'s severity table, plus separate **Positive**
   (patterns done well — always include at least one when the diff has any) and
   **Questions** (genuine ambiguity, not a disguised complaint) buckets.

4. **Write the report** from `assets/codereview-report-template.md` to
   `.aifullpeople/features/<id>/developer/codereview-feature-<ISO-ts>.md` (feature
   scope) or `.../developer/codereview-<task-id>-<ISO-ts>.md` (task scope).

5. **Present, never decide.** This skill produces no verdict and blocks nothing —
   contrast with `evaluator`'s approve/reject and the Gates' pass/fail. Feature-scope
   reports fold into `aifullpeople-developer`'s existing HiTL handoff checkpoint
   (architecture.md §15) — present the findings alongside the Gate summary in that
   same approval, don't add a second pause. Task-scope reports (on-demand) present
   immediately to whoever asked for the review.

6. **If the human wants a finding addressed now:** this is still pre-`evaluator`, so
   it's still `aifullpeople-developer`'s work, under `aifullpeople-developer`'s own
   lock — not `aifullpeople-developer-fix-runner`, which exists specifically for
   *post-rejection* cycles (architecture.md §19). Make the targeted edit, re-run the
   Gates that apply to the touched files, one commit
   (`refactor(<feature-id>): code review — address <finding-ids>`), and re-invoke this
   skill's Step 1–4 on the new diff only if the human wants confirmation the finding
   is resolved — don't assume silently.

## Always / Never

Always: ground every finding in a specific `guidelines/*.md` rule, the resolved stack
guidance skill (or `guidelines/<stack>/` when `guidance_source: guidelines`), or a
concrete observed risk, not taste; cite file:line; include at least one positive
observation when one exists; keep the report advisory — no verdict field, no blocking
status.

Never: block, reject, or auto-fix anything; treat a finding as resolved without being
told; invent a rule that isn't in `guidelines/` or the resolved stack guidance skill;
route findings through
`aifullpeople-developer-fix-runner` (that skill is for `evaluator` rejections only);
nitpick something a Gate (lint/format) already enforces mechanically.
