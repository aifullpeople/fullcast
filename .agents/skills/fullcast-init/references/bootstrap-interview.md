# Bootstrap: always ask, let detection make it fast

Detail for `fullcast-init` Steps 2-3. Same posture the rest of the framework already
takes (`fullcast-pm`'s interview, `fullcast-tech-lead`'s pattern discovery): infer from
what already exists so the question is fast, but always put it in front of the human —
code in the repo answers *what to suggest*, never *whether to ask*. `init.sh`'s own
defaults (`en`, `go`) exist for direct manual use of the script; this skill never relies
on them standing in for a real, human-confirmed answer.

Fields map directly onto `assets/context-template.<language>.md`'s sections — see that
file for the exact placeholders each answer fills.

## Step A — read what's already there (before asking anything)

1. **`context_project.md` already exists and is populated** (real content under
   "Architecture" or "Domain", not just the empty-skeleton placeholders)? Pull Stack/
   Overview straight from it — that's your suggestion for the confirmations below
   (architecture.md §11's priority rule: a populated file outranks a generic guess).
   Still confirm, don't skip past the question entirely.
2. **Repo has code already** — determines `Overview: Type` (`brownfield`, no need to
   ask) and seeds the Stack block. Look for the strongest signal, in this order (stop
   at the first match; note when signals conflict, e.g. a `frontend/` and a `backend/`
   folder both present — that's `full-stack`, not a tie to break):

   | Signal found | `primary_language` | Build/pkg manager (if also present) |
   |---|---|---|
   | `go.mod` | `go` | Go modules |
   | `pom.xml` | `java` | Maven |
   | `build.gradle`(`.kts`) | `java` | Gradle |
   | `next.config.*` | `nextjs` | see lockfile below |
   | `package.json` + `tsconfig.json`, no `next.config.*` | `typescript` | see lockfile |
   | `package.json`, no `tsconfig.json`/`next.config.*` | `javascript` | see lockfile |
   | `requirements.txt` / `pyproject.toml` / `Pipfile` | `python` | pip / Poetry / pipenv |
   | `Cargo.toml` | `rust` | Cargo |
   | `Gemfile` | `ruby` | Bundler |
   | `composer.json` | `php` | Composer |

   Lockfile → JS/TS package manager: `package-lock.json` → npm, `yarn.lock` → Yarn,
   `pnpm-lock.yaml` → pnpm. A framework (Express, Gin, Spring Boot, ...) is sometimes
   visible from dependencies in the same manifest — name it as a suggestion if obvious,
   otherwise leave it for question 6.
3. **Repo has no code** — `Overview: Type` is `greenfield`, no need to ask. Nothing to
   suggest for the Stack block either; questions 5-9 get asked cold.

## Step B — the interview

One question at a time (same rule `fullcast-pm`'s interview follows) — don't dump
several as a single message. Split into two blocks: **required** (always asked/
confirmed in full) and **optional** (offer a fast skip after the required block, then
still go one at a time through whichever the human wants to answer).

### Required

1. **Language for generated content** (`en` or `pt-BR`) — always asked cold; nothing in
   a repo's code answers this. This conversation has already been happening in some
   language, though — name it as your suggestion ("Você tem falado em português — uso
   pt-BR pros documentos gerados?" / "We've been talking in English — use `en`?") and
   let the human confirm or override.
2. **What are you building?** One line → `Overview: Description`. Skip re-asking if the
   human already said this before invoking `fullcast-init`; otherwise always ask, even
   with code present (code rarely states its own purpose in a form worth quoting back).
3. **Category** → `Overview: Category` (backend/API, frontend, full-stack, CLI tool,
   library, mobile, other). With a Step A signal (e.g. both `frontend/`+`backend/`):
   confirm it. Without one: ask directly.
4. **Primary stack language** → `Stack: Primary language`. With a Step A signal (from
   the table, or question 2 already naming one clearly, e.g. "a Go API"): confirm it
   ("Detectei Go via `go.mod` — confirma?"). Without one: ask directly. Resolves to a
   guidance skill (`<primary_language>-pro`) or a custom `guidelines/<primary_language>/`
   — architecture.md §5.2.

After these four, offer the fast exit before continuing: *"Quer detalhar mais agora
(framework, banco de dados, convenções, restrições) ou prefere deixar 'a definir' e
preencher depois?"* — a human who wants to get moving can decline the rest wholesale;
don't force questions 5-9 on someone who explicitly said skip.

### Optional (still one at a time if the human wants them; "a definir" / "ainda não
decidido" is always a valid, non-blocking answer to any single one of these)

5. **Version** of the primary language, if known → `Stack: Primary language (version)`.
6. **Framework** → `Stack: Framework`.
7. **Build/package manager** → `Stack: Build / package manager`. Often already known
   from Step A's lockfile detection — confirm rather than ask when so.
8. **Database** and **infra** → `Stack: Database`, `Stack: Infra`. Ask together, one
   message, since they're both simple facts-or-"not yet".
9. **Testing / lint-format / commit-branch conventions** → `Conventions:` block. Ask
   together as one round; this is genuinely useful to capture now because
   `fullcast-developer`'s Gate command discovery (architecture.md §8) reads exactly
   this kind of thing later — capturing it here can save a rediscovery.
10. **Audience** → `Overview: Audience`.
11. **NFRs, prohibitions, AI autonomy notes** → `Constraints:` block. Ask together, one
    round. AI autonomy notes are free-text nuance *beyond* `config.yaml`'s
    `human_in_the_loop`/`gates` (which already exist and don't need restating here) —
    only capture something if the human states an actual exception or preference.

Summarize whatever was answered (required + whichever optional fields weren't skipped)
and get explicit confirmation before writing `context_project.md` and running the
script — same "summarize and confirm before drafting" discipline `fullcast-pm` uses.

## What this interview is NOT

Not the architecture-style question (Clean Architecture, hexagonal, layered,
inter-module communication) — that's `fullcast-tech-lead`'s bootstrap question on the
first feature (architecture.md §11), asked once real design work starts, not here.
Not domain modeling (main entities, critical business rules) — that comes from the PRD
(`fullcast-pm`) and the design (`fullcast-tech-lead`), grounded in an actual feature,
not guessed before one exists. Asking either here would be premature (nothing to ground
the answer in yet) and redundant with a question those roles ask properly, in context,
later.
