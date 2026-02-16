#!/bin/bash
set -e

OS_ID=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')

while true; do
clear
echo "PANELS"
echo "1. Pterodactyl"
echo "2. Feather"
echo "3. Jexactyl"
echo "4. Jexpanel"
echo "5. Mythicaldash (Old)"
echo "6. Mythicaldash (New)"
echo "7. Reviactyl"
echo "8. Skyport"
echo "9. PufferPanel"
echo "10. Hydra"
echo "0. Back"
read -rp "Select: " p

[ "$p" = "0" ] && break

if [[ "$OS_ID" != "ubuntu" ]]; then
  echo "This panel supports Ubuntu only"
  sleep 2
  continue
fi

bash <(curl -s https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/install.sh)
done
