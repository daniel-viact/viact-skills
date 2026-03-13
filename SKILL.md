---
name: setup-vibe-kanban
description: |
  Guides users through setting up a complete Vibe Kanban isolated environment
  on Docker (Vibe Kanban + Claude Code + GitHub integration).
  Trigger when user says: "setup vibe kanban", "install vibe kanban",
  "configure kanban docker", "vibe kanban docker setup", "setup kanban environment",
  "deploy vibe kanban", "vibe kanban shared workstation", "kanban local setup",
  or any request to install/configure the Vibe Kanban stack.
---

# Goal

Automate the full setup of a Vibe Kanban Docker environment — from zero to a
running Kanban stack connected to a shared remote server — in either **Local**
or **Shared Workstation** mode, with all config files generated automatically.

---

# Introduction

Display this welcome banner at the very start:

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║        🚀  Vibe Kanban — Docker Environment Setup                ║
║                                                                  ║
║   Vibe Kanban + Claude Code + GitHub — all in one stack          ║
║   Isolation-ready · Team-friendly · Production-grade             ║
║                                                                  ║
║   ✦  Author: Viact Team — Daniel Le                              ║
║   ✦  Support: https://github.com/BloopAI/vibe-kanban             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Then say:

> "Welcome! I'll walk you through setting up Vibe Kanban on Docker step by step.
> This setup gives you a fully isolated Kanban environment with Claude Code and
> GitHub integration built in. Let's get started!"

---

# Instructions

## Step 0 — Check Prerequisites

Run silently before asking the user anything:

```bash
docker --version
git --version
```

- If **Docker** is missing: stop and guide the user to https://docs.docker.com/get-docker/
- If **Git** is missing: stop and guide the user to https://git-scm.com/downloads

Only continue to Step 1 when both tools are confirmed available.

---

## Step 1 — Detect Existing Installation

Check whether a Vibe Kanban stack is already present on this machine:

```bash
# Check running containers
docker ps --filter "name=viact-vibe-kanban" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check if default install directory has a compose file
ls ~/vibe-kanban/docker-compose.yml 2>/dev/null && echo "FOUND" || echo "NOT_FOUND"
```

Determine the state and branch accordingly:

---

### Branch A — Stack is running (containers found in `docker ps`)

Detect the install directory from the running compose project:
```bash
docker inspect viact-vibe-kanban-server --format '{{index .Config.Labels "com.docker.compose.project.working_dir"}}' 2>/dev/null || echo "~/vibe-kanban"
```

Save as `INSTALL_DIR`. Then display the current status and ask:

> "Vibe Kanban is already running at `{INSTALL_DIR}`.
>
> Running containers:
> {table output from docker ps above}
>
> What would you like to do?
>
> **1️⃣  Restart** — Stop and restart all services (keeps data)
> **2️⃣  Stop** — Shut down the stack (keeps data)
> **3️⃣  Reinstall** — Wipe config files and run fresh setup
> **4️⃣  Cancel** — Do nothing"

Handle the answer:
- **1 → Restart:** Run `docker compose -f {INSTALL_DIR}/docker-compose.yml restart`, then show final service status. Done.
- **2 → Stop:** Run `docker compose -f {INSTALL_DIR}/docker-compose.yml down`, confirm stopped. Done.
- **3 → Reinstall:** Run `docker compose -f {INSTALL_DIR}/docker-compose.yml down`, then ask:
  > "Do you want to **keep existing data** (volumes, database) or **wipe everything**?
  > **1️⃣  Keep data** · **2️⃣  Wipe everything**"
  - If wipe: `docker compose -f {INSTALL_DIR}/docker-compose.yml down -v`
  - Then continue to **Step 2** (Gather Configuration).
- **4 → Cancel:** Say "No changes made." and stop.

---

### Branch B — Files exist but stack is not running

(`docker-compose.yml` found but no running containers)

Save the detected directory as `INSTALL_DIR`. Then ask:

> "Found an existing Vibe Kanban install at `{INSTALL_DIR}` but it is not running.
>
> What would you like to do?
>
> **1️⃣  Start** — Start the existing stack as-is
> **2️⃣  Reinstall** — Wipe config files and run fresh setup
> **3️⃣  Cancel** — Do nothing"

