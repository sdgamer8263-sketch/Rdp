#!/bin/bash
set -e

OS_ID=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')

if [[ "$OS_ID" == "ubuntu" ]]; then
  snap install tailscale
else
  curl -fsSL https://tailscale.com/install.sh | sh
fi

tailscale up
