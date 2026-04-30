#!/usr/bin/env bash
# Code Trace — rastreia chamadas de funcao e imports num codebase
# Uso: ./code-trace.sh <function_or_import> [path]
set -euo pipefail
TARGET="${1:?Usage: $0 <function_or_import> [path]}"
SEARCH_PATH="${2:-.}"
echo "=== Definition ==="
grep -rn "def ${TARGET}\|class ${TARGET}" "$SEARCH_PATH" --include="*.py" 2>/dev/null || echo "(not found)"
echo ""
echo "=== Calls ==="
grep -rn "${TARGET}(" "$SEARCH_PATH" --include="*.py" 2>/dev/null | head -30 || echo "(not found)"
echo ""
echo "=== Imports ==="
grep -rn "from.*import.*${TARGET}\|import.*${TARGET}" "$SEARCH_PATH" --include="*.py" 2>/dev/null | head -20 || echo "(not found)"
