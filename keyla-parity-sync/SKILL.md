---
name: keyla-parity-sync
description: Sincronizacao de contexto entre EC2 Claude Codex OpenClaw e outros agentes
category: Organization
version: 1.0.0
author: Keyla
---

# Keyla Parity Sync

Sincronização de contexto e estado entre ambientes: EC2, Claude, Codex, OpenClaw. Garantir que decisões, configs e conhecimento fluam entre todos os agentes.

## Quando usar

- Mudança significativa feita em um ambiente que afeta outros
- Nova decisão arquitetural ou operacional
- Atualização de configs compartilhadas (CLAUDE.md, AGENTS.md, skills)
- Novo processo ou playbook criado
- Antes de trocar de agente/sessão
- Quando Keyla pedir "sincroniza com os outros"

## Princípios de Paridade

1. **EC2 é a fonte canônica** — o vault e configs da EC2 são truth
2. **Contexto flui, não duplica** — sincronizar mudanças, não copiar tudo
3. **Local é réplica curada** — `/root/keyla-context/` é subset do vault
4. **Skills são portáteis** — uma skill criada em um ambiente pode ir para outro
5. **Decisões ficam registradas** — nada importante existe só em memória de agente

## Protocolo de Sync

### Sync de Configs
```
Quando mudar CLAUDE.md, AGENTS.md, ou skills na EC2:

1. Verificar a versão local
2. Aplicar as mesmas mudanças local (se relevante)
3. Registrar no vault: 06-Decisoes/ ou 99-Snapshots/
4. Notificar Keyla: "Config X atualizada em EC2 + local"
```

### Sync de Decisões
```
Quando uma decisão importante for tomada:

1. Criar nota em 06-Decisoes/ no vault da EC2
2. Formato:
   ---
   data: 2026-04-30
   tipo: decisão
   impacto: alto/médio/baixo
   ---
   # Título
   Contexto: ...
   Decisão: ...
   Racional: ...
   Alternativas descartadas: ...

3. Atualizar AGENTS.md se a decisão mudar regras operacionais
```

### Sync de Skills
```
Quando criar/atualizar skill em um ambiente:

1. EC2 → Local: copiar SKILL.md para /root/.codex/skills/
2. Local → EC2: scp ou SSH para /home/ubuntu/.codex/skills/
3. Local → Claude: skill vai em ~/.claude/skills/
4. Testar que a skill carrega no ambiente destino
```

### Sync de Vault
```
Vault EC2 → Local (curated):
- Copiar apenas notas relevantes para /root/keyla-context/
- Não copiar tudo (segurança, espaço, relevância)
- Manter README.md atualizado com o que está no local

Local → Vault EC2:
- Notas criadas localmente que são persistentes → subir para EC2
- Usar SSH + scp ou escrever direto via SSH
- Classificar na pasta correta (00-Inbox, 03-Projetos, etc.)
```

### Sync entre Agentes (Handoff)
```
Quando Keyla trocar de agente (Codex → Claude → OpenClaw):

1. Atualizar nota de sessão em 04-Sessoes/ com status atual
2. Deixar nota de handoff:
   ---
   data: 2026-04-30
   de: codex
   para: claude
   ---
   # Handoff: <tarefa>
   Status: em progresso / pausado / completo
   Último feito: ...
   Próximo passo: ...
   Atenção: ...
   Arquivos tocados: ...

3. Commit no vault se mudou algo
4. Informar Keyla que o handoff está pronto
```

## Mapa de Ambientes

| Ambiente | Path principal | Função |
|---|---|---|
| EC2 | `/home/ubuntu/` | Produção, vault, serviços, runtime |
| EC2 Vault | `/home/ubuntu/cerebro-vault/` | Memória canônica, notas, decisões |
| EC2 Codex | `/home/ubuntu/.codex/` | Skills e config do Codex na EC2 |
| EC2 Claude | `/home/ubuntu/.claude/` | Skills e hooks do Claude na EC2 |
| Local | `/root/` | Réplica curada, AGENTS.md, skills |
| Local Context | `/root/keyla-context/` | Contexto portátil |
| Local Skills | `/root/.codex/skills/` | Skills locais do agente |

## Checklist de Sync

Após trabalho significativo:
- [ ] Notas relevantes registradas no vault da EC2
- [ ] CLAUDE.md/AGENTS.md atualizados se mudou algo estrutural
- [ ] Skills novas/alteradas copiadas para ambientes relevantes
- [ ] Handoff note criada se trocando de agente
- [ ] Git commit no vault (`/home/ubuntu/cerebro-vault/`)
- [ ] Keyla informada do que mudou e onde

## Quando NÃO Syncar

- Debug temporário (não é persistente)
- Testes/experimentos descartados
- Informações sensíveis (creds, tokens)
- Dados efêmeros (logs, outputs intermediários)
- Conversas contextuais que não geram decisão

## Ferramentas de Sync

```bash
# EC2 → Local (copiar nota)
ssh -i <key> ubuntu@56.126.138.7 "cat /home/ubuntu/cerebro-vault/03-Projetos/nota.md" > /tmp/nota.md

# Local → EC2 (enviar nota)
scp -i <key> /tmp/nota.md ubuntu@56.126.138.7:/home/ubuntu/cerebro-vault/00-Inbox/

# Sync skills
scp -i <key> -r /root/.codex/skills/keyla-nova/ ubuntu@56.126.138.7:/home/ubuntu/.codex/skills/

# Verificar sync
diff <(cat local.md) <(ssh -i <key> ubuntu@56.126.138.7 "cat remoto.md")
```

## Regras de Ouro

1. **EC2 manda** — em caso de conflito, a versão da EC2 é a correta
2. **Sync não é backup** — sincronizar decisões e configs, não tudo
3. **Vault é memória** — se não está no vault, não aconteceu
4. **Handoff é responsabilidade** — nunca abandonar tarefa sem deixar estado
5. **Testar depois de sync** — verificar que skill/config funciona no destino
