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

# ---------- ALL APPS SUB-MENU ----------
apps_menu() {
banner
echo -e "${CYAN}--- APPS & BROWSERS ---${NC}"
echo -e "${YELLOW}1.${NC} Firefox"
echo -e "${YELLOW}2.${NC} Opera"
echo -e "${YELLOW}3.${NC} Google Chrome"
echo -e "${YELLOW}4.${NC} YouTube (Shortcut)"
echo -e "${YELLOW}5.${NC} WhatsApp (Linux Client)"
echo -e "${YELLOW}6.${NC} Play Store (Shortcut)"
echo -e "${YELLOW}7.${NC} App Store (Shortcut)"
echo -e "${YELLOW}0.${NC} Back to Main Menu"
echo -ne "${CYAN}Select an option: ${NC}"
read a < /dev/tty

case $a in
    1) install_pkg "firefox" ;;
    2) install_pkg "opera-stable" ;;
    3) 
        wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo apt install -y ./google-chrome*.deb
        rm -f google-chrome*.deb
        ;;
    4)
        echo -e "[Desktop Entry]\nName=YouTube\nExec=xdg-open https://www.youtube.com\nIcon=youtube\nType=Application" > ~/Desktop/YouTube.desktop
        chmod +x ~/Desktop/YouTube.desktop
        echo -e "${GREEN}YouTube shortcut created!${NC}"
        ;;
    5)
        sudo snap install whatsapp-for-linux || install_pkg "whatsapp-for-linux"
        ;;
    6)
        echo -e "[Desktop Entry]\nName=Play Store\nExec=xdg-open https://play.google.com\nIcon=google-play\nType=Application" > ~/Desktop/PlayStore.desktop
        chmod +x ~/Desktop/PlayStore.desktop
        echo -e "${GREEN}Play Store shortcut created!${NC}"
        ;;
    7)
        echo -e "[Desktop Entry]\nName=App Store\nExec=xdg-open https://www.apple.com/app-store/\nIcon=apple\nType=Application" > ~/Desktop/AppStore.desktop
        chmod +x ~/Desktop/AppStore.desktop
        echo -e "${GREEN}App Store shortcut created!${NC}"
        ;;
    0) main_menu ;;
    *) echo -e "${RED}Invalid option!${NC}"; sleep 1; apps_menu ;;
esac
echo -e "\nPress Enter to continue..."
read < /dev/tty
apps_menu
}

# ---------- MAIN MENU ----------
main_menu() {
banner
echo -e "${CYAN}OS: ${NC}$OS | ${CYAN}PM: ${NC}$PM"
echo "---------------------------------------"
echo -e "${YELLOW}1.${NC} XRDP + XFCE / VNC Setup"
echo -e "${YELLOW}2.${NC} Apps (Browsers, Social, Stores)"
echo -e "${YELLOW}3.${NC} Install Tailscale"
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
    2) apps_menu ;;
    3) curl -fsSL https://tailscale.com/install.sh | sh; sudo tailscale up ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid selection!${NC}"; sleep 1; main_menu ;;
esac
}

# START
detect_os
main_menu
