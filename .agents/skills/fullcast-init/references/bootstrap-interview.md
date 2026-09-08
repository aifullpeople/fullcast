# Bootstrap: always ask, let detection make it fast

Detail for `fullcast-init` Step 2. Same posture the rest of the framework already takes
(`fullcast-pm`'s interview, `fullcast-tech-lead`'s pattern discovery): infer from what
already exists so the question is fast, but always put it in front of the human — code
in the repo answers *what to suggest*, never *whether to ask*. `init.sh`'s own defaults
(`en`, `go`) exist for direct manual use of the script; this skill never relies on them
standing in for a real, human-confirmed answer.

## Step A — read what's already there (before asking anything)

1. **`context_project.md` already exists and is populated** (real content under
   "Architecture" or "Discovered patterns", not just the empty-skeleton placeholders)?
   Pull `stack.primary_language` and project type straight from it — that's your
   suggestion for questions 3/4 below (architecture.md §11's priority rule: a populated
   file outranks a generic guess). Still confirm with the human in question 3/4, don't
   skip straight past them.
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

   This becomes your suggestion for question 4 below. A `frontend/`+`backend/` (or
   similar) split is your suggestion of "full-stack" for question 3. Nothing here skips
   a question — it only changes its shape, per Step B.
3. **Neither found anything** — genuinely nothing to suggest from. Questions 3/4 get
   asked cold instead of as a confirmation.

## Step B — the interview (always runs, code or no code)

One question at a time (same rule `fullcast-pm`'s interview follows) — don't dump all
four as a single message. Two shapes per question, depending on what Step A found:

1. **Language for generated content** (`en` or `pt-BR`) — always asked cold; nothing in
   a repo's code answers this. This conversation has already been happening in some
   language, though — name it as your suggestion ("Você tem falado em português — uso
   pt-BR pros documentos gerados?" / "We've been talking in English — use `en`?") and
   let the human confirm or override.
2. **What are you building?** One line, free text — "a task-tracking API", "an
   e-commerce storefront". Skip re-asking if the human already said this before
   invoking `fullcast-init`; otherwise always ask, even with code present (a repo's
   code rarely states its own purpose in a form worth quoting back).
3. **Project type** — backend/API, frontend, full-stack, CLI tool, library, mobile, or
   other. With a Step A signal: confirm it ("Vi `frontend/` e `backend/` — é full-stack,
   certo?"). Without one: ask directly. Either way, the answer goes into
   `context_project.md`'s Stack section verbatim (`init.sh --project-type`).
4. **Primary stack language** — Go, Java, TypeScript/Node, Python, Rust, Ruby, PHP, or
   other. With a Step A signal (from the table, or question 2 already naming one
   clearly, e.g. "a Go API"): confirm it ("Detectei Go via `go.mod` — confirma?").
   Without one: ask directly. Becomes `stack.primary_language` — see architecture.md
   §5.2 for how it resolves to a guidance skill (`<primary_language>-pro`) or a custom
   `guidelines/<primary_language>/`.

Summarize the four answers and get explicit confirmation before running the script —
same "summarize and confirm before drafting" discipline `fullcast-pm` uses. Don't run
`init.sh` on an unconfirmed guess, detected or not.

## What this interview is NOT

Not the architecture-style question (Clean Architecture, hexagonal, layered, ...) —
that's `fullcast-tech-lead`'s bootstrap question on the first feature (architecture.md
§11), asked once real design work starts, not here. Asking it in `fullcast-init` too
would be redundant and premature — there's no feature yet to design around it.
