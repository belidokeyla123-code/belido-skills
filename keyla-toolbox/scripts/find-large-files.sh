#!/usr/bin/env bash
# Find largest files/directories
set -euo pipefail
dir="${1:-/home/ubuntu}"
echo "Largest directories in $dir:"
du -ah "$dir" 2>/dev/null | sort -rh | head -20
