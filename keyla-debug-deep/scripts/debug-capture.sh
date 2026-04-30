#!/usr/bin/env bash
# Debug Capture — captura logs e estado de um servico para analise
# Uso: ./debug-capture.sh <service-name>
set -euo pipefail
if [ -z "${1:-}" ]; then echo "Usage: $0 <service-name>"; exit 1; fi
SVC="$1"
OUTDIR="/tmp/debug-${SVC}-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTDIR"
echo "Capturing debug info for $SVC -> $OUTDIR"
systemctl status "$SVC" --no-pager > "$OUTDIR/status.txt" 2>&1
journalctl -u "$SVC" -n 500 --no-pager > "$OUTDIR/journal.log" 2>&1
cat "/etc/systemd/system/${SVC}.service" > "$OUTDIR/service-unit.txt" 2>/dev/null || true
for dropin in /etc/systemd/system/${SVC}.service.d/*.conf; do
    [ -f "$dropin" ] && cat "$dropin" >> "$OUTDIR/service-unit.txt" 2>/dev/null || true
done
ps aux | grep "$SVC" | grep -v grep > "$OUTDIR/process.txt" 2>&1 || true
ss -tlnp | head -1 > "$OUTDIR/ports.txt" 2>&1
echo "Debug capture complete: $OUTDIR"
ls -la "$OUTDIR/"
