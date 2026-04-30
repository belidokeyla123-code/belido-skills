#!/usr/bin/env bash
# Quick EC2 health check
set -euo pipefail
echo "Uptime: $(uptime -p)"
echo "Disk: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
echo "RAM: $(free -h | awk 'NR==2{print "Used:"$3" Free:"$4" Avail:"$7}')"
echo "Load: $(cat /proc/loadavg | awk '{print $1,$2,$3}')"
echo "Services: $(systemctl list-units --type=service --state=failed --no-pager 2>/dev/null | grep -c 'failed') failed"
