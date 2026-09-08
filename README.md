# fullcast

Fullcast — de "fullpeople" + o conceito de cast (elenco) de personas especializadas (PM, Tech Lead, Developer, Evaluator) que tocam o pipeline junto. Curto, soa como produto de verdade.

Framework de Spec-Driven Development (SDD): PM → Tech Lead → Developer → Evaluator, com Gates de qualidade, aprovação humana em cada etapa (HiTL) e organização por **initiative** (uma pasta por demanda, podendo ter várias em paralelo). Detalhe completo da arquitetura: [`docs/architecture.md`](docs/architecture.md).

## Instalação num projeto

Duas formas — escolha uma. As duas instalam as mesmas skills; a diferença é o que mais vem
junto (ver nota abaixo).

### Opção A — `install.sh` (completa, recomendada)

Requer `git`. Não precisa clonar dentro do projeto de destino — o script copia o necessário de
onde este repo estiver.

```sh
git clone https://github.com/aifullpeople/fullcast.git
cd fullcast
```

**Projeto existente:**
```sh
./install.sh /caminho/do/seu-projeto
```

**Projeto zerado** (a pasta pode nem existir ainda — o script cria):
```sh
./install.sh /caminho/do/projeto-novo
```

Copia pro destino: as 10 skills do framework (`fullcast-*`), a skill de linguagem (`golang-pro`,
hoje só Go), os 5 guidelines compartilhados, e o schema de referência — mais os symlinks em
`.claude/skills/` que o Claude Code precisa pra descobrir as skills. Não mexe em nada que já
exista no projeto (código, git, etc.).

### Opção B — `npx skills` (só as skills)

Se você já usa o [`npx skills`](https://github.com/vercel-labs/skills) (o mesmo instalador do
`grill-me` deste repo), dá pra apontar pra pasta local que você já clonou na Opção A:

```sh
git clone https://github.com/aifullpeople/fullcast.git
npx skills add ./fullcast --all -a claude-code -y
```

`--list` mostra as 11 skills disponíveis (as 10 `fullcast-*` + `golang-pro`) antes de instalar,
ou escolha específicas:

```sh
npx skills add ./fullcast --list
npx skills add ./fullcast --skill fullcast-pm --skill fullcast-tech-lead -a claude-code
```

Também dá pra apontar direto pro GitHub, sem clonar antes — `npx skills add
aifullpeople/fullcast --all -a claude-code -y` — mas nesse caso ele reflete o que estiver
pushado no repo remoto, não o seu checkout local.

**Diferença pra Opção A:** `npx skills` só entende pacotes com `SKILL.md` — ele não sabe copiar
`guidelines/` nem `schema/`, que não são skills. Pra ter o framework completo por esse caminho,
depois de instalar as skills copie essas duas pastas à mão do repo clonado
(`cp -R fullcast/guidelines fullcast/schema /caminho/do/seu-projeto/`). Sem `guidelines/`, os 5
arquivos compartilhados (SOLID, anti-patterns, etc.) que `fullcast-developer-codereview` espera
não existem — ele ainda funciona, só com menos contexto pra fundamentar os achados.

## Setup do projeto

Abra o projeto de destino no Claude Code e rode:

```
fullcast-init
```

Isso cria `.fullcast/` (config + estado) e `context_project.md` na raiz. Depois disso:

```
fullcast-pm
```

pra começar o brief/PRD da primeira initiative. `fullcast-status` a qualquer momento mostra onde cada initiative/feature está.

## Re-instalar / atualizar

**Opção A:** rodar `./install.sh <projeto>` de novo é seguro — sobrescreve só os arquivos do
framework (`.agents/skills/`, `.claude/skills/`, `guidelines/`, `schema/`). Nunca toca em
`.fullcast/` (seu estado, brief, PRD, features) nem no seu código.

**Opção B:** `npx skills update` (dentro do projeto de destino) atualiza as skills instaladas
por esse caminho pra última versão do repo.
