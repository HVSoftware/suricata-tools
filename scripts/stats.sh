#!/usr/bin/env bash
set -euo pipefail

EVE="${EVE:-/var/log/suricata/eve.json}"
TAIL="${TAIL:-20000}"

if [[ ! -r "$EVE" ]]; then
  echo "Kan $EVE niet lezen (bestaat Suricata / EVE-log wel?)" >&2
  exit 1
fi

stats=$(tail -n "$TAIL" "$EVE" | grep '"event_type":"stats"' | tail -1 || true)

if [[ -z "$stats" ]]; then
  echo "Geen stats-event gevonden in de laatste $TAIL regels van $EVE"
  exit 0
fi

echo "$stats" | jq '{timestamp, uptime: .stats.uptime, detect: .stats.detect}'
