#!/usr/bin/env bash
# Execute command on EC2 via SSH
# Usage: ./ec2-remote-exec.sh "command"
set -euo pipefail

KEY="${EC2_KEY:-/data/user/0/gptos.intelligence.assistant/cache/codex-web-uploads/f-KeDIcg/cerebro-ec2-keyla.pem}"
EC2_HOST="56.126.138.7"
EC2_USER="ubuntu"

if [ $# -eq 0 ]; then
    echo "Usage: $0 \"command to execute\""
    exit 1
fi

ssh -o StrictHostKeyChecking=no -i "$KEY" "$EC2_USER@$EC2_HOST" "$1"
