#!/usr/bin/env bash
set -euo pipefail

EVE="${EVE:-/var/log/suricata/eve.json}"
FAST="${FAST:-/var/log/suricata/fast.log}"
CONFIG="${CONFIG:-/etc/suricata/suricata.yaml}"

required_failures=0

pass() {
  local message="$1"
  printf 'PASS: %s\n' "$message"
}

fail_required() {
  local message="$1"
  printf 'FAIL: %s\n' "$message"
  required_failures=$((required_failures + 1))
}

fail_warning() {
  local message="$1"
  printf 'FAIL: %s (warning only)\n' "$message"
}

if command -v suricata >/dev/null 2>&1; then
  version="$(suricata --version 2>/dev/null || true)"
  version="${version%%$'\n'*}"
  if [[ -n "$version" ]]; then
    pass "suricata binary present ($version)"
  else
    fail_required "suricata binary present (unable to read version)"
  fi
else
  fail_required "suricata binary present"
fi

if command -v jq >/dev/null 2>&1; then
  pass "jq present"
else
  fail_required "jq present"
fi

if systemctl is-active --quiet suricata; then
  pass "service active (suricata)"
else
  state="$(systemctl is-active suricata 2>/dev/null || true)"
  state="${state:-unknown}"
  fail_required "service active (suricata: $state)"
fi

if [[ -r "$EVE" ]]; then
  pass "EVE log readable ($EVE)"
else
  fail_required "EVE log readable ($EVE)"
fi

if [[ -r "$FAST" ]]; then
  pass "FAST log readable ($FAST)"
else
  fail_required "FAST log readable ($FAST)"
fi

if [[ -r "$CONFIG" ]]; then
  pass "CONFIG readable ($CONFIG)"
else
  fail_required "CONFIG readable ($CONFIG)"
fi

if command -v suricata-update >/dev/null 2>&1; then
  pass "suricata-update present"
else
  fail_warning "suricata-update present"
fi

if (( required_failures > 0 )); then
  exit 1
fi
