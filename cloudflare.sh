#!/bin/bash
set -e

read -rp "Enter Cloudflare Tunnel Token: " TOKEN

curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/cloudflare.gpg] https://pkg.cloudflare.com/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/cloudflare.list

apt update
apt install -y cloudflared

cloudflared service install "$TOKEN"
