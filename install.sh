#!/usr/bin/env bash

# =========================
#   AUTHOR : SDGAMER
#    INSTALLER
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

# ---------- OS + PACKAGE MANAGER ----------
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

# ---------- XRDP / VNC ----------
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
    ;;
2)
    echo -e "${GREEN}Installing VNC...${NC}"
    install_pkg tigervnc-standalone-server xfce4
    ;;
0) main_menu ;;
*) echo -e "${RED}Invalid option${NC}"; sleep 1; xrdp_menu ;;
esac
read -p "Press Enter to continue..."
xrdp_menu
}

# ---------- BROWSERS ----------
install_firefox() {
echo -e "${GREEN}Installing Firefox...${NC}"
if command -v apt >/dev/null; then
    sudo apt update -y && sudo apt install -y firefox
elif command -v snap >/dev/null; then
    sudo snap install firefox
fi
}

install_chrome() {
echo -e "${GREEN}Installing Google Chrome...${NC}"
if command -v apt >/dev/null; then
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome*.deb
    rm -f google-chrome*.deb
elif command -v snap >/dev/null; then
    sudo snap install google-chrome
fi
}

install_opera() {
echo -e "${GREEN}Installing Opera...${NC}"
if command -v apt >/dev/null; then
    sudo apt update -y && sudo apt install -y opera
elif command -v snap >/dev/null; then
    sudo snap install opera
fi
}

# ---------- APPS ----------
apps_menu() {
banner
echo -e "${YELLOW}1.${NC} ${GREEN}YouTube (Web)${NC}"
echo -e "${YELLOW}2.${NC} ${GREEN}WhatsApp Web${NC}"
echo -e "${YELLOW}3.${NC} ${GREEN}Play Store (Browser/Emulator info)${NC}"
echo -e "${YELLOW}4.${NC} ${GREEN}App Store (Browser info)${NC}"
echo -e "${YELLOW}0.${NC} ${GREEN}Back${NC}"
read -p "$(echo -e ${CYAN}Select: ${NC})" a

case $a in
1)
    echo -e "${GREEN}Opening YouTube in default browser...${NC}"
    if command -v firefox >/dev/null; then
        firefox https://www.youtube.com &
    elif command -v google-chrome >/dev/null; then
        google-chrome https://www.youtube.com &
    else
        echo -e "${RED}No browser installed!${NC}"
    fi
    ;;
2)
    echo -e "${GREEN}Opening WhatsApp Web in default browser...${NC}"
    if command -v firefox >/dev/null; then
        firefox https://web.whatsapp.com &
    elif command -v google-chrome >/dev/null; then
        google-chrome https://web.whatsapp.com &
    else
        echo -e "${RED}No browser installed!${NC}"
    fi
    ;;
3)
    echo -e "${YELLOW}Play Store cannot be natively installed on Linux.${NC}"
    echo "Use an Android emulator or visit https://play.google.com/store"
    ;;
4)
    echo -e "${YELLOW}App Store cannot be natively installed on Linux.${NC}"
    echo "Visit https://www.apple.com/app-store/"
    ;;
0) main_menu ;;
*) echo -e "${RED}Invalid option${NC}"; sleep 1; apps_menu ;;
esac
read -p "Press Enter to continue..."
apps_menu
}

# ---------- TAILSCALE ----------
tailscale_install() {
banner
echo -e "${GREEN}Installing Tailscale...${NC}"
if command -v apt >/dev/null; then
    sudo apt update -y && sudo apt install -y tailscale
elif command -v snap >/dev/null; then
    sudo snap install tailscale
fi
sudo tailscale up
read -p "Press Enter to continue..."
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
echo -e "${YELLOW}3.${NC} ${GREEN}Apps${NC}"
echo -e "${YELLOW}4.${NC} ${GREEN}Tailscale${NC}"
echo -e "${YELLOW}0.${NC} ${GREEN}Exit${NC}"
read -p "$(echo -e ${CYAN}Select: ${NC})" m

case $m in
1) xrdp_menu ;;
2) apps_menu ;;
3) apps_menu ;;
4) tailscale_install ;;
0) exit ;;
*) echo -e "${RED}Invalid option${NC}"; sleep 1; main_menu ;;
esac
}

# ---------- START ----------
detect_os
main_menu
