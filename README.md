# Hermes MEP Drawing Review Platform

Docker-based deployment of [Hermes Agent](https://github.com/NousResearch/hermes-agent) tailored for **engineering drawing review workflows** — HVAC, Plumbing, Firefighting, and Medical Gas systems in healthcare, commercial, and industrial facilities.

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/YOURNAME/hermes-mep-review.git
cd hermes-mep-review

# 2. Bootstrap environment
make init        # creates .env from template + workspace/ dirs

# 3. Add your API keys to .env (OpenRouter, OpenAI, Anthropic — pick one)
nano .env

# 4. Launch
make up

# 5. Open shell to interact
make shell
```

Hermes Agent UI: http://localhost:6789

## Platform Structure

```
.
├── docker-compose.yml      # Hermes container + optional services
├── Makefile                # Common operations (up, down, logs, shell)
├── .env.example            # Template for secrets & config
├── workspace/              # Shared volume for drawings, PDFs, reviews
└── skills/                 # Custom Hermes skills (mounted read-only)
```

## Makefile Commands

| Command | What it does |
|---------|-------------|
| `make up` | Start Hermes in background |
| `make down` | Stop containers |
| `make logs` | Tail live logs |
| `make shell` | Bash inside the Hermes container |
| `make status` | Container health & port check |
| `make pull` | Update to latest Hermes image |
| `make init` | First-time setup (.env + dirs) |
| `make clean` | **Destructive** — removes containers + named volume |

## Workflow

1. **Drop drawings** into `workspace/` (PDFs, DWG exports, screenshots).
2. **Enter container**: `make shell` → Hermes sees files at `/workspace`.
3. **Run reviews**: Use Hermes skills (e.g. `mep-drawing-review`) to annotate, check ASHRAE compliance, generate stamp sheets, or build custom tools.
4. **Persist output**: Results saved in `workspace/` appear instantly on your host.

## Spotty Internet / Offline

The container caches skills and memory in `hermes_data` volume. For fully offline inference, pair with a local LLM server (Ollama, vLLM, llama.cpp) and set `OLLAMA_BASE_URL` in `.env`.

## Custom Skills

Drop `.md` skill files into `skills/` — they mount read-only into `/root/.hermes/skills/` at runtime. Restart container to load new skills: `make down && make up`.

## License

MIT