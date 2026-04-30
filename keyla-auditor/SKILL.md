---
name: keyla-auditor
description: Auditoria completa de sistemas codigo infraestrutura processos e seguranca
category: Audit
version: 1.0.0
author: Keyla
---

# Keyla Auditor

Auditoria completa de sistemas, código, infraestrutura, processos e segurança. Esta skill é para quando a Keyla pede "verifica se tá tudo certo", "audita o sistema", "revisa tudo", "checa se tá seguro".

## Quando usar

- Keyla pedir "audita", "verifica", "checa", "revisa tudo"
- Depois de mudança significativa no sistema
- Antes de deploy ou atualização importante
- Checagem periódica de saúde do sistema
- Investigar anomalia ou comportamento estranho
- Revisar segurança de credenciais e permissões
- Validar que backup e sync estão funcionando

## Protocolo de Auditoria

### Fase 1: Estado do Sistema (EC2 REAL)

**SEMPRE verificar na EC2, nunca inferir.**

```bash
KEY="/data/user/0/gptos.intelligence.assistant/cache/codex-web-uploads/f-KeDIcg/cerebro-ec2-keyla.pem"
EC2="ssh -o StrictHostKeyChecking=no -i $KEY ubuntu@56.126.138.7"

# Saúde geral
$EC2 "echo '=== UPTIME ===' && uptime && echo '=== DISCO ===' && df -h && echo '=== MEMÓRIA ===' && free -h && echo '=== CPU ===' && top -bn1 | head -15"

# Serviços ativos vs esperados
$EC2 "systemctl list-units --type=service --state=running --no-pager"

# Serviços falhando
$EC2 "systemctl list-units --type=service --state=failed --no-pager"

# Portas abertas
$EC2 "ss -tlnp"

# Logs de erro recentes
$EC2 "journalctl -p err --since '24 hours ago' --no-pager | tail -50"
```

### Fase 2: Auditoria de Serviços

```bash
# Robô Jurídico
$EC2 "systemctl status robo-pauta --no-pager"
$EC2 "tail -30 /home/ubuntu/apps/juridico/logs/app.log 2>/dev/null || echo 'Sem log encontrado'"

# RoboVânia
$EC2 "systemctl status robo-vania --no-pager || systemctl list-units '*vania*' --no-pager"
$EC2 "tail -30 /home/ubuntu/apps/vania/logs/*.log 2>/dev/null || echo 'Sem log encontrado'"

# MATER V2
$EC2 "systemctl status agente-redator-inicial --no-pager"
$EC2 "tail -30 /home/ubuntu/apps/mater_v2/logs/*.log 2>/dev/null || echo 'Sem log encontrado'"

# James
$EC2 "systemctl status james-v2 --no-pager"
$EC2 "ls /home/ubuntu/james-bus/inbox/ 2>/dev/null | wc -l && echo 'mensagens pendentes'"

# Docker
$EC2 "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

# Nginx
$EC2 "systemctl status nginx --no-pager"
$EC2 "tail -20 /var/log/nginx/error.log 2>/dev/null"

# PostgreSQL
$EC2 "systemctl status postgresql --no-pager"
$EC2 "PGPASSWORD=cerebro123 psql -h localhost -U cerebro -d terminal_cerebro -c 'SELECT version();' 2>&1"

# Ollama
$EC2 "systemctl status ollama --no-pager || curl -s http://localhost:11434/api/health 2>&1"
```

### Fase 3: Auditoria de Segurança

```bash
# Chaves SSH e permissões
$EC2 "ls -la ~/.ssh/ && echo '---' && stat -c '%a %n' ~/.ssh/*"

# Arquivos com permissão world-readable
$EC2 "find /home/ubuntu -perm -o+r -type f 2>/dev/null | grep -E '\.(pem|key|env|secret|config)' | head -20"

# Usuários com shell
$EC2 "grep -v nologin /etc/passwd | grep -v false"

# Portas expostas publicamente (vs localhost only)
$EC2 "ss -tlnp | grep -v '127.0.0.1' | grep -v '::1'"

# Fail2ban ou proteção contra brute force
$EC2 "systemctl status fail2ban --no-pager 2>&1 || echo 'Fail2ban não instalado'"

# Firewall
$EC2 "sudo iptables -L -n 2>&1 | head -30"

# Arquivos sensíveis no Git
$EC2 "for dir in /home/ubuntu/apps/*/; do cd \$dir 2>/dev/null && git ls-files | grep -iE '\.(env|pem|key|secret)' 2>/dev/null && cd - > /dev/null; done"

# Tokens expostos em logs
$EC2 "grep -r 'sk-\|Bearer\|password\|token' /home/ubuntu/apps/*/logs/ 2>/dev/null | head -20"
```

### Fase 4: Auditoria de Backups e Sync

