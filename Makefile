# =============================================================================
# Makefile — Hermes MEP Drawing Review Platform
# =============================================================================

.PHONY: help up down logs shell status pull init clean

COMPOSE := docker compose
SERVICE := hermes

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	 awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

up: ## Start the Hermes platform (detached)
	$(COMPOSE) up -d
	@echo "✅ Hermes running on http://localhost:6789"
	@echo "📁 Workspace mounted at ./workspace"

down: ## Stop and remove containers
	$(COMPOSE) down

logs: ## Tail Hermes logs
	$(COMPOSE) logs -f $(SERVICE)

shell: ## Open a shell inside the Hermes container
	$(COMPOSE) exec $(SERVICE) bash

status: ## Check container status
	$(COMPOSE) ps
	$(COMPOSE) exec $(SERVICE) curl -s http://localhost:6789/health || true

pull: ## Pull latest Hermes image
	$(COMPOSE) pull $(SERVICE)

init: ## Bootstrap workspace and .env from template
	@test -f .env || cp .env.example .env
	@mkdir -p workspace skills
	@echo "✅ Initialized. Edit .env with your API keys, then run 'make up'"

clean: ## Stop, remove containers, and purge named volumes (⚠️ destroys Hermes data)
	$(COMPOSE) down -v
	@echo "🧹 Cleaned. Run 'make init' to start fresh."