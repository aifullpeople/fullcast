# design.md + tasks.md rules

Detail for the `design` and `tasks` stages of `aifullpeople-tech-lead`. Loaded when
actually drafting these two files — adapted from the exemplogs `spec-writer` skill.
Renamed per `docs/architecture.md` §3: `spec.md` → `design.md`, `plan.md` → `tasks.md`
(OpenSpec-style naming). `contract.md`'s rules are separate — see `contract-rules.md`.

## Complexity levels

| Complexity | Criteria |
|---|---|
| `trivial` | Single component, no API changes, no DB changes, no integrations |
| `simple` | Few components, 1-10 endpoints, slight DB schema changes, no integrations |
| `medium` | Multiple components, 11-30 endpoints, regular DB schema changes, basic integrations |
| `complex` | Multiple layers, 30+ endpoints, complex DB migrations, external services |

This is `estimated_difficulty` in `state.json` — set it there, not just in prose.

Depth scaling by complexity (design.md sections 2/4/5/6/7) and phase/step count
(tasks.md) follow the same table the exemplogs used: trivial → 1-2 phases/2-4 steps;
simple → 2-3/5-8; medium → 3-4/10-15; complex → 4-5/15-25.

## Step 1: Resolve input and pre-analysis

1. Identify the target feature from the PRD (by ID or name; ask if ambiguous). PRD is
   mandatory — if `.aifullpeople/pm/prd.md` doesn't exist, direct the user to
   `aifullpeople-pm` first.
2. **Dependency readiness and Foundation check.** Read the PRD's Section 8. For each
   dependency of the target feature, check `state.json` — is that feature's `stage`
   already `done`? If not, warn and ask to continue anyway. If Section 8 has a
   Foundation Features subsection, check each listed Foundation feature's `state.json`
   stage the same way: greenfield (none done) + target IS Foundation → proceed;
   greenfield + target is NOT Foundation → warn and recommend starting with Foundation
   first; partial Foundation + target isn't one of the pending ones → warn about file
   conflicts. Foundation complete → skip these checks.
