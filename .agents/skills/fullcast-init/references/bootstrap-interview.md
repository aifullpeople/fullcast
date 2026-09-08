# Bootstrap: read first, ask only what's left

Detail for `fullcast-init` Step 2. Same posture the rest of the framework already takes
(`fullcast-pm`'s interview, `fullcast-tech-lead`'s pattern discovery): infer from what
already exists before asking the human to repeat it, and when there's genuinely nothing
to infer from, ask — never silently default. `config.yaml`'s own defaults (`en`, `go`)
exist for direct manual use of `init.sh`; this skill should never rely on them standing
in for a real answer.

## Step A — read what's already there

1. **`context_project.md` already exists and is populated** (has real content under
   "Architecture" or "Discovered patterns", not just the empty-skeleton placeholders)?
   That's authoritative per architecture.md §11's priority rule. Pull `stack.primary_language`
   straight from it, skip straight to running the script — don't ask the interview below
   at all, and don't ask the user to confirm something the file already answers.
2. **Repo has code already** — look for the strongest signal, in this order (stop at
   the first match; note when two conflict, e.g. a `frontend/` and a `backend/` folder
   both present — that's a full-stack project, not a tie to break):

   | Signal found | `primary_language` |
   |---|---|
   | `go.mod` | `go` |
   | `pom.xml` or `build.gradle`(`.kts`) | `java` |
   | `next.config.*` | `nextjs` |
   | `package.json` with no `next.config.*` (has `tsconfig.json`) | `typescript` |
   | `package.json`, no `tsconfig.json` | `javascript` |
   | `requirements.txt`, `pyproject.toml`, or `Pipfile` | `python` |
   | `Cargo.toml` | `rust` |
   | `Gemfile` | `ruby` |
   | `composer.json` | `php` |

   Detected stack is used directly — don't ask "is this a Go project?" when `go.mod` is
   sitting right there. If nothing in the table matches but the repo clearly has code
   (some other language, or a monorepo mixing several), name what you found and ask the
   human to confirm/correct rather than guessing further.
3. **Neither** — `context_project.md` doesn't exist (or exists but is still the empty
   skeleton) **and** the repo has no code. This is the only case that reaches Step B.

## Step B — the interview (genuinely greenfield only)

One question at a time (same rule `fullcast-pm`'s interview follows) — don't dump all
four as a single message:

1. **Language for generated content** (`en` or `pt-BR`). Don't default to `en` blind —
   this conversation has already been happening in some language; name it as your
   suggestion ("Você tem falado em português — uso pt-BR pros documentos gerados?" /
   "We've been talking in English — use `en` for generated docs?") and let the human
   confirm or override. This is the one question a same-language default is reasonable
   for; still ask, don't silently assume.
2. **What are you building?** One line, free text — "a task-tracking API", "an
   e-commerce storefront". Not stored verbatim anywhere critical; it's context for
   framing question 3 and 4 sensibly, and for the model's own understanding this
   session. Skip asking separately if the human already said this before invoking
   `fullcast-init`.
3. **Project type** — backend/API, frontend, full-stack, CLI tool, library, mobile, or
   other (let the human name it if none fit). Goes into `context_project.md`'s Stack
   section verbatim (`init.sh --project-type`) — this is what a future reader (human or
   `tech-lead`) sees before any code exists to infer it from.
4. **Primary stack language** — Go, Java, TypeScript/Node, Python, Rust, Ruby, PHP, or
   other. If question 2's answer already named one clearly ("a Go API"), confirm it
   instead of asking cold. This becomes `stack.primary_language` — see architecture.md
   §5.2 for how it resolves to a guidance skill (`<primary_language>-pro`) or a custom
   `guidelines/<primary_language>/`.

Summarize the four answers and get explicit confirmation before running the script —
same "summarize and confirm before drafting" discipline `fullcast-pm` uses. Don't run
`init.sh` on an unconfirmed guess.

## What this interview is NOT

Not the architecture-style question (Clean Architecture, hexagonal, layered, ...) —
that's `fullcast-tech-lead`'s bootstrap question on the first feature (architecture.md
§11), asked once real design work starts, not here. Asking it in `fullcast-init` too
would be redundant and premature — there's no feature yet to design around it.
