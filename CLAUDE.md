# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **Claude Code skills repository** — markdown-based skill definitions that Claude Code loads and executes as automated workflows. There is no build system, test runner, or compiled code. All work is editing `.md` files.

## Skill File Format

Each skill is a single Markdown file with YAML frontmatter:

```markdown
---
name: skill-name
description: |
  One-line summary.
  Trigger phrases that cause Claude to invoke this skill.
---

# Goal
...

# Introduction
...

# Instructions
## Step N — Step Name
...

# Examples
...
```

- `name` — kebab-case identifier matching the filename/command name
- `description` — the trigger detection block; Claude reads this to decide when to auto-invoke the skill
- `Instructions` — the executable steps Claude follows; this is the core of the skill
- `Examples` — concrete user flows used for validation and documentation

## Architecture: setup-vibe-kanban Skill

`SKILL.md` is the primary skill. It is a **15-step linear pipeline** with conditional branching on `MODE` (`local` | `shared`):

| Steps | Scope | What happens |
|-------|-------|-------------|
| 0–1 | Both | Mode selection, Docker/Git prerequisite check |
| 2–3 | Both | Clone `BloopAI/vibe-kanban` to `/tmp`, build remote server image |
| 4 | Shared only | Collect `DOMAIN_REMOTE_SERVER` and `MAIN_DOMAIN` |
| 5–9 | Both | Ask install dir, generate `.env` (secrets via `openssl`), write `Dockerfile` + `entrypoint.sh`, build desktop client image |
| 10–12 | Shared only | Collect `PEOPLE` list, create `caddy-net` network, generate `Caddyfile` |
| 13–14 | Both | Generate `docker-compose.yml`, run `docker compose up -d` |
| 15 | Both | Post-setup guide; Shared mode displays per-person domain table for DevOps DNS setup |

**Key runtime variables** carried across steps: `MODE`, `INSTALL_DIR`, `DOMAIN_REMOTE_SERVER`, `MAIN_DOMAIN`, `PEOPLE` (list), all `.env` secret values.

**Generated files** (written to `INSTALL_DIR`): `.env`, `Dockerfile`, `entrypoint.sh`, `docker-compose.yml`, `Caddyfile` (Shared only).

## Editing Guidelines

- **Step ordering matters** — steps reference variables set in earlier steps. When adding a step, check upstream/downstream dependencies.
- **Mode guards** — Shared-only steps must begin with `**SKIP if MODE = local`.**`
- **Shared mode domain pattern** — per-person subdomains always follow `kanban-{name}.{MAIN_DOMAIN}`. Keep this consistent across the Caddyfile template, docker-compose template, and Step 15 output.
- `setup-vibe-kanban.md` is the original user requirements doc — treat it as read-only reference, not the authoritative spec. `SKILL.md` is authoritative.
- `resources/` is currently empty and reserved for reusable templates.
