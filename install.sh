#!/usr/bin/env bash

# =======================================
#   AUTHOR    : SDGAMER
#   TOOL      : AUTO OS INSTALLER (FIXED)
# =======================================

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

# ---------- OS DETECTION ----------
detect_os() {
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi
if command -v apt >/dev/null; then PM="apt"; elif command -v dnf >/dev/null; then PM="dnf"; else PM="pacman"; fi
}

install_pkg() {
PKG=$1
echo -e "${YELLOW}Installing $PKG...${NC}"
case $PM in
    apt) sudo apt update -y && sudo apt install -y $PKG ;;
    dnf) sudo dnf install -y $PKG ;;
    pacman) sudo pacman -Sy --noconfirm $PKG ;;
esac
}

# ---------- APPS MENU (NEW) ----------
apps_menu() {
banner
echo -e "${YELLOW}1.${NC} ${GREEN}Install WhatsApp (Linux Version)${NC}"
echo -e "${YELLOW}2.${NC} ${GREEN}Install YouTube (Browser-based Launcher)${NC}"
echo -e "${YELLOW}3.${NC} ${GREEN}Google Play Store (Web Shortcut)${NC}"
echo -e "${YELLOW}0.${NC} ${GREEN}Back${NC}"
echo -ne "${CYAN}Select an app to setup: ${NC}"
read a < /dev/tty

case $a in
    1)
        echo -e "${GREEN}Installing WhatsApp Desktop client...${NC}"
        # Installing via snap as it's the most stable for Linux
        sudo snap install whatsapp-for-linux || install_pkg "whatsapp-for-linux"
        ;;
    2)
        echo -e "${GREEN}Setting up YouTube Shortcut...${NC}"
        # Creating a simple desktop shortcut for YouTube
        echo -e "[Desktop Entry]\nName=YouTube\nExec=xdg-open https://www.youtube.com\nIcon=youtube\nType=Application" > ~/Desktop/YouTube.desktop
        chmod +x ~/Desktop/YouTube.desktop
        echo -e "${GREEN}YouTube shortcut created on Desktop!${NC}"
        ;;
    3)
        echo -e "${GREEN}Setting up Play Store Shortcut...${NC}"
        echo -e "[Desktop Entry]\nName=Play Store\nExec=xdg-open https://play.google.com\nIcon=google-play\nType=Application" > ~/Desktop/PlayStore.desktop
        chmod +x ~/Desktop/PlayStore.desktop
        echo -e "${GREEN}Play Store shortcut created on Desktop!${NC}"
        ;;
    0) main_menu ;;
    *) echo -e "${RED}Invalid option!${NC}"; sleep 1; apps_menu ;;
esac
echo -e "\nPress Enter to return..."
read < /dev/tty
apps_menu
}

# ---------- MAIN MENU ----------
main_menu() {
banner
echo -e "${CYAN}Detected OS: ${NC}$OS"
echo "---------------------------------------"
echo -e "${YELLOW}1.${NC} XRDP + XFCE / VNC Setup"
echo -e "${YELLOW}2.${NC} Install Browsers"
echo -e "${YELLOW}3.${NC} WhatsApp, YouTube & Play Store"
echo -e "${YELLOW}4.${NC} Install Tailscale"
echo -e "${YELLOW}0.${NC} Exit"
echo -ne "${CYAN}Choose: ${NC}"
read m < /dev/tty

case $m in
    1) 
        banner
        echo -e "1. Install XRDP+XFCE\n2. Install VNC\n0. Back"
        read x < /dev/tty
        [[ $x == "1" ]] && (install_pkg "xfce4 xfce4-goodies xrdp"; sudo systemctl enable xrdp --now; echo "xfce4-session" > ~/.xsession)
        [[ $x == "2" ]] && install_pkg "tigervnc-standalone-server xfce4"
        main_menu
        ;;
    2)
        banner
        echo -e "1. Firefox\n2. Chrome\n0. Back"
        read b < /dev/tty
        [[ $b == "1" ]] && install_pkg "firefox"
        [[ $b == "2" ]] && (wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; sudo apt install -y ./google-chrome*.deb; rm -f google-chrome*.deb)
        main_menu
        ;;
    3) apps_menu ;;
    4) curl -fsSL https://tailscale.com/install.sh | sh; sudo tailscale up ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid selection!${NC}"; sleep 1; main_menu ;;
esac
}

# START
detect_os
main_menu
