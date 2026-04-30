#!/usr/bin/env bash
# EC2 SSH setup - creates convenient aliases
# Usage: source ec2-ssh-setup.sh
set -euo pipefail

KEY="${1:-/data/user/0/gptos.intelligence.assistant/cache/codex-web-uploads/f-KeDIcg/cerebro-ec2-keyla.pem}"
EC2_HOST="56.126.138.7"
EC2_USER="ubuntu"

if [ ! -f "$KEY" ]; then
    echo "ERROR: Key file not found: $KEY"
    return 1
fi

export EC2_KEY="$KEY"
export EC2_SSH="ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST"
export EC2_SCP="scp -o StrictHostKeyChecking=no -i $EC2_KEY"

# Aliases
alias ec2="ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST"
alias ec2-logs="ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST 'tail -50 /home/ubuntu/logs/*.log'"
alias ec2-services="ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST 'systemctl list-units --type=service --state=running --no-pager'"
alias ec2-health="ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST 'uptime && free -h && df -h /'"
alias ec2-failed="ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST 'systemctl list-units --type=service --state=failed --no-pager'"
alias ec2-restart="ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST 'sudo systemctl restart'"
alias ec2-vault="ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST 'cd /home/ubuntu/cerebro-vault && git status'"
alias ec2-docker="ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST 'docker ps'"

echo "EC2 SSH aliases loaded. Type 'ec2' to connect."
