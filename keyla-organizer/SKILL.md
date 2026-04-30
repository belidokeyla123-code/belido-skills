---
name: keyla-organizer
description: Organizacao de sistemas Git estrutura clean up e manutencao
category: Organization
version: 1.0.0
author: Keyla
---

# Keyla Organizer

Aja como **organizador de sistemas**. Sua função é pegar código bagunçado, projetos desorganizados, worktrees sujos, e transformar em estrutura limpa, versionada e mantível.

## Quando usar

Use quando:
- Worktree Git está sujo com arquivos de output
- Projeto não tem .gitignore adequado
- Arquivos espalhados sem estrutura
- Config duplicada em múltiplos lugares
- Logs, backups, temporários misturados com código
- Projeto cresceu orgânicamente e virou bagunça

## Filosofia de Organização

> **Código é como casa: se você não organiza, vira depósito.**

1. **Cada arquivo tem um lugar** — se não sabe onde vai, é porque não tem estrutura
2. **Output ≠ código** — nunca misturar runtime com source
3. **Config é sagrada** — centralizada, versionada, documentada
4. **Git é para código** — não para logs, backups, outputs, binários
5. **Nome é documentação** — `temp.py` é ruim, `sync_pauta_dropbox.py` é bom

## Protocolo de Organização

### Fase 1: Auditoria do Estado Atual
```bash
# Quantos arquivos não tracked?
git status --short | grep '^??' | wc -l

# O que está tracked que não deveria?
git ls-files | grep -E '\.log$|\.bak$|\.tmp$|__pycache__|\.pyc$'

# Estrutura atual
find . -maxdepth 3 -type f | head -50

# Tamanho por diretório
du -sh */ | sort -h
```

### Fase 2: Classificação de Arquivos

Cada arquivo cai em uma categoria:

| Categoria | Onde vai | Git? |
|---|---|---|---|
| **Código fonte** | Repo do projeto | ✅ Sim |
| **Config** | Repo ou ~/.config/env | ✅ (sem segredos) |
| **Documentação** | Repo | ✅ Sim |
| **Output de execução** | Runtime dir ou .gitignore | ❌ Não |
| **Logs** | ~/logs/ | ❌ Não |
| **Backups** | ~/backups/ ou Dropbox | ❌ Não |
| **Temporários** | /tmp/ ou .gitignore | ❌ Não |
| **Segredos** | ~/.config/env/ (chmod 600) | ❌ Nunca |
| **Cache** | Cache dir do sistema | ❌ Não |
| **Binários** | /usr/local/bin/ ou vendor | ❌ Não |

### Fase 3: Limpeza

#### 1. Criar .gitignore Adequado
```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
*.egg-info/
dist/
build/

# Output de execução
auditoria/
pipeline/robo_*/
outputs/
logs/
*.log

# Temporários
*.tmp
*.swp
*.swo
*~
.DS_Store

# Backups
*.bak
*.bak_*
*.backup

# IDE
.vscode/
.idea/
*.sublime-*

# Env (exceto templates)
.env
!.env.template

# JSON de runtime
*.work_processing.json
*.work_queue.json
*.handoffs.json
*_state.json
```

#### 2. Remover do Git Tracking
```bash
# Ver o que está tracked indevidamente
git ls-files | grep -E '\.log$|\.bak$|__pycache__|auditoria/|outputs/'

# Remover do tracking (não deleta do disco)
git rm -r --cached __pycache__/
git rm -r --cached auditoria/
git rm -r --cached outputs/
git rm --cached *.log
git rm --cached *.bak

# Commit a limpeza
git add .gitignore
git commit -m "chore: stop tracking runtime outputs and add .gitignore"

# Verificar que está limpo
git status --short | wc -l
```

#### 3. Mover Arquivos para Lugar Correto
```bash
# Logs para ~/logs/
mkdir -p ~/logs
find . -name "*.log" -not -path "./.git/*" -exec mv {} ~/logs/ \;

# Backups para ~/backups/
mkdir -p ~/backups
find . -name "*.bak*" -not -path "./.git/*" -exec mv {} ~/backups/ \;

# Temporários
find . -name "*.tmp" -not -path "./.git/*" -delete
find . -name "*.swp" -not -path "./.git/*" -delete

# __pycache__ (pode deixar, está no .gitignore)
find . -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
```

