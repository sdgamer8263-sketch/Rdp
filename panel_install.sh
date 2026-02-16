#!/bin/bash
set -e

while true; do
  clear
  echo "Panel Installers"
  echo "1. Pterodactyl Panel"
  echo "2. Feather Panel"
  echo "0. Back"
  read -rp "Select option: " panel_choice

  case $panel_choice in
    1) bash ./pterodactyl.sh ;;
    2) bash ./feather.sh ;;
    0) break ;;
    *) echo "Invalid option"; sleep 1 ;;
  esac
done
