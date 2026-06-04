# Hermes + Ollama — Engineering Drawing Review Platform

Docker-based deployment of [Hermes Agent](https://github.com/NousResearch/hermes-agent) with **Ollama** local inference, tailored for **engineering drawing review workflows** — HVAC, Plumbing, Firefighting, and Medical Gas systems.

## Architecture

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Hermes     │────▶│   Ollama     │────▶│  GPU / CPU   │
│   :6789      │     │  :11434      │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
        │
        ▼
┌──────────────┐
│  workspace/  │  ← your drawings, PDFs, reviews
└──────────────┘
```

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/Basilalsultan/engineering-drawing-review.git
cd engineering-drawing-review

# 2. Bootstrap environment
make init        # creates .env from template + workspace/ dirs

# 3. Edit .env — at minimum set OLLAMA_MODEL if you use a custom tag
nano .env

# 4. Launch everything
make up

# 5. Pull your model (first time only)
make model-pull

# 6. Open Hermes shell
make shell
```

Endpoints:
- **Hermes UI**: http://localhost:6789
- **Ollama API**: http://localhost:11434

## Makefile Commands

| Command | What it does |
|---------|-------------|
| `make up` | Start Hermes + Ollama in background |
| `make down` | Stop containers |
| `make logs` | Tail Hermes logs |
| `make logs-ollama` | Tail Ollama logs |
| `make shell` | Bash inside Hermes container |
| `make ollama-shell` | Bash inside Ollama container |
| `make status` | Container health checks |
| `make pull` | Update to latest images |
| `make model-pull` | Download the configured Ollama model |
| `make model-list` | Show installed Ollama models |
| `make init` | First-time setup (.env + dirs) |
| `make clean` | **Destructive** — removes containers + volumes |

## Ollama Model Management

```bash
# Pull a specific model
make model-pull              # uses OLLAMA_MODEL from .env

# Or manually inside the Ollama container
make ollama-shell
ollama pull gpt-oss:120b-cloud
ollama list
```

## Workflow

1. **Drop drawings** into `workspace/` (PDFs, DWG exports, screenshots).
2. **Enter Hermes**: `make shell` → files visible at `/workspace`.
3. **Run reviews**: Use Hermes skills (`mep-drawing-review`, `generate_stamp_sheet`, etc.) backed by your local Ollama model.
4. **Persist output**: Results saved in `workspace/` appear instantly on your host.

## Cloud Fallback

If you also want cloud providers (OpenRouter, OpenAI, Anthropic), add their keys to `.env`. Hermes will use whichever provider is configured in its active profile.

## GPU Support

Uncomment the `deploy.resources.reservations.devices` block in `docker-compose.yml` for the `ollama` service if you have NVIDIA Docker (nvidia-docker2) installed.

For CPU-only mode, set `OLLAMA_CPU_ONLY=1` in `.env` or uncomment it in `docker-compose.yml`.

## Custom Skills

Drop `.md` skill files into `skills/` — they mount read-only into `/root/.hermes/skills/`. Restart to reload: `make down && make up`.

## License

MIT
