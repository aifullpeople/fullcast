# fullcast

Fullcast — de "fullpeople" + o conceito de cast (elenco) de personas especializadas (PM, Tech Lead, Developer, Evaluator) que tocam o pipeline junto. Curto, soa como produto de verdade.

Framework de Spec-Driven Development (SDD): PM → Tech Lead → Developer → Evaluator, com Gates de qualidade, aprovação humana em cada etapa (HiTL) e organização por **initiative** (uma pasta por demanda, podendo ter várias em paralelo). Detalhe completo da arquitetura: [`docs/architecture.md`](docs/architecture.md).

## Instalação num projeto

Requer `git` e o Claude Code instalado. Não precisa clonar dentro do projeto de destino — o `install.sh` copia o necessário de onde este repo estiver.

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

Isso copia pro destino: as 10 skills do framework (`fullcast-*`), a skill de linguagem (`golang-pro`, hoje só Go), os 5 guidelines compartilhados, e o schema de referência — mais os symlinks em `.claude/skills/` que o Claude Code precisa pra descobrir as skills. Não mexe em nada que já exista no projeto (código, git, etc.).

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

Rodar `./install.sh <projeto>` de novo é seguro — sobrescreve só os arquivos do framework (`.agents/skills/`, `.claude/skills/`, `guidelines/`, `schema/`). Nunca toca em `.fullcast/` (seu estado, brief, PRD, features) nem no seu código.
