#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# Root check
if [ "$EUID" -ne 0 ]; then
  echo "Run with: sudo ./install.sh"
  exit 1
fi

clear

# =======================
# BANNER
# =======================
cat <<'EOF'
███████╗██████╗ ██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ███╗███████╗██████╗
██╔════╝██╔══██╗██║  ██║██╔══██╗██╔════╝██╔══██╗████╗ ████║██╔════╝██╔══██╗
███████╗██║  ██║███████║███████║█████╗  ███████║██╔████╔██║█████╗  ██████╔╝
╚════██║██║  ██║██╔══██║██╔══██║██╔══╝  ██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗
███████║██████╔╝██║  ██║██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗██║  ██║
╚══════╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝

              SKA HOSTING
 XRDP + VNC + XFCE + FIREFOX + TAILSCALE
EOF

echo "================================="

# =======================
# OS DETECT
# =======================
OS_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

if [[ "$OS_ID" != "ubuntu" && "$OS_ID" != "debian" ]]; then
  echo "❌ Unsupported OS"
  exit 1
fi

echo "✅ Detected OS: $OS_ID"

# =======================
# SYSTEM UPDATE
# =======================
apt update -y
apt -y -o Dpkg::Options::="--force-confnew" full-upgrade
dpkg --configure -a || true

# =======================
# INSTALL DESKTOP + XRDP + VNC
# =======================
apt install -y xfce4 xfce4-goodies dbus-x11 xrdp tigervnc-standalone-server tigervnc-common

adduser xrdp ssl-cert || true

# =======================
# XFCE SESSION
# =======================
echo "xfce4-session" > /etc/skel/.xsession
sed -i '/^exec /d' /etc/xrdp/startwm.sh
echo "startxfce4" >> /etc/xrdp/startwm.sh

# =======================
# POLKIT FIX
# =======================
mkdir -p /etc/polkit-1/localauthority/50-local.d
cat <<EOF >/etc/polkit-1/localauthority/50-local.d/46-allow-colord.pkla
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.*
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

# =======================
# AUTO START XRDP
# =======================
systemctl enable xrdp
systemctl enable xrdp-sesman
systemctl restart xrdp

# =======================
# RDP PORT
# =======================
sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini
systemctl restart xrdp

# =======================
# VNC AUTO START (DISPLAY :1)
# =======================
cat <<EOF >/etc/systemd/system/vncserver@:1.service
[Unit]
Description=TigerVNC Server
After=network.target

[Service]
Type=forking
User=root
ExecStart=/usr/bin/vncserver :1 -geometry 1280x800 -depth 24
ExecStop=/usr/bin/vncserver -kill :1
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable vncserver@:1.service
systemctl start vncserver@:1.service

# =======================
# FIREWALL
# =======================
ufw allow 3390/tcp || true
ufw allow 5901/tcp || true
ufw --force enable || true

# =======================
# FIREFOX
# =======================
if [[ "$OS_ID" == "ubuntu" ]]; then
  snap install firefox
else
  apt install -y firefox-esr
fi

#
echo "================================"
echo "======================================"
echo "SUCCESS "
