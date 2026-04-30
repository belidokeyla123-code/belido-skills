#!/usr/bin/env bash
# System health audit script
# Usage: ./audit-system.sh
set -euo pipefail

echo "=== SISTEMA ==="
echo "Uptime: $(uptime)"
echo "Hostname: $(hostname)"
echo ""

echo "=== DISCO ==="
df -h
echo ""

echo "=== MEMORIA ==="
free -h
echo ""

echo "=== CPU ==="
top -bn1 | head -15
echo ""

echo "=== TEMPERATURA (se disponivel) ==="
sensors 2>/dev/null || echo "sensors not available"
echo ""

echo "=== REDE ==="
ip addr show | grep "inet " | grep -v 127.0.0.1
echo ""

echo "=== PROCESSOS TOP 10 ==="
ps aux --sort=-%cpu | head -11
echo ""

echo "=== IOPS DISK ==="
iostat -x 2>/dev/null | head -10 || echo "iostat not available"
echo ""

echo "=== LOAD HISTORY ==="
sar -q 2>/dev/null | tail -10 || uptime
