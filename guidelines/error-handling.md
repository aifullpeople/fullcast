# Error handling (universal preamble)

Deliberately thin — the mechanics are almost entirely stack-specific (Go returns errors
as values, Java throws exceptions, JS rejects promises/throws). The stack's own
`error-handling.md` (e.g. `go/error-handling.md`) carries the concrete mechanism. What's
here holds regardless of language:

## Fail fast, at the point where the problem is known

Detect and report a problem as close as possible to where it happens, with the context
available at that point (what operation, what input, what was expected) — not several
layers up where that context is gone.

## Never swallow an error silently

Every error is either handled (recovered from, with a documented reason it's safe to
continue) or propagated (with enough context added at each layer that a person
debugging later doesn't have to re-derive what was happening). "Catch and ignore" is
neither — see `anti-patterns.md`, "swallowing errors".

## Distinguish expected failure from a bug

A validation failure, a not-found lookup, a conflict — these are expected outcomes of
normal operation and should be handled as regular control flow, not treated as
exceptional. Reserve the stack's "this should never happen" mechanism (Go's `panic`,
an unchecked exception in other stacks) for violations of an invariant the program
cannot safely continue past.

## Log with context, not just a message

An error surfaced to a log or a caller should carry enough state to reproduce or
diagnose it — the operation, the relevant IDs/inputs, and (when propagated through
layers) the chain of what was being attempted, not just the innermost message.

## User-facing messages never leak internals

An error surfaced to an end user (not a log) should say what they can act on, without
exposing stack traces, internal identifiers, or infrastructure details that are only
meaningful to someone debugging the system.
