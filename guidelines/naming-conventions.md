# Naming conventions (universal preamble)

Deliberately thin — naming is mostly idiom-specific (Go's `MixedCaps` has nothing to do
with Java's `PascalCase`-for-classes-plus-verbose-names). The stack's own
`naming-conventions.md` (e.g. `go/naming-conventions.md`) carries the concrete rule.
What's here holds regardless of language:

## Consistency over personal preference

Once a project has an established convention (discovered via `context_project.md`, not
invented fresh per feature), follow it even if a different style would be your first
choice. A codebase that's consistently "not my favorite style" is better than one
that's inconsistent.

## Name for what it means, not how it's stored

A name should describe the thing's role, not its type or storage mechanism (`userList`
naming the storage shape instead of `users` naming the thing) — the type is already
visible at the declaration; the name should carry information the type doesn't.

## No abbreviation that isn't already standard in the domain

`ctx`, `id`, `URL` are fine because they're near-universal. Inventing a shorthand for
this codebase only (`usr`, `cfg` when the rest of the codebase spells things out) adds
a small tax every time someone reads it.

## No Hungarian notation

Don't encode the type in the name (`strName`, `iCount`) — the type system already knows
the type; repeating it in the name is noise that goes stale the moment the type changes.

## Boolean names read as a question

`isActive`, `hasPermission`, `canEdit` — a boolean name should make the `if` statement
read like a sentence. This one generalizes across nearly every stack's idiom.
