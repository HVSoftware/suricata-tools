#!/usr/bin/env bash
set -euo pipefail

FAST="${FAST:-/var/log/suricata/fast.log}"

if [[ ! -r "$FAST" ]]; then
  echo "Cannot read $FAST (does Suricata / fast.log exist?)" >&2
  exit 1
fi

exec sudo tail -F "$FAST"
