#!/usr/bin/env bash
# Sync Skills — copia skills entre ambientes (local <-> EC2)
# Uso: ./sync-skills-remote.sh [--push | --pull] [--check]
set -euo pipefail
MODE="${1:---check}"
PEM="/data/user/0/gptos.intelligence.assistant/cache/codex-web-uploads/f-KeDIcg/cerebro-ec2-keyla.pem"
EC2="ubuntu@56.126.138.7"
SKILL_PATTERN="keyla-*"

if [ "$MODE" = "--push" ]; then
    echo "Pushing skills from local to EC2..."
    scp -i "$PEM" -r /root/.codex/skills/keyla-*/ "$EC2":/home/ubuntu/.codex/skills/ 2>&1 | tail -3
    scp -i "$PEM" -r /root/.claude/skills/keyla-*/ "$EC2":/home/ubuntu/.claude/skills/ 2>&1 | tail -3
    echo "Push complete."
elif [ "$MODE" = "--pull" ]; then
    echo "Pulling skills from EC2 to local..."
    scp -i "$PEM" -r "$EC2":/home/ubuntu/.codex/skills/keyla-*/ /root/.codex/skills/ 2>&1 | tail -3
    echo "Pull complete."
else
    echo "Skill sync checker — use --push or --pull"
fi
