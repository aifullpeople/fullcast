# Go — testing

Concrete rules on top of the shared philosophy in `guidelines/testing.md` (pyramid,
what to mock, Arrange-Act-Assert — read that first).

## Table-driven tests

The default shape for testing multiple input/output pairs of the same behavior:

```go
func TestParseAmount(t *testing.T) {
    cases := []struct {
        name    string
        input   string
        want    int
        wantErr bool
    }{
        {name: "valid integer", input: "100", want: 100},
        {name: "negative rejected", input: "-1", wantErr: true},
    }
    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            got, err := ParseAmount(tc.input)
            if tc.wantErr {
                if err == nil {
                    t.Fatalf("expected error, got none")
                }
                return
            }
            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }
            if got != tc.want {
                t.Errorf("got %d, want %d", got, tc.want)
            }
        })
    }
}
```

`t.Run(tc.name, ...)` subtests give each case its own name in `go test -run` and in
failure output — never loop without `t.Run` for anything beyond a single trivial case.

## stdlib vs. `testify`

If the project has already picked one (check `context_project.md` and `go.mod` first),
follow it. Absent an established convention: stdlib's `testing` package is enough for
most table-driven cases (compare with `==` or `reflect.DeepEqual`/`cmp.Diff` for
structs); reach for `testify`'s `assert`/`require` when a suite needs many small
assertions per test and the extra dependency is already justified elsewhere in the
project. Don't introduce `testify` for a single test file — that's a project-wide
convention decision, not a per-feature one.

## Test file placement and naming

`<file>_test.go` alongside the file it tests, same package for white-box tests
(`package user`) or `<package>_test` for black-box tests exercising only the exported
API. Prefer black-box (`_test` package) for anything that should really be testing the
public contract, not internals — this keeps tests honest about what "behavior" means,
consistent with the shared file's "test behavior, not implementation" rule.

## Integration tests needing real infrastructure

Gate behind a build tag or an environment check (`if testing.Short() { t.Skip(...) }`,
or a `//go:build integration` tag) so `go test ./...` in a constrained environment
soft-fails cleanly instead of hanging on a missing database — this is what Gate 5
(tests, `gates.md`) needs to distinguish a real failure from an environment that simply
can't run this test right now.
