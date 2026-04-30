---
name: keyla-ec2-bridge
description: Bridge SSH para acessar todos os servicos da EC2 localmente
category: Infrastructure
version: 1.0.0
author: Keyla
---

# Keyla EC2 Bridge

Acesso completo aos serviços da EC2 via SSH. Esta skill substitui MCPs que não rodam localmente, usando comandos SSH pré-configurados.

## Configuração de Acesso

```bash
KEY="/data/user/0/gptos.intelligence.assistant/cache/codex-web-uploads/f-KeDIcg/cerebro-ec2-keyla.pem"
EC2="ssh -o StrictHostKeyChecking=no -i $KEY ubuntu@56.126.138.7"
SCP="scp -o StrictHostKeyChecking=no -i $KEY"
```

## PostgreSQL (EC2)

```bash
# Query direta
ssh -i $KEY ubuntu@56.126.138.7 "PGPASSWORD=cerebro123 psql -h localhost -U cerebro -d terminal_cerebro -c 'SELECT * FROM tabela LIMIT 10;'"

# Listar tabelas
ssh -i $KEY ubuntu@56.126.138.7 "PGPASSWORD=cerebro123 psql -h localhost -U cerebro -d terminal_cerebro -c '\dt'"

# Backup
ssh -i $KEY ubuntu@56.126.138.7 "PGPASSWORD=cerebro123 pg_dump -h localhost -U cerebro terminal_cerebro" > /tmp/backup.sql

# Executar script SQL
cat /tmp/query.sql | ssh -i $KEY ubuntu@56.126.138.7 "PGPASSWORD=cerebro123 psql -h localhost -U cerebro -d terminal_cerebro"
```

## Dropbox (EC2)

```bash
# Listar arquivos no Dropbox (via vault sync)
ssh -i $KEY ubuntu@56.126.138.7 "ls -la ~/Dropbox/"

# Ver status do sync
ssh -i $KEY ubuntu@56.126.138.7 "systemctl status dropbox"

# Ver logs do sync
ssh -i $KEY ubuntu@56.126.138.7 "tail -50 /home/ubuntu/.dropbox/daemon.log"
```

## GitHub (EC2)

```bash
# Via SSH (chave configurada na EC2)
ssh -i $KEY ubuntu@56.126.138.7 "cd /home/ubuntu/apps/juridico && git status"

# Via gh CLI (token configurado na EC2)
ssh -i $KEY ubuntu@56.126.138.7 "gh pr list --repo belidokeyla123-code/belido-juridico"
```

## Sistema EC2 (systemd, logs, processos)

```bash
# Status de serviços
ssh -i $KEY ubuntu@56.126.138.7 "systemctl list-units --type=service --state=running"

# Serviço específico
ssh -i $KEY ubuntu@56.126.138.7 "systemctl status robo-pauta"
ssh -i $KEY ubuntu@56.126.138.7 "systemctl status james-v2"
ssh -i $KEY ubuntu@56.126.138.7 "systemctl status agente-redator-inicial"

# Logs
ssh -i $KEY ubuntu@56.126.138.7 "journalctl -u robo-pauta --since '1 hour ago' --no-pager"
ssh -i $KEY ubuntu@56.126.138.7 "tail -100 /home/ubuntu/apps/juridico/logs/app.log"

# Recursos
ssh -i $KEY ubuntu@56.126.138.7 "free -h && df -h && top -bn1 | head -20"

# Docker
ssh -i $KEY ubuntu@56.126.138.7 "docker ps && docker stats --no-stream"
```

## PJe (EC2 via Robôs)

```bash
# Ver status do RoboVânia (PJe)
ssh -i $KEY ubuntu@56.126.138.7 "systemctl status robo-vania"

# Ver fila de processamento
ssh -i $KEY ubuntu@56.126.138.7 "ls -la /home/ubuntu/apps/vania/queue/"

# Ver logs PJe
ssh -i $KEY ubuntu@56.126.138.7 "tail -50 /home/ubuntu/apps/vania/logs/pje.log"
```

## Arquivos Remotos (EC2)

