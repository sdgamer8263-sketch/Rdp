#!/bin/bash

# ========== COLORS ==========
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# ========== BANNER + LOGO ==========
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

# ========== OS + PACKAGE MANAGER DETECT ==========
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
    echo "No supported package manager found"
    exit 1
fi
}

install_pkg() {
PKG=$1
case $PM in
    apt) sudo apt update && sudo apt install -y $PKG ;;
    dnf) sudo dnf install -y $PKG ;;
    pacman) sudo pacman -Sy --noconfirm $PKG ;;
    snap) sudo snap install $PKG ;;
esac
}

# ========== XRDP + XFCE ==========
xrdp_menu() {
banner
echo "1. Install XRDP + XFCE"
echo "2. Install VNC"
echo "0. Back"
read -p "Select: " x

case $x in
1)
    install_pkg xfce4
    install_pkg xrdp
    sudo systemctl enable xrdp
    sudo systemctl start xrdp
    ;;
2)
    install_pkg tigervnc
    ;;
0) main_menu ;;
esac
read -p "Press Enter..."
xrdp_menu
}

# ========== BROWSERS & APPS ==========
apps_menu() {
banner
echo "1. Firefox"
echo "2. Chrome"
echo "3. Opera"
echo "4. YouTube (Web)"
echo "5. WhatsApp (Web)"
echo "0. Back"
read -p "Select: " a

case $a in
1) install_pkg firefox ;;
2)
   if [ "$PM" = "apt" ]; then
     wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
     sudo apt install ./google-chrome*.deb
   else
     install_pkg google-chrome
   fi
   ;;
3) install_pkg opera ;;
4) echo "Use browser → youtube.com" ;;
5) echo "Use browser → web.whatsapp.com" ;;
0) main_menu ;;
esac
read -p "Press Enter..."
apps_menu
}

# ========== TAILSCALE ==========
tailscale_install() {
banner
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
read -p "Press Enter..."
main_menu
}

# ========== MAIN MENU ==========
main_menu() {
banner
echo "Detected OS: $OS"
echo "Package Manager: $PM"
echo
echo "1. XRDP + XFCE / VNC"
echo "2. Browsers & Apps"
echo "3. Tailscale (install + up)"
echo "0. Exit"
read -p "Select: " m

case $m in
1) xrdp_menu ;;
2) apps_menu ;;
3) tailscale_install ;;
0) exit ;;
esac
}

# ========== START ==========
detect_os
main_menu
