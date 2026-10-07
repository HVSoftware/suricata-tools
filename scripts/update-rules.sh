#!/usr/bin/env bash
set -euo pipefail

if ! command -v suricata-update >/dev/null 2>&1; then
  echo "suricata-update niet gevonden. Installeer Suricata eerst." >&2
  exit 1
fi

echo "[+] Updating rules"
sudo suricata-update

echo "[+] Restarting Suricata"
sudo systemctl restart suricata

echo "[+] Finished"