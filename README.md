# Suricata Tools

Handy management and analysis scripts for Suricata IDS.

## Installation

```bash
git clone <repo-url> suricata-tools
cd suricata-tools
./scripts/bootstrap.sh   # installs jq + make (Debian/Ubuntu)
```

## Usage

```bash
make status      # service status + processes
make test        # configuration test (suricata -T)
make update      # update rules + restart
make alerts      # tail fast.log live
make eve         # last 50 alerts from eve.json
make rules       # loaded/failed rules (latest stats event)
make talkers     # top 10 source IPs
make stats       # last stats event (jq)
make restart     # restart the service
make logs        # journalctl -f
```

The scripts can also be run directly, e.g.:

```bash
./scripts/eve-alerts.sh
```

## Options

| Variable | Default                       | Used by                              |
|----------|-------------------------------|--------------------------------------|
| `EVE`    | `/var/log/suricata/eve.json`  | eve-alerts, stats, top-talkers, rules-loaded |
| `TAIL`   | `20000` lines                 | eve-alerts, stats, top-talkers, rules-loaded |
| `TOP`    | `10` (top-talkers)            | top-talkers                          |

Large `eve.json` files are therefore not read entirely.

## Requirements

- Suricata (Debian/Ubuntu: `sudo apt install suricata`)
- `jq`
- sudo rights for service/log commands