#!/usr/bin/env bash
set -euo pipefail

CONFIG="${CONFIG:-/etc/suricata/suricata.yaml}"

if [[ ! -r "$CONFIG" ]]; then
  echo "Kan $CONFIG niet lezen" >&2
  exit 1
fi

sudo suricata -T -c "$CONFIG"
