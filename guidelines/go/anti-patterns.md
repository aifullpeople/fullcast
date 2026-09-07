# Go — anti-patterns

On top of the universal list in `guidelines/anti-patterns.md` (god object, magic
numbers, copy-paste, premature abstraction/optimization — read that first).

## Ignoring a returned error

```go
data, _ := os.ReadFile(path) // the error just vanished
```
Every `error` return has to be checked or explicitly, visibly discarded with a comment
explaining why it's safe (rare — almost always it isn't). This is Go's version of
"swallowing errors" from the universal list, and it's the single most common Go
anti-pattern because the language makes it syntactically effortless to do.

## `panic` as control flow

Using `panic`/`recover` to unwind out of a deeply nested call instead of returning
`error` up the stack. See `error-handling.md` in this folder — `panic` is reserved for
violated invariants, not for expected failure paths.

## `interface{}` / `any` as an escape hatch

Reaching for `any` (or the pre-1.18 `interface{}`) to avoid deciding a concrete type or
writing a proper interface, then type-asserting it back inside the function. This
throws away the compiler's type checking for no real gain — if the type is genuinely
one of a few options, use a proper interface or a sum-type-style pattern; if it's
generic behavior, use Go generics instead.

## Returning a nil interface wrapping a nil pointer

```go
func do() error {
    var e *MyError // nil pointer
    return e       // returned as `error` — the interface itself is NOT nil!
}
```
`err != nil` is now true even though the pointer is nil, because the interface value
carries a type. Return a literal `nil`, not a typed nil pointer, when there's no error.

## Overusing goroutines without a clear termination/error path

Launching a goroutine with no way to signal it to stop and no channel/errgroup to
collect its error means both a possible leak and a swallowed failure. Every goroutine
needs an owner that knows how it ends — prefer `errgroup` (or an equivalent explicit
pattern) over a bare `go func(){ ... }()` whose error just disappears.

## `bufio.Scanner` token buffer smaller than your own documented limit

```go
scanner := bufio.NewScanner(r)
scanner.Buffer(make([]byte, 0, 64*1024), 10*1024*1024) // 10MB max token
```
If your own API promises to accept input up to some size (e.g. "up to 100MB"), the
scanner's max-token-size argument has to be at least that large — a single line/word
token bigger than the buffer's second argument fails with `bufio.Scanner: token too
long`, even though the total input is within your documented limit. Size the buffer
against the actual limit you promise, not an arbitrary round number. (Found by
actually running this framework end-to-end on its first demo feature — a hard-fail
caught by the task's own unit test, exactly the kind of thing Gate 5 exists for.)

## Package-level mutable state as an implicit dependency

A package-level `var` used as hidden shared state instead of being passed explicitly
makes testing hard (state leaks between tests) and hides a real dependency the type
signature should show — this is Dependency Inversion (`solid-principles.md`) violated
via a global instead of an injected collaborator.