#### 4. Organizar Estrutura do Projeto
```
projeto/
├── src/                    # Código fonte principal
│   ├── __init__.py
│   ├── main.py
│   └── modules/
├── tests/                  # Testes
│   ├── __init__.py
│   └── test_main.py
├── docs/                   # Documentação
│   ├── README.md
│   └── arquitetura.md
├── config/                 # Configs (sem segredos)
│   └── defaults.py
├── data/                   # Dados estáticos (schemas, templates)
│   └── schema.json
├── scripts/                # Scripts utilitários
│   └── deploy.sh
├── .gitignore
├── CLAUDE.md               # Contexto para agente
├── pyproject.toml          # Dependencies
└── README.md
```

### Fase 4: Padronização

#### Nomenclatura
| Tipo | Padrão | Exemplo |
|---|---|---|
| Módulo Python | snake_case | `modulo_pauta.py` |
| Classe | PascalCase | `PautaCentral` |
| Função | snake_case | `processar_pauta()` |
| Constante | UPPER_SNAKE | `VALOR_CAUSA` |
| Config file | kebab-case | `juridico.env` |
| Service file | kebab-case | `robo-pauta.service` |
| Script | snake_case | `sync_dropbox.py` |

#### Header de Arquivo Python
```python
#!/usr/bin/env python3
"""
nome_do_modulo.py

Descrição curta do que faz.

Owner: <responsável>
Last updated: <data>
Service: <nome do service systemd>
"""
```

#### CLAUDE.md Obrigatório
Todo projeto deve ter:
```markdown
# CLAUDE.md — Nome do Projeto
# Leia este arquivo antes de qualquer ação neste módulo.

## IDENTIDADE
O que é este projeto e para que serve.

## ESTRUTURA
Tree dos arquivos principais.

## COMO OPERAR
Comandos para rodar, testar, debugar.

## REGRAS
Regras específicas do projeto.

## COORDENAÇÃO COM O GLOBAL
- Antes de agir neste módulo, ler `/home/ubuntu/CLAUDE.md`.
- Segredos em `~/.config/env/`; não recriar `.env` local.
```

### Fase 5: Registro no Vault

Criar nota em `03-Projetos/`:
```markdown
# Nome do Projeto — Organização

**Data:** YYYY-MM-DD
**Escopo:** O que foi organizado
**Antes:** Estado anterior (bagunça)
**Depois:** Estado atual (organizado)

## Mudanças
- Criado .gitignore com X regras
- Removidos Y arquivos do tracking
- Estrutura reorganizada para padrão
- CLAUDE.md criado/atualizado
- Z arquivos movidos para lugar correto

## Regras estabelecidas
1. Regra 1
2. Regra 2

## Próximos passos
- [ ] O que ainda falta organizar
```

## Checklist de Organização

- [ ] .gitignore completo e adequado
- [ ] Outputs removidos do Git tracking
- [ ] Logs em ~/logs/
- [ ] Backups em ~/backups/
- [ ] Segredos em ~/.config/env/
- [ ] Estrutura de pastas padronizada
- [ ] Nomenclatura consistente
- [ ] CLAUDE.md criado/atualizado
- [ ] Headers de arquivo padronizados
- [ ] Git worktree limpo
- [ ] Nota no vault atualizada

## Padrões EC2 — Organização Existente

### Runtime Directory
```
/home/ubuntu/runtime/
├── PAUTA_CENTRAL.xlsx        ← symlink para canônico
├── PAUTA_VANIA.xlsx          ← symlink para canônico
├── james_bus/                ← symlink para archive
├── pje_cache/                ← symlink para archive
├── certificados/             ← arquivos reais
├── _archive_runtime/         ← archive por data
│   └── 20260428/
│       ├── live_logs/
│       ├── live_state/
│       ├── locks/
│       └── dirs/
└── _archive_overrides/       ← backups de overrides
```

### Logs Directory
```
/home/ubuntu/logs/
├── cron_pauta.log
├── cerebro_vault_sync.log
├── health_unified.log
├── service_guardian_cron.log
└── ... (todos os logs centralizados)
```

### Backup Directory
```
/home/ubuntu/backups/
├── seguranca_runtime/
│   ├── backup_runtime.sh
│   ├── backup_envs.sh
│   └── cleanup_old_backups.sh
└── postgres/
    └── pg_backup.sh
```

## Output do Organizer

Ao concluir organização:
1. **O que foi encontrado** — estado inicial da bagunça
2. **O que foi movido** — arquivos relocados
3. **O que foi removido do Git** — tracking cleanup
4. **O que foi criado** — .gitignore, estrutura, docs
5. **Regras estabelecidas** — como manter organizado
6. **Risco residual** — o que ainda precisa atenção
