# Anti-patterns (universal)

Shared across every stack — these hold regardless of language. A stack's own
`anti-patterns.md` adds what's specific to it (e.g. Go's "ignored error return"). Check
both when `aifullpeople-developer` reviews its own work before a Gate run.

## God object / god function

One unit that knows or does too much — usually the end state of ignoring Single
Responsibility (`solid-principles.md`) commit after commit. Symptom: a file that keeps
growing because "that's already where similar things live."

## Magic numbers and strings

A literal value with meaning that isn't obvious at the point of use, repeated in more
than one place. Name it once; reference the name.

## Copy-paste duplication

The same logic reimplemented in two places instead of extracted once. Minor
duplication of a couple of lines is often fine (premature extraction has its own cost —
see below); duplication of a decision (a validation rule, a business calculation) is
the kind that causes real bugs when only one copy gets updated later.

## Premature abstraction

Building a generic/pluggable mechanism for a case that doesn't exist yet, on the
speculation that it might. Costs real complexity now for a maybe later. Prefer adding
the abstraction when the second real case shows up (see Open/Closed in
`solid-principles.md`).

## Premature optimization

Optimizing a path before measuring that it's actually a bottleneck, at the cost of
clarity. Correct and readable first; optimize the part that profiling actually shows is
slow.

## Swallowing errors

Catching or ignoring a failure without handling it or surfacing it — the failure just
disappears instead of being handled. See `error-handling.md` (both the shared
philosophy here and the stack-specific mechanics) for what to do instead.

## Shotgun surgery

A single conceptual change requires touching many unrelated files to take effect. Often
the flip side of too much duplication (see above) — the same decision expressed in
multiple places, so changing it means finding every copy.

## Testing implementation instead of behavior

A test that breaks whenever the internal structure changes, even though the observable
behavior didn't. Test what a caller can observe, not how the unit gets there
internally — see `testing.md` for the fuller version of this idea, and
`docs/architecture.md` §7 for how `contract.md` items are specifically designed to
avoid this trap (they describe behavior at the feature's outer boundary, never internal
units).