Handle the answer:
- **1 → Start:** Run `docker compose -f {INSTALL_DIR}/docker-compose.yml up -d`, show status. Done.
- **2 → Reinstall:** Ask about data (keep / wipe), then continue to **Step 2**.
- **3 → Cancel:** Say "No changes made." and stop.

---

### Branch C — No existing installation found

Proceed directly to **Step 2** (Gather Configuration).

---

## Step 2 — Gather Configuration (one question at a time)

**Only run this step for fresh install or reinstall.**

Ask each question separately and **wait for the user's answer** before asking the next one.

---

**Question 1 — Mode:**

Ask only this, then wait:

> "Which mode would you like to install?
>
> **1️⃣  Local** — Runs on your own device. You get your own private Kanban
> board that connects to a remote shared server for project/task sync.
> Best for: individual developers.
>
> **2️⃣  Shared Workstation** — Runs on a team server. Each team member gets
> their own separate Kanban board, all syncing to the same remote server.
> Best for: teams sharing a server.
>
> Please type **1** or **2**."

Save as `MODE = local` or `MODE = shared`. Then continue to the next question.

---

**Question 2 — Install Directory:**

Ask only this, then wait:

> "Where should I create the Vibe Kanban setup files?
>
> **1️⃣  Default** — `~/vibe-kanban` (recommended)
> **2️⃣  Custom** — I'll enter my own path
>
> Please type **1** or **2**."

If user answers **2**, ask immediately:

> "Please enter the full path (e.g. `/opt/vibe-kanban`):"

Save as `INSTALL_DIR`. Then run:
```bash
mkdir -p {INSTALL_DIR}
```

Then continue to the next question.

---

**Question 3 — Shared Remote Domain (Shared mode only):**

**SKIP if MODE = `local`.**

Ask only this, then wait:

> "What is the domain for your remote API server? (`DOMAIN_REMOTE_SERVER`)
> Example: `api-vg01-kanban-01.viact.ai`"

Save as `DOMAIN_REMOTE_SERVER`. Then continue to the next question.

---

**Question 4 — Main Domain (Shared mode only):**

**SKIP if MODE = `local`.**

Ask only this, then wait:

> "What is your root domain? (`MAIN_DOMAIN`)
> Example: `viact.ai`
> Individual Kanban boards will be served at `kanban-{name}-{6-char-token}.{MAIN_DOMAIN}`."

Save as `MAIN_DOMAIN`. Then continue to the next question.

---

**Question 5 — Team Members (Shared mode only):**

**SKIP if MODE = `local`.**

Ask only this, then wait:

> "List the team members who will use Shared Workstation Kanban.
> Use lowercase names, no spaces, separated by commas.
> Example: `daniel, eric, sophia`"

Parse and save as an ordered list: `PEOPLE = [daniel, eric, ...]`.

---

Once all applicable answers are collected, confirm with a summary before proceeding:

> "Got it! Here's what I'll set up:
> - Mode: {MODE}
> - Install directory: {INSTALL_DIR}
> - (Shared only) Remote domain: {DOMAIN_REMOTE_SERVER}
> - (Shared only) Main domain: {MAIN_DOMAIN}
> - (Shared only) Team members: {PEOPLE}
>
> Starting installation now..."

---

## Step 3 — Generate Install Bundle Script

**Generate all secrets and per-person tokens now** (before writing the script):

```bash
VIBEKANBAN_REMOTE_JWT_SECRET=$(openssl rand -base64 48)
ELECTRIC_ROLE_PASSWORD=$(openssl rand -hex 24)
DB_PASSWORD=$(openssl rand -hex 24)

# For Shared mode: generate one 6-char token per person
# e.g. daniel → xy1a67,  eric → 9bm2qk,  sophia → z4rp01
# Use: openssl rand -hex 3   (produces exactly 6 lowercase hex chars)
# Store as an associative mapping: PERSON_TOKEN[daniel]="xy1a67" etc.
```

Then write a **single self-contained bash script** to `{INSTALL_DIR}/run-install.sh`.
The script must have **all config, secrets, and per-person tokens embedded as variables** — no user prompts inside it.

