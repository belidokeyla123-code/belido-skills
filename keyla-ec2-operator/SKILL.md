---
name: keyla-ec2-operator
description: Operacoes completas na EC2 - servicos config deploy monitoramento
category: Infrastructure
version: 1.0.0
author: Keyla
---

# Keyla EC2 Operator

Aja como **operador completo da EC2 Advocacia Belido**. Esta skill dá acesso ao mapa total da infraestrutura, serviços, projetos e formas de operar.

## Mapa Rápido da EC2

| Item | Valor |
|---|---|
| Host público | 56.126.138.7 |
| Host interno | ip-172-31-12-90 |
| OS | Ubuntu 22.04.1 LTS, kernel 6.8.0-1052-aws |
| CPU | 2 vCPU (Intel Xeon 8488C) |
| RAM | 7.6GB total, ~2.2GB usado, ~5.1GB disponível |
| Disco | 194GB total, ~37GB usado, ~158GB livre (19%) |
| Supervisor | systemd (PM2 = descontinuado) |

## Acesso SSH

```bash
# Buscar chave
find /data/user/0/gptos.intelligence.assistant/cache -name "cerebro-ec2-keyla.pem"

# Conectar
ssh -o StrictHostKeyChecking=no -i <CAMINHO> ubuntu@56.126.138.7
```

## Serviços 24/7 — Health Check Rápido

```bash
# Todos os serviços críticos de uma vez
ssh ubuntu@56.126.138.7 "systemctl is-active james-v2 cerebro-api openclaw-gateway robo-pauta agente-redator-inicial gotenberg-watchdog vault-mcp filesystem-mcp ana-pje-api ia-worker webhook-hub nginx postgresql@14-main docker"
```

### Mapa de Portas Críticas
| Porta | Serviço |
|---|---|
| 80/443 | Nginx |
| 5432 | PostgreSQL 14 |
| 5000 | James Listener (Telegram) |
| 5001 | Cerebro API Flask |
| 8083 | Filesystem MCP |
| 8091 | Cerebro API |
| 8093 | Vault MCP |
| 18208 | Agente Redator Inicial (MATER) |
| 18789 | OpenClaw Gateway |
| 3001 | Gotenberg (Docker) |
| 11434 | Ollama |

## Projetos e Paths

| Projeto | Path | Serviço |
|---|---|---|
| Robô Jurídico | `/home/ubuntu/apps/juridico/` | `robo-pauta.service` |
| RoboVânia | `/home/ubuntu/apps/vania/` | Daemon 24/7 próprio |
| MATER V2 | `/home/ubuntu/apps/mater_v2/` | `agente-redator-inicial.service` |
| James | `/home/ubuntu/apps/james/` | `james-v2.service` |
| Infra EC2 | `/home/ubuntu/apps/infra-ec2/` | — |
| Shared | `/home/ubuntu/apps/shared/` | `market-shared-listener.service` |
| Atendimento | `/home/ubuntu/apps/atendimento/` | `ia-worker.service` |
| Luiza | `/home/ubuntu/apps/luiza/` | `luiza.service` |
| Trader | `/home/ubuntu/apps/trader_bot/` | `james-trader.service` |
| MCP Bridge | `/home/ubuntu/apps/mcp_bridge/` | `openclaw-mcp-bridge.service` |
| Vault MCP | `/home/ubuntu/apps/vault_mcp/` | `vault-mcp.service` |
| Filesystem MCP | `/home/ubuntu/apps/filesystem/` | `filesystem-mcp.service` |

## Operações Comuns

### Diagnóstico de Serviço
```bash
# Status
systemctl status <servico> --no-pager

# Logs recentes
journalctl -u <servico> -n 50 --no-pager

# Logs com timestamp
journalctl -u <servico> --since "1 hour ago" --no-pager

# Reiniciar
sudo systemctl restart <servico>
```

### Verificar Portas
```bash
ss -tlnp | grep <porta>
```

### Docker
```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
docker start gotenberg
docker start portainer
```

### Recursos
```bash
free -h
df -h /
top -bn1 | head -20
```

## Regras de Operação

1. **systemd é o supervisor real** — PM2 foi descontinuado como referência de verdade
2. **Não editar CLAUDE.md e AGENTS.md de um projeto ao mesmo tempo**
3. **Segredos em `~/.config/env/`** — nunca recriar `.env` com credenciais duplicadas
4. **Nginx config tem flag imutável** (`chattr +i`) — desbloquear antes de editar
5. **Nunca dois sistemas controlando a mesma coisa**
6. **Sempre backup antes de alteração estrutural**
7. **Não deletar `.bak` sem aprovação da Keyla**
8. **Verificar sintaxe Python:** `python3 -m py_compile arquivo.py`

## Runtime — Contratos Públicos

`/home/ubuntu/runtime/` é o diretório de contratos públicos entre robôs:

- `PAUTA_CENTRAL.xlsx` → symlink para `apps/juridico/data/PAUTA_CENTRAL.xlsx`
- `PAUTA_VANIA.xlsx` → symlink para `apps/juridico/data/PAUTA_VANIA.xlsx`

**Regra:** runtime é para leitura. Edição sempre no canônico em `apps/`.

## Segredos

Todos em `~/.config/env/` (chmod 600):
- `juridico.env` — Robô Jurídico
- `shared.env` — Shared package
- `trader.env` — James Trader
- `atendimento.env` — WhatsApp/Atendimento
- `infra.env` — Infraestrutura
- `luiza.env` — Projeto Luiza

## Nginx

- Config: `/etc/nginx/nginx.conf`
- Sites: `/etc/nginx/sites-enabled/openclaw`
- TLS ativo via certbot
- Rate limit: 30r/s global
