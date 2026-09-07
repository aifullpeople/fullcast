# Code Review: <feature-id> — <scope: whole feature | task <task-id>>

**Diff reviewed:** <commit range or single commit SHA>
**Summary:** <1-2 sentence recap of what the diff does>

*Advisory only — no verdict, nothing blocked. The human decides what to act on.*

## Critical

### 1. `<file>:<line>` — <one-line title>
- **Observed:** <what the code does>
- **Risk:** <why it matters — security/data-loss/crash>
- **Suggested:** <concrete fix, with a short snippet if it clarifies>
- **Guideline:** <which guidelines/*.md rule this traces to, or "n/a — direct risk">

*(omit this section entirely if empty)*

## Major

### 1. `<file>:<line>` — <one-line title>
- **Observed:** <...>
- **Impact:** <maintainability/performance/design cost>
- **Suggested:** <...>
- **Guideline:** <...>

*(omit this section entirely if empty)*

## Minor

### 1. `<file>:<line>` — <one-line title>
- **Observed:** <...>
- **Suggested:** <...>

*(omit this section entirely if empty)*

## Positive

- <specific pattern done well, and why>

## Questions

- `<file>:<line>` — <genuine ambiguity, not a softened complaint>

*(omit if none)*

## Category coverage

<one line per category from review-criteria.md noting it was checked, even when clean —
Design/Structure, Logic, Security, Performance, Tests, Naming, Error Handling, Documentation>
