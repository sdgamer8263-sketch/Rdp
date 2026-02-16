#!/bin/bash
set -e

clear

OS_ID=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
OS_NAME=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')

banner() {
clear
cat <<'EOF'
███████╗██████╗ ██╗  ██╗ ██████╗  █████╗ ███╗   ███╗███████╗██████╗
██╔════╝██╔══██╗██║  ██║██╔════╝ ██╔══██╗████╗ ████║██╔════╝██╔══██╗
███████╗██║  ██║███████║██║  ███╗███████║██╔████╔██║█████╗  ██████╔╝
╚════██║██║  ██║██╔══██║██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗
███████║██████╔╝██║  ██║╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║
╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
SDHGAMER | SKA HOSTING
XRDP • VNC • PANELS • TAILSCALE • CLOUDFLARE
EOF
echo
echo "Detected OS: $OS_NAME"
echo
}

while true; do
banner
echo "1. VPS Setup"
echo "2. Panels"
echo "3. XRDP + XFCE"
echo "4. VNC / noVNC"
echo "5. Browsers & Apps"
echo "6. Tailscale"
echo "7. Cloudflare Tunnel"
echo "0. Exit"
read -rp "Select: " opt

case $opt in
1) bash <(curl -s https://vps1.jishnu.fun) ;;
2) bash panels.sh ;;
3) bash rdp.sh ;;
4) bash vnc.sh ;;
5) bash apps.sh ;;
6) bash tailscale.sh ;;
7) bash cloudflare.sh ;;
0) exit ;;
esac
done
