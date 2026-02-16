#!/bin/bash
set -e

while true; do
  clear
  echo "1. Panel Installers"
  echo "2. VPS Setup"
  echo "0. Exit"
  read -rp "Select option: " choice

  case $choice in
    1) bash ./panel_install.sh ;;
    2) bash -c "curl -s https://vps1.jishnu.fun" ;;
    0) exit ;;
    *) echo "Invalid option"; sleep 1 ;;
  esac
done
