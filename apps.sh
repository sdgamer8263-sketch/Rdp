#!/bin/bash
set -e

if command -v snap >/dev/null; then
  snap install firefox
  snap install chromium
  snap install opera
else
  apt install -y firefox-esr chromium
fi
