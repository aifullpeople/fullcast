# Go — Gate commands

Concrete tool per Gate (`docs/architecture.md` §8) for `stack.primary_language: go`.
`aifullpeople-developer` reads this the FIRST time a Gate's command is needed for a
project, then caches the resolved command in `context_project.md`'s "Gate commands"
section — never re-derive it from here every task (see
`aifullpeople-developer/references/execution-rules.md`, "Gate command discovery").

| # | Gate | Command | Notes |
|---|---|---|---|
| 1 | Compile/contract | `go build ./...` | Also run `go vet ./...` here — it catches real bugs (unreachable code, format-string mismatches), not just style. If the project defines API contracts (protobuf, OpenAPI), validate those too if a generator/linter for them is already part of the project's toolchain. |
| 2 | Lint | `golangci-lint run` | If `.golangci.yml` doesn't exist yet, that's a project setup decision, not something this Gate should silently skip forever — flag it in `context_project.md` as a missing convention the first time it's needed, same as any other undiscovered convention. |
| 3 | Dependency/architecture boundary | `depguard` (via `golangci-lint`, if configured) or a project-specific import-boundary check | Go has no built-in enforcement here — if the project hasn't configured one, this Gate can only warn, not block, until a convention exists. Document that state in `context_project.md` rather than pretending the Gate ran when it didn't. |
| 4 | Project's own script | *(project-specific — discover from `Makefile`/README the first time; see the open item in `docs/architecture.md` §15)* | Only runs when `config.yaml: gates.custom` is `true`. |
| 5 | Tests | `go test ./...` | Add `-race` when the project has any concurrent code — a data race caught in CI is far cheaper than one caught in production. |
| 6 | Dead code / unused dependencies | `staticcheck ./...` (catches unused code via `U1000`) + `go mod tidy -diff` (flags `go.mod` drift without modifying it) | `go mod tidy -diff` is the non-mutating check; only run plain `go mod tidy` when you actually intend to fix the drift, not as a Gate check. |
| 7 (proposed, off by default) | Security | `govulncheck ./...` | Checks the module's dependency tree against the Go vulnerability database. Enable via `config.yaml: gates.security: true`. |
