#!/usr/bin/env bash
set -euo pipefail

EVE="${EVE:-/var/log/suricata/eve.json}"
TAIL="${TAIL:-20000}"
TOP="${TOP:-10}"

if [[ ! -r "$EVE" ]]; then
  echo "Kan $EVE niet lezen (bestaat Suricata / EVE-log wel?)" >&2
  exit 1
fi

talkers=$(tail -n "$TAIL" "$EVE" \
  | jq -r 'select(.src_ip) | .src_ip' \
  | sort | uniq -c | sort -nr | head -n "$TOP" || true)

if [[ -z "$talkers" ]]; then
  echo "Geen bron-IP's gevonden in de laatste $TAIL regels van $EVE"
  exit 0
fi

echo "$talkers"
