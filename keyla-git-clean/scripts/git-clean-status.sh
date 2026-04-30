#!/usr/bin/env bash
# Git Clean Status — resumo de todos os repos no dir
# Uso: ./git-clean-status.sh [base-dir]
set -euo pipefail
BASE="${1:-/home/ubuntu/apps}"
echo "Git Status Summary — $BASE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for repo in "$BASE"/*/; do
    [ -d "$repo/.git" ] || continue
    name=$(basename "$repo")
    cd "$repo"
    status=$(git status --short 2>/dev/null | wc -l)
    untracked=$(git status --short 2>/dev/null | grep '^??' | wc -l)
    modified=$(git status --short 2>/dev/null | grep '^ M\|^M ' | wc -l)
    if [ "$status" -gt 0 ]; then
        printf "  ⚠️  %-30s %d changes (%d untracked, %d modified)\n" "$name" "$status" "$untracked" "$modified"
    else
        printf "  ✅  %-30s clean\n" "$name"
    fi
done
