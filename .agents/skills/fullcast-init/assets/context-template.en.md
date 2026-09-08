# Project context

*Living document. pm/tech-lead/developer/evaluator append to it; nobody rewrites it wholesale
(architecture.md §11). Not tied to any one methodology — shared by whatever methodology
touches this repo.*

## Priority rule

If this file has content under "Architecture" or "Domain" below, that content is
authoritative — no role should override it with a generic default. Only while this file
is genuinely empty (true greenfield) does the user's stated preference take priority;
once they answer, the answer is written here and becomes the next authoritative entry
(architecture.md §11).

## Overview

- Type: <greenfield | brownfield>
- Category: <backend | frontend | full-stack | CLI tool | library | mobile | other>
- Description: <one line — what this is>
- Audience: <one line, or "not stated yet">

## Stack

- Primary language: <language> (<version, or "not pinned yet">) — see `.fullcast/config.yaml`
- Framework: <or "not decided yet">
- Build / package manager: <or "not decided yet">
- Database: <or "none yet">
- Infra: <or "not decided yet">

## Architecture

(empty — the first feature's tech-lead pass asks for the architecture style and
inter-module/service communication explicitly — Clean Architecture, hexagonal, simple
layered, whatever the user names — before anything else, and writes the answer here)

## Conventions

- Tests: <or "not decided yet">
- Lint / format: <or "not decided yet">
- Commits / branches: <or "not decided yet">

## Domain

(empty — pm/tech-lead populate this from the PRD/design as features get built: main
entities, critical business rules)

## Constraints

- NFRs: <or "none stated yet">
- Prohibitions: <or "none stated yet">
- AI autonomy notes: <free-form nuance beyond config.yaml's human_in_the_loop/gates — or
  "see config.yaml">

## Discovered patterns

(empty — appended by any role that finds a real pattern in the code not already
documented above; never rewritten wholesale, only added to)

## Gate commands

(empty — developer fills this in the first time each Gate's command is discovered,
so it is never rediscovered per task; see architecture.md §7/§8)
