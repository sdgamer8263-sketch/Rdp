#!/usr/bin/env bash

# =======================================
#   AUTHOR    : SDGAMER
#   TOOL      : UBUNTU RDP + Tailscale (APT COMMANDS FIXED)
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
echo -e "${GREEN}         UBUNTU RDP INSTALLER (FULL APT SETUP)${NC}"
echo "======================================="
echo
}

# ---------- HELPERS ----------
success_msg() {
    echo -e "\n${GREEN}✔ $1 Process Completed Successfully!${NC}"
    echo -e "${YELLOW}Press Enter to return...${NC}"
    read -r < /dev/tty
}

# ---------- FULL RDP SETUP (XRDP + XFCE) ----------
install_rdp_full() {
    echo -e "${YELLOW}Starting Ubuntu Full RDP Setup...${NC}"
    
    # APT Update and Installation
    sudo apt update -y
    sudo apt install -y xfce4 xfce4-goodies xrdp 

    # RDP Configuration
    sudo systemctl enable xrdp --now
    
    # Fix for Black Screen (Ubuntu LTS)
    echo "xfce4-session" > ~/.xsession
    echo "unset DBUS_SESSION_BUS_ADDRESS" > ~/.xsessionrc
    echo "exec startxfce4" >> ~/.xsessionrc
    
    # Adding user to SSL group for permissions
    sudo adduser xrdp ssl-cert
    sudo systemctl restart xrdp
    
    success_msg "Full RDP Setup"
}

# ---------- BROWSERS MENU ----------
browsers_menu() {
    banner
    echo -e "${CYAN}--- [2] WEB BROWSERS ---${NC}"
    echo -e "${YELLOW}1.${NC} Google Chrome (Direct Deb)"
    echo -e "${YELLOW}2.${NC} Firefox (Apt/Snap)"
    echo -e "${YELLOW}3.${NC} Brave Browser (Apt Repo)"
    echo -e "${YELLOW}0.${NC} Back"
    echo -ne "${CYAN}Select: ${NC}"
    read -r b < /dev/tty
    case $b in
        1) 
           sudo apt update -y
           wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
           sudo apt install -y ./google-chrome*.deb
           rm -f google-chrome*.deb
           success_msg "Chrome" 
           ;;
        2) 
           sudo apt update -y
           sudo apt install -y firefox || sudo snap install firefox
           success_msg "Firefox" 
           ;;
        3) 
           sudo apt update -y
           sudo apt install -y curl
           curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
           echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
           sudo apt update -y
           sudo apt install -y brave-browser
           success_msg "Brave" 
           ;;
        0) main_menu ;;
        *) browsers_menu ;;
    esac
    browsers_menu
}

# ---------- MAIN MENU ----------
main_menu() {
    banner
    echo -e "${YELLOW}OS:${NC} Ubuntu LTS | ${YELLOW}Package Manager:${NC} APT (Primary)"
    echo "---------------------------------------"
    echo -e "${CYAN}1.${NC} INSTALL FULL RDP SETUP (XRDP + XFCE)"
    echo -e "${CYAN}2.${NC} Web Browsers (Chrome, Firefox, Brave)"
    echo -e "${CYAN}3.${NC} Install Tailscale (VPN)"
    echo -e "${CYAN}4.${NC} System Update & Full Cleanup"
    echo -e "${RED}0. Exit${NC}"
    echo "---------------------------------------"
    echo -ne "${CYAN}Choose: ${NC}"
    read -r m < /dev/tty

    case $m in
        1) install_rdp_full ;;
        2) browsers_menu ;;
        3) 
           sudo apt update -y
           curl -fsSL https://tailscale.com/install.sh | sh
           sudo tailscale up
           success_msg "Tailscale" 
           ;;
        4) 
           sudo apt update -y
           sudo apt upgrade -y
           sudo apt autoremove -y
           sudo apt clean
           success_msg "System Update & Clean" 
           ;;
        0) exit 0 ;;
        *) main_menu ;;
    esac
    main_menu
}

# START
main_menu
