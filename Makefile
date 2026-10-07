.PHONY: help status test update alerts eve rules talkers stats restart logs bootstrap

help: ## Toon dit overzicht
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

status: ## Servicestatus + processen
	./scripts/status.sh

test: ## Configuratie-test
	./scripts/test-config.sh

update: ## Regels updaten + herstart
	./scripts/update-rules.sh

alerts: ## Live fast.log volgen
	./scripts/alerts.sh

eve: ## Laatste 50 alerts uit eve.json
	./scripts/eve-alerts.sh

rules: ## Geladen regels (laatste stats-event)
	./scripts/rules-loaded.sh

talkers: ## Top 10 bron-IP's
	./scripts/top-talkers.sh

stats: ## Laatste stats-event
	./scripts/stats.sh

restart: ## Service herstarten
	sudo systemctl restart suricata

logs: ## Levensecht loggen
	sudo journalctl -u suricata -f

bootstrap: ## Dependencies installeren
	./scripts/bootstrap.sh