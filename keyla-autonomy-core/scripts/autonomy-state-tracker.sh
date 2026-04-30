#!/usr/bin/env bash
# Autonomy State Tracker — log de missao para sync entre agentes
# Uso: ./autonomy-state-tracker.sh <mission-id> <status> <detail>
set -euo pipefail
LOG_FILE="/home/ubuntu/cerebro-vault/04-Sessoes/autonomy-log.md"
mkdir -p "$(dirname "$LOG_FILE")"
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
echo "| $TIMESTAMP | $1 | $2 | $3 |" >> "$LOG_FILE"
if [ ! -f "$LOG_FILE" ] || [ "$(wc -l < "$LOG_FILE")" -le 1 ]; then
    echo "# Autonomy Mission Log" > "$LOG_FILE"
    echo "| Timestamp | Mission | Status | Detail |" >> "$LOG_FILE"
    echo "|---|---|---|---|" >> "$LOG_FILE"
fi
