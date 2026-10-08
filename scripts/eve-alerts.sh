#!/usr/bin/env bash
set -euo pipefail

EVE="${EVE:-/var/log/suricata/eve.json}"
TAIL="${TAIL:-20000}"
SEV="${SEV:-}"
SIP="${SIP:-}"
SINCE="${SINCE:-}"

if [[ ! -r "$EVE" ]]; then
  echo "Cannot read $EVE (does Suricata / the Eve log exist?)" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed. Install it (e.g. sudo apt install jq)." >&2
  exit 1
fi

if [[ -n "$SEV" && ! "$SEV" =~ ^[0-9]+$ ]]; then
  echo "Invalid SEV value: $SEV" >&2
  exit 1
fi

if [[ -n "$SIP" && ! "$SIP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo "Invalid SIP value: $SIP" >&2
  exit 1
fi

filter_tmp=$(mktemp)
trap 'rm -f "$filter_tmp"' EXIT

if [[ -n "$SEV" || -n "$SIP" || -n "$SINCE" ]]; then
  tail -n "$TAIL" "$EVE" \
    | grep '"event_type":"alert"' \
    | SEV="$SEV" SIP="$SIP" SINCE="$SINCE" python3 -c 'import json, os, re, sys
from datetime import datetime, timezone

sev_limit = os.environ.get("SEV") or None
sip_filter = os.environ.get("SIP") or None
since_filter = os.environ.get("SINCE") or None

if sev_limit is not None:
    try:
        sev_limit = int(sev_limit)
    except ValueError as exc:
        raise SystemExit(f"Invalid SEV value: {sev_limit}") from exc

if since_filter is not None:
    match = re.fullmatch(r"(?i)(\d+)([smhdw])", since_filter)
    if match is None:
        raise SystemExit(f"Invalid SINCE value: {since_filter}")
    amount, unit = match.groups()
    seconds = {
        "s": 1,
        "m": 60,
        "h": 3600,
        "d": 86400,
        "w": 604800,
    }[unit.lower()]
    cutoff = datetime.now(timezone.utc).timestamp() - (int(amount) * seconds)
else:
    cutoff = None

for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    try:
        event = json.loads(line)
    except json.JSONDecodeError:
        continue
    if event.get("event_type") != "alert":
        continue
    if sev_limit is not None:
        severity = event.get("alert", {}).get("severity")
        if severity is None:
            continue
        try:
            severity = int(severity)
        except (TypeError, ValueError):
            continue
        if severity > sev_limit:
            continue
    if sip_filter is not None and event.get("src_ip") != sip_filter:
        continue
    if cutoff is not None:
        timestamp = event.get("timestamp")
        if not timestamp:
            continue
        try:
            dt = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            ts = dt.astimezone(timezone.utc).timestamp()
        except ValueError:
            continue
        if ts < cutoff:
            continue
    print(line)' > "$filter_tmp"
else
  tail -n "$TAIL" "$EVE" | grep '"event_type":"alert"' > "$filter_tmp"
fi

if [[ ! -s "$filter_tmp" ]]; then
  echo "No alerts found in the last $TAIL lines of $EVE"
  exit 0
fi

tail -50 "$filter_tmp" | jq -c '{timestamp, src_ip, src_port, dst_ip, dst_port, signature: .alert.signature, severity: .alert.severity}'
