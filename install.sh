#!/bin/bash
set -e

# Force non-interactive mode (IMPORTANT)
export DEBIAN_FRONTEND=noninteractive

# Root check
if [ "$EUID" -ne 0 ]; then
  echo "Run with: sudo ./install.sh"
  exit 1
fi

# Ubuntu check
if ! grep -qi ubuntu /etc/os-release; then
  echo "Ubuntu LTS only"
  exit 1
fi

echo "=== Ubuntu LTS xRDP + XFCE Setup ==="

echo "Updating system..."
apt update -y
apt -y -o Dpkg::Options::="--force-confnew" full-upgrade

echo "Fixing any pending packages..."
dpkg --configure -a || true

echo "Installing XFCE..."
apt install -y xfce4 xfce4-goodies dbus-x11

echo "Installing xRDP..."
apt install -y xrdp

echo "Adding xRDP to ssl-cert group..."
adduser xrdp ssl-cert

echo "Configuring XFCE session..."
echo "xfce4-session" > /etc/skel/.xsession

sed -i.bak '/^exec /d' /etc/xrdp/startwm.sh
grep -q startxfce4 /etc/xrdp/startwm.sh || echo "startxfce4" >> /etc/xrdp/startwm.sh

echo "Fixing black screen issue..."
mkdir -p /etc/polkit-1/localauthority/50-local.d
cat <<EOF >/etc/polkit-1/localauthority/50-local.d/46-allow-colord.pkla
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.*
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

echo "Setting RDP port to 3390..."
sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini

echo "Configuring firewall..."
ufw allow 3390/tcp || true
ufw --force enable || true

echo "Starting xRDP..."
systemctl enable xrdp
systemctl restart xrdp

echo "================================="
echo "INSTALL COMPLETE"
echo "RDP Port : 3390"
echo "Login    : Normal Ubuntu user"
echo "================================="

echo "Xrdp complete"
echo "Firefox install"
apt install
apt update
snap install firefox
echo "================================="
echo "Firefox Complete 🤗"
snap install tailscale
echo "Complete 🤗"
tailscale up
echo "Success 🤗"
