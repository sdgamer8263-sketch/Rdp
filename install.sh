#!/usr/bin/env bash

# =======================================
#   AUTHOR    : SDGAMER
#   TOOL      : ULTIMATE VPS/OS INSTALLER
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
 ██████╗██████╗  ██████╗  █████╗ ███╗   ███╗███████╗██████╗ 
██╔════╝██╔══██╗██╔════╝ ██╔══██╗████╗ ████║██╔════╝██╔══██╗
╚█████╗ ██║  ██║██║  ███╗███████║██╔████╔██║█████╗  ██████╔╝
 ╚════██║██║  ██║██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗
██████╔╝██████╔╝╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║
╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${GREEN}            ULTIMATE AUTO INSTALLER TOOL${NC}"
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

# ---------- HELPERS ----------
success_msg() {
    echo -e "\n${GREEN}✔ $1 Process Completed Successfully!${NC}"
    echo -e "${YELLOW}Press Enter to return...${NC}"
    read -r < /dev/tty
}

create_desktop_dir() {
    [ ! -d "$HOME/Desktop" ] && mkdir -p "$HOME/Desktop"
}

install_pkg() {
    PKG=$1
    NAME=$2
    echo -e "${YELLOW}Installing $NAME...${NC}"
    case $PM in
        apt) sudo apt update -y && sudo apt install -y $PKG ;;
        dnf) sudo dnf install -y $PKG ;;
        pacman) sudo pacman -Sy --noconfirm $PKG ;;
    esac
    success_msg "$NAME"
}

# ---------- SUB-MENUS ----------

# 1. XRDP & VNC MENU
xrdp_menu() {
    banner
    echo -e "${CYAN}--- [1] RDP & VNC SETUP ---${NC}"
    echo -e "${YELLOW}1.${NC} Install XRDP + XFCE (Standard)"
    echo -e "${YELLOW}2.${NC} Install TigerVNC Server"
    echo -e "${YELLOW}3.${NC} Fix RDP Black Screen"
    echo -e "${YELLOW}0.${NC} Back"
    echo -ne "${CYAN}Select: ${NC}"
    read -r x < /dev/tty
    case $x in
        1) install_pkg "xfce4 xfce4-goodies xrdp" "XRDP"
           sudo systemctl enable xrdp --now
           echo "xfce4-session" > ~/.xsession ;;
        2) install_pkg "tigervnc-standalone-server xfce4" "VNC" ;;
        3) echo "unset DBUS_SESSION_BUS_ADDRESS" >> ~/.xsession
           echo "exec startxfce4" >> ~/.xsession
           success_msg "RDP Fix" ;;
        0) main_menu ;;
        *) xrdp_menu ;;
    esac
    xrdp_menu
}

# 2. BROWSERS MENU
browsers_menu() {
    banner
    echo -e "${CYAN}--- [2] WEB BROWSERS ---${NC}"
    echo -e "${YELLOW}1.${NC} Google Chrome"
    echo -e "${YELLOW}2.${NC} Firefox"
    echo -e "${YELLOW}3.${NC} Opera Browser"
    echo -e "${YELLOW}4.${NC} Brave Browser"
    echo -e "${YELLOW}0.${NC} Back"
    echo -ne "${CYAN}Select: ${NC}"
    read -r b < /dev/tty
    case $b in
        1) wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
           sudo apt install -y ./google-chrome*.deb; rm -f google-chrome*.deb; success_msg "Chrome" ;;
        2) install_pkg "firefox" "Firefox" ;;
        3) install_pkg "opera-stable" "Opera" ;;
        4) sudo apt install curl -y && curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
           echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
           sudo apt update && sudo apt install brave-browser -y; success_msg "Brave" ;;
        0) main_menu ;;
        *) browsers_menu ;;
    esac
    browsers_menu
}

# 3. SOCIAL APPS MENU
social_menu() {
    banner
    echo -e "${CYAN}--- [3] SOCIAL APPS ---${NC}"
    echo -e "${YELLOW}1.${NC} WhatsApp Desktop"
    echo -e "${YELLOW}2.${NC} Telegram Desktop"
    echo -e "${YELLOW}3.${NC} Discord"
    echo -e "${YELLOW}0.${NC} Back"
    echo -ne "${CYAN}Select: ${NC}"
    read -r s < /dev/tty
    case $s in
        1) sudo snap install whatsapp-for-linux || success_msg "WhatsApp" ;;
        2) install_pkg "telegram-desktop" "Telegram" ;;
        3) sudo snap install discord || success_msg "Discord" ;;
        0) main_menu ;;
        *) social_menu ;;
    esac
    social_menu
}

# 4. STORES MENU (SHORTCUTS)
stores_menu() {
    banner
    echo -e "${CYAN}--- [4] WEB STORES ---${NC}"
    echo -e "${YELLOW}1.${NC} YouTube"
    echo -e "${YELLOW}2.${NC} Google Play Store"
    echo -e "${YELLOW}3.${NC} Apple App Store"
    echo -e "${YELLOW}0.${NC} Back"
    echo -ne "${CYAN}Select: ${NC}"
    read -r st < /dev/tty
    case $st in
        1) create_desktop_dir
           echo -e "[Desktop Entry]\nName=YouTube\nExec=xdg-open https://www.youtube.com\nIcon=youtube\nType=Application" > "$HOME/Desktop/YouTube.desktop"
           chmod +x "$HOME/Desktop/YouTube.desktop"; success_msg "YouTube Shortcut" ;;
        2) create_desktop_dir
           echo -e "[Desktop Entry]\nName=Play Store\nExec=xdg-open https://play.google.com\nIcon=google-play\nType=Application" > "$HOME/Desktop/PlayStore.desktop"
           chmod +x "$HOME/Desktop/PlayStore.desktop"; success_msg "Play Store Shortcut" ;;
        3) create_desktop_dir
           echo -e "[Desktop Entry]\nName=App Store\nExec=xdg-open https://www.apple.com/app-store/\nIcon=apple\nType=Application" > "$HOME/Desktop/AppStore.desktop"
           chmod +x "$HOME/Desktop/AppStore.desktop"; success_msg "App Store Shortcut" ;;
        0) main_menu ;;
        *) stores_menu ;;
    esac
    stores_menu
}

# ---------- MAIN MENU ----------
main_menu() {
    banner
    echo -e "${YELLOW}Detected OS: ${NC}$OS | ${YELLOW}PM: ${NC}$PM"
    echo "---------------------------------------"
    echo -e "${CYAN}1.${NC} XRDP / VNC Setup"
    echo -e "${CYAN}2.${NC} Web Browsers (Chrome, Firefox, etc.)"
    echo -e "${CYAN}3.${NC} Social Apps (WhatsApp, Telegram)"
    echo -e "${CYAN}4.${NC} Web Stores (YouTube, PlayStore)"
    echo -e "${CYAN}5.${NC} Tailscale (VPN) Setup"
    echo -e "${CYAN}6.${NC} System Update & Cleanup"
    echo -e "${RED}0. Exit${NC}"
    echo "---------------------------------------"
    echo -ne "${CYAN}Choose: ${NC}"
    read -r m < /dev/tty

    case $m in
        1) xrdp_menu ;;
        2) browsers_menu ;;
        3) social_menu ;;
        4) stores_menu ;;
        5) curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up; success_msg "Tailscale" ;;
        6) sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y; success_msg "System Clean" ;;
        0) exit 0 ;;
        *) main_menu ;;
    esac
}

# START
detect_os
main_menu
