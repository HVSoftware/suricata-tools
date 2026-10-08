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

talkers=$(tail -n "$TAIL" "$EVE" \
  | jq -r 'select(.src_ip) | .src_ip' \
  | sort | uniq -c | sort -nr | head -n "$TOP" || true)

if [[ -z "$talkers" ]]; then
  echo "No source IPs found in the last $TAIL lines of $EVE"
  exit 0
fi

echo "$talkers"