3. **Pattern discovery — read `context_project.md` first, don't re-derive it.** This is
   the single biggest difference from the exemplogs' `spec-writer`, which re-ran a full
   two-layer codebase scan per feature. Here: read `context_project.md`'s "Discovered
   patterns" and "Architecture" sections. If it already answers runtime/framework/
   database/auth/API style/validation/testing/error handling/folder structure/
   architecture style, use that — don't re-explore the codebase, and don't second-guess
   it against a generic preference. **Priority rule (architecture.md §11): a populated
   `context_project.md` is authoritative, full stop** — it reflects what the actual
   code already does, which outranks any default this skill would otherwise assume.
   Only fall back to fresh exploration for a genuinely empty `context_project.md`
   (first feature of a greenfield project — see Step 2's Empty codebase bootstrap,
   where the *user's* stated preference becomes authoritative instead), and when you
   do, **append your findings back into `context_project.md`** (append, never rewrite —
   it's a living document per architecture.md §11) so the next feature doesn't repeat
   this work.
4. Load the target feature's full PRD data: Consumes, Provides, Core Scope, Full Scope,
   Capabilities, Experience, Error Handling, Section 9 acceptance criteria (including
   Cross-Feature Integration entries referencing this feature).
5. Present understanding to the user before interviewing further.

## Step 2: Interview

One question at a time, walking the decision tree, recommending an answer for each.
Skip anything already answered by the PRD, `context_project.md`, or a prior feature's
`design.md`/`tasks.md` in this same project.

**Scope question first, when applicable:** if the feature has both Core Scope and Full
Scope blocks, ask whether the spec covers Core only or Core+Full. Otherwise skip and
assume full scope.

Focus questions on what neither the PRD nor `context_project.md` answers: internal
architecture, schema details, endpoint signatures, validation rules not already in
Capabilities, file naming, library choice when no pattern is established, edge cases
not in Error Handling.

**Empty codebase bootstrap:** if `context_project.md` is genuinely empty (first feature,
greenfield), ask the transversal stack questions inline here — **architecture style
first** (e.g. Clean Architecture, hexagonal, simple layered, or whatever the user
names; don't assume one), then framework, ORM, auth, API style, validation, testing,
error handling, folder structure. Architecture style gets its own question, not folded
into "folder structure" — it drives Component Overview shape for every feature after
this one, so a vague answer here compounds. Write the answer to `context_project.md`'s
"Architecture" section specifically (separate from "Discovered patterns" — see
architecture.md §11); the rest goes under "Discovered patterns" as usual. This
becomes the project's convention going forward, per the priority rule in Step 1 — once
written, it's authoritative and this question is never asked again for this project.

## Step 3: Summary and assumptions

Summarize decisions, list assumptions (from PRD, `context_project.md`, and interview
answers), and note which PRD blocks informed which parts of the design.

## Step 4: Generate design.md

7 sections, scaled by complexity (skip API Contracts/Data Model for trivial/simple if
not applicable):

1. **Technical Overview** — what/why/scope.
2. **Architecture Impact** — affected components with file paths + Mermaid diagram.
   Quote any node label containing `/ \ ( ) [ ] { } |` or `"` (otherwise Mermaid reads
   the leading character as a shape modifier and breaks).
3. **Technical Decisions** — table: Decision / Chosen Approach / Alternative / Trade-off.
4. **Component Overview** — table per layer (frontend/backend/database/...): File Path
   / New-Modified / Purpose / Key Responsibilities. Complete paths, not directory names.
5. **API Contracts** (when applicable) — per endpoint: method/path/auth, request table +
   JSON example, response table + JSON example, error codes table.
6. **Data Model** (when applicable) — per table: columns with types/nullable/default,
   indexes, constraints, migration example.
7. **Testing Strategy** — test files, test type/target/coverage goal, and per-file test
   function names with their assertions. This section is what `contract.md`'s Testing
   Strategy mapping (see `contract-rules.md`) draws from for its own Coverage Manifest —
   keep function names concrete enough to cross-reference. **If the feature persists
   anything to disk, name a test function for the fresh-environment case** (storage
   location doesn't exist yet, first write must still succeed) — `t.TempDir()`-based
   tests never exercise this, and it's easy to ship a store that only works once
   something else has already created its directory (found running this exact
   framework on a Todo CRUD example — the persistence layer failed on a genuinely
   fresh checkout, uncaught by Gates or Evaluator because no test or contract item named it).

**PRD → design.md mapping:** Consumes/Provides → Scope (input/output contracts) + API
Contracts when exposed via API; Core Scope → Scope "Included"; Full Scope additions →
"Deferred" (Core-only pick) or "Included" (Core+Full pick); Capabilities → Business
Rules; Experience → UX Flows; Error Handling → Error Handling section; Section 9
per-feature ACs → Testing Strategy acceptance tests; Cross-Feature Integration ACs
referencing this feature → Testing Strategy integration tests.

**Never:** actual code, step-by-step instructions, repeated PRD product-language, time
estimates, user stories.

## Step 5: Generate tasks.md

Prerequisites section (tools/versions, env vars, config files), then phases with
numbered steps, continuous numbering across phases (1, 2, 3...). Each step: 1-3
sentences, WHAT not HOW, references design.md for technical detail.

**Never:** code/pseudo-code, implementation details (types, column names, method
signatures), testing sections, time estimates, bullet points within a step, priority
levels.

Every step becomes one entry in `state.json`'s `features[].tasks[]` — **including which
phase it belongs to**, not just its position in the flat list:
```json
{ "id": "F01-T1", "phase": 1, "description": "<the step's one-line WHAT>", "status": "pending" }
```
Task IDs are `<feature-id>-T<n>`, continuous across phases, matching the step numbering.
`phase` is the ONLY place this grouping survives outside `tasks.md` itself — without it,
`developer`'s per-task execution and reports read as an unstructured flat list and the
plan tech-lead just wrote effectively disappears the moment execution starts. Get this
right the first time; don't rely on `developer` re-deriving it from `tasks.md` later.

## Step 6: Generate contract.md

See `contract-rules.md` — separate file, same run, same feature folder.

## Step 7: Validate and save

Before saving, check: required design.md sections present for the complexity level;
Component Overview has full paths; API contracts have JSON examples; data model has
types/indexes/constraints; testing strategy has concrete function names; PRD blocks
mapped per the table above; tasks.md steps are numbered/WHAT-only.

Save to `.aifullpeople/features/<feature-id>-<kebab-name>/tech-lead/{design.md,tasks.md,contract.md}`.
Kebab-case: lowercase the PRD feature name, spaces → hyphens,
strip anything outside `[a-z0-9-]`.

Update `state.json`:
- `features[].artifacts.design` and `.tasks` → `{path, status: "done"}`.
- `features[].estimated_difficulty` → the complexity level from this run.
- `features[].stage` → `"tasks"` (both design and tasks are produced in this same
  stage transition, per architecture.md §6 — there is no separate canonical stage for
  each file).
- Append a history entry (`event: "feature_design_generated"`, `role: "tech-lead"`,
  `feature: "<id>"`).

## Batch mode — not carried over yet

The exemplogs' `spec-writer` supported generating multiple same-wave features in
parallel with an Auto-Accept Policy. This hasn't been re-specified for `tech-lead` yet
(flagged as an open item in `docs/architecture.md` §16). For now, always run the
single-feature interactive flow above, even when the user names several features —
process them one at a time.
