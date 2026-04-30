---
name: keyla-git-workflow
description: Workflow Git profissional - branching commits PRs conventions
category: Development
version: 1.0.0
author: Keyla
---

# Keyla Git Workflow

Workflow Git profissional para projetos da Keyla. Branching strategy, commit conventions, PR process, e regras de ouro para manter repos limpos.

## Quando usar

- Criar nova feature em qualquer projeto
- Preparar commit antes de push
- Criar PR
- Definir estratégia de branching para novo projeto
- Revisar histórico de commits

## Branching Strategy (GitHub Flow Simplificado)

```
main ──────────────────────────────────── (produção/estável)
  └── feature/nome-da-feature ──── (desenvolvimento)
  └── fix/nome-do-bug ──── (correção)
  └── refactor/nome ──── (refatoração)
```

### Regras
- `main` é sagrado — nunca commitar direto
- Toda mudança vai por branch
- Branch nome: `feature/descrição`, `fix/descrição`, `refactor/descrição`
- Branch deve ser descritiva: `feature/mater-template-revisao` ✅, `feature/nova` ❌
- Deletar branch após merge

## Commit Convention

```
<tipo>: <descrição curta>

<corpo opcional com detalhes>
```

### Tipos
| Tipo | Uso |
|---|---|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `refactor` | Refatoração sem mudança de comportamento |
| `chore` | Manutenção, configs, limpeza |
| `docs` | Documentação |
| `test` | Testes |
| `perf` | Melhoria de performance |
| `style` | Formatação, sem mudança lógica |

### Exemplos
```bash
# Bom
git commit -m "feat: add PJe publication parser for DOU"
git commit -m "fix: handle empty response in API timeout"
git commit -m "chore: update .gitignore for Python artifacts"
git commit -m "refactor: extract deadline calculator to utils"
git commit -m "docs: add setup instructions to README"

# Ruído
git commit -m "update" ❌
git commit -m "fix stuff" ❌
git commit -m "wip" ❌
git commit -m "asdfasdf" ❌
```

### Corpo do Commit (quando necessário)
```bash
git commit -m "fix: handle empty DOU response gracefully

The DOU API sometimes returns 200 with empty body instead of
proper error response. Now we detect this and retry with
exponential backoff before failing.

Fixes #42"
```

## Workflow Padrão

### 1. Criar Branch
```bash
git checkout main
git pull origin main
git checkout -b feature/nome-da-feature
```

### 2. Trabalhar
```bash
# Fazer alterações
# Ver status frequentemente
git status

# Ver o que mudou
git diff

# Ver o que está staged
git diff --staged
```

### 3. Commit
```bash
# Adicionar arquivos específicos (melhor que git add .)
git add src/parser.py tests/test_parser.py

# Commit descritivo
git commit -m "feat: add DOU publication parser with retry logic"

# Múltiplos commits relacionados → squash antes do PR
git rebase -i HEAD~3
# Trocar 'pick' por 'squash' nos commits 2 e 3
```

### 4. Push e PR
```bash
git push -u origin feature/nome-da-feature

# Depois criar PR no GitHub
gh pr create --title "feat: add DOU parser" --body "Description of changes"
```

### 5. Merge e Cleanup
```bash
# Após PR aprovado e merged:
git checkout main
git pull origin main
git branch -d feature/nome-da-feature
git push origin --delete feature/nome-da-feature  # se não deletado pelo GitHub
```

## Hotfix (urgência em produção)

```bash
# Branch de main, não de feature
git checkout main
git pull origin main
git checkout -b hotfix/descrição-curta

# Fix e commit
git add <files>
git commit -m "hotfix: fix critical PJe timeout in production"

# Push e PR urgente
git push -u origin hotfix/descrição-curta
gh pr create --title "HOTFIX: PJe timeout fix" --body "Critical fix"
# Merge direto após review mínimo

# Cleanup
git checkout main
git pull
git branch -d hotfix/descrição-curta
```

## Rebase vs Merge

### Quando usar rebase
- Atualizar branch com mudanças de main (antes de PR)
- Limpar histórico de commits (squash)
- Manter histórico linear e legível

### Quando usar merge
- Juntar feature branch em main (via PR)
- Preservar histórico completo de branches paralelas

### Rebase workflow
```bash
# Sua branch está atrás de main
git checkout feature/sua-branch
git fetch origin
git rebase origin/main

# Se conflito:
# Resolver conflitos em cada arquivo
git add <files>
git rebase --continue

# Se quiser abortar:
git rebase --abort
```

## Git Hooks (recomendados)

### pre-commit (validar antes de commit)
```bash
#!/bin/bash
# .git/hooks/pre-commit
echo "Running pre-commit checks..."

# Python lint
python -m ruff check --select E,F,W .
if [ $? -ne 0 ]; then
  echo "Lint failed. Fix errors before committing."
  exit 1
fi

# Python format check
python -m ruff format --check .
if [ $? -ne 0 ]; then
  echo "Format check failed. Run 'ruff format .' before committing."
  exit 1
fi
```

### commit-msg (validar mensagem)
```bash
#!/bin/bash
# .git/hooks/commit-msg
msg=$(cat "$1")
if ! echo "$msg" | grep -qE "^(feat|fix|refactor|chore|docs|test|perf|style|hotfix): "; then
  echo "Commit message must follow convention: <tipo>: <descrição>"
  echo "Tipos: feat, fix, refactor, chore, docs, test, perf, style, hotfix"
  exit 1
fi
```

## Git Log Útil

```bash
# Commits recentes
git log --oneline -20

# Commits por autor
git shortlog -sn --all

# Commits com diff estatístico
git log --stat -10

# Commits entre datas
git log --oneline --after="2026-04-01" --before="2026-04-30"

# Quem mudou qual arquivo
git log --follow -- <arquivo>

# Commits não merged em main
git log main..feature/branch --oneline
```

## Git para EC2 (local-only repos)

Projetos sem remote (como MCP Bridge):
```bash
# Manter histórico local mesmo sem GitHub
git add .
git commit -m "chore: backup snapshot - <descrição>"

# Ver histórico
git log --oneline

# Se for adicionar remote depois:
git remote add origin <url>
git push -u origin main
```

## Regras de Ouro

1. **Commit pequeno e frequente** — melhor 10 commits de 1 arquivo que 1 commit de 50 arquivos
2. **Testar antes de commitar** — nunca commitar código quebrado
3. **Não commitar secrets** — `.env`, `.pem`, `.key` nunca
4. **Rebase antes de PR** — manter PR clean com main
5. **Descrição > código** — o commit message explica o porquê, não o quê
6. **Um propósito por commit** — não misturar fix + refactor + docs no mesmo commit
