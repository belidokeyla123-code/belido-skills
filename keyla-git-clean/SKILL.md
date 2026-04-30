---
name: keyla-git-clean
description: Limpeza cirurgica de repositorios Git - untrack branches conflicts
category: Development
version: 1.0.0
author: Keyla
---

# Keyla Git Clean

Limpeza cirúrgica de repositórios Git. Untrack files corretamente, limpar histórico, organizar branches, resolver conflitos sem destruir nada.

## Quando usar

- Repositório com arquivos que não deveriam estar tracked
- `.gitignore` ignorado por arquivos já commitados
- Branches antigos acumulados
- Commits com dados sensíveis (creds, keys)
- Git status poluído com centenas de untracked files
- Conflitos de merge difíceis
- Repositório inchado (`.git` muito grande)

## Protocolo Git Clean

### Fase 1: Diagnóstico
```bash
# Estado atual
git status
git branch -a
git log --oneline -20
git log --oneline --all --graph | head -50

# O que está tracked que não deveria?
git ls-files | grep -E "\.(env|pem|key|secret|pyc|log)"

# Tamanho do .git
du -sh .git
du -sh .git/objects
```

### Fase 2: Limpeza de Untracked (segura)
```bash
# Ver O QUE seria removido (dry run)
git clean -fd --dry-run

# Remover de verdade (cuidado!)
git clean -fd

# Incluir ignored files também
git clean -fdx
```

### Fase 3: Remover arquivos tracked que deveriam estar no .gitignore
```bash
# O problema clássico: arquivo foi commitado, depois colocado no .gitignore
# O git continua trackando. Para parar:

# Single file
git rm --cached <file>

# Directory
git rm -r --cached <dir>

# Pattern (todos .env files)
git ls-files --ignored --exclude-standard | xargs git rm --cached

# Pattern (todos .pyc)
find . -name "*.pyc" -exec git rm --cached {} \;

# Commit a remoção
git commit -m "chore: stop tracking files that should be gitignored"
```

### Fase 4: Atualizar .gitignore corretamente
```bash
# Adicionar padrões ao .gitignore
cat >> .gitignore << 'EOF'
# Python
__pycache__/
*.pyc
*.pyo
.env
.venv/
venv/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Secrets
*.pem
*.key
*.secret
EOF

# Verificar o que agora é ignorado
git status
```

### Fase 5: Organizar Branches
```bash
# Ver branches locais e remoto
git branch -vv
git remote show origin

# Branches merged que podem ser deletadas
git branch --merged main | grep -v "^\* main" | xargs git branch -d

# Branches merged em develop
git branch --merged develop | grep -v "^\* develop" | xargs git branch -d

# Force delete (se -d recusar)
git branch --merged main | grep -v "^\* main" | xargs git branch -D

# Remover refs de branches remotas deletadas
git remote prune origin
git fetch --prune
```

### Fase 6: Limpar Commits Sensíveis
```bash
# Se credenciais foram commitadas:
# 1. Mudar a credencial imediatamente
# 2. Remover do histórico

# Para o último commit:
git reset --soft HEAD~1
git reset HEAD <file>
git commit -m "new commit without sensitive file"

# Para commits mais antigos (rewritet history):
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch <file>" \
  --prune-empty --tag-name-filter cat -- --all

# OU com BFG (mais rápido):
# bfg --delete-files <filename> repo.git

# Force push (só se ninguém mais usa o repo):
git push --force-with-lease origin main
```

### Fase 7: Reduzir tamanho do .git
```bash
# Garbage collection
git gc --aggressive --prune=now

# Ver maiores objetos
git rev-list --objects --all | git cat-file --batch-check | sort -k 3 -n -r | head -20

# Limpar reflog
git reflog expire --expire=now --all
git gc --prune=now

# Ver tamanho pós-limpeza
du -sh .git
```

### Fase 8: Resolver Conflitos com Método
```bash
# Quando o merge tem conflito:

# 1. Ver o que conflita
git status | grep "both modified"

# 2. Para cada arquivo conflitado:
# Ver as versões
git diff <file>

# Ver lado deles
git show :3:<file>

# Ver nosso lado
git show :2:<file>

# Ver base comum
git show :1:<file>

# 3. Editar o arquivo manualmente
# Ou aceitar uma versão:
git checkout --ours <file>
git checkout --theirs <file>

# 4. Marcar como resolvido
git add <file>

# 5. Completar
git commit
```

## Git Status Limpo Checklist

Para deixar `git status` limpo:
- [ ] Arquivos tracked removidos com `git rm --cached`
- [ ] `.gitignore` atualizado
- [ ] `git clean -fd` rodado (se seguro)
- [ ] Stash aplicado ou limpo: `git stash list`
- [ ] Branches merged deletadas
- [ ] Remote pruned: `git remote prune origin`

## Nuking Nuclear Options

**Só usar se tudo mais falhou:**

```bash
# Reset completo para último commit (perde tudo não-commitado)
git reset --hard HEAD
git clean -fdx

# Reset para um commit específico
git reset --hard <commit-hash>

# Voltar ao estado do remote (perde commits locais)
git fetch origin
git reset --hard origin/main
```

## Regras de Ouro

1. **Nunca `git push --force` sem `--with-lease`** — protege contra sobrescrever trabalho alheio
2. **Sempre `--dry-run` antes de `git clean`** — ver o que será deletado
3. **Backup antes de `filter-branch`** — `git clone --local . ../backup`
4. **Não reescrever history em branch compartilhado** — a não ser que seja combinado
5. **`.gitignore` não retroage** — só afeta untracked files
