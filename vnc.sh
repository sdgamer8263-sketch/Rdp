#!/bin/bash
set -e

apt update
apt install -y tigervnc-standalone-server xfce4 xfce4-goodies

mkdir -p /root/.vnc
echo -e "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4 &" > /root/.vnc/xstartup
chmod +x /root/.vnc/xstartup

printf "root\nroot\nn\n" | vncpasswd
vncserver :1
