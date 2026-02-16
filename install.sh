#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# ===============================
# AUTO SUDO
# ===============================
if [ "$EUID" -ne 0 ]; then
  echo "Re-running with sudo..."
  exec sudo bash "$0"
fi

clear

# ===============================
# BANNER
# ===============================
cat <<'EOF'
███████╗██████╗ ██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ███╗███████╗██████╗
██╔════╝██╔══██╗██║  ██║██╔══██╗██╔════╝██╔══██╗████╗ ████║██╔════╝██╔══██╗
███████╗██║  ██║███████║███████║█████╗  ███████║██╔████╔██║█████╗  ██████╔╝
╚════██║██║  ██║██╔══██║██╔══██║██╔══╝  ██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗
███████║██████╔╝██║  ██║██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗██║  ██║
╚══════╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝

              SDHGAMER
              SKA HOSTING
   XRDP + VNC + XFCE + FIREFOX + TAILSCALE
EOF

echo "================================="

# ===============================
# OS DETECT
# ===============================
OS_ID=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
OS_VER=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | tr -d '"')

echo "Detected OS : $OS_ID $OS_VER"
echo "================================="

if [[ "$OS_ID" != "ubuntu" && "$OS_ID" != "debian" ]]; then
  echo "❌ Unsupported OS"
  exit 1
fi

# ===============================
# SYSTEM UPDATE
# ===============================
apt update -y
apt -y -o Dpkg::Options::="--force-confnew" full-upgrade || true
dpkg --configure -a || true

# ===============================
# INSTALL BASE PACKAGES
# ===============================
apt install -y xfce4 xfce4-goodies xrdp tigervnc-standalone-server dbus-x11 curl ufw

# ===============================
# XRDP CONFIG (PORT 3389)
# ===============================
sed -i 's/^port=.*/port=3389/' /etc/xrdp/xrdp.ini
echo "xfce4-session" > /etc/skel/.xsession

sed -i '/^exec /d' /etc/xrdp/startwm.sh
cat <<EOF >> /etc/xrdp/startwm.sh
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
exec startxfce4 &
EOF

systemctl enable xrdp
systemctl restart xrdp

# ===============================
# BLACK SCREEN FIX
# ===============================
mkdir -p /etc/polkit-1/localauthority/50-local.d
cat <<EOF >/etc/polkit-1/localauthority/50-local.d/46-allow-colord.pkla
[Allow Colord]
Identity=unix-user:*
Action=org.freedesktop.color-manager.*
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

# ===============================
# VNC SETUP (AUTO START)
# ===============================
mkdir -p /etc/vnc
cat <<EOF >/etc/vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4 &
EOF
chmod +x /etc/vnc/xstartup

cat <<EOF >/etc/systemd/system/vncserver@.service
[Unit]
Description=TigerVNC Server
After=network.target

[Service]
Type=forking
User=%i
ExecStart=/usr/bin/vncserver -xstartup /etc/vnc/xstartup :1
ExecStop=/usr/bin/vncserver -kill :1

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable vncserver@root.service
systemctl start vncserver@root.service

# ===============================
# FIREFOX
# ===============================
if [ "$OS_ID" = "ubuntu" ]; then
  echo "Installing Firefox via SNAP (Ubuntu)"
  snap install firefox
else
  echo "Installing Firefox via APT (Debian)"
  apt install -y firefox-esr
fi

# ===============================
# TAILSCALE (AS YOU ASKED)
# ===============================
echo "Installing Tailscale..."

if [ "$OS_ID" = "ubuntu" ]; then
  echo "Ubuntu → snap install tailscale"
  snap install tailscale
else
  echo "Debian → apt install tailscale"
  apt install -y tailscale
fi

systemctl enable tailscaled
systemctl start tailscaled

echo "Running tailscale up..."
tailscale up || true

# ===============================
# FIREWALL
# ===============================
ufw allow 3389/tcp || true
ufw allow 5901/tcp || true
ufw --force enable || true

# ===============================
# DONE
# ===============================
echo "================================="
echo "✅ INSTALL COMPLETE"
echo "OS   : $OS_ID $OS_VER"
echo "RDP  : 3389"
echo "VNC  : 5901"
echo "================================="
