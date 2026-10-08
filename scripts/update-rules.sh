#!/usr/bin/env bash
set -euo pipefail

CONFIG="${CONFIG:-/etc/suricata/suricata.yaml}"

if ! command -v suricata-update >/dev/null 2>&1; then
  echo "suricata-update not found. Install Suricata first." >&2
  exit 1
fi

if [[ ! -r "$CONFIG" ]]; then
  echo "Cannot read $CONFIG" >&2
  exit 1
fi

echo "[+] Updating rules"
sudo suricata-update

echo "[+] Validating Suricata config and rules"
if ! sudo suricata -T -c "$CONFIG"; then
  echo "Validation failed; not restarting Suricata. Existing instance left untouched." >&2
  exit 1
fi

echo "[+] Restarting Suricata"
sudo systemctl restart suricata

echo "[+] Finished"