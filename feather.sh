#!/bin/bash
set -e

OS_ID=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')

if [[ "$OS_ID" == "ubuntu" ]]; then
  echo "Installing Feather Panel on Ubuntu..."
  # Ubuntu-specific commands
  apt update
  apt install -y dependencies
  # ... add Feather Panel install steps
elif [[ "$OS_ID" == "debian" ]]; then
  echo "Feather Panel is not supported on Debian directly."
fi