The script must follow this structure exactly:

```bash
#!/usr/bin/env bash
# ── Vibe Kanban Install Bundle ─────────────────────────────────────────────
# Auto-generated by Claude Code. Safe to re-run.
set -euo pipefail

# ── Embedded config (do not edit unless reinstalling) ──────────────────────
MODE="<local|shared>"
INSTALL_DIR="<INSTALL_DIR>"
DOMAIN_REMOTE_SERVER="<value>"   # shared only, empty string for local
MAIN_DOMAIN="<value>"            # shared only, empty string for local
PEOPLE=(<name1> <name2> ...)     # shared only, empty for local

# Per-person subdomain tokens (shared only) — generated once, never change
# Format: PERSON_TOKEN_<NAME>="<6-char-hex>"
PERSON_TOKEN_daniel="xy1a67"     # → kanban-daniel-xy1a67.<MAIN_DOMAIN>
PERSON_TOKEN_eric="9bm2qk"       # → kanban-eric-9bm2qk.<MAIN_DOMAIN>
# (one line per person, actual values generated at script-creation time)

# ── Embedded secrets ───────────────────────────────────────────────────────
VIBEKANBAN_REMOTE_JWT_SECRET="<generated>"
ELECTRIC_ROLE_PASSWORD="<generated>"
DB_PASSWORD="<generated>"

# ── Helpers ────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
ok()   { echo -e "${GREEN}  ✓${NC}  $1"; }
warn() { echo -e "${YELLOW}  !${NC}  $1"; }
err()  { echo -e "${RED}  ✗${NC}  $1"; }
step() { echo -e "\n${BOLD}[$1]${NC} $2"; }

# ── Retry helper ───────────────────────────────────────────────────────────
retry() {
  local max=$1 delay=$2; shift 2
  local n=0
  until "$@"; do
    n=$((n+1))
    [[ $n -ge $max ]] && { err "Failed after $max attempts: $*"; return 1; }
    warn "Attempt $n failed — retrying in ${delay}s..."
    sleep "$delay"
  done
}

# ── Autofix error trap ─────────────────────────────────────────────────────
on_error() {
  local line=$1 cmd=$2
  err "Error at line $line: $cmd"
  echo ""
  echo "  Attempting autofix..."

  # Fix: port conflict — show which process owns the port
  if echo "$cmd" | grep -q "compose up"; then
    warn "Checking for port conflicts..."
    for port in 8081 3000 80 443; do
      if lsof -i ":$port" &>/dev/null 2>&1; then
        warn "  Port $port is in use by: $(lsof -ti :$port | xargs ps -p 2>/dev/null | tail -1 || echo 'unknown')"
      fi
    done
    warn "Trying 'docker compose down' then up again..."
    docker compose -f "$INSTALL_DIR/docker-compose.yml" down 2>/dev/null || true
    sleep 3
    docker compose -f "$INSTALL_DIR/docker-compose.yml" up -d && {
      ok "Autofix succeeded — stack is up."
      return 0
    }
  fi

  # Fix: Docker daemon not running
  if echo "$cmd" | grep -q "docker"; then
    if ! docker info &>/dev/null 2>&1; then
      err "Docker daemon is not running. Please start Docker and re-run this script."
      exit 1
    fi
  fi

  err "Autofix could not resolve the error. Please check the output above."
  exit 1
}
trap 'on_error $LINENO "$BASH_COMMAND"' ERR

# ══════════════════════════════════════════════════════════════════════════════

step "1/6" "Pulling images"
retry 3 5 docker pull thanhlcm90/vibe-kanban-remote-server:latest
ok "Remote server image ready"
retry 3 5 docker pull thanhlcm90/vibe-kanban:latest
ok "Desktop client image ready"

step "2/6" "Creating install directory"
mkdir -p "$INSTALL_DIR"
ok "$INSTALL_DIR"

step "3/6" "Writing .env"
cat > "$INSTALL_DIR/.env" << 'ENVEOF'
# ── Auto-generated secrets ──────────────────────────────────────
VIBEKANBAN_REMOTE_JWT_SECRET=<VIBEKANBAN_REMOTE_JWT_SECRET>
ELECTRIC_ROLE_PASSWORD=<ELECTRIC_ROLE_PASSWORD>
DB_PASSWORD=<DB_PASSWORD>

# ── OAuth — fill these in before starting ──────────────────────
GOOGLE_OAUTH_CLIENT_ID=please-change-me
GOOGLE_OAUTH_CLIENT_SECRET=please-change-me
GITHUB_OAUTH_CLIENT_ID=please-change-me
GITHUB_OAUTH_CLIENT_SECRET=please-change-me

# ── GitHub Integration ──────────────────────────────────────────
GITHUB_TOKEN=please-change-me

# ── Anthropic API ───────────────────────────────────────────────
ANTHROPIC_API_KEY=please-change-me
ENVEOF
# Replace placeholders with actual generated values
sed -i.bak \
  -e "s|<VIBEKANBAN_REMOTE_JWT_SECRET>|$VIBEKANBAN_REMOTE_JWT_SECRET|" \
  -e "s|<ELECTRIC_ROLE_PASSWORD>|$ELECTRIC_ROLE_PASSWORD|" \
  -e "s|<DB_PASSWORD>|$DB_PASSWORD|" \
  "$INSTALL_DIR/.env" && rm -f "$INSTALL_DIR/.env.bak"
ok ".env written"

step "4/6" "Writing config files"
# [AI: write docker-compose.yml and Caddyfile here as heredocs — see templates below]

step "5/6" "Starting the stack"
if [[ "$MODE" == "shared" ]]; then
  docker network create caddy-net 2>/dev/null || true
fi
cd "$INSTALL_DIR"
docker compose up -d
ok "Stack started"

step "6/6" "Waiting for services to be healthy"
echo "  Checking service health (up to 60s)..."
timeout 60 bash -c '
  until docker inspect viact-vibe-kanban-server \
    --format "{{.State.Health.Status}}" 2>/dev/null | grep -q "healthy"; do
    sleep 3
  done
' && ok "All services healthy" || {
  warn "Health check timed out — showing container status:"
  docker compose -f "$INSTALL_DIR/docker-compose.yml" ps
}

echo ""
echo -e "${GREEN}${BOLD}  ✅  Vibe Kanban is running!${NC}"
if [[ "$MODE" == "local" ]]; then
  echo "  → http://localhost:3000"
fi
```

