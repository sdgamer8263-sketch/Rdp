#!/bin/bash
set -e

apt update
apt install -y xfce4 xfce4-goodies dbus-x11 xrdp

echo "startxfce4" > /etc/skel/.xsession
sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini

systemctl enable xrdp
systemctl restart xrdp
