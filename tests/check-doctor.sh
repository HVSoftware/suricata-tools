#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCTOR_SCRIPT="$ROOT_DIR/scripts/doctor.sh"

assert_output_contains() {
  local output="$1"
  local needle="$2"

  if ! grep -Fq "$needle" <<<"$output"; then
    echo "[FAIL] Expected output to contain: $needle" >&2
    echo "$output" >&2
    exit 1
  fi
}

create_common_files() {
  local work_dir="$1"
  touch "$work_dir/eve.json" "$work_dir/fast.log" "$work_dir/suricata.yaml"
}

create_fake_suricata() {
  local bin_dir="$1"
  cat >"$bin_dir/suricata" <<'EOF'
#!/usr/bin/bash
if [[ "${1:-}" == "--version" ]]; then
  echo "suricata 7.0.0 RELEASE"
  exit 0
fi
exit 0
EOF
}

create_fake_systemctl() {
  local bin_dir="$1"
  cat >"$bin_dir/systemctl" <<'EOF'
#!/usr/bin/bash
if [[ "${1:-}" == "is-active" && "${2:-}" == "--quiet" ]]; then
  exit "${SYSTEMCTL_ACTIVE_EXIT:-0}"
fi
if [[ "${1:-}" == "is-active" ]]; then
  echo "${SYSTEMCTL_ACTIVE_TEXT:-active}"
  exit "${SYSTEMCTL_ACTIVE_EXIT:-0}"
fi
exit 0
EOF
}

create_stub_command() {
  local bin_dir="$1"
  local name="$2"
  cat >"$bin_dir/$name" <<'EOF'
#!/usr/bin/bash
exit 0
EOF
}

run_doctor() {
  local bin_dir="$1"
  local work_dir="$2"
  set +e
  output="$(
    PATH="$bin_dir" \
    EVE="$work_dir/eve.json" \
    FAST="$work_dir/fast.log" \
    CONFIG="$work_dir/suricata.yaml" \
    /usr/bin/bash "$DOCTOR_SCRIPT" 2>&1
  )"
  status=$?
  set -e
}

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

# Scenario 1: all required + optional checks pass.
bin_ok="$tmp_dir/bin-ok"
work_ok="$tmp_dir/work-ok"
mkdir -p "$bin_ok" "$work_ok"
create_common_files "$work_ok"
create_fake_suricata "$bin_ok"
create_fake_systemctl "$bin_ok"
create_stub_command "$bin_ok" jq
create_stub_command "$bin_ok" suricata-update
chmod +x "$bin_ok"/*

run_doctor "$bin_ok" "$work_ok"
if [[ "$status" -ne 0 ]]; then
  echo "[FAIL] doctor should succeed when all required checks pass." >&2
  echo "$output" >&2
  exit 1
fi
assert_output_contains "$output" "PASS: suricata binary present (suricata 7.0.0 RELEASE)"
assert_output_contains "$output" "PASS: jq present"
assert_output_contains "$output" "PASS: service active (suricata)"
assert_output_contains "$output" "PASS: EVE log readable ($work_ok/eve.json)"
assert_output_contains "$output" "PASS: FAST log readable ($work_ok/fast.log)"
assert_output_contains "$output" "PASS: CONFIG readable ($work_ok/suricata.yaml)"
assert_output_contains "$output" "PASS: suricata-update present"

# Scenario 2: missing jq should fail.
bin_no_jq="$tmp_dir/bin-no-jq"
work_no_jq="$tmp_dir/work-no-jq"
mkdir -p "$bin_no_jq" "$work_no_jq"
create_common_files "$work_no_jq"
create_fake_suricata "$bin_no_jq"
create_fake_systemctl "$bin_no_jq"
create_stub_command "$bin_no_jq" suricata-update
chmod +x "$bin_no_jq"/*

run_doctor "$bin_no_jq" "$work_no_jq"
if [[ "$status" -eq 0 ]]; then
  echo "[FAIL] doctor should fail when jq is missing." >&2
  echo "$output" >&2
  exit 1
fi
assert_output_contains "$output" "FAIL: jq present"

# Scenario 3: missing suricata-update should be warning-only.
bin_no_update="$tmp_dir/bin-no-update"
work_no_update="$tmp_dir/work-no-update"
mkdir -p "$bin_no_update" "$work_no_update"
create_common_files "$work_no_update"
create_fake_suricata "$bin_no_update"
create_fake_systemctl "$bin_no_update"
create_stub_command "$bin_no_update" jq
chmod +x "$bin_no_update"/*

run_doctor "$bin_no_update" "$work_no_update"
if [[ "$status" -ne 0 ]]; then
  echo "[FAIL] doctor should pass when only suricata-update is missing." >&2
  echo "$output" >&2
  exit 1
fi
assert_output_contains "$output" "FAIL: suricata-update present (warning only)"

echo "doctor checks passed."
