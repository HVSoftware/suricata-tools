# Suricata Tools

[![CI](https://github.com/HVSoftware/suricata-tools/actions/workflows/lint.yml/badge.svg)](https://github.com/HVSoftware/suricata-tools/actions/workflows/lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

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
make update      # update rules + validate + restart
make alerts      # tail fast.log live
make eve         # last 50 alerts from eve.json
make rules       # loaded/failed rules (latest stats event)
make talkers     # top 10 source IPs
make attackers   # top 10 alert source IPs
make top-alerts  # top 10 alert signatures from eve.json
make dns         # top 10 queried domains
make tls         # top 10 TLS SNI values
make stats       # last stats event (jq)
make install     # symlink commands into /usr/local/bin
make uninstall   # remove symlinked commands
make restart     # restart the service
make logs        # journalctl -f
```

The scripts can also be run directly, e.g.:

```bash
./scripts/eve-alerts.sh
```

To run commands from anywhere, install symlinks into `/usr/local/bin`:

```bash
make install
suricata-eve
suricata-stats
```

Remove them again with:

```bash
make uninstall
```

## Options

| Variable | Default                       | Used by                                               |
|----------|-------------------------------|-------------------------------------------------------|
| `EVE`    | `/var/log/suricata/eve.json`  | eve-alerts, stats, top-talkers, top-attackers, top-alerts, dns, tls, rules-loaded |
| `TAIL`   | `20000` lines                 | eve-alerts, stats, top-talkers, top-attackers, top-alerts, dns, tls, rules-loaded |
| `TOP`    | `10`                          | top-talkers, top-attackers, top-alerts, dns, tls    |
| `SEV`    | unset                         | eve-alerts                                            |
| `SIP`    | unset                         | eve-alerts (`src_ip` only)                             |
| `SINCE`  | unset                         | eve-alerts (`s`, `m`, `h`, `d`, `w` units)             |

`SEV` keeps only alerts with severity less than or equal to the value (an integer such as `2`; lower numbers are more severe in Suricata). `SIP` filters to alerts whose `src_ip` matches a single source IP, and `SINCE` keeps only alerts newer than the given age such as `1h`, `30m`, `2d`, or `30s`.

Large `eve.json` files are therefore not read entirely.

## Requirements

- Suricata (Debian/Ubuntu: `sudo apt install suricata`)
- `jq`
- sudo rights for service/log commands

## Releases

This repository uses [Release Please](https://github.com/googleapis/release-please) on `main` to manage semantic versioning, tags (`vX.Y.Z`), `CHANGELOG.md`, and GitHub Releases.

Use Conventional Commits for changes:

- `feat:` → minor release
- `fix:` → patch release
- `feat!:` or `BREAKING CHANGE:` footer → major release

Scopes are recommended (for example: `feat(scripts): ...`).

When a PR closes an issue, include `Fixes: #N` in the PR description.