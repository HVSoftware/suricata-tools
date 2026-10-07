# Suricata Tools

Handige beheer- en analyse scripts voor Suricata IDS.

## Installatie

```bash
git clone <repo-url> suricata-tools
cd suricata-tools
./scripts/bootstrap.sh   # installeert jq + make (Debian/Ubuntu)
```

## Gebruik

```bash
make status      # serviced status + processen
make test        # configuratie-test (suricata -T)
make update      # regels updaten + herstart
make alerts      # live fast.log volgen
make eve         # laatste 50 alerts uit eve.json
make rules       # geladen/mislukte regels (laatste stats-event)
make talkers     # top 10 bron-IP's
make stats       # laatste stats-event (jq)
make restart     # service herstarten
make logs        # journalctl -f
```

Alle scripts zijn ook los uitvoerbaar, bijvoorbeeld:

```bash
./scripts/eve-alerts.sh
```

## Opties

| Variabele | Standaard | Gebruikt door |
|-----------|-----------|---------------|
| `EVE`     | `/var/log/suricata/eve.json` | eve-alerts, stats, top-talkers, rules-loaded |
| `TAIL`    | `20000` regels               | eve-alerts, stats, top-talkers, rules-loaded |

Grote `eve.json`-bestanden worden daarom niet volledig gelezen.

## Vereisten

- Suricata (Debian/Ubuntu: `sudo apt install suricata`)
- `jq`
- sudo-rechten voor service-/logcommands
