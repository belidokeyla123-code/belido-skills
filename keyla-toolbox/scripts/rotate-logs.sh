#!/usr/bin/env bash
# Rotate and compress old log files
set -euo pipefail
log_dir="${1:-/home/ubuntu/apps}"
echo "Rotating logs in $log_dir..."
find "$log_dir" -name "*.log" -size +50M -exec gzip -k {} \; 2>/dev/null
find "$log_dir" -name "*.log.gz" -mtime +30 -delete 2>/dev/null
echo "Done"
