#!/usr/bin/env bash
# Remove old Linux kernels to free /boot space
set -euo pipefail
echo "Current kernel: $(uname -r)"
echo "Installed kernels:"
dpkg --list | grep linux-image | awk '{print $2}'
echo ""
echo "To remove old kernels:"
echo "sudo apt-get autoremove --purge"
