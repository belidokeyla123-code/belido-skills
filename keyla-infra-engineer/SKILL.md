---
name: keyla-infra-engineer
description: Infraestrutura Linux systemd nginx PostgreSQL Docker mastery
category: Infrastructure
version: 1.0.0
author: Keyla
---

# Keyla Infra Engineer

Aja como **engenheiro de infraestrutura sênior**. Você domina Linux, systemd, networking, Docker, Nginx, PostgreSQL, monitors, backups, disaster recovery e toda a stack que mantém a EC2 rodando.

## Quando usar

Use quando:
- Serviço caiu ou está degradado
- Precisa criar/modificar systemd units
- Configurar Nginx reverse proxy
- Gerenciar Docker containers
- Tunar PostgreSQL
- Configurar monitoring/alerting
- Planejar backup e recovery
- Otimizar performance do sistema
- Resolver problemas de rede/DNS/SSL

## Stack da EC2 Keyla

### Sistema Base
```
OS: Ubuntu 22.04.1 LTS (Jammy)
Kernel: 6.8.0-1052-aws
CPU: 2 vCPU (Intel Xeon 8488C)
RAM: 7.6GB
Disk: 194GB EBS (19% usado)
Swap: 8GB
Supervisor: systemd
```

### Serviços Gerenciados
- **systemd** — supervisor de todos os serviços
- **Nginx** — reverse proxy, TLS, rate limiting
- **PostgreSQL 14** — banco de dados central
- **Docker** — Gotenberg (PDF), Portainer (gestão)
- **Ollama** — modelos de IA locais
- **Cron** — jobs agendados

## Comandos de Diagnóstico

### Health Check Completo
```bash
# Estado do sistema
uptime
free -h
df -h /
top -bn1 | head -5

# Serviços críticos
systemctl is-active james-v2 cerebro-api openclaw-gateway \
    robo-pauta agente-redator-inicial vault-mcp \
    filesystem-mcp nginx postgresql@14-main docker

# Portas ouvindo
ss -tlnp | sort -t: -k2 -n

# Logs recentes (últimos erros)
journalctl -p err --since "1 hour ago" --no-pager

# Processos com maior consumo
ps aux --sort=-%mem | head -10
ps aux --sort=-%cpu | head -10
```

### Diagnóstico de Serviço Específico
```bash
# Status completo
systemctl status <servico> --no-pager -l

# Config efetiva (incluindo drop-ins)
systemctl cat <servico>

# Logs do serviço
journalctl -u <servico> --since "today" --no-pager

# Últimas 50 linhas com timestamp
journalctl -u <servico> -n 50 --no-pager

# Follow logs em tempo real
journalctl -u <servico> -f

# Restart
sudo systemctl restart <servico>

# Verificar se restartou com sucesso
sleep 3 && systemctl status <servico> --no-pager
```

## Systemd — Guia Completo

### Criar Novo Serviço
```ini
# /etc/systemd/system/meu-servico.service
[Unit]
Description=Meu Serviço — descrição clara
After=network-online.target postgresql.service
Wants=network-online.target

[Service]
Type=simple
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/apps/meu-app
EnvironmentFile=/home/ubuntu/.config/env/meu-app.env
ExecStart=/usr/bin/python3 main.py
Restart=on-failure
RestartSec=5
MemoryMax=256M
StandardOutput=journal
StandardError=journal
SyslogIdentifier=meu-servico

# Hardening
NoNewPrivileges=true
ProtectSystem=strict
ReadWritePaths=/home/ubuntu/apps/meu-app/data
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

### Tipos de Service
| Type | Quando usar | Exemplo |
|---|---|---|---|
| simple | Processo foreground (default) | Python app, Node.js server |
| forking | Daemon que fork (old style) | Nginx, sshd |
| oneshot | Roda e termina (batch) | Backup, sync, cleanup |
| notify | Notifica quando pronto (sd_notify) | Apps com health signaling |

### Drop-in Overrides
```bash
# Criar override (sem editar o unit original)
sudo systemctl edit <servico>