**Filling in Step 4/6 — write config files as heredocs:**

The `docker-compose.yml` and (if Shared) `Caddyfile` must be written as `cat > file << 'EOF'` heredocs inside the script, with all placeholders already replaced by their real values from the collected config.

### docker-compose.yml content for Local mode:

```yaml
services:
  remote-db:
    image: postgres:16-alpine
    container_name: viact-vibe-kanban-db
    command: ["postgres", "-c", "wal_level=logical"]
    restart: unless-stopped
    environment:
      POSTGRES_DB: remote
      POSTGRES_USER: remote
      POSTGRES_PASSWORD: ${DB_PASSWORD:-remote}
    volumes:
      - remote-db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U remote -d remote"]
      interval: 5s
      timeout: 5s
      retries: 5
      start_period: 5s
    networks:
      - vibe-kanban-net

  electric:
    image: electricsql/electric:1.3.3
    container_name: viact-vibe-kanban-electric
    working_dir: /app
    restart: unless-stopped
    environment:
      DATABASE_URL: postgresql://electric_sync:${ELECTRIC_ROLE_PASSWORD}@remote-db:5432/remote?sslmode=disable
      PG_PROXY_PORT: 65432
      LOGICAL_PUBLISHER_HOST: electric
      AUTH_MODE: insecure
      ELECTRIC_INSECURE: true
      ELECTRIC_MANUAL_TABLE_PUBLISHING: true
      ELECTRIC_USAGE_REPORTING: false
      ELECTRIC_FEATURE_FLAGS: allow_subqueries,tagged_subqueries
    volumes:
      - electric-data:/app/persistent
    depends_on:
      remote-db:
        condition: service_healthy
      remote-server:
        condition: service_healthy
    networks:
      - vibe-kanban-net

  remote-server:
    image: thanhlcm90/vibe-kanban-remote-server:latest
    container_name: viact-vibe-kanban-server
    restart: unless-stopped
    depends_on:
      remote-db:
        condition: service_healthy
    ports:
      - "8081:8081"
    environment:
      RUST_LOG: info,remote=info
      SERVER_DATABASE_URL: postgres://remote:${DB_PASSWORD:-remote}@remote-db:5432/remote
      SERVER_LISTEN_ADDR: 0.0.0.0:8081
      ELECTRIC_URL: http://electric:3000
      SERVER_PUBLIC_BASE_URL: http://localhost:8081
      GITHUB_OAUTH_CLIENT_ID: ${GITHUB_OAUTH_CLIENT_ID:-}
      GITHUB_OAUTH_CLIENT_SECRET: ${GITHUB_OAUTH_CLIENT_SECRET:-}
      GOOGLE_OAUTH_CLIENT_ID: ${GOOGLE_OAUTH_CLIENT_ID:-}
      GOOGLE_OAUTH_CLIENT_SECRET: ${GOOGLE_OAUTH_CLIENT_SECRET:-}
      VIBEKANBAN_REMOTE_JWT_SECRET: ${VIBEKANBAN_REMOTE_JWT_SECRET}
      ELECTRIC_ROLE_PASSWORD: ${ELECTRIC_ROLE_PASSWORD}
      LOOPS_EMAIL_API_KEY: ${LOOPS_EMAIL_API_KEY:-}
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://127.0.0.1:8081/v1/health"]
      interval: 5s
      timeout: 5s
      retries: 10
      start_period: 10s
    networks:
      - vibe-kanban-net

  desktop-client:
    container_name: viact-vibe-kanban-desktop
    image: thanhlcm90/vibe-kanban:latest
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - HOST=0.0.0.0
      - PORT=3000
      - BROWSER=none
      - VK_SHARED_API_BASE=http://remote-server:8081
      - ELECTRIC_SERVICE=http://electric:3000
      - RUST_LOG=info
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - GITHUB_TOKEN=${GITHUB_TOKEN}
    working_dir: /home/node/workspaces
    volumes:
      - home_local:/home/node:rw
      - temp_local:/var/tmp:rw
    depends_on:
      remote-server:
        condition: service_healthy
    networks:
      - vibe-kanban-net

volumes:
  remote-db-data:
  electric-data:
  home_local:
  temp_local:

networks:
  vibe-kanban-net:
    driver: bridge
```

