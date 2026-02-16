#!/usr/bin/env bash

# =========================
#   AUTHOR : SDGAMER
#   FULL AUTOMATIC VPS INSTALLER
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

# ---------- XRDP + XFCE AUTO ----------
xrdp_auto() {
banner
echo -e "${GREEN}Installing XFCE + XRDP automatically...${NC}"
install_pkg xfce4 xfce4-goodies
install_pkg xrdp
sudo systemctl enable xrdp --now
echo xfce4-session > ~/.xsession
echo -e "${GREEN}XRDP Installed. Port: 3389${NC}"
}

# ---------- VNC AUTO ----------
vnc_auto() {
banner
echo -e "${GREEN}Installing VNC automatically...${NC}"
install_pkg tigervnc-standalone-server xfce4
echo -e "${GREEN}VNC Installed. Configure manually.${NC}"
}

# ---------- BROWSERS AUTO ----------
install_firefox_auto() {
echo -e "${GREEN}Installing Firefox automatically...${NC}"
if command -v apt >/dev/null; then
    sudo apt update -y && sudo apt install -y firefox
elif command -v snap >/dev/null; then
    sudo snap install firefox
fi
}

install_chrome_auto() {
echo -e "${GREEN}Installing Google Chrome automatically...${NC}"
if command -v apt >/dev/null; then
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome*.deb
    rm -f google-chrome*.deb
elif command -v snap >/dev/null; then
    sudo snap install google-chrome
fi
}

install_opera_auto() {
echo -e "${GREEN}Installing Opera automatically...${NC}"
if command -v apt >/dev/null; then
    sudo apt update -y && sudo apt install -y opera
elif command -v snap >/dev/null; then
    sudo snap install opera
fi
}

browsers_auto() {
banner
install_firefox_auto
install_chrome_auto
install_opera_auto
echo -e "${GREEN}All browsers installed.${NC}"
}

# ---------- TAILSCALE AUTO ----------
tailscale_auto() {
banner
echo -e "${GREEN}Installing Tailscale automatically...${NC}"
if command -v apt >/dev/null; then
    sudo apt update -y && sudo apt install -y tailscale
elif command -v snap >/dev/null; then
    sudo snap install tailscale
fi
sudo tailscale up
echo -e "${GREEN}Tailscale is up.${NC}"
}

# ---------- MAIN AUTOMATIC INSTALL ----------
main_auto() {
banner
echo -e "${GREEN}Starting full automatic VPS setup...${NC}"
xrdp_auto
vnc_auto
browsers_auto
tailscale_auto
echo -e "${GREEN}All tasks completed successfully!${NC}"
}

# ---------- START ----------
detect_os
main_auto