```bash
# Vault Git
$EC2 "cd /home/ubuntu/cerebro-vault && git status && git log --oneline -5"

# Dropbox sync
$EC2 "ls -la ~/Dropbox/ 2>&1 | head -10"
$EC2 "find /home/ubuntu -name '*dropbox*sync*' -type f 2>/dev/null | head -5"

# Cron jobs ativos
$EC2 "crontab -l 2>&1 && echo '---' && ls -la /etc/cron.d/ 2>&1"

# Últimos commits no vault
$EC2 "cd /home/ubuntu/cerebro-vault && git log --oneline --since='24 hours ago'"

# Disk usage do vault
$EC2 "du -sh /home/ubuntu/cerebro-vault/ && du -sh /home/ubuntu/Dropbox/ 2>/dev/null"
```

### Fase 5: Auditoria de Repos Git

```bash
$EC2 "for dir in /home/ubuntu/apps/*/; do
  proj=\$(basename \$dir)
  cd \$dir 2>/dev/null
  if [ -d .git ]; then
    status=\$(git status --short 2>/dev/null)
    if [ -n \"\$status\" ]; then
      echo \"=== \$proj ===\"
      echo \"\$status\" | head -10
      echo ''
    fi
  fi
done"
```

### Fase 6: Auditoria de Configurações

```bash
# settings.json válido
$EC2 "python3 -c \"import json; json.load(open('/home/ubuntu/settings.json'))\" && echo 'settings.json: OK' || echo 'settings.json: ERRO'"

# Variáveis de ambiente
$EC2 "env | grep -iE 'KEY|TOKEN|SECRET|PASSWORD|API' | sed 's/=.*/=***/'"

# Configs de apps
$EC2 "find /home/ubuntu/apps -name 'config.*' -o -name '.env' -o -name '*.yaml' -o -name '*.yml' | head -20"

# Serviços systemd customizados
$EC2 "ls /etc/systemd/system/*.service | head -20"
```

## Checklist de Auditoria

### Críticos (sempre verificar)
- [ ] EC2 acessível via SSH
- [ ] Disco com espaço suficiente (< 80% uso)
- [ ] Memória disponível (> 500MB free)
- [ ] Todos os serviços principais rodando
- [ ] Nenhum serviço em estado failed
- [ ] PostgreSQL acessível
- [ ] Nginx respondendo

### Segurança
- [ ] Sem chaves/arquivos sensíveis em repos Git
- [ ] Permissões corretas em arquivos sensíveis (600)
- [ ] Sem tokens expostos em logs
- [ ] Firewall ativo
- [ ] Sem portas desnecessárias expostas

### Backups e Dados
- [ ] Vault Git com commits recentes
- [ ] Dropbox sync funcionando
- [ ] Cron jobs rodando
- [ ] James Bus processando (inbox não acumulando)

### Código e Deploy
- [ ] Repos sem untracked files críticos
- [ ] Sem branches abandonadas em produção
- [ ] Configs válidas (JSON, YAML)
- [ ] Sem erros nos logs de aplicação

## Formato do Relatório

```markdown
# Auditoria - 2026-04-30

## Resumo
✅ OK / ⚠️ Atenção / ❌ Crítico

## Sistema
- Uptime: X dias
- Disco: X% usado (Y GB livre)
- Memória: X% usado (Y MB livre)
- CPU: X% avg

## Serviços
| Serviço | Status | Notas |
|---|---|---|
| robo-pauta | ✅ rodando | |
| robo-vania | ⚠️ reiniciou 2x | logs com timeout |
| james-v2 | ✅ rodando | |
| nginx | ✅ rodando | |
| postgresql | ✅ rodando | |

## Segurança
- Chaves: OK
- Tokens em logs: ❌ encontrado em vania/app.log (linha 234)
- Permissões: OK
- Firewall: ativo

## Backups
- Vault Git: último commit há 6h
- Dropbox: sync OK
- Cron: 5 jobs ativos

## Pendências
1. [ ] Limpar token exposto em log
2. [ ] Investigar timeouts do RoboVânia
3. [ ] Atualizar serviço X

## Recomendações
-
```

## Regras de Ouro

1. **SEMPRE verificar na EC2 real** — nunca inferir, nunca assumir, nunca usar dados antigos
2. **Estado real > memória** — se a memória do agente diz uma coisa e a EC2 diz outra, a EC2 manda
3. **Auditor sem ação** — esta skill é para diagnóstico, não para consertar (a não ser que a Keyla peça)
4. **Relatar tudo** — mesmo que pareça trivial, reportar no relatório
5. **Priorizar por impacto** — ❌ crítico primeiro, ⚠️ atenção depois, ✅ OK por último
6. **Não alarmar sem motivo** — se é normal, dizer que é normal
7. **Propor solução** — ao encontrar problema, já sugerir como resolver
