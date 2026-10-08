.PHONY: help status test lint update alerts eve rules talkers stats restart logs bootstrap install uninstall

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
BIN_DIR ?= /usr/local/bin

install: ## Symlink scripts into $(BIN_DIR)
	sudo mkdir -p "$(BIN_DIR)"
	sudo ln -sf "$(CURDIR)/scripts/status.sh" "$(BIN_DIR)/suricata-status"
	sudo ln -sf "$(CURDIR)/scripts/test-config.sh" "$(BIN_DIR)/suricata-test"
	sudo ln -sf "$(CURDIR)/scripts/update-rules.sh" "$(BIN_DIR)/suricata-update"
	sudo ln -sf "$(CURDIR)/scripts/alerts.sh" "$(BIN_DIR)/suricata-alerts"
	sudo ln -sf "$(CURDIR)/scripts/eve-alerts.sh" "$(BIN_DIR)/suricata-eve"
	sudo ln -sf "$(CURDIR)/scripts/rules-loaded.sh" "$(BIN_DIR)/suricata-rules"
	sudo ln -sf "$(CURDIR)/scripts/top-talkers.sh" "$(BIN_DIR)/suricata-talkers"
	sudo ln -sf "$(CURDIR)/scripts/stats.sh" "$(BIN_DIR)/suricata-stats"

uninstall: ## Remove symlinked scripts from $(BIN_DIR)
	sudo rm -f "$(BIN_DIR)/suricata-status"
	sudo rm -f "$(BIN_DIR)/suricata-test"
	sudo rm -f "$(BIN_DIR)/suricata-update"
	sudo rm -f "$(BIN_DIR)/suricata-alerts"
	sudo rm -f "$(BIN_DIR)/suricata-eve"
	sudo rm -f "$(BIN_DIR)/suricata-rules"
	sudo rm -f "$(BIN_DIR)/suricata-talkers"
	sudo rm -f "$(BIN_DIR)/suricata-stats"
