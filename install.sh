#!/usr/bin/env bash

# =========================
#   AUTHOR : SDGAMER
#   INTERACTIVE VPS INSTALLER
# =========================

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- BANNER ----------
banner() {
clear
echo -e "${CYAN}"
cat <<'EOF'
███████╗██████╗  ██████╗  █████╗ ███╗   ███╗███████╗██████╗ 
██╔════╝██╔══██╗██╔════╝ ██╔══██╗████╗ ████║██╔════╝██╔══██╗
███████╗██║  ██║██║  ███╗███████║██╔████╔██║█████╗  ██████╔╝
╚════██║██║  ██║██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗
███████║██████╔╝╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║
╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${GREEN}            AUTO OS INSTALLER TOOL${NC}"
echo "======================================="
echo
}

detect_os() {
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi
if command -v apt >/dev/null; then PM="apt"; elif command -v dnf >/dev/null; then PM="dnf"; elif command -v pacman >/dev/null; then PM="pacman"; else PM="snap"; fi
}

install_pkg() {
PKG=$1
case $PM in
    apt) sudo apt update -y && sudo apt install -y $PKG ;;
    dnf) sudo dnf install -y $PKG ;;
    pacman) sudo pacman -Sy --noconfirm $PKG ;;
    snap) sudo snap install $PKG ;;
esac
}

xrdp_menu() {
banner
echo -e "${YELLOW}1.${NC} ${GREEN}Install XRDP + XFCE${NC}"
echo -e "${YELLOW}2.${NC} ${GREEN}Install VNC${NC}"
echo -e "${YELLOW}0.${NC} ${GREEN}Back${NC}"
read -p "Select: " x < /dev/tty
case $x in
1) install_pkg xfce4; install_pkg xrdp; sudo systemctl enable xrdp --now; echo xfce4-session > ~/.xsession ;;
2) install_pkg tigervnc-standalone-server; install_pkg xfce4 ;;
0) main_menu ;;
*) echo -e "${RED}Invalid option${NC}"; sleep 1; xrdp_menu ;;
esac
read -p "Press Enter to continue..." < /dev/tty
xrdp_menu
}

apps_menu() {
banner
echo -e "${YELLOW}1.${NC} ${GREEN}YouTube${NC}"
echo -e "${YELLOW}2.${NC} ${GREEN}WhatsApp${NC}"
echo -e "${YELLOW}0.${NC} ${GREEN}Back${NC}"
read -p "Select: " a < /dev/tty
case $a in
1) xdg-open http://youtube.com & ;;
2) xdg-open https://web.whatsapp.com & ;;
0) main_menu ;;
*) echo -e "${RED}Invalid option${NC}"; sleep 1; apps_menu ;;
esac
read -p "Press Enter to continue..." < /dev/tty
apps_menu
}

main_menu() {
banner
echo -e "${CYAN}Detected OS: ${NC}$OS"
echo
echo -e "${YELLOW}1.${NC} ${GREEN}XRDP + XFCE / VNC${NC}"
echo -e "${YELLOW}2.${NC} ${GREEN}Apps${NC}"
echo -e "${YELLOW}0.${NC} ${GREEN}Exit${NC}"
read -p "Select: " m < /dev/tty
case $m in
1) xrdp_menu ;;
2) apps_menu ;;
0) exit ;;
*) echo -e "${RED}Invalid option${NC}"; sleep 1; main_menu ;;
esac
}

detect_os
main_menu
