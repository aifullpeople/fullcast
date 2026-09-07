# Go — stack overview

Overview for `stack.primary_language: go`. Concrete rules live in the sibling files in
this folder (`error-handling.md`, `naming-conventions.md`, `testing.md`,
`anti-patterns.md`, `gates.md`) — this file is the index plus what doesn't fit
elsewhere: package layout. The shared, stack-agnostic files at `guidelines/*.md`
(`solid-principles.md`, the philosophy half of `error-handling.md`/`naming-
conventions.md`/`testing.md`/`anti-patterns.md`) still apply — this folder only adds
what Go needs on top.

## Package layout

Standard Go project layout, adapted as the project actually needs it (don't create a
folder for a category with nothing in it yet):

- `cmd/<binary-name>/main.go` — one subfolder per binary the module produces; `main.go`
  should be thin (wire dependencies, call into `internal/`).
- `internal/` — everything not meant to be imported by another module. Most business
  logic lives here. Sub-package by domain concept (`internal/user/`,
  `internal/billing/`), not by technical layer (`internal/models/`,
  `internal/services/`) — a domain package can still separate its own types/logic
  internally, but the top-level cut should be domain-first.
- `pkg/` — only for code genuinely meant to be imported by other modules. If nothing
  outside this project imports it, it belongs in `internal/`, not `pkg/`.
- `api/` (when applicable) — protobuf/OpenAPI definitions, generated client stubs.

## Module and dependency hygiene

- One `go.mod` per module unless there's a specific reason for a multi-module repo
  (rare — don't default to it).
- Run `go mod tidy` before every commit that changes imports; a dependency added but
  never referenced, or referenced but missing from `go.mod`, is exactly what Gate 6
  (dead code / unused dependencies, `gates.md`) exists to catch.

## Concurrency

Prefer passing `context.Context` as the first parameter of any function that does I/O
or could be cancelled — this is also what `error-handling.md` in this folder assumes
when it talks about respecting cancellation. Don't reach for a goroutine/channel
because it's available; reach for it when there's a real concurrent operation to
express (fan-out I/O, a background worker) — see the universal "premature
optimization"/"premature abstraction" anti-patterns for why unmotivated concurrency is
still an anti-pattern even in a language that makes it easy.