# Ou criar drop-in manual
sudo mkdir -p /etc/systemd/system/<servico>.service.d/
sudo nano /etc/systemd/system/<servico>.service.d/override.conf

# Reload e restart
sudo systemctl daemon-reload
sudo systemctl restart <servico>
```

### Memory Limits
```ini
[Service]
MemoryMax=256M          # Hard limit — OOM kill se ultrapassar
MemoryHigh=200M         # Soft limit — throttle antes do kill
MemoryMin=64M           # Reserva mínima garantida
```

### Timers (substituem cron)
```ini
# /etc/systemd/system/meu-timer.timer
[Unit]
Description=Timer para meu serviço

[Timer]
OnCalendar=*-*-* 12:00:00 UTC    # Todo dia ao meio-dia UTC
OnBootSec=5min                   # 5 min após boot
OnUnitActiveSec=1h               # A cada 1h após ativação
Persistent=true                  # Roda se perdeu execução

[Install]
WantedBy=timers.target
```

### Comandos de Timer
```bash
# Listar todos os timers
systemctl list-timers --all

# Ativar timer
sudo systemctl enable --now meu-timer.timer

# Ver quando vai rodar
systemctl status meu-timer.timer
```

## Nginx — Configuração

### Reverse Proxy
```nginx
server {
    listen 443 ssl http2;
    server_name api.exemplo.com;

    ssl_certificate /etc/letsencrypt/live/api.exemplo.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.exemplo.com/privkey.pem;

    # Rate limiting
    limit_req zone=api burst=20 nodelay;

    location / {
        proxy_pass http://127.0.0.1:18789;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "ok";
    }
}
```

### Comandos Nginx
```bash
# Testar config antes de reload
sudo nginx -t

# Reload sem downtime
sudo systemctl reload nginx

# Ver config ativa
nginx -T

# Logs de acesso
tail -f /var/log/nginx/access.log

# Logs de erro
tail -f /var/log/nginx/error.log
```

### Flag Imutável (EC2 Keyla)
```bash
# Nginx config na EC2 tem chattr +i
# Para editar:
sudo chattr -i /etc/nginx/sites-enabled/openclaw
# Editar...
sudo chattr +i /etc/nginx/sites-enabled/openclaw
```

## PostgreSQL — Administração

### Conexão
```bash
# Conectar como cerebro user
psql -U cerebro -d terminal_cerebro -h localhost

# Como postgres admin
sudo -u postgres psql
```

### Diagnóstico
```sql
-- Conexões ativas
SELECT count(*) FROM pg_stat_activity;

-- Queries lentas
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - pg_stat_activity.query_start > interval '5 seconds';

-- Tamanho do banco
SELECT pg_size_pretty(pg_database_size('terminal_cerebro'));

-- Tamanho das tabelas
SELECT relname, pg_size_pretty(pg_total_relation_size(relid))
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Índices não usados
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0 AND schemaname = 'public';
```

### Backup
```bash
# Backup completo
pg_dump -U cerebro terminal_cerebro > backup_$(date +%Y%m%d).sql

# Restore
psql -U cerebro terminal_cerebro < backup_20260430.sql

# Backup de uma tabela
pg_dump -U cerebro -t tabela terminal_cerebro > tabela.sql
```

### Manutenção
```sql
-- Vacuum analyze (otimiza)
VACUUM ANALYZE;

-- Reindex (reconstrói índices)
REINDEX DATABASE terminal_cerebro;

-- Verificar corrupção
SELECT pg_check_database();
```

## Docker — Gestão

### Comandos Essenciais
```bash
# Listar containers
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# Ver logs
docker logs --tail 100 gotenberg
docker logs -f gotenberg

# Restart
docker restart gotenberg

# Ver recursos
docker stats --no-stream

# Limpar
docker system prune -f
docker image prune -f
```

### Gotenberg (PDF)
```bash
# Verificar se está rodando
curl -s http://127.0.0.1:3001/health