```bash
# Ler arquivo remoto
ssh -i $KEY ubuntu@56.126.138.7 "cat /home/ubuntu/cerebro-vault/03-Daily/$(date +%Y-%m-%d).md"

# Copiar arquivo da EC2 para local
scp -i $KEY ubuntu@56.126.138.7:/home/ubuntu/apps/juridico/config.yaml /tmp/config-ec2.yaml

# Copiar arquivo local para EC2
scp -i $KEY /tmp/novo-script.py ubuntu@56.126.138.7:/home/ubuntu/apps/juridico/scripts/

# Executar script remoto
ssh -i $KEY ubuntu@56.126.138.7 "python3 /home/ubuntu/apps/juridico/scripts/script.py"
```

## MCP Bridge (EC2)

```bash
# Acessar OpenClaw via MCP Bridge
ssh -i $KEY ubuntu@56.126.138.7 "curl -s http://localhost:18789/api/status"

# Enviar tarefa para OpenClaw
ssh -i $KEY ubuntu@56.126.138.7 "curl -s -X POST http://localhost:18789/api/tasks -H 'Content-Type: application/json' -d '{\"task\": \"verificar status do vault\"}'"
```

## Ollama (EC2)

```bash
# Ver modelos disponíveis
ssh -i $KEY ubuntu@56.126.138.7 "curl -s http://localhost:11434/api/tags"

# Gerar texto
ssh -i $KEY ubuntu@56.126.138.7 "curl -s http://localhost:11434/api/generate -d '{\"model\": \"llama3\", \"prompt\": \"texto\"}'"
```

## Gotenberg (EC2 - PDF)

```bash
# Converter HTML para PDF
ssh -i $KEY ubuntu@56.126.138.7 "curl -s -X POST http://localhost:3001/forms/chromium/convert/html -F 'file=@/tmp/doc.html' -o /tmp/doc.pdf"
```

## Nginx (EC2)

```bash
# Status
ssh -i $KEY ubuntu@56.126.138.7 "systemctl status nginx"

# Config
ssh -i $KEY ubuntu@56.126.138.7 "cat /etc/nginx/sites-enabled/default"

# Logs
ssh -i $KEY ubuntu@56.126.138.7 "tail -50 /var/log/nginx/access.log"
ssh -i $KEY ubuntu@56.126.138.7 "tail -50 /var/log/nginx/error.log"

# Reload
ssh -i $KEY ubuntu@56.126.138.7 "sudo nginx -t && sudo systemctl reload nginx"
```

## James Bus (EC2)

```bash
# Ver tamanho do bus
ssh -i $KEY ubuntu@56.126.138.7 "du -sh /home/ubuntu/james-bus/{inbox,outbox,done}"

# Ver mensagens recentes
ssh -i $KEY ubuntu@56.126.138.7 "ls -lt /home/ubuntu/james-bus/inbox/ | head -20"

# Ver mensagens pendentes
ssh -i $KEY ubuntu@56.126.138.7 "ls /home/ubuntu/james-bus/inbox/ | wc -l"
```

## Comandos de Emergência

```bash
# Reiniciar todos os robôs
ssh -i $KEY ubuntu@56.126.138.7 "sudo systemctl restart robo-pauta robo-vania agente-redator-inicial james-v2"

# Reiniciar um serviço
ssh -i $KEY ubuntu@56.126.138.7 "sudo systemctl restart <servico>"

# Verificar saúde geral
ssh -i $KEY ubuntu@56.126.138.7 "echo '=== DISCO ===' && df -h && echo '=== MEMORIA ===' && free -h && echo '=== CPU ===' && top -bn1 | head -5 && echo '=== SERVIÇOS ===' && systemctl list-units --type=service --state=running | grep -E 'robo|james|mater|vania|nginx|postgres|docker'"

# Parar um serviço
ssh -i $KEY ubuntu@56.126.138.7 "sudo systemctl stop <servico>"
```

## Quando usar

- Precisar acessar banco de dados PostgreSQL
- Verificar/manipular Dropbox
- Consultar PJe ou filas do RoboVânia
- Verificar status de serviços na EC2
- Acessar logs de produção
- Manipular arquivos do vault
- Gerar PDF via Gotenberg
- Usar modelos locais via Ollama
- Enviar tarefas para OpenClaw
- Qualquer operação que requeira acesso à EC2

## Regras

1. **Sempre usar StrictHostKeyChecking=no** — evitar prompt de host key
2. **Nunca logar credenciais** — a chave PEM é sensível
3. **Usar variáveis $KEY e $EC2** — manter comandos limpos
4. **Verificar conectividade primeiro** — ssh antes de assumir que funciona
5. **EC2 é produção** — cuidado com comandos destrutivos
