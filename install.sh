#!/usr/bin/env bash

# =========================
#   AUTHOR : SDGAMER
#   FULL ALL-IN-ONE  INSTALLER
# =========================

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- BANNER + LOGO ----------
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

# ---------- OS + PACKAGE MANAGER DETECT ----------
detect_os() {
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi

if command -v apt >/dev/null; then
    PM="apt"
elif command -v dnf >/dev/null; then
    PM="dnf"
elif command -v pacman >/dev/null; then
    PM="pacman"
elif command -v snap >/dev/null; then
    PM="snap"
else
    echo -e "${RED}No supported package manager found${NC}"
    exit 1
fi
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

# ---------- XRDP + XFCE ----------
xrdp_menu() {
banner
echo -e "${YELLOW}1.${NC} ${GREEN}Install XRDP + XFCE${NC}"
echo -e "${YELLOW}2.${NC} ${GREEN}Install VNC${NC}"
echo -e "${YELLOW}0.${NC} ${GREEN}Back${NC}"
read -p "$(echo -e ${CYAN}Select: ${NC})" x

case $x in
1)
    echo -e "${GREEN}Installing XFCE + XRDP...${NC}"
    install_pkg xfce4 xfce4-goodies
    install_pkg xrdp
    sudo systemctl enable xrdp --now
    echo xfce4-session > ~/.xsession
    echo -e "${GREEN}XRDP Installed. Port: 3389${NC}"
    ;;
2)
    echo -e "${GREEN}Installing VNC...${NC}"
    install_pkg tigervnc-standalone-server xfce4
    echo "VNC installed. Configure manually."
    ;;
0) main_menu ;;
*) echo -e "${RED}Invalid option${NC}"; sleep 1; xrdp_menu ;;
esac
read -p "Press Enter..."
xrdp_menu
}

# ---------- BROWSERS ----------
install_firefox() {
banner
echo -e "${GREEN}Installing Firefox...${NC}"
if command -v apt >/dev/null; then
    sudo apt update -y
    sudo apt install -y firefox
elif command -v snap >/dev/null; then
    sudo snap install firefox
else
    echo -e "${RED}No supported package manager found for Firefox${NC}"
fi
read -p "Press Enter..."
apps_menu
}

install_chrome() {
banner
echo -e "${GREEN}Installing Google Chrome...${NC}"
if command -v apt >/dev/null; then
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome*.deb
    rm -f google-chrome*.deb
elif command -v snap >/dev/null; then
    sudo snap install google-chrome
else
    echo -e "${RED}No supported package manager found for Chrome${NC}"
fi
read -p "Press Enter..."
apps_menu
}

install_opera() {
banner
echo -e "${GREEN}Installing Opera...${NC}"
if command -v apt >/dev/null; then
    sudo apt update -y
    sudo apt install -y opera
elif command -v snap >/dev/null; then
    sudo snap install opera
else
    echo -e "${RED}No supported package manager found for Opera${NC}"
fi
read -p "Press Enter..."
apps_menu
}

apps_menu() {
banner
echo -e "${YELLOW}1.${NC} ${GREEN}Firefox${NC}"
echo -e "${YELLOW}2.${NC} ${GREEN}Google Chrome${NC}"
echo -e "${YELLOW}3.${NC} ${GREEN}Opera${NC}"
echo -e "${YELLOW}0.${NC} ${GREEN}Back${NC}"
read -p "$(echo -e ${CYAN}Select: ${NC})" a

case $a in
1) install_firefox ;;
2) install_chrome ;;
3) install_opera ;;
0) main_menu ;;
*) echo -e "${RED}Invalid option${NC}"; sleep 1; apps_menu ;;
esac
}

# ---------- TAILSCALE ----------
tailscale_install() {
banner
echo -e "${GREEN}Installing Tailscale...${NC}"
if command -v apt >/dev/null; then
    sudo apt update -y
    sudo apt install -y tailscale
elif command -v snap >/dev/null; then
    sudo snap install tailscale
else
    echo -e "${RED}No supported package manager found for Tailscale${NC}"
    read -p "Press Enter..."
    main_menu
fi
sudo tailscale up
read -p "Press Enter..."
main_menu
}

# ---------- MAIN MENU ----------
main_menu() {
banner
echo -e "${CYAN}Detected OS: ${NC}$OS"
echo -e "${CYAN}Package Manager: ${NC}$PM"
echo
echo -e "${YELLOW}1.${NC} ${GREEN}XRDP + XFCE / VNC${NC}"
echo -e "${YELLOW}2.${NC} ${GREEN}Browsers${NC}"
echo -e "${YELLOW}3.${NC} ${GREEN}Tailscale${NC}"
echo -e "${YELLOW}0.${NC} ${GREEN}Exit${NC}"
read -p "$(echo -e ${CYAN}Select: ${NC})" m

case $m in
1) xrdp_menu ;;
2) apps_menu ;;
3) tailscale_install ;;
0) exit ;;
*) echo -e "${RED}Invalid option${NC}"; sleep 1; main_menu ;;
esac
}

# ---------- START ----------
detect_os
main_menu
