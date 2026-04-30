---
name: keyla-toolbox
description: Comandos scripts templates e one-liners para operacoes rapidas
category: Utilities
version: 1.0.0
author: Keyla
---

# Keyla Toolbox

Aja como **engenheiro com caixa de ferramentas completa**. Esta skill é um catálogo de comandos, scripts, one-liners e utilitários prontos para resolver problemas comuns na EC2 e nos projetos da Keyla.

## Quando usar

Use quando:
- Precisar de um comando rápido para resolver algo
- Quiser um script pronto em vez de escrever do zero
- Precisar de um template (systemd, nginx, etc.)
- Quiser automações comuns prontas

## Comandos Rápidos — Diagnóstico

### Estado do Sistema
```bash
# Resumo em 1 linha
echo "Uptime: $(uptime -p) | RAM: $(free -h | awk '/Mem:/{printf "%s/%s", $3, $2}') | Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}') | Load: $(cat /proc/loadavg | cut -d' ' -f1-3)"

# Top 10 processos por RAM
ps aux --sort=-%mem | head -11

# Top 10 processos por CPU
ps aux --sort=-%cpu | head -11

# Serviços que mais usam memória
systemctl list-units --type=service --state=active --no-pager | while read line; do
    svc=$(echo "$line" | awk '{print $1}')
    mem=$(systemctl show "$svc" --property=MemoryCurrent 2>/dev/null | cut -d= -f2)
    echo "$svc: $mem"
done | sort -t: -k2 -h | tail -10

# Arquivos modificados hoje
find /home/ubuntu -type f -mtime -1 -not -path '*/\.*' -not -path '*/__pycache__/*' 2>/dev/null | head -20
```

### Git Limpeza
```bash
# Worktree sujo? Ver o que é
git status --short

# Ver só untracked
git status --short | grep '^??'

# Ver só modified
git status --short | grep '^ M'

# Remover untracked (CUIDADO: deleta arquivos)
git clean -fd --dry-run   # primeiro ver o que vai deletar
git clean -fd             # depois executar

# Ver tamanho do repo
git count-objects -vH

# Ver branches
git branch -a

# Ver último commit
git log --oneline -5
```

### PostgreSQL Rápido
```bash
# Conectar
psql -U cerebro -d terminal_cerebro -h localhost -c "SELECT version();"

# Listar tabelas
psql -U cerebro -d terminal_cerebro -h localhost -c "\dt"

# Contagem de registros por tabela
psql -U cerebro -d terminal_cerebro -h localhost -c "
SELECT relname, n_live_tup
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;"

# Query genérica
psql -U cerebro -d terminal_cerebro -h localhost -c "SELECT * FROM tabela LIMIT 5;"
```

### Docker Rápido
```bash
# Ver containers
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# Ver todos (incluindo parados)
docker ps -a --format 'table {{.Names}}\t{{.Status}}'

# Logs de um container
docker logs --tail 50 gotenberg

# Disco Docker
docker system df
```

### Networking
```bash
# Porta específica está ouvindo?
ss -tlnp | grep <porta>

# Quem está usando a porta?
lsof -i :<porta>

# Conexões ativas por IP
ss -tnp | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head

# DNS resolve?
nslookup api.anthropic.com
dig +short api.openai.com

# SSL válido?
echo | openssl s_client -connect 56.126.138.7:443 2>/dev/null | openssl x509 -noout -dates
```

## Scripts Prontos

