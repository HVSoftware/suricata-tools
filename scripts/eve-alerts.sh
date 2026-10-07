#!/usr/bin/env bash
set -euo pipefail

EVE="${EVE:-/var/log/suricata/eve.json}"
TAIL="${TAIL:-20000}"

if [[ ! -r "$EVE" ]]; then
  echo "Kan $EVE niet lezen (bestaat Suricata / EVE-log wel?)" >&2
  exit 1
fi

alerts=$(tail -n "$TAIL" "$EVE" | grep '"event_type":"alert"' || true)

if [[ -z "$alerts" ]]; then
  echo "Geen alerts gevonden in de laatste $TAIL regels van $EVE"
  exit 0
fi

echo "$alerts" | tail -50 \
  | jq -c '{timestamp, src_ip, src_port, dst_ip, dst_port, signature: .alert.signature, severity: .alert.severity}'
