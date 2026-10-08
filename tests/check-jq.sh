#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVE_FILE="$ROOT_DIR/testdata/eve.json"

assert_script() {
  local script="$1"
  local expected="$2"
  local actual

  actual=$(EVE="$EVE_FILE" bash "$script")

  if ! diff -u <(printf '%s\n' "$expected") <(printf '%s\n' "$actual"); then
    echo "[FAIL] $(basename "$script")" >&2
    exit 1
  fi

  echo "[PASS] $(basename "$script")"
}

assert_script "$ROOT_DIR/scripts/eve-alerts.sh" '{"timestamp":"2024-05-01T00:00:00.123456+00:00","src_ip":"10.0.0.5","src_port":1234,"dst_ip":"192.168.1.10","dst_port":80,"signature":"ET TROJAN Suspicious User-Agent","severity":1}
{"timestamp":"2024-05-01T00:00:10.123456+00:00","src_ip":"10.0.0.5","src_port":1234,"dst_ip":"192.168.1.11","dst_port":443,"signature":"ET TROJAN Suspicious User-Agent","severity":1}
{"timestamp":"2024-05-01T00:01:00.123456+00:00","src_ip":"10.0.0.7","src_port":4321,"dst_ip":"192.168.1.12","dst_port":80,"signature":"ET SCAN Nmap Scripting Engine","severity":2}'

assert_script "$ROOT_DIR/scripts/stats.sh" '{
  "timestamp": "2024-05-01T00:02:00.123456+00:00",
  "uptime": 1234,
  "detect": {
    "rules_loaded": 42,
    "rules_failed": 3
  }
}'

assert_script "$ROOT_DIR/scripts/rules-loaded.sh" '{
  "rules_loaded": 42,
  "rules_failed": 3
}'

# top-talkers counts every event with a src_ip: 10.0.0.5 has 3 total records
# (2 alert records + 1 flow record), 10.0.0.9 has 2 flow records, and
# 10.0.0.7 has 1 alert record.
assert_script "$ROOT_DIR/scripts/top-talkers.sh" '      3 10.0.0.5
      2 10.0.0.9
      1 10.0.0.7'

assert_script "$ROOT_DIR/scripts/top-attackers.sh" '      2 10.0.0.5
      1 10.0.0.7'

assert_script "$ROOT_DIR/scripts/top-alerts.sh" '      2 ET TROJAN Suspicious User-Agent
      1 ET SCAN Nmap Scripting Engine'

assert_script "$ROOT_DIR/scripts/top-dns.sh" '      2 example.com
      1 github.com'

assert_script "$ROOT_DIR/scripts/top-tls.sh" '      2 api.example.com
      1 login.example.com'

echo "All jq fixture checks passed."
