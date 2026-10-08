.PHONY: help status test lint update alerts eve rules talkers stats restart logs bootstrap

help: ## Show this overview
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

status: ## Service status + processes
	./scripts/status.sh

test: ## Configuration test
	./scripts/test-config.sh

lint: ## Bash syntax + shellcheck
	bash -n scripts/*.sh
	shellcheck -e SC2009 scripts/*.sh

update: ## Update rules + validate + restart
	./scripts/update-rules.sh

alerts: ## Tail fast.log live
	./scripts/alerts.sh

eve: ## Last 50 alerts from eve.json
	./scripts/eve-alerts.sh

rules: ## Loaded rules (latest stats event)
	./scripts/rules-loaded.sh

talkers: ## Top 10 source IPs
	./scripts/top-talkers.sh

stats: ## Last stats event
	./scripts/stats.sh

restart: ## Restart the service
	sudo systemctl restart suricata

logs: ## Stream service logs
	sudo journalctl -u suricata -f

bootstrap: ## Install dependencies
	./scripts/bootstrap.sh