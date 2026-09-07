---
name: aifullpeople-pm
description: |
  PM role (persona: Miguel O'Hara) of the aifullpeople framework. Owns the discovery
  and requirements stages: writes brief.md and prd.md through iterative clarification.
  Use when starting a new project or a new set of requirements under this framework.
  Keywords: "prd", "product requirements", "aifullpeople pm", "start requirements".
---

# aifullpeople: PM

Owns the `discovery` and `requirements` stages of the state machine (see
`docs/architecture.md` §6 in the framework repo for the full diagram). Produces
`.aifullpeople/pm/brief.md` (optional) and `.aifullpeople/pm/prd.md`, and creates each
feature's entry in `state.json` with its `methodology` locked at creation time.

Persona note: internally this role is nicknamed after Miguel O'Hara — the one who
decides what must be canon. That's flavor for tone only; nothing about the steps below
depends on it, and it never appears in generated files.
Invocation note: recommended to run as a delegated subagent, not inline in the
orchestrating conversation (`docs/architecture.md` §17) — it keeps the orchestrating
context small and gives the execution lock (§18) a clean owner.

## Prerequisites

- `.aifullpeople/` must exist. If not, tell the user to run `aifullpeople-init` first.
- Read `.aifullpeople/config.yaml` for `language` — every generated document's prose
  follows it (IDs and file names stay ASCII regardless).
- Read `context_project.md` for existing project context before asking the user
  anything it already answers.
- **Acquire the project-level lock** (architecture.md §18) before touching anything:
  `../aifullpeople-init/scripts/lock.sh acquire .aifullpeople/.lock pm`. If it exits
  non-zero, another run holds it — stop and tell the user, don't retry silently.
  **Release it** (`lock.sh release .aifullpeople/.lock`) on every exit path — after
  Step 4 completes, and just as much on any abort.

## Steps

### 1. Discovery (optional)

Skip straight to Requirements if the user already arrives with full context (product
description, or an existing PRD-equivalent to import).

Otherwise: confirm understanding of the problem/audience/value hypothesis, check
`context_project.md` for an existing-capabilities inventory when the repo isn't empty,
and write `.aifullpeople/pm/brief.md` from `assets/brief-template.md`. Set
`state.json.artifacts.brief` to `{path, status: "pending_approval"}`.

**HiTL checkpoint (architecture.md §15, skip only if `config.yaml:
human_in_the_loop` is `false`):** present the brief and wait for the user's explicit
approval before continuing to the interview. If they ask for changes, revise and
re-present — do not proceed on silence or an ambiguous reply. Once approved, set
`state.json.artifacts.brief` to `{path, status: "done"}` and append a history entry
(`event: "brief_generated"`, `role: "pm"`).

### 2. Requirements interview

Conduct a structured interview, one question at a time, walking the product's decision
tree until problem space, audience, objectives, stories, functionalities, scope
boundaries, dependencies, and acceptance criteria are all resolved. For every decision,
resolve its dependencies before moving on. Summarize and get explicit confirmation
before drafting.

Full section-by-section rules (the 9 PRD sections, feature ID system, dependency graph
parts, validation checklist): `references/prd-sections.md`. Load it now — this is the
step that needs it.

### 3. Draft the PRD

Write `.aifullpeople/pm/prd.md` per `references/prd-sections.md`. For the Section 8
dependency graph, build `{id: {priority, dependencies}}` from what you've drafted and
pipe it to `scripts/compute_waves.py` — use its `order` for the table's row order and
its `waves` for the Execution Waves list. Don't hand-compute topology; that's exactly
the kind of algorithm this script exists for (architecture.md §5).

Run the validation checklist from `references/prd-sections.md` before saving (up to 3
correction passes; then stop and ask the user if issues persist).

### 4. Save, get approval, and update state

1. Save `.aifullpeople/pm/prd.md`. Read it back to confirm Section 1 and Section 9
   headings are present. Set `state.json.artifacts.prd` to
   `{path, status: "pending_approval"}`.
2. **HiTL checkpoint (architecture.md §15, skip only if `human_in_the_loop` is
   `false`):** present the PRD (or a clear summary plus the file path — the user's
   choice) and wait for explicit approval. Revise and re-present on any requested
   change; do not treat silence as approval. This gate exists precisely because
   `tech-lead` starts real design work from this document — an unapproved PRD should
   never unlock that.
3. Once approved, set `state.json.artifacts.prd` to `{path, status: "done"}`.
4. For each feature in Section 6, add an entry to `state.json.features` if it doesn't
   already exist:
   ```json
   {
     "id": "F01",
     "name": "<from PRD>",
     "methodology": "<state.json.default_methodology, read NOW and frozen here>",
     "stage": "design",
     "artifacts": {},
     "estimated_difficulty": null,
     "real_difficulty": null,
     "tokens_estimated": null,
     "tasks": []
   }
   ```
   The `methodology` value is copied from the current default and never changes again
   for this feature (architecture.md §9) — even if `aifullpeople-set-methodology` runs
   later, this feature stays on what it was created with.
5. Append a history entry (`event: "prd_generated"`, `role: "pm"`).
6. Report the PRD path, feature count, and that features are now ready for
   `aifullpeople-tech-lead`.

## Always / Never

Always: one question at a time in the interview; infer specifics from product domain
when the user doesn't answer, rather than leaving placeholders; validate before saving;
lock each feature's methodology at creation; wait for explicit HiTL approval before
advancing the stage (unless `human_in_the_loop: false`).

Never: skip the interview because the description "seems obvious"; put ID/date/version
headers in the PRD; let `state.json`'s feature `methodology` drift from what it was
created with; treat silence or an ambiguous reply as approval.
