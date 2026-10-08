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

stats=$(tail -n "$TAIL" "$EVE" | grep '"event_type":"stats"' | tail -1 || true)

if [[ -z "$stats" ]]; then
  echo "No stats event found in the last $TAIL lines of $EVE"
  exit 0
fi

echo "$stats" | jq '{timestamp, uptime: .stats.uptime, detect: .stats.detect}'
