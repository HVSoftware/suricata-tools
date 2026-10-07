#!/usr/bin/env bash
set -euo pipefail

FAST="${FAST:-/var/log/suricata/fast.log}"

if [[ ! -r "$FAST" ]]; then
  echo "Kan $FAST niet lezen (bestaat Suricata / fast-log wel?)" >&2
  exit 1
fi

exec sudo tail -F "$FAST"