### docker-compose.yml content for Shared Workstation mode:

Generate dynamically from PEOPLE list. Starting port `3000`, incrementing per person (skip occupied ports detected by `lsof -i :{port}`). All `{PERSON_NAME}`, `{DOMAIN_REMOTE_SERVER}`, `{MAIN_DOMAIN}`, `{ASSIGNED_PORT}` must be replaced with real values before writing.

```yaml
services:
  caddy:
    image: caddy:2-alpine
    container_name: viact-vibe-kanban-caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    depends_on:
      - remote-server
    networks:
      - caddy-net
      - vibe-kanban-net

  remote-db:
    image: postgres:16-alpine
    container_name: viact-vibe-kanban-db
    command: ["postgres", "-c", "wal_level=logical"]
    restart: unless-stopped
    environment:
      POSTGRES_DB: remote
      POSTGRES_USER: remote
      POSTGRES_PASSWORD: ${DB_PASSWORD:-remote}
    volumes:
      - remote-db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U remote -d remote"]
      interval: 5s
      timeout: 5s
      retries: 5
      start_period: 5s
    networks:
      - vibe-kanban-net

  electric:
    image: electricsql/electric:1.3.3
    container_name: viact-vibe-kanban-electric
    working_dir: /app
    restart: unless-stopped
    environment:
      DATABASE_URL: postgresql://electric_sync:${ELECTRIC_ROLE_PASSWORD}@remote-db:5432/remote?sslmode=disable
      PG_PROXY_PORT: 65432
      LOGICAL_PUBLISHER_HOST: electric
      AUTH_MODE: insecure
      ELECTRIC_INSECURE: true
      ELECTRIC_MANUAL_TABLE_PUBLISHING: true
      ELECTRIC_USAGE_REPORTING: false
      ELECTRIC_FEATURE_FLAGS: allow_subqueries,tagged_subqueries
    volumes:
      - electric-data:/app/persistent
    depends_on:
      remote-db:
        condition: service_healthy
      remote-server:
        condition: service_healthy
    networks:
      - vibe-kanban-net

  remote-server:
    image: thanhlcm90/vibe-kanban-remote-server:latest
    container_name: viact-vibe-kanban-server
    restart: unless-stopped
    depends_on:
      remote-db:
        condition: service_healthy
    ports:
      - "8081:8081"
    environment:
      RUST_LOG: info,remote=info
      SERVER_DATABASE_URL: postgres://remote:${DB_PASSWORD:-remote}@remote-db:5432/remote
      SERVER_LISTEN_ADDR: 0.0.0.0:8081
      ELECTRIC_URL: http://electric:3000
      SERVER_PUBLIC_BASE_URL: https://<DOMAIN_REMOTE_SERVER>
      GITHUB_OAUTH_CLIENT_ID: ${GITHUB_OAUTH_CLIENT_ID:-}
      GITHUB_OAUTH_CLIENT_SECRET: ${GITHUB_OAUTH_CLIENT_SECRET:-}
      GOOGLE_OAUTH_CLIENT_ID: ${GOOGLE_OAUTH_CLIENT_ID:-}
      GOOGLE_OAUTH_CLIENT_SECRET: ${GOOGLE_OAUTH_CLIENT_SECRET:-}
      VIBEKANBAN_REMOTE_JWT_SECRET: ${VIBEKANBAN_REMOTE_JWT_SECRET}
      ELECTRIC_ROLE_PASSWORD: ${ELECTRIC_ROLE_PASSWORD}
      LOOPS_EMAIL_API_KEY: ${LOOPS_EMAIL_API_KEY:-}
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://127.0.0.1:8081/v1/health"]
      interval: 5s
      timeout: 5s
      retries: 10
      start_period: 10s
    networks:
      - vibe-kanban-net

  desktop-client-<PERSON_NAME>:
    container_name: viact-vibe-kanban-desktop-<PERSON_NAME>
    image: thanhlcm90/vibe-kanban:latest
    restart: unless-stopped
    ports:
      - "<ASSIGNED_PORT>:3000"
    environment:
      - HOST=0.0.0.0
      - PORT=3000
      - BROWSER=none
      - VK_SHARED_API_BASE=https://<DOMAIN_REMOTE_SERVER>
      - ELECTRIC_SERVICE=https://kanban-<PERSON_NAME>-<PERSON_TOKEN>.<MAIN_DOMAIN>/electric
      - RUST_LOG=info
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - GITHUB_TOKEN=${GITHUB_TOKEN}
    working_dir: /home/node/workspaces
    volumes:
      - home_<PERSON_NAME>:/home/node:rw
      - temp_<PERSON_NAME>:/var/tmp:rw
    depends_on:
      remote-server:
        condition: service_healthy
    networks:
      - vibe-kanban-net
      - caddy-net

volumes:
  remote-db-data:
  electric-data:
  caddy_data:
  caddy_config:
  home_<PERSON_1>:
  temp_<PERSON_1>:
  # repeat for each person

networks:
  caddy-net:
    external: true
  vibe-kanban-net:
    driver: bridge
```

