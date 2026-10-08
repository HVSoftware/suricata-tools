#!/usr/bin/env bash
set -euo pipefail

EVE="${EVE:-/var/log/suricata/eve.json}"
TAIL="${TAIL:-20000}"
TOP="${TOP:-10}"

if [[ ! -r "$EVE" ]]; then
  echo "Cannot read $EVE (does Suricata / the Eve log exist?)" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed. Install it (e.g. sudo apt install jq)." >&2
  exit 1
fi

alerts=$(tail -n "$TAIL" "$EVE" \
  | jq -r 'select(.event_type=="alert" and .alert and .alert.signature) | .alert.signature' \
  | sort | uniq -c | sort -nr | head -n "$TOP")

if [[ -z "$alerts" ]]; then
  echo "No alert signatures found in the last $TAIL lines of $EVE"
  exit 0
fi

echo "$alerts"
