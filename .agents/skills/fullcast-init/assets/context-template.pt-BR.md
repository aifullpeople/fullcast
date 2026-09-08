# Contexto do projeto

*Documento vivo. pm/tech-lead/developer/evaluator vão complementando; ninguém reescreve por
completo (architecture.md §11). Não é amarrado a uma metodologia só — compartilhado por
qualquer metodologia que tocar este repo.*

## Regra de prioridade

Se este arquivo já tiver conteúdo em "Arquitetura" ou "Domínio" abaixo, esse conteúdo é
autoritativo — nenhum papel deve substituí-lo por um padrão genérico. Só enquanto este
arquivo estiver genuinamente vazio (greenfield de verdade) é que a preferência declarada
pelo usuário manda; assim que ele responder, a resposta é escrita aqui e vira a próxima
entrada autoritativa (architecture.md §11).

## Overview

- Tipo: <greenfield | brownfield>
- Categoria: <backend | frontend | full-stack | CLI | biblioteca | mobile | outro>
- Descrição: <uma linha — o que é>
- Público: <uma linha, ou "ainda não definido">

## Stack

- Linguagem principal: <linguagem> (<versão, ou "ainda não fixada">) — ver `.fullcast/config.yaml`
- Framework: <ou "ainda não decidido">
- Build / gerenciador de pacotes: <ou "ainda não decidido">
- Banco de dados: <ou "nenhum ainda">
- Infra: <ou "ainda não decidido">

## Arquitetura

(vazio — a primeira passada do tech-lead pergunta o estilo de arquitetura e a comunicação
entre módulos/serviços explicitamente — Clean Architecture, hexagonal, camadas simples, o
que o usuário nomear — antes de qualquer outra coisa, e escreve a resposta aqui)

## Convenções

- Testes: <ou "ainda não decidido">
- Lint / format: <ou "ainda não decidido">
- Commits / branches: <ou "ainda não decidido">

## Domínio

(vazio — pm/tech-lead populam isso a partir do PRD/design conforme as features forem
construídas: entidades principais, regras de negócio críticas)

## Restrições

- NFRs: <ou "nenhum declarado ainda">
- Proibições: <ou "nenhuma declarada ainda">
- Notas de autonomia da IA: <nuance livre além do `human_in_the_loop`/gates do config.yaml
  — ou "ver config.yaml">

## Padrões descobertos

(vazio — qualquer papel que encontrar um padrão de verdade no código, ainda não
documentado acima, adiciona aqui; nunca reescreve por completo, só acrescenta)

## Comandos de Gate

(vazio — developer preenche na primeira vez que o comando de cada Gate for descoberto, pra
nunca ser redescoberto por task; ver architecture.md §7/§8)
