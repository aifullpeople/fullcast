# Testing philosophy (universal)

Philosophy only — no tool names here on purpose. The stack's own `testing.md` (e.g.
`go/testing.md`) covers the concrete framework and style. This file covers what to test
and how much, which doesn't change with the language.

## The pyramid, roughly

Most coverage from fast, isolated unit tests; fewer integration tests crossing a real
boundary (database, another service); fewer still end-to-end tests exercising the whole
system. If a suite is inverted (mostly slow end-to-end tests, few unit tests), test runs
get slow and flaky, and failures get harder to localize.

`fullcast`'s `contract.md` (`docs/architecture.md` §7) sits above this pyramid, not
inside it — its items are behavior promises at the feature's outer boundary, verified
however that surface calls for (a unit test, an integration test, or a full E2E run
depending on the surface). Don't confuse contract items with the pyramid's layers;
`design.md`'s Testing Strategy is where the pyramid's actual layers get planned.

## What to test

Behavior a caller can observe: given this input/state, what comes out, what changes.
Not internal structure — a refactor that doesn't change observable behavior should not
break tests (see `anti-patterns.md`, "testing implementation instead of behavior").

Always test the failure paths, not just the happy path — especially anything flagged
Error Handling in the PRD/design (auth, payments, data-loss risk, security-sensitive,
irreversible operations).

## What to mock

Mock at a real boundary — network calls, third-party services, anything slow or
non-deterministic (time, randomness). Don't mock your own internal collaborators just
to isolate a unit if calling them for real is fast and deterministic; that turns the
test into a test of the mock's assumptions instead of the actual code.

## Structure: Arrange-Act-Assert

Set up state, perform the one action under test, assert the outcome. Keep these three
parts visually distinct in a test — a test that interleaves setup and assertions is
harder to read and more likely to assert the wrong thing after a copy-paste edit.

## Test naming

Name a test after the behavior it verifies, not after the function it calls — a
reader should understand what broke from the test name alone in a failure list, before
opening the file.
