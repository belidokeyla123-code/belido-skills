#!/usr/bin/env bash
# Organize Worktree — limpa arquivos que nao deveriam estar num repo
# Uso: ./organize-worktree.sh [dir]
set -euo pipefail
TARGET="${1:-.}"
cd "$TARGET"
echo "Organizing worktree: $(pwd)"
echo "Untracked files: $(git status --short | grep '^??' | wc -l)"
echo "Tracked that should be ignored:"
git ls-files | grep -E '\.(log|bak|tmp|pyc|pyo)$|__pycache__|auditoria/|outputs/' || echo "  (none)"
echo ""
echo "To clean (dry-run):"
git clean -fd --dry-run
echo ""
echo "Run with --exec to actually clean"
if [ "${2:-}" = "--exec" ]; then
    git clean -fd
    echo "Cleaned."
fi
