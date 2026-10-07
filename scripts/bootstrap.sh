#!/usr/bin/env bash
set -euo pipefail

echo "[+] Updating packages"
sudo apt-get update

echo "[+] Installing dependencies"
sudo apt-get install -y jq make

echo "[+] Done"