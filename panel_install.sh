#!/bin/bash
set -e

while true; do
  clear
  echo "Panel Installers"
  echo "1. Pterodactyl Panel"
  echo "2. Feather Panel"
  echo "3. Jexactyl"
  echo "4. Jexpanel"
  echo "5. Mythicaldash (old)"
  echo "6. Mythicaldash (new)"
  echo "7. Reviactyl"
  echo "8. Skyport Panel"
  echo "9. Puffer Panel (old)"
  echo "10. Puffer Panel (new)"
  echo "11. Hydra Panel"
  echo "12. Air Link Panel"
  echo "13. Darco Panel"
  echo "0. Back"
  read -rp "Select option: " panel_choice

  case $panel_choice in
    1) bash ./pterodactyl.sh ;;
    2) bash ./feather.sh ;;
    3) bash ./jexactyl.sh ;;
    # Add other panel scripts similarly
    0) break ;;
    *) echo "Invalid option"; sleep 1 ;;
  esac
done
