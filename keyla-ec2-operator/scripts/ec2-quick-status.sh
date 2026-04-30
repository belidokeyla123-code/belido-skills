#!/usr/bin/env bash
# EC2 Quick Status — resumo rapido de todos os servicos criticos
set -euo pipefail
echo "EC2 Health — $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for svc in robo-pauta cerebro-api openclaw-gateway agente-redator-inicial james-v2 vault-mcp filesystem-mcp ia-worker nginx docker postgresql@14-main gotenberg health-check-telegram dashboard-web; do
    status=$(systemctl is-active "$svc" 2>/dev/null || echo "missing")
    mem=$(systemctl show "$svc" --property=MemoryCurrent 2>/dev/null | cut -d= -f2)
    mem_h="[?]"
    if [ "$mem" != "[not set]" ] && [ "$mem" != "" ]; then
        mem_h="$(( mem / 1024 / 1024 ))MB"
    fi
    case "$status" in
        active) icon="✅" ;; failed) icon="❌" ;; *) icon="⭕" ;;
    esac
    printf "  %s %-35s %-8s %s\n" "$icon" "$svc" "$status" "$mem_h"
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "RAM: $(free -h | awk '/^Mem:/{print $3 "/" $2 " (" int($3/$2*100) "%)"}')"
echo "Disk: $(df -h / | awk 'NR==2{print $3 "/" $2 " (" $5 ")"}')"
