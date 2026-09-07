# SOLID principles

Shared across every stack — these are design-level concepts, not language syntax.
Applied by `aifullpeople-tech-lead` when making Technical Decisions, and referenced by
`aifullpeople-developer` during implementation. A stack folder may add a short note on
how a principle looks in that language's idiom, but the principle itself belongs here.

## Single Responsibility

A unit (function, type, module — the granularity depends on the stack) should have one
reason to change. In practice: if describing what something does requires "and", it's
probably two responsibilities. This is the most useful of the five day-to-day — most
"god object" anti-patterns (see `anti-patterns.md`) are a Single Responsibility
violation left unchecked.

## Open/Closed

A unit should be open for extension, closed for modification: adding a new case should
mean adding new code, not editing a long chain of conditionals in existing code. Don't
over-apply this pre-emptively — speculative extensibility for a case that doesn't exist
yet is its own anti-pattern (see `anti-patterns.md`, "premature abstraction"). Apply it
when a second case actually shows up.

## Liskov Substitution

Anything implementing an interface/contract must be usable anywhere that contract is
expected, without surprising the caller. A common violation: an implementation that
throws/returns an error for an input the interface's contract says it should accept —
that's not a stricter implementation, it's a broken one. How this principle is
expressed varies most by stack (classical inheritance vs. structural interfaces) — see
the stack's own file for the concrete shape.

## Interface Segregation

Prefer several small, specific contracts over one large one that forces implementers to
support methods they don't need. A caller should only need to know about the surface it
actually uses.

## Dependency Inversion

Depend on an abstraction, not a concrete implementation — especially across a
layer boundary (business logic depending on a specific database driver, for example).
This is also what makes Gate 3 (dependency/architecture boundary, `docs/
architecture.md` §8) mechanically checkable: a clean dependency direction is what that
Gate is actually verifying.

## When these principles are in tension with each other

They usually are, at the edges (Interface Segregation can push toward more interfaces
than Dependency Inversion wants to inject). When they conflict, `aifullpeople-tech-lead`
should state the trade-off explicitly in `design.md`'s Technical Decisions table rather
than silently picking one — that's exactly what that table exists for.
