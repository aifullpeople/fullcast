# Go — error handling

Concrete rules on top of the shared philosophy in `guidelines/error-handling.md` (fail
fast, never swallow, log with context — read that first if you haven't).

## Errors are values, not exceptions

Return `error` as the last return value; check it immediately at the call site. Go has
no exception mechanism for ordinary failure — don't simulate one with `panic`/`recover`
for expected outcomes (validation failure, not-found, conflict). That's what the
"expected failure vs. a bug" distinction in the shared file means concretely here.

## Wrap with context, using `%w`

```go
if err != nil {
    return fmt.Errorf("loading user %s: %w", userID, err)
}
```

`%w` (not `%v`) preserves the underlying error so callers can unwrap it. Each layer
adds ONE clause of context (what it was doing), not a restatement of the whole chain —
the chain itself carries the full path when unwrapped.

## Inspect with `errors.Is` / `errors.As`

- `errors.Is(err, sql.ErrNoRows)` — is this (or does it wrap) a specific sentinel error?
- `errors.As(err, &myErr)` — does this (or does it wrap) a specific error TYPE, and if
  so, extract it.

Never compare wrapped errors with `==` or a type switch on the raw error — wrapping
breaks both; `errors.Is`/`errors.As` are the only correct way to inspect an error that
might have been wrapped by an intermediate layer.

## Sentinel errors and custom error types

- A sentinel (`var ErrNotFound = errors.New("not found")`) for a condition callers need
  to check by identity.
- A custom type implementing `error` when callers need to extract structured data
  (which field failed validation, what the conflicting value was) — pair it with an
  `errors.As`-compatible type, not a string they have to parse.

## `panic` — only for a violated invariant, never for control flow

Reserve `panic` for "this program cannot safely continue" (a genuinely impossible
state, a programmer error like a nil map write in a place that should be unreachable).
Never `panic` for a validation failure, a not-found, or anything an external input can
trigger — that belongs in a returned `error`. A library should essentially never
`panic` across its own public API boundary.

## Respect `context.Context` cancellation

Any function doing I/O should accept `ctx context.Context` and check `ctx.Err()` (or
let the underlying call do so) rather than continuing work after the caller has already
given up.