### 1. Health Check Completo
```bash
#!/bin/bash
# health_full.sh — health check completo da EC2

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== EC2 Health Check — $(date) ==="
echo

# Sistema
echo "--- SISTEMA ---"
echo "Uptime: $(uptime -p)"
echo "Load: $(cat /proc/loadavg | cut -d' ' -f1-3)"
RAM=$(free | awk '/Mem:/{printf "%.0f", $3/$2*100}')
echo "RAM: $(free -h | awk '/Mem:/{print $3"/"$2" ("'"$RAM"'%)"}')"
DISK=$(df / --output=pcent | tail -1 | tr -d '%')
if [ "$DISK" -gt 85 ]; then
    echo -e "Disk: ${RED}$(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}${NC}"
else
    echo "Disk: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
fi
echo

# Serviços críticos
echo "--- SERVIÇOS CRÍTICOS ---"
SERVICES="james-v2 cerebro-api openclaw-gateway robo-pauta agente-redator-inicial \
    vault-mcp filesystem-mcp nginx postgresql@14-main docker gotenberg"

for svc in $SERVICES; do
    status=$(systemctl is-active "$svc" 2>/dev/null)
    if [ "$status" = "active" ]; then
        echo -e "  ${GREEN}✓${NC} $svc"
    else
        echo -e "  ${RED}✗${NC} $svc ($status)"
    fi
done
echo

# Portas
echo "--- PORTAS CRÍTICAS ---"
PORTS="80 443 5432 5000 5001 8083 8091 8093 18789 3001 11434"
for port in $PORTS; do
    if nc -z -w1 127.0.0.1 $port 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Porta $port"
    else
        echo -e "  ${RED}✗${NC} Porta $port"
    fi
done
echo

# Docker
echo "--- DOCKER ---"
docker ps --format '  {{.Names}}: {{.Status}}' 2>/dev/null || echo "  Docker não está rodando"
echo

# Git (repos com mudanças)
echo "--- GIT REPOS COM MUDANÇAS ---"
for dir in /home/ubuntu/apps/*/; do
    if [ -d "$dir/.git" ]; then
        count=$(cd "$dir" && git status --short 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
            echo "  $(basename $dir): $count mudanças"
        fi
    fi
done
echo

echo "=== Fim do Health Check ==="
```

### 2. Backup Rápido
```bash
#!/bin/bash
# quick_backup.sh — backup rápido de configs e dados importantes

BACKUP_DIR="/home/ubuntu/backups/quick_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Backup → $BACKUP_DIR"

# CLAUDE.md e AGENTS.md
cp /home/ubuntu/CLAUDE.md "$BACKUP_DIR/" 2>/dev/null
cp /home/ubuntu/AGENTS.md "$BACKUP_DIR/" 2>/dev/null

# Env files (com permissões)
mkdir -p "$BACKUP_DIR/env"
cp -a /home/ubuntu/.config/env/* "$BACKUP_DIR/env/" 2>/dev/null

# Systemd units custom
mkdir -p "$BACKUP_DIR/systemd"
cp /etc/systemd/system/*.service "$BACKUP_DIR/systemd/" 2>/dev/null

# Nginx config
mkdir -p "$BACKUP_DIR/nginx"
cp -a /etc/nginx/sites-enabled/* "$BACKUP_DIR/nginx/" 2>/dev/null

# Git commit vault
cd /home/ubuntu/cerebro-vault && git add . && git commit -m "pre-backup snapshot $(date)" 2>/dev/null

echo "Backup completo: $(du -sh $BACKUP_DIR | cut -f1)"
```

### 3. Log Search
```bash
#!/bin/bash
# log_search.sh <pattern> [service]
# Busca pattern em logs de serviço ou journal

PATTERN="${1:-error}"
SERVICE="${2:-}"

if [ -n "$SERVICE" ]; then
    echo "Buscando '$PATTERN' em $SERVICE (últimas 24h):"
    journalctl -u "$SERVICE" --since "24 hours ago" --no-pager | grep -i "$PATTERN"
else
    echo "Buscando '$PATTERN' em todos os logs (últimas 24h):"
    journalctl --since "24 hours ago" --no-pager | grep -i "$PATTERN"
fi
```

