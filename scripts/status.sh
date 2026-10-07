#!/usr/bin/env bash
set -euo pipefail

echo "=== Service Status ==="
sudo systemctl status suricata --no-pager || true

echo
echo "=== Resource Usage ==="
ps aux | grep '[s]uricata' || echo "Geen suricata-processen gevonden"
