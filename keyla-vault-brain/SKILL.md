---
name: keyla-vault-brain
description: Interface com vault Obsidian na EC2 - ler escrever classificar memoria
category: Organization
version: 1.0.0
author: Keyla
---

# Keyla Vault Brain

Interface com o cérebro da Keyla: o vault do Obsidian na EC2. Ler, escrever, classificar e manter a memória do sistema.

## Quando usar

- Keyla pedir para "salvar no cérebro"
- Consultar contexto antes de trabalho
- Criar nota de sessão, decisão, projeto
- Buscar informação no vault
- Registrar briefing, panorama, lista
- Atualizar notas existentes

## Vault Structure

```
/home/ubuntu/cerebro-vault/
├── 00-Inbox/          # Captura crua, sem classificação
├── 01-Areas/          # Áreas de responsabilidade
├── 02-Recursos/       # Referências, templates, guias
├── 03-Projetos/       # Projetos ativos
├── 03-Daily/          # Notas diárias
├── 04-Sessoes/        # Logs de sessão de trabalho
├── 05-Playbooks/      # Procedimentos recorrentes
├── 06-Decisoes/       # Decisões importantes
├── 07-Arquivados/     # Projetos/concluídos
├── 99-Snapshots/      # Marcos, backups de contexto
└── 00-Operacional/    # Configs operacionais do sistema
```

## Protocolo de Leitura

### Antes de qualquer trabalho
```bash
# 1. Buscar nota do dia
ls /home/ubuntu/cerebro-vault/03-Daily/ | grep $(date +%Y-%m-%d)

# 2. Se não existe, buscar nota recente de sessão
ls -lt /home/ubuntu/cerebro-vault/04-Sessoes/ | head -5

# 3. Verificar inbox
ls /home/ubuntu/cerebro-vault/00-Inbox/

# 4. Ver briefing operacional se relevante
cat /home/ubuntu/cerebro-vault/00-Operacional/*.md
```

### Busca por conteúdo
```bash
# Buscar por palavra no vault
grep -rl "termo" /home/ubuntu/cerebro-vault/ --include="*.md"

# Buscar por tag
grep -rl "#tag" /home/ubuntu/cerebro-vault/ --include="*.md"

# Buscar notas recentes (últimas 24h)
find /home/ubuntu/cerebro-vault/ -name "*.md" -mtime -1
```

## Protocolo de Escrita

### Classificar antes de escrever
```
Perguntas para classificar:
1. É ideia crua/lembrete? → 00-Inbox/
2. É projeto ativo? → 03-Projetos/
3. É log de sessão? → 04-Sessoes/
4. É procedimento recorrente? → 05-Playbooks/
5. É decisão/pesquisa? → 06-Decisoes/
6. É marco/congelamento? → 99-Snapshots/
7. É nota do dia? → 03-Daily/
8. Se não sabe → 00-Inbox/ (classificar depois)
```

### Criar nota diária
```bash
# Template
cat > /home/ubuntu/cerebro-vault/03-Daily/2026-04-30.md << 'EOF'
# 2026-04-30

## Prioridades
- [ ]

## Tarefas
- [ ]

## Notas
-

## Financeiro
-

## End of Day
- Resumo do que foi feito
- Pendências
EOF
```

### Criar log de sessão
```bash
# Template
cat > "/home/ubuntu/cerebro-vault/04-Sessoes/2026-04-30-$(date +%H%M)-agent-tarefa.md" << 'EOF'
# Sessão: <título>
Data: 2026-04-30
Agente: <codex/claude/openclaw>
Duração: <inicio> - <fim>

## Objetivo
<o que precisava ser feito>

## Realizado
- [x]
- [x]

## Decisões
-

## Pendências
- [ ]

## Arquivos tocados
-
EOF
```

### Criar nota de decisão
```markdown
# Título da Decisão

**Data:** 2026-04-30
**Impacto:** alto/médio/baixo
**Status:** decidida / em revisão / revisitar em <data>

## Contexto
O que levou a esta decisão.

## Decisão
O que foi decidido.

## Racional
Por que esta opção e não outras.

## Alternativas Descartadas
1. Opção X — por que não
2. Opção Y — por que não

## Consequências
O que muda com esta decisão.

## Revisitar
Quando reavaliar (se aplicável).
```

### Criar playbook
```markdown
# Playbook: <nome>

**Tipo:** procedimento recorrente
**Atualizado:** 2026-04-30

## Quando usar
Situações que acionam este playbook.

## Passos
1. Passo 1
2. Passo 2
3. Passo 3

## Comandos
```bash
comando aqui
```

## Troubleshooting
- Se X acontecer → fazer Y
- Se Z falhar → verificar W
```

## Protocolo de Manutenção

### Git no Vault
```bash
cd /home/ubuntu/cerebro-vault

# Ver mudanças
git status
git diff

# Commit
git add .
git commit -m "chore: daily notes - $(date +%Y-%m-%d)"
```

### Auto-commit (já configurado)
- Cron diário às 03:30 UTC faz commit automático
- Manual: `cd /home/ubuntu/cerebro-vault && git add . && git commit -m "auto: $(date)"`

### Dropbox Sync (já configurado)
- Push 3x/dia: 12:10, 18:10, 00:10 UTC
- Nunca deleta remoto
- Conflitos: Dropbox cria cópia conflicted

## Busca Inteligente

### Por contexto da Keyla
```bash
# O que a Keyla tem pendente?
grep -rl "pendente\|TODO\|to-do\|prioridade" /home/ubuntu/cerebro-vault/ --include="*.md"

# Financeiro
grep -rl "financeiro\|gasto\|vencimento\|pagar" /home/ubuntu/cerebro-vault/ --include="*.md"

# Projetos ativos
ls /home/ubuntu/cerebro-vault/03-Projetos/

# Decisões recentes
ls -lt /home/ubuntu/cerebro-vault/06-Decisoes/ | head -10
```

### Por robô/agente
```bash
grep -rl "juridico\|pauta\|vania\|mater\|james" /home/ubuntu/cerebro-vault/ --include="*.md"
```

## Regras de Classificação

### Se em dúvida
1. Colocar em `00-Inbox/` primeiro
2. Classificar depois quando tiver mais contexto
3. Perder uma nota no Inbox é melhor que perder em qualquer outro lugar

### Nomes de arquivo
```
Boa prática:
2026-04-30-briefing-manha.md          # Datas primeiro
mater-v2-arquitetura.md               # Projetos sem data
decisao-migracao-pg.md                # Decisões claras

Evitar:
nota1.md, novo.md, rascunho.md        # Sem contexto
Untitled.md, sem-título.md            # Sem contexto
```

### Links entre notas
```markdown
# Usar wikilinks do Obsidian
[[Projeto Mater V2]]
[[decisao-migracao-pg]]

# Referências cruzadas
Ver também: [[playbook-deploy-ec2]]
Relacionado: [[2026-04-29-sessao-codex]]
```

## Regras de Ouro

1. **C apturar primeiro, classificar depois** — melhor Inbox que perdido
2. **Vault é memória externa** — não confiar em memória de agente
3. **Se não está no vault, não existe** — decisões só valem se registradas
4. **Datá tudo** — notas sem data são difíceis de encontrar depois
5. **Manter limpo** — arquivar projetos concluídos em `07-Arquivados/`
6. **EC2 é canônico** — o vault local é réplica, a EC2 é a verdade
