#!/bin/bash
set -e

# Must be run as root
if [ "$EUID" -ne 0 ]; then
  echo "Run with: sudo ./install.sh"
  exit 1
fi

# Ubuntu check
if ! grep -qi ubuntu /etc/os-release; then
  echo "This script supports Ubuntu LTS only"
  exit 1
fi

echo "Updating system..."
apt update && apt upgrade -y

echo "Installing XFCE..."
apt install -y xfce4 xfce4-goodies dbus-x11

echo "Installing xRDP..."
apt install -y xrdp

echo "Adding xRDP to ssl-cert group..."
adduser xrdp ssl-cert

echo "Configuring XFCE session for xRDP..."
echo "xfce4-session" > /etc/skel/.xsession

sed -i.bak '/^exec /d' /etc/xrdp/startwm.sh
grep -q startxfce4 /etc/xrdp/startwm.sh || echo "startxfce4" >> /etc/xrdp/startwm.sh

echo "Fixing black screen issue (polkit)..."
cat <<EOF >/etc/polkit-1/localauthority/50-local.d/46-allow-colord.pkla
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.*
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

echo "Setting custom RDP port 3390..."
sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini

echo "Configuring firewall..."
ufw allow 3390/tcp || true
ufw --force enable || true

echo "Enabling xRDP service..."
systemctl enable xrdp
systemctl restart xrdp

echo "DONE"
echo "RDP Port: 3390"
echo "Login with normal Ubuntu user (not root)"

echo "Firefox"
apt install 
apt update 
snap install firefox
