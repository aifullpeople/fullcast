# PRD section rules

Detail for the `requirements` stage of `aifullpeople-pm`. Loaded only when actually
drafting `prd.md` — adapted from the exemplogs `prd-writer` skill, translated into this
framework's vocabulary (`.aifullpeople/pm/prd.md` instead of a generic PRD path; content
language follows `config.yaml: language` instead of being hardcoded to English).

## Feature ID system

- Every functionality gets a unique ID: `F01, F02, ...F99`, zero-padded, sequential, no
  gaps. IDs are used in Sections 5, 6, 8, 9. Sections 1-4 and 7 use descriptive names
  only.
- Typical PRDs have 5-15 features. Fewer than 3 usually means features are grouped too
  broadly; more than 20 usually means related capabilities should consolidate.

## The 9 sections, in order

### 1. Executive Summary
2-3 paragraphs: what is the product, for whom, core value, how it works at a high level.

### 2. Problem and Opportunity
**The Problem** — 3-5 pain categories, bold title + 3-4 quantified bullets.
**The Opportunity** — connect each problem to its solution, be specific about the
differentiator. (This section already covers the "why" that OpenSpec calls
`proposal.md` — we do not generate a separate proposal document; see
`docs/architecture.md` §3.)

### 3. Target Audience
**Primary Users** — as many personas as the product genuinely needs (1 if the audience
is homogeneous, more if journeys diverge). Bold name + 3 bullets each.
**Behavioral Profile** — common characteristics across personas; omit if there is only
one persona (redundant with its own bullets).

### 4. Objectives
**Product Objectives** (3-5) — bold action verb, specific, verifiable.
**Success Metrics** — one measurable metric with a number per objective, plus the
measurement condition.

### 5. User Stories
Grouped by feature ID:
```markdown
### F01. User Registration and Authentication
- As a user, I want to register with email and password so that I can access the platform
```
- As many stories as the feature needs — no fixed range.
- Group by feature only, never by persona.
- Infrastructure/backend features with no direct user interaction: write from the
  system's perspective ("As the system, I want to...").

### 6. Functionalities
Per feature, in this order (omit blocks that don't apply):

1. **Consumes** (omit if no functional data dependency) — what this feature needs from
   others, referenced by ID, semi-technical level (business objects and key fields, not
   programming types). Never list auth/session — it's assumed everywhere.
2. **Provides** (omit if nobody consumes from this feature) — what this feature makes
   available to others, with consumers named in parentheses. Group entries when the
   same data serves multiple consumers: `(used by F04, F06)`.
3. **Core Scope** (omit if the whole feature is equally essential) — minimum
   capabilities for the feature's primary purpose, only when priorities are mixed.
4. **Full Scope additions** (omit if Core Scope is omitted) — enhancements beyond Core.
5. **Capabilities** — specific limits (sizes, quantities, times), formats, business
   rules. Always concrete numbers, never generic.
6. **Experience** — detailed user flow, feedback, validations, messages, states.
7. **Error Handling** (only for critical functionalities: auth, payments, data-loss
   risk, security-sensitive, long-running/irreversible operations) — 3-5 failure
   scenarios with specific messages. Test: "if this fails silently, does the user lose
   data, money, or security?" If no, skip.

### 7. Out of Scope
Grouped by category: what this version will not do.

### 8. Dependency Graph
Up to five parts — Part numbers stay stable even when a part is omitted (a PRD without
Foundation Features emits Part 1, 3, 4, 5; Part 2 is simply absent).

**Part 1 — Dependency Table:**
| # | Feature | Priority | Dependencies |
Every feature appears exactly once, in topological order (every dependency's row is
above the row referencing it). `Dependencies` is a superset of `Consumes` (includes
infra dependencies like Foundation, not just functional data). Compute the order and
the topological tie-break with `scripts/compute_waves.py` (§ below) rather than
reasoning through the graph by hand — feed it `{id: {priority, dependencies}}` and use
its `order` output directly for the table's row order.

**Part 2 — Foundation Features** (only when a feature's primary purpose is shared
scaffolding — top-level layout/routing, DB/ORM setup, cross-cutting middleware — that
every later feature implicitly relies on). List in topological order. A feature that
merely creates UI structure while doing its own product job is NOT Foundation.

**Part 3 — Execution Waves:** feed the same `{id: {priority, dependencies}}` object to
`compute_waves.py` and render its `waves` output as:
```markdown
- **Wave 1**: F01
- **Wave 2**: F02, F03
```
Include the Foundation-serialization note only when Part 2 was emitted.

**Part 4 — Priority legend** (always, verbatim):
```markdown
- **1** = Essential — product does not work without it
- **2** = Important — significant value addition
- **3** = Desirable — incremental improvement
```

**Part 5 — Mermaid diagram** (`graph TD`, edges matching the dependency table exactly;
quote any node label containing `/ \ ( ) [ ] { } |` or `"` — see the Mermaid quoting
rule under §2 in `aifullpeople-tech-lead`'s `design-and-tasks-rules.md` if unsure).

### 9. Acceptance Criteria
Per feature, verifiable + specific + covering success and failure. End with a
**Cross-Feature Integration** block: one or more criteria derived from each `Consumes`
declaration in Section 6, testing that data actually flows between features. A feature
with no `Consumes` generates no integration criteria here.

Note: these Section 9 criteria are the SOURCE that `aifullpeople-tech-lead` later turns
into `contract.md`'s Coverage Manifest — write them so each is independently testable,
not as vague statements of intent.

## Validation before saving

Run once; on failure, fix and re-run, up to 3 iterations, then stop and ask the user:

- Every Section 6 feature appears exactly once in Section 8's table (and vice versa).
- Every Section 6 feature has stories (§5) and acceptance criteria (§9).
- No contradiction between Section 6 and Section 7.
- Every objective (§4) has a numeric metric.
- No orphan/circular dependency; topological order holds (re-check against
  `compute_waves.py`'s output rather than eyeballing it).
- Every `Consumes` reference is a subset of that feature's `Dependencies`.
- Every `Consumes` name is covered by the corresponding `Provides` entry (same name, or
  a clearly broader term).
- Wave coverage: every feature appears in exactly one wave; wave = max(dep waves) + 1.
- Every Foundation Features entry exists in the dependency table, in the same order.

## Always / Never

**Always:** write prose in `config.yaml: language` (default `en`); consider existing
project patterns via `context_project.md`; use concrete numbers; use feature IDs in
Sections 5/6/8/9; validate before saving; start with the product title (H1), no
ID/date/version header.

**Never:** extra sections beyond the 9; generic functionality descriptions; a forced
persona/story count; forward references in the dependency table.
