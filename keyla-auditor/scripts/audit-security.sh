#!/usr/bin/env bash
# Security audit script
# Usage: ./audit-security.sh
set -euo pipefail

echo "=== USUARIOS COM SHELL ==="
grep -v nologin /etc/passwd | grep -v false
echo ""

echo "=== ARQUIVOS SENSIVEIS COM PERMISSAO ERRADA ==="
find /home -perm -o+r -type f \( -name "*.pem" -o -name "*.key" -o -name "*.env" -o -name "*.secret" \) 2>/dev/null || echo "None found"
echo ""

echo "=== PORTAS EXPOSTAS (NÃO LOCALHOST) ==="
ss -tlnp | grep -v '127.0.0.1' | grep -v '::1'
echo ""

echo "=== FAIL2BAN ==="
systemctl is-active fail2ban 2>/dev/null || echo "NOT RUNNING"
echo ""

echo "=== FIREWALL ==="
sudo iptables -L -n 2>/dev/null | head -20 || echo "iptables not accessible"
echo ""

echo "=== SSH CONFIG ==="
grep -E "^(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication)" /etc/ssh/sshd_config 2>/dev/null || echo "Cannot read sshd_config"
echo ""

echo "=== TOKENS EM LOGS ==="
grep -rl 'sk-[a-zA-Z0-9]\{20,\}' /var/log/ /home/*/logs/ 2>/dev/null | head -10 || echo "None found"