### Caddyfile content for Shared mode (embed as heredoc):

```caddyfile
(websocket_headers) {
    header_up Host {host}
    header_up X-Real-IP {remote_host}
    header_up X-Forwarded-For {remote_host}
    header_up X-Forwarded-Proto {scheme}
    header_up Connection "Upgrade"
    header_up Upgrade "websocket"
    flush_interval -1
}

# repeat per person:
https://kanban-<PERSON_NAME>-<PERSON_TOKEN>.<MAIN_DOMAIN> {
    tls {
        issuer acme
        issuer internal
    }
    handle /electric/* {
        uri strip_prefix /electric
        reverse_proxy electric:3000
    }
    handle /* {
        reverse_proxy desktop-client-<PERSON_NAME>:3000 {
            import websocket_headers
        }
    }
    encode zstd gzip
}

https://<DOMAIN_REMOTE_SERVER> {
    tls {
        issuer acme
        issuer internal
    }
    handle /* {
        reverse_proxy remote-server:8081 {
            import websocket_headers
        }
    }
    encode zstd gzip
}
```

After writing the script, make it executable:
```bash
chmod +x {INSTALL_DIR}/run-install.sh
```

Say:
> "Install script generated at `{INSTALL_DIR}/run-install.sh`. Running it now..."

---

