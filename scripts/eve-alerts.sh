#!/usr/bin/env bash
set -euo pipefail

EVE="${EVE:-/var/log/suricata/eve.json}"
TAIL="${TAIL:-20000}"

if [[ ! -r "$EVE" ]]; then
  echo "Cannot read $EVE (does Suricata / the Eve log exist?)" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed. Install it (e.g. sudo apt install jq)." >&2
  exit 1
fi

alerts=$(tail -n "$TAIL" "$EVE" | grep '"event_type":"alert"' || true)

if [[ -z "$alerts" ]]; then
  echo "No alerts found in the last $TAIL lines of $EVE"
  exit 0
fi

echo "$alerts" | tail -50 \
  | jq -c '{timestamp, src_ip, src_port, dst_ip, dst_port, signature: .alert.signature, severity: .alert.severity}'