### 4. Git Commit em Massa (Todos os Repos)
```bash
#!/bin/bash
# git_all.sh <message> — commit em todos os repos com mudanças

MESSAGE="${1:-chore: auto commit}"

for dir in /home/ubuntu/apps/*/; do
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        changes=$(git status --short | wc -l)
        if [ "$changes" -gt 0 ]; then
            echo "$(basename $dir): $changes mudanças → commit"
            git add .
            git commit -m "$MESSAGE"
        fi
    fi
done
```

### 5. Service Monitor (one-liner)
```bash
# Ver todos os serviços custom e seu estado
systemctl list-units --type=service --state=active --no-pager | grep -E 'james|robo|openclaw|vault|filesystem|cerebro|mater|vania|nginx|postgres|docker|ia-worker|webhook|dashboard' | awk '{printf "%-45s %s\n", $1, $4}'
```

## Templates

### systemd Service (Python)
```ini
[Unit]
Description={DESC}
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=ubuntu
Group=ubuntu
WorkingDirectory={PATH}
EnvironmentFile=/home/ubuntu/.config/env/{ENV}
ExecStart=/usr/bin/python3 {SCRIPT}
Restart=on-failure
RestartSec=5
MemoryMax={MEM}
StandardOutput=journal
StandardError=journal
SyslogIdentifier={NAME}

[Install]
WantedBy=multi-user.target
```

### systemd Service (Node.js)
```ini
[Unit]
Description={DESC}
After=network-online.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory={PATH}
ExecStart=/usr/bin/node {SCRIPT}
Restart=on-failure
RestartSec=5
MemoryMax={MEM}
SyslogIdentifier={NAME}

[Install]
WantedBy=multi-user.target
```

### Nginx Reverse Proxy
```nginx
server {
    listen 443 ssl http2;
    server_name {DOMAIN};

    ssl_certificate /etc/letsencrypt/live/{DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{DOMAIN}/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:{PORT};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### Python Script Template
```python
#!/usr/bin/env python3
"""
{NAME}.py
{DESCRIPTION}

Service: {SERVICE_NAME}
Owner: Keyla Belido
"""
import logging
import sys
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


def main():
    logger.info("Iniciando %s", __file__)
    try:
        # TODO: lógica principal
        pass
    except Exception as e:
        logger.error("Falha: %s", e, exc_info=True)
        sys.exit(1)
    logger.info("Concluído")


if __name__ == "__main__":
    main()
```

## One-Liners Úteis

```bash
# Ver quanto RAM cada serviço systemd usa
systemctl list-units --type=service --state=active --no-pager | awk '{print $1}' | while read svc; do mem=$(systemctl show "$svc" --property=MemoryCurrent 2>/dev/null | cut -d= -f2); if [ "$mem" != "[not set]" ] && [ "$mem" != "0" ]; then echo "$svc: $(numfmt --to=iec $mem)"; fi; done | sort -t: -k2 -h

# Ver quantos arquivos tem no james_bus
echo "inbox: $(ls /home/ubuntu/james_bus/inbox/ 2>/dev/null | wc -l)"
echo "outbox: $(ls /home/ubuntu/james_bus/outbox/ 2>/dev/null | wc -l)"
echo "done: $(ls /home/ubuntu/james_bus/done/ 2>/dev/null | wc -l)"

# Últimos commits de todos os repos
for d in /home/ubuntu/apps/*/; do [ -d "$d/.git" ] && cd "$d" && echo "$(basename $d): $(git log --oneline -1)"; done

# Ver se há arquivos .env no projeto (não deveria)
find /home/ubuntu/apps -name ".env" -not -path "*/node_modules/*" -not -name "*.template" -not -name "*.env" 2>/dev/null

# Tamanho de cada app
du -sh /home/ubuntu/apps/*/ 2>/dev/null | sort -h

# Quantos services custom existem
ls /etc/systemd/system/*.service 2>/dev/null | wc -l

# Ver serviços com restart recente
journalctl -b --no-pager | grep "Started " | tail -20
```
