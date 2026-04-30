# Keyla Skills — Advocacia Belido

17 skills para Manus AI, Claude Code, Codex e OpenClaw.

## Como importar no Manus

1. Acesse manus.im → **Skills** → **+ Add** → **Import from GitHub**
2. Cole a URL do repo: 
3. Selecione as skills para importar

## Skills

| Skill | Categoria | Descrição |
|---|---|---|
| keyla-autonomy-core | Orchestration | Orquestração autônoma ponta a ponta |
| keyla-auditor | Audit | Auditoria completa de sistemas e segurança |
| keyla-code-architect | Development | Arquitetura e design de sistemas |
| keyla-code-hacker | Development | Penetração, debug e refatoração de código |
| keyla-debug-deep | Development | Debug cirúrgico - bugs misteriosos, race conditions |
| keyla-ec2-bridge | Infrastructure | Bridge SSH para acessar todos os serviços da EC2 |
| keyla-ec2-operator | Infrastructure | Operações EC2 - serviços, config, deploy |
| keyla-git-clean | Development | Limpeza cirúrgica de repos Git |
| keyla-git-workflow | Development | Workflow Git profissional |
| keyla-infra-engineer | Infrastructure | Infra Linux, systemd, nginx, PostgreSQL, Docker |
| keyla-line-by-line-review | Development | Revisão cirúrgica linha por linha |
| keyla-organizer | Organization | Organização de sistemas, Git, estrutura |
| keyla-parity-sync | Organization | Sincronização entre EC2, Claude, Codex, OpenClaw |
| keyla-process-creator | Organization | Criação de processos, automações, workflows |
| keyla-python-senior | Development | Python 3.10+ best practices |
| keyla-toolbox | Utilities | Comandos, scripts, templates, one-liners |
| keyla-vault-brain | Organization | Interface com vault Obsidian na EC2 |

## Formato

Todas as skills seguem o **Agent Skills Open Standard**:
-  com YAML frontmatter (name, description, category, version)
-  com scripts executáveis
-  com templates reutilizáveis

## Contexto da Keyla

Sou Keyla, advogada, opero a Advocacia Belido. Minha EC2 é o centro de tudo:
- Host: 56.126.138.7 (Ubuntu 22.04, 2 vCPU, 7.6GB RAM)
- Vault: /home/ubuntu/cerebro-vault/ (Obsidian via Dropbox)
- Robôs: jurídico/pauta, RoboVânia, MATER v2, James
- Serviços: PostgreSQL, Nginx, Docker, Ollama
- Sempre responda em português do Brasil
