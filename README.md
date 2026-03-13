# setup-vibe-kanban

> **Author:** Viact Team — Daniel Le
> **Version:** 1.0.0

A skill that guides Claude through setting up a complete **Vibe Kanban** isolated
Docker environment (Vibe Kanban + Claude Code + GitHub) in either Local or
Shared Workstation mode.

---

## What this skill does

- Checks and installs prerequisites (Docker, Git)
- Clones and builds the Vibe Kanban remote server image
- Builds the desktop client Docker image with Claude Code + GitHub CLI pre-installed
- Generates all required config files: `.env`, `Dockerfile`, `entrypoint.sh`,
  `docker-compose.yml`, and (for Shared mode) `Caddyfile`
- Auto-generates secrets (JWT, DB, ElectricSQL passwords)
- Starts the full stack with `docker compose up -d`
- Provides a comprehensive post-setup guide for OAuth credentials

---

## Modes

| Mode | Description |
|------|-------------|
| **Local** | Runs on your own device. Single Kanban board, no Caddy reverse proxy. Access at `localhost:3000`. |
| **Shared Workstation** | Runs on a team server. One Kanban board per team member, served via Caddy at `kanban-{name}.{domain}`. |

---

## How to trigger

Just say any of:
- `"setup vibe kanban"`
- `"install vibe kanban docker"`
- `"setup kanban shared workstation"`
- `"deploy vibe kanban for my team"`

---

## Files generated

### Both modes
| File | Purpose |
|------|---------|
| `.env` | All environment variables (secrets auto-generated) |
| `Dockerfile` | Desktop client image with Node 22, Claude Code, GitHub CLI |
| `entrypoint.sh` | Container entrypoint that runs Vibe Kanban as `node` user |
| `docker-compose.yml` | Full service stack |

### Shared mode only
| File | Purpose |
|------|---------|
| `Caddyfile` | Reverse proxy config with SSL + WebSocket support |

---

## After setup

Fill in these values in your `.env` then restart:
```bash
cd ~/vibe-kanban
docker compose down
docker compose up -d
```

| Variable | Where to get it |
|----------|----------------|
| `GOOGLE_OAUTH_CLIENT_ID/SECRET` | Google Cloud Console → APIs → Credentials |
| `GITHUB_OAUTH_CLIENT_ID/SECRET` | GitHub → Settings → Developer settings → OAuth Apps |
| `GITHUB_TOKEN` | GitHub → Settings → Developer settings → Fine-grained tokens |
| `ANTHROPIC_API_KEY` | console.anthropic.com → API Keys |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Vibe Kanban Stack                  │
│                                                      │
│  ┌──────────┐   ┌──────────┐   ┌──────────────────┐ │
│  │  Caddy   │   │  Remote  │   │  Desktop Client  │ │
│  │ (Shared) │──▶│  Server  │──▶│  (per user)      │ │
│  └──────────┘   └────┬─────┘   └──────────────────┘ │
│                      │                               │
│               ┌──────┴──────┐                        │
│               │  ElectricSQL│                        │
│               │  + PostgreSQL│                       │
│               └─────────────┘                        │
└─────────────────────────────────────────────────────┘
```

---

## Troubleshooting

**Docker build fails:** Check internet connection and Docker daemon is running.

**Port already in use:** The skill auto-detects and skips occupied ports.

**Caddy SSL issues:** Ensure ports 80 and 443 are open on your firewall.

**WebSocket disconnects:** Verify the `(websocket_headers)` snippet is in your Caddyfile.