# Converter DOCX → PDF
curl -X POST http://127.0.0.1:3001/forms/libreoffice/convert \
    -F "files=@documento.docx" \
    -o documento.pdf
```

## Networking — Diagnóstico

```bash
# Conectividade externa
ping -c 3 8.8.8.8

# DNS
nslookup exemplo.com
dig exemplo.com

# Porta específica
nc -zv 127.0.0.1 5432
curl -s http://127.0.0.1:8093/health

# Todas as conexões ativas
ss -tnp | head -30

# Traceroute
traceroute exemplo.com

# Bandwidth
iftop
```

## SSL/TLS — Certbot

```bash
# Ver certificados
sudo certbot certificates

# Renovar
sudo certbot renew --dry-run

# Renovar forçado
sudo certbot renew --force-renewal

# Ver expiração
echo | openssl s_client -connect localhost:443 2>/dev/null | openssl x509 -noout -dates
```

## Monitoring — Alertas

### Health Check Script Template
```bash
#!/bin/bash
# health_check.sh — verifica serviços críticos
SERVICES="james-v2 cerebro-api openclaw-gateway robo-pauta nginx postgresql@14-main"
ALERTS=()

for svc in $SERVICES; do
    if ! systemctl is-active --quiet "$svc"; then
        ALERTS+=("$svc está INATIVO")
    fi
done

# Verificar disco
DISC=$(df / --output=pcent | tail -1 | tr -d '% ')
if [ "$DISC" -gt 85 ]; then
    ALERTS+=("Disco em ${DISC}%")
fi

# Verificar RAM
RAM=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
if [ "$RAM" -gt 85 ]; then
    ALERTS+=("RAM em ${RAM}%")
fi

# Verificar portas críticas
for port in 5000 5001 8083 8091 8093 18789 5432; do
    if ! nc -z -w1 127.0.0.1 $port 2>/dev/null; then
        ALERTS+=("Porta $port não responde")
    fi
done

if [ ${#ALERTS[@]} -gt 0 ]; then
    echo "ALERTAS:"
    printf '%s\n' "${ALERTS[@]}"
    # Enviar via Telegram
    # python3 -c "from shared.shared_telegram_bus import enviar_telegram; enviar_telegram('🚨 $(printf '%s\\n' '${ALERTS[@]}')')"
else
    echo "Tudo OK"
fi
```

## Disaster Recovery

### Backup Estratégia
```
1. PostgreSQL: diariamente 04:00 UTC (cron)
2. Env files: diariamente 05:00 UTC (cron)
3. Runtime: a cada 30 min light, a cada 6h full (cron)
4. Vault: Git commit 03:30 UTC + Dropbox sync 3x/dia
5. CLAUDE.md/AGENTS.md: backup antes de cada edição
```

### Recovery Steps
```bash
# 1. Serviço caiu
sudo systemctl restart <servico>
journalctl -u <servico> -n 50  # ver por que caiu

# 2. PostgreSQL corrompeu
sudo systemctl stop postgresql@14-main
sudo pg_dropcluster 14 main --stop
sudo pg_createcluster 14 main --start
psql -U cerebro -d terminal_cerebro < backup_20260430.sql

# 3. Disco cheio
sudo find / -type f -size +100M -exec ls -lh {} \;
sudo journalctl --vacuum-size=100M
sudo docker system prune -f
sudo apt-get clean

# 4. Nginx quebrou
sudo nginx -t  # testar config
sudo systemctl reload nginx
```

## Checklist de Infra Nova

- [ ] systemd service criado e enabled
- [ ] EnvironmentFile configurado
- [ ] MemoryMax definido
- [ ] Log no journal funcionando
- [ ] Health check implementado
- [ ] Alerta de falha configurado
- [ ] Nginx proxy (se público)
- [ ] SSL/TLS (se externo)
- [ ] Backup agendado
- [ ] CLAUDE.md atualizado
- [ ] Vault registrado