## Step 4 — Run the Install Script

Run the single bundle script:

```bash
bash {INSTALL_DIR}/run-install.sh
```

This is the **only** script execution in the install flow. The script handles:
- Pulling both Docker images (with 3-attempt retry + backoff)
- Writing `.env`, `docker-compose.yml`, and `Caddyfile` to disk
- Creating the `caddy-net` network (Shared mode)
- Running `docker compose up -d`
- Waiting for health checks (up to 60 s)
- **Autofix on error**: detects port conflicts, Docker daemon issues, and retries compose up automatically

If the script exits with an error after autofix attempts:
1. Show the full error output
2. Diagnose the root cause (check `docker compose logs`, inspect the failed container)
3. Apply a targeted fix to `run-install.sh` or the generated config files
4. Re-run `bash {INSTALL_DIR}/run-install.sh`

Repeat fix→rerun until the stack is fully healthy.

---

## Step 5 — Post-Setup Guide

Display a comprehensive setup guide:

### How to get OAuth credentials

**Google OAuth:**
1. Go to https://console.cloud.google.com/apis/credentials
2. Create → "OAuth 2.0 Client ID" → Application type: Web application
3. Authorized redirect URIs:
   - Local: `http://localhost:8081/auth/google/callback`
   - Shared: `https://{DOMAIN_REMOTE_SERVER}/auth/google/callback`
4. Copy `Client ID` → `GOOGLE_OAUTH_CLIENT_ID`
5. Copy `Client Secret` → `GOOGLE_OAUTH_CLIENT_SECRET`

