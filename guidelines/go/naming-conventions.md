# Go — naming conventions

Concrete rules on top of the shared preamble in `guidelines/naming-conventions.md`
(consistency, name for meaning, no abbreviation/Hungarian notation — read that first).

## MixedCaps, not snake_case

`userCount`, not `user_count`. Exported identifiers start uppercase (`UserCount`),
unexported start lowercase (`userCount`) — this is Go's actual visibility mechanism,
not just a style choice, so getting it backwards is a correctness bug, not a lint nit.

## No `Get` prefix on simple accessors

`user.Name()`, not `user.GetName()` — Go convention omits `Get`. A setter, when needed,
is named for what it does (`SetName`), not just mirrored from the getter.

## No package-name stutter

`user.Service`, not `user.UserService` — the package name is already the namespace;
repeating it in every exported identifier defeats the purpose of having a package name
at all. Same logic for files: `user/service.go`, not `user/user_service.go`.

## Short receiver names, consistent per type

A method receiver is typically a one- or two-letter abbreviation of the type, the same
abbreviation for every method on that type: `func (s *Service) Create(...)`, not a
different name per method and not a full word like `service`.

## Interface names: `-er` suffix for single-method interfaces

`Reader`, `Writer`, `Closer` — a single-method interface named for what its one method
does, suffixed `-er`. Multi-method interfaces don't need to force this pattern; name
them for the role they play (`UserRepository`, not `UserRepositoryer`).

## Package names: short, lowercase, no underscore

`user`, not `user_management` or `userManagement`. A package name is a namespace
prefix everywhere it's imported (`user.Service`) — it should read well in that
position, which rules out anything long or mixed-case.

## Error variable names: `Err` prefix for sentinels

`var ErrNotFound = errors.New(...)` — exported sentinel errors are prefixed `Err`, not
suffixed or unprefixed, so they're recognizable at the call site
(`errors.Is(err, user.ErrNotFound)`).
