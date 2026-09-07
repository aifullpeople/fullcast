---
name: aifullpeople-set-methodology
description: |
  Changes the DEFAULT methodology for new features in .aifullpeople/config.yaml. Does
  NOT touch features already in progress — each feature is locked to the methodology
  it was created under (architecture.md §9). Use when the user wants to switch
  methodology going forward. Keywords: "switch methodology", "use bmad instead",
  "change default methodology".
---

# aifullpeople: Set Methodology

Renamed from an earlier "switch" idea specifically because it does not switch anything
in flight — it only changes what NEW features default to. See the framework's
`docs/architecture.md` §9 for the full rationale if needed; this file only needs the
rule and the steps.

## The rule (do not violate this)

- `config.yaml: methodology` is the default for features that don't exist yet.
- Every feature already in `state.json` carries its own `methodology` field, set once
  when the feature was created, immutable after that.
- A feature can only be moved to `stage: done` by the methodology recorded on it. If
  today only `aifullpeople` exists as a methodology, this is a no-op in practice — but
  every role (`pm`, `tech-lead`, `developer`, `evaluator`) still reads the feature's own
  `methodology` field before acting, not the config default, so this stays correct the
  day a second methodology exists.

## Steps

1. Read `.aifullpeople/config.yaml`. Confirm the requested methodology is one this
   installation actually supports (today: `aifullpeople` only).

2. Update `methodology:` in `config.yaml` to the new default. This is a one-line edit —
   no script involved.

3. **Do not touch `state.json`.** No feature's `methodology` field changes. If the user
   seems to expect in-flight features to switch too, explain the lock explicitly: they
   finish under the methodology they started with; only features created after this
   point pick up the new default.

4. Confirm to the user: "New features will now use `<methodology>`. Features already in
   progress (`<list ids>`) continue under `<their own methodology>`."
