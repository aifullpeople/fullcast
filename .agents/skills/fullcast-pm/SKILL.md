---
name: fullcast-pm
description: |
  PM role (persona: Miguel O'Hara) of the fullcast framework. Owns the discovery
  and requirements stages: writes brief.md and prd.md through iterative clarification.
  Use when starting a new project or a new set of requirements under this framework.
  Keywords: "prd", "product requirements", "fullcast pm", "start requirements".
---

# fullcast: PM

Owns the `discovery` and `requirements` stages of the state machine (see
`docs/architecture.md` §6 in the framework repo for the full diagram). Produces
`<initiative>/pm/brief.md` (optional) and `<initiative>/pm/prd.md`, creates the
initiative itself (architecture.md §21) the first time either is written, and creates
each feature's entry in `state.json` with its `methodology` locked at creation time.

Persona note: internally this role is nicknamed after Miguel O'Hara — the one who
decides what must be canon. That's flavor for tone only; nothing about the steps below
depends on it, and it never appears in generated files.
Invocation note: recommended to run as a delegated subagent, not inline in the
orchestrating conversation (`docs/architecture.md` §17) — it keeps the orchestrating
context small and gives the execution lock (§18) a clean owner. When the orchestrating
tool supports isolated subagent worktrees (Claude Code's Agent tool: `isolation:
"worktree"`), **always** use it for this invocation (§17, §21) — no exceptions, not
just for parallel runs.

## Prerequisites

- `.fullcast/` must exist. If not, tell the user to run `fullcast-init` first.
- Read `.fullcast/config.yaml` for `language` — every generated document's prose
  follows it (IDs and file names stay ASCII regardless) — and for `git.suggest_branch`
  (used in Step 0).
- Read `context_project.md` for existing project context before asking the user
  anything it already answers.
- **Acquire the project-level lock** (architecture.md §18) before touching anything:
  `../fullcast-init/scripts/lock.sh acquire .fullcast/.lock pm`. If it exits
  non-zero, another run holds it — stop and tell the user, don't retry silently.
  **Release it** (`lock.sh release .fullcast/.lock`) on every exit path — after
  Step 4 completes, and just as much on any abort.

## Steps

### 0. Resolve the initiative

Look in `state.json.initiatives` for one already open for this run — `status:
"in_progress"` with `feature_ids: []` and an `artifacts.brief`/`artifacts.prd` still
`pending_approval` (a revision continuing mid-flight, e.g. the user asked for changes to
a brief already presented). Reuse it if found; otherwise this run is starting a new
initiative — don't create its `state.json` entry yet, that happens the first time Step 1
or Step 3 actually writes a file (a `Discovery` conversation that gets abandoned before
anything is saved shouldn't leave a stub initiative behind).

**When the initiative entry IS created** (first write, Step 1 or Step 3): pick the next
`I<nn>` id (architecture.md §21, same rule as feature ids — highest existing + 1), a
name (from the brief's title, or ask the user for a couple of words if skipping
Discovery straight to a PRD you're importing), derive a kebab-case slug from the name,
and add to `state.json.initiatives`:
```json
{
  "id": "I01",
  "name": "<name>",
  "status": "in_progress",
  "branch": null,
  "artifacts": {},
  "feature_ids": [],
  "changesfullcast": null,
  "created_at": "<ISO timestamp>"
}
```
Then, **before writing any content**, check the branch (architecture.md §21): if
`git branch --show-current` is a trunk branch (`main`, `master`, `develop`,
`development`) and `config.yaml: git.suggest_branch` isn't `false`, ask the user whether
to create `initiative/I01-<slug>` (or a name they prefer) for this initiative. If they
agree, create and switch to it, and set the initiative's `branch` field. If they decline,
leave `branch: null` — the initiative just proceeds on whatever branch is current, and
nothing about this framework requires a dedicated branch to function. Never create the
branch without asking.

All of this initiative's files live under
`.fullcast/I01-<slug>/` — `pm/{brief,prd}.md` at that level,
`features/<feature-id>-<kebab-name>/` for what `tech-lead` and later roles add.

### 1. Discovery (optional)

Skip straight to Requirements if the user already arrives with full context (product
description, or an existing PRD-equivalent to import).

Otherwise: confirm understanding of the problem/audience/value hypothesis, check
`context_project.md` for an existing-capabilities inventory when the repo isn't empty,
and write `<initiative>/pm/brief.md` from `assets/brief-template.md` (creating the
initiative first, per Step 0, if this is the first file written). Set
`state.json.initiatives[].artifacts.brief` to `{path, status: "pending_approval"}`.

**HiTL checkpoint (architecture.md §15, skip only if `config.yaml:
human_in_the_loop` is `false`):** present the brief and wait for the user's explicit
approval before continuing to the interview. If they ask for changes, revise and
re-present — do not proceed on silence or an ambiguous reply. Once approved, set
`state.json.initiatives[].artifacts.brief` to `{path, status: "done"}` and append a
history entry (`event: "brief_generated"`, `role: "pm"`).

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

Write `<initiative>/pm/prd.md` (creating the initiative first, per Step 0, if Discovery
was skipped and this is the first file written) per `references/prd-sections.md`. For
the Section 8
dependency graph, build `{id: {priority, dependencies}}` from what you've drafted and
pipe it to `scripts/compute_waves.py` — use its `order` for the table's row order and
its `waves` for the Execution Waves list. Don't hand-compute topology; that's exactly
the kind of algorithm this script exists for (architecture.md §5).

Run the validation checklist from `references/prd-sections.md` before saving (up to 3
correction passes; then stop and ask the user if issues persist).

### 4. Save, get approval, and update state

1. Save `<initiative>/pm/prd.md`. Read it back to confirm Section 1 and Section 9
   headings are present. Set `state.json.initiatives[].artifacts.prd` to
   `{path, status: "pending_approval"}`.
2. **HiTL checkpoint (architecture.md §15, skip only if `human_in_the_loop` is
   `false`):** present the PRD (or a clear summary plus the file path — the user's
   choice) and wait for explicit approval. Revise and re-present on any requested
   change; do not treat silence as approval. This gate exists precisely because
   `tech-lead` starts real design work from this document — an unapproved PRD should
   never unlock that.
3. Once approved, set `state.json.initiatives[].artifacts.prd` to `{path, status: "done"}`.
4. For each feature in Section 6, add an entry to `state.json.features` if it doesn't
   already exist, and its id to this initiative's `feature_ids`:
   ```json
   {
     "id": "F01",
     "name": "<from PRD>",
     "methodology": "<state.json.default_methodology, read NOW and frozen here>",
     "stage": "design",
     "initiative_id": "I01",
     "artifacts": {},
     "estimated_difficulty": null,
     "real_difficulty": null,
     "tokens_estimated": null,
     "tasks": []
   }
   ```
   The `methodology` value is copied from the current default and never changes again
   for this feature (architecture.md §9) — even if `fullcast-set-methodology` runs
   later, this feature stays on what it was created with. `initiative_id` never changes
   either (architecture.md §21) — a feature stays with the initiative it was born under.
5. Append a history entry (`event: "prd_generated"`, `role: "pm"`).
6. Report the initiative id/name, the PRD path, feature count, and that features are
   now ready for `fullcast-tech-lead`.

## Always / Never

Always: one question at a time in the interview; infer specifics from product domain
when the user doesn't answer, rather than leaving placeholders; validate before saving;
lock each feature's `methodology` and `initiative_id` at creation; ask before creating a
branch, never create one silently; wait for explicit HiTL approval before advancing the
stage (unless `human_in_the_loop: false`).

Never: skip the interview because the description "seems obvious"; put ID/date/version
headers in the PRD; let `state.json`'s feature `methodology` or `initiative_id` drift
from what it was created with; create a git branch without asking first; treat silence
or an ambiguous reply as approval.