**GitHub OAuth:**
1. Go to https://github.com/settings/developers → "OAuth Apps" → "New OAuth App"
2. Homepage URL:
   - Local: `http://localhost:3000`
   - Shared: `https://kanban-{name}-{token}.{MAIN_DOMAIN}` (use each person's actual URL from the table below)
3. Authorization callback URL:
   - Local: `http://localhost:8081/auth/github/callback`
   - Shared: `https://{DOMAIN_REMOTE_SERVER}/auth/github/callback`
4. Copy `Client ID` → `GITHUB_OAUTH_CLIENT_ID`
5. Generate a new client secret → `GITHUB_OAUTH_CLIENT_SECRET`

**GitHub Token (for PR/push/pull):**
1. Go to https://github.com/settings/tokens → "Fine-grained personal access tokens"
2. Generate new token with scopes: `Contents`, `Pull requests`, `Metadata`
3. Copy token → `GITHUB_TOKEN`

**Anthropic API Key:**
1. Go to https://console.anthropic.com/settings/api-keys
2. Create new key → `ANTHROPIC_API_KEY`

### After updating .env, restart the stack:

```bash
cd {INSTALL_DIR}
docker compose down
docker compose up -d
```

### Access your Kanban:
- **Local:** http://localhost:3000
- **Shared:** One URL per team member (see list below)

**If MODE = `shared`**, generate and display a per-person domain table from `PEOPLE` and `MAIN_DOMAIN`:

```
📋 Kanban URLs for your team — send these to your DevOps team to map DNS:

  Person       Domain
  ──────────────────────────────────────────────────────────
  daniel    →  kanban-daniel-{token}.{MAIN_DOMAIN}
  eric      →  kanban-eric-{token}.{MAIN_DOMAIN}
  sophia    →  kanban-sophia-{token}.{MAIN_DOMAIN}
  ...
```

Each `{token}` is the unique 6-char hex generated for that person. Use the actual
values from `PERSON_TOKEN_*` variables in `{INSTALL_DIR}/run-install.sh`.

> ⚠️  **Action required — DNS setup:**
> Please send the domain list above to your **DevOps team** and ask them to:
> 1. Create a DNS **A record** (or CNAME) for each domain pointing to this server's IP address.
> 2. Once DNS propagates, Caddy will automatically issue SSL certificates and each person can open their own URL.
> Until DNS is configured, the HTTPS URLs will not be reachable from outside the server.

---

# Examples

## Example 1: Fresh local install

**User:** "Setup vibe kanban for me locally"

**AI flow:**
1. Shows welcome banner
2. Step 0: Checks Docker + Git silently — both found
3. Step 1: No running containers, no existing files → Branch C (fresh install)
4. Step 2: Asks mode (Local), then install directory one question at a time
5. Step 3: Generates secrets, writes `~/vibe-kanban/run-install.sh` with all config + heredocs embedded
6. Step 4: Runs `bash ~/vibe-kanban/run-install.sh` — pulls images, writes files, starts stack, health check
7. Step 5: Shows post-setup guide with localhost URLs

---

## Example 2: Stack already running — user wants to restart

**User:** "Setup vibe kanban"

**AI flow:**
1. Shows welcome banner
2. Step 0: Checks Docker + Git — both found
3. Step 1: Detects `viact-vibe-kanban-*` containers running → Branch A
4. Shows management menu, user picks **1 (Restart)**
5. Runs `docker compose restart`, shows updated status — done (no bundle script needed)

---

## Example 3: Shared Workstation fresh install for 3 people

**User:** "Setup vibe kanban shared workstation for our team"

**AI flow:**
1. Shows welcome banner
2. Step 0: Checks Docker + Git — both found
3. Step 1: No existing install → Branch C (fresh install)
4. Step 2: Asks mode (Shared), install directory, DOMAIN_REMOTE_SERVER, MAIN_DOMAIN, team members one at a time
5. Step 3: Generates secrets, writes `run-install.sh` with: docker-compose (3 desktop-clients, ports 3000-3002), Caddyfile (3 kanban blocks), .env — all as heredocs
6. Step 4: Runs `bash run-install.sh` — script handles network, files, stack, health check in one shot
7. Step 5: Shows URLs with embedded tokens e.g. kanban-daniel-xy1a67.viact.ai, kanban-eric-9bm2qk.viact.ai, kanban-sophia-z4rp01.viact.ai

---

# Constraints

- Always run Step 0 (prerequisite check) and Step 1 (detection) silently before asking the user anything
- The install flow (Steps 2–5) only runs for fresh install or reinstall — never skip detection
- When detecting the install dir from a running container, fall back to `~/vibe-kanban` if the label is missing
- Always ask questions one at a time in Step 2, waiting for the user's answer before asking the next — never bundle multiple questions in one message
- Always generate all secrets AND per-person tokens at the START of Step 3 before writing any files
- Each person in PEOPLE gets a unique 6-char token via `openssl rand -hex 3`; store as `PERSON_TOKEN_<name>` variable embedded in the script
- The token is part of the subdomain: `kanban-{name}-{token}.{MAIN_DOMAIN}` — use it consistently in Caddyfile, ELECTRIC_SERVICE, and the final URL table
- `ELECTRIC_ROLE_PASSWORD` and `DB_PASSWORD` must be generated with `openssl rand -hex 24` (alphanumeric only, no special characters)
- The bundle script `run-install.sh` must be fully self-contained: all config, secrets, and file content embedded as heredocs — zero user prompts inside it
- Never run individual docker/compose commands one by one — always bundle everything into `run-install.sh` and run it once
- The bundle script must include the retry helper and `on_error` trap for autofix
- If `run-install.sh` fails after autofix: diagnose, patch the script or config files, then re-run the script — never abandon mid-install
- Never hardcode API keys, OAuth secrets, or tokens in generated files — always use `${VAR_NAME}` env var references in docker-compose.yml
- Check port availability before assigning ports to services — skip occupied ports
- For the Caddyfile, always include the `(websocket_headers)` snippet — Vibe Kanban uses WebSockets and they will break without it
- Show final access URLs at the end so the user knows exactly where to open their browser
- After setup, remind the user to fill in OAuth credentials and restart the stack
