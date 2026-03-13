# setup-vibe-kanban

> **Author:** Viact Team — Daniel Le
> **Version:** 2.0.0

A Claude Code skill that automates the full setup of a **Vibe Kanban** Docker
environment — from zero to a running stack — in either **Local** or **Shared
Workstation** mode.

---

## What this skill does

- Checks prerequisites (Docker, Git) silently before asking anything
- Detects if the stack is already running and offers Restart / Stop / Reinstall
- Pulls pre-built images (`thanhlcm90/vibe-kanban-remote-server`, `thanhlcm90/vibe-kanban`)
- Generates all required config files: `.env`, `docker-compose.yml`, and (Shared mode) `Caddyfile`
- Auto-generates secrets with no special characters (safe for all env parsers)
- Starts the full stack with `docker compose up -d`
- Provides a post-setup guide for OAuth credentials and DNS setup

---

## Installation

### Auto install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/daniel-viact/viact-skills/main/install.sh | bash
```

### Manual install

**Step 1** — Download the command file:

```bash
curl -fsSL https://raw.githubusercontent.com/daniel-viact/viact-skills/main/SKILL.md \
  -o ~/.claude/commands/setup-vibe-kanban.md
```

Or clone the repo and copy:

```bash
git clone https://github.com/daniel-viact/viact-skills.git
cd viact-skills
mkdir -p ~/.claude/commands
cp SKILL.md ~/.claude/commands/setup-vibe-kanban.md
```

**Step 2** — Verify the file is in place:

```bash
ls ~/.claude/commands/setup-vibe-kanban.md
```

That's it. Claude Code will pick up the command automatically.

### Uninstall

```bash
# Using the install script
./install.sh --uninstall

# Or manually
rm ~/.claude/commands/setup-vibe-kanban.md
```

---

## Usage

After installing, trigger via slash command or natural language:

```
/setup-vibe-kanban
```

Or say any of:

- `"setup vibe kanban"`
- `"install vibe kanban docker"`
- `"setup kanban shared workstation"`
- `"deploy vibe kanban for my team"`

Claude will run the full setup flow interactively.

---

## Modes

| Mode | Description |
|------|-------------|
| **Local** | Single Kanban board on your own device. Access at `localhost:3000`. |
| **Shared Workstation** | One board per team member on a shared server, served via Caddy at `kanban-{name}.{domain}`. |

---

## Setup flow

```
Banner
  │
  ▼
Step 0 — Check Prerequisites (Docker + Git) — silent
  │
  ▼
Step 1 — Detect Existing Installation
  │
  ├─ Running    → Restart / Stop / Reinstall / Cancel
  ├─ Stopped    → Start / Reinstall / Cancel
  └─ Fresh      ──────────────────────────────────────────┐
                                                          │
Step 2 — Gather config (one question at a time)  ◀───────┘
  Mode → Install dir → (Shared) Domain + Team members
  │
Step 3 — Pull thanhlcm90/vibe-kanban-remote-server:latest
Step 4 — Pull thanhlcm90/vibe-kanban:latest
Step 5 — Generate .env + secrets
Step 6 — Create caddy-net network (Shared only)
Step 7 — Generate Caddyfile (Shared only)
Step 8 — Generate docker-compose.yml
Step 9 — docker compose up -d
Step 10 — Post-setup guide (OAuth + DNS)
```

---

## Files generated

| File | Modes | Purpose |
|------|-------|---------|
| `.env` | Both | Auto-generated secrets + credential placeholders |
| `docker-compose.yml` | Both | Full service stack |
| `Caddyfile` | Shared only | Reverse proxy with SSL + WebSocket support |

---

## After setup

Fill in the placeholder values in `.env`, then restart:

```bash
cd ~/vibe-kanban
docker compose down
docker compose up -d
```

| Variable | Where to get it |
|----------|----------------|
| `GOOGLE_OAUTH_CLIENT_ID/SECRET` | [Google Cloud Console](https://console.cloud.google.com/apis/credentials) → APIs → Credentials |
| `GITHUB_OAUTH_CLIENT_ID/SECRET` | GitHub → Settings → Developer settings → OAuth Apps |
| `GITHUB_TOKEN` | GitHub → Settings → Developer settings → Fine-grained tokens |
| `ANTHROPIC_API_KEY` | [console.anthropic.com](https://console.anthropic.com/settings/api-keys) → API Keys |

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

**Port already in use:** The skill auto-detects occupied ports and skips them.

**Caddy SSL issues:** Ensure ports 80 and 443 are open on your firewall.

**WebSocket disconnects:** Verify the `(websocket_headers)` snippet is in your Caddyfile.

**Stack not detected:** If `docker inspect` cannot find the working dir label,
the skill falls back to `~/vibe-kanban`.
