---
name: aifullpeople-init
description: |
  Bootstraps the aifullpeople SDD framework in a project: creates .aifullpeople/
  (config.yaml, state.json) and context_project.md at the project root. Use when
  starting a new project with this framework, or re-initializing one. Keywords:
  "init aifullpeople", "set up sdd framework", "start aifullpeople".
---

# aifullpeople: Init

Sets up the two things every other aifullpeople skill depends on: `.aifullpeople/`
(config + state) and `context_project.md` (shared engineering context, outside
`.aifullpeople/` because any methodology can read it — see the framework's
`docs/architecture.md` §9 and §11 if you need the full rationale; this file only
needs the steps).

## Steps

1. **Check for an existing setup.** Look for `.aifullpeople/` in the current directory.
   If it exists, tell the user and ask whether to inspect it (point them at
   `aifullpeople-status`) or reinitialize with `--force`. Never silently overwrite.

2. **Ask what isn't obvious from context:**
   - Language for generated content: `en` or `pt-BR`. Default `en` if the user doesn't say.
   - Primary stack language for this project (`go`, `java`, `nextjs`, ...). If the repo
     already has code, infer it from the dominant language instead of asking.

3. **Run the script:**
   ```
   scripts/init.sh --language <en|pt-BR> --stack <primary_language> [--force]
   ```
   This creates `.aifullpeople/{config.yaml,state.json,features/}` and, if it doesn't
   already exist, a starter `context_project.md` at the project root.

4. **If the codebase is non-empty**, do a first pass of pattern discovery — the same
   two-layer approach `aifullpeople-tech-lead` uses (runtime/framework, database, auth,
   API style, testing, folder structure, plus anything else worth noting) — and append
   the findings to `context_project.md` under "Discovered patterns" (append, don't
   rewrite the file — see the "Documento vivo" rule in the framework's architecture
   doc §11). Skip this step entirely for a greenfield project; the skeleton the script
   wrote is enough, and the first feature's `tech-lead` pass will fill it in.

5. **Report** what was created and the two next steps: run `aifullpeople-pm` to start
   discovery/requirements, or `aifullpeople-status` to check state at any time.

## Notes

- Never hand-edit `state.json`'s structure to add ad-hoc fields — check
  `schema/state.schema.json` (in the installed framework) first; it documents every
  field this framework's skills expect.
- This skill never touches an existing `context_project.md`'s content beyond the
  discovery append in step 4 — it's a living document owned collectively by every role,
  not by `init`.
