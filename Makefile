# =============================================================================
# Makefile — Hermes MEP Drawing Review Platform (with Ollama)
# =============================================================================

.PHONY: help up down logs shell ollama-shell status pull init clean model-pull model-list

COMPOSE := docker compose
SERVICE := hermes

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	 awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

up: ## Start Hermes + Ollama (detached)
	$(COMPOSE) up -d
	@echo "✅ Hermes running on http://localhost:6789"
	@echo "🧠 Ollama running on http://localhost:11434"
	@echo "📁 Workspace mounted at ./workspace"

down: ## Stop and remove containers
	$(COMPOSE) down

logs: ## Tail Hermes logs
	$(COMPOSE) logs -f $(SERVICE)

logs-ollama: ## Tail Ollama logs
	$(COMPOSE) logs -f ollama

shell: ## Open a shell inside the Hermes container
	$(COMPOSE) exec $(SERVICE) bash

ollama-shell: ## Open a shell inside the Ollama container
	$(COMPOSE) exec ollama bash

status: ## Check container status
	$(COMPOSE) ps
	@echo "---"
	@$(COMPOSE) exec $(SERVICE) curl -s http://localhost:6789/health 2>/dev/null || true

pull: ## Pull latest images
	$(COMPOSE) pull

model-pull: ## Pull the configured Ollama model
	@echo "Pulling $(OLLAMA_MODEL) ..."
	$(COMPOSE) exec ollama ollama pull $(OLLAMA_MODEL)

model-list: ## List models available in Ollama
	$(COMPOSE) exec ollama ollama list

init: ## Bootstrap workspace and .env from template
	@test -f .env || cp .env.example .env
	@mkdir -p workspace skills
	@echo "✅ Initialized. Edit .env, then run 'make up && make model-pull'"

clean: ## Stop, remove containers, and purge named volumes (⚠️ destroys data)
	$(COMPOSE) down -v
	@echo "🧹 Cleaned. Run 'make init' to start fresh."
