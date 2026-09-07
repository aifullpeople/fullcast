# Review criteria

Detail for `aifullpeople-developer-codereview`. Adapted from a `code-reviewer` template
the project owner brought in — condensed from 6 reference files into this one, and
re-grounded: every category below points at this framework's own `guidelines/*.md`
files, or the resolved stack guidance skill, as the concrete standard, instead of
restating general knowledge those already cover.

**Resolving the stack-concrete source (architecture.md §5):** by default, the
installed Agent Skill named `<primary_language>-pro` under `.agents/skills/` (config
`stack.guidance_skill` overrides the name) — read exactly as it ships, never rewritten
by this framework. For Go that's `golang-pro`: its `SKILL.md` (Core Workflow,
Constraints — MUST DO / MUST NOT DO) plus whichever `references/*.md` matches the
category (`concurrency.md`, `interfaces.md`, `generics.md`, `testing.md`,
`project-structure.md`). Only when `.aifullpeople/config.yaml` sets
`stack.guidance_source: guidelines` does a project-authored `guidelines/<primary_language>/`
apply instead. Either way, the 5 shared root `guidelines/*.md` files
(solid-principles, anti-patterns, testing, naming-conventions, error-handling) always
apply too — they're the stack-agnostic philosophy layer a stack skill isn't expected to
restate.

## The 8 categories

| Category | What to check | Grounded in |
|---|---|---|
| **Design/Structure** | Does the diff match `design.md`'s Component Overview (right files, right responsibilities)? Is the abstraction level appropriate — no god object, no premature abstraction? | `guidelines/solid-principles.md`, `guidelines/anti-patterns.md` + the stack skill's structural guidance (Go: golang-pro `SKILL.md` Constraints, `references/project-structure.md`, `references/interfaces.md`) |
| **Logic** | Edge cases handled (empty/nil/boundary)? Order of operations correct? Any race condition in concurrent code? | project's own `design.md` Error Handling section as the spec of what should be handled |
| **Security** | Input validated at the boundary? Secrets not hardcoded? Injection risk (SQL, command, path traversal) in any dynamic query/exec? Auth/authz checked where the feature requires it? | OWASP Top 10 as a baseline — no dedicated framework guideline yet (flagged in architecture.md §16 as a possible future addition) |
| **Performance** | Obvious N+1 pattern? Unbounded loop over external data? Blocking I/O where the stack's idiom is non-blocking? | the stack skill's idiom/performance guidance (Go: golang-pro `SKILL.md` "Optimize" step + `references/concurrency.md`) |
| **Tests** | Do tests assert behavior, not implementation (guidelines/anti-patterns.md's "testing implementation instead of behavior")? Are failure paths tested, not just the happy path? | `guidelines/testing.md` + the stack skill's testing reference (Go: golang-pro `references/testing.md`) |
| **Naming** | Consistent with the codebase's own convention (check `context_project.md` first)? Meaningful, not abbreviated for no reason? | `guidelines/naming-conventions.md` (the shared root file is the concrete standard here — golang-pro doesn't ship a dedicated naming reference; don't invent one) |
| **Error Handling** | Every error handled or propagated with context, never swallowed? Distinguishes expected failure from a genuine bug? | `guidelines/error-handling.md` + the stack skill's error-handling conventions (Go: golang-pro `SKILL.md` Constraints — `fmt.Errorf("%w", err)`, no naked returns) |
| **Documentation** | Public/exported identifiers documented where the stack's convention expects it? Non-obvious logic has a comment explaining *why*, not restating *what*? | `context_project.md`'s discovered convention for this project |

## Severity

| Severity | Definition | Examples |
|---|---|---|
| **Critical** | Security risk, data loss, crash, or a Gate-equivalent correctness bug that somehow wasn't caught | injection, swallowed error hiding data loss, nil-panic on a common path |
| **Major** | Significant maintainability/performance/design concern, not urgent but real cost if left | N+1 query, god function, missing edge-case handling, design.md structural drift |
| **Minor** | Style, naming, small readability improvement | unclear variable name, could be simplified |

**Never duplicate what a Gate already enforces mechanically** (§8) — if `golangci-lint`
would catch it, it's noise here, not a finding. This skill exists for what tools can't
mechanically check: whether the code actually honors the *philosophy* behind a
guideline (e.g. lint can catch an unused variable; it can't catch "this function does
three unrelated things").

## Positive findings — always look

At least one, whenever the diff has anything worth reinforcing. Specific, not generic
("nice") — name the pattern and why it's good, the same way a finding names the
problem and why it matters.

## Questions — genuine ambiguity only

A question is for something the reviewer can't resolve alone (an intentional-looking
choice whose reasoning isn't obvious from the diff or `design.md`) — not a softened
complaint. If you already know it's wrong, that's a finding, not a question.

## What this is not

- Not a verdict. No Approve/Request-Changes/Comment field — that binary belongs to
  `evaluator`'s contract walk, which is about behavior, not code quality. This report
  has severities, not a gate.
- Not spec compliance verification. Whether the feature *behaves* as `contract.md`
  promises is `evaluator`'s job entirely; this pass only asks whether the *code* that
  produces that behavior is well-built. A Design/Structure finding about `design.md`
  drift is about internal shape, not observable behavior — do not re-derive
  contract-item pass/fail here.
