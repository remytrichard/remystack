# Remystack

A Claude Code plugin that turns a Claude Code session into a persistent Telegram AI companion with identity, long-term memory, and proactive heartbeats.

Inspired by [OpenClaw](https://learnopenclaw.com)'s architecture — SOUL/IDENTITY/USER file stack, markdown memory, and heartbeat scheduling — adapted for Claude Code's native primitives (Channels, `/loop`, systemd).

## What's New in This Release

- **Conversation log with context replay**: every Telegram exchange is appended to `memory/conversation-log.jsonl`. On session restart, the companion replays the last 50 lines filtered to the active `chat_id`, restoring conversational continuity without any extra prompting.
- **Promise tracking**: when the companion commits to notifying you ("I'll let you know when it's done"), it writes a `notify-on-complete` entry to `memory/pending-outbox.json` *before* sending the reply. The heartbeat picks this up and fulfils it autonomously.
- **Ivy Lee daily planning**: a six-task ranked plan generated at 17:00, executed autonomously at 02:00. Silence = approved. `[needs-input]` tasks surface in the morning briefing.
- **Daily logs** (`memory/YYYY-MM-DD.md`): decisions, installs, and open loops from each day are recorded and read at boot for continuity.

## Prerequisites

- **Claude Code** with the Telegram channel plugin installed (do **not** enable it globally — the listener loads it via `--settings`)
- **tmux** — the listener runs inside a tmux session so you can attach/detach at will
- **curl** + **jq** — used by the heartbeat to send Telegram messages via Bot API
- **systemd (user units)** — for service management (`systemctl --user`). Linux only; macOS users can run the listener manually.

The `/remystack:init` wizard will check for these and offer to install any that are missing.

## Quick Start

```bash
# Install the plugin (if not already registered)
# Then run the init wizard:
/remystack:init
```

The wizard will guide you through:
1. Choosing your companion's personality and identity
2. Setting up your user profile
3. Scaffolding identity + memory files
4. Generating and installing systemd services

## Skills

| Skill | Description |
|-------|-------------|
| `/remystack:init` | Guided setup wizard |
| `/remystack:status` | Check health of all services |
| `/remystack:update` | Regenerate config and restart services |
| `/remystack:memory-sync` | Persist facts to memory files |
| `/remystack:outbox-check` | Check heartbeat context before replying |
| `/remystack:heartbeat-register` | Register /loop self-exit cycle |

## Architecture

- **Listener** (`claude-telegram.service`): Long-running Claude Code with `--settings '{"enabledPlugins":...}'` + `--channels plugin:telegram@claude-plugins-official`, running inside a tmux session for attach/detach. Uses the `telegram-companion` agent. The plugin is loaded exclusively by the listener via `--settings` to prevent competing `getUpdates` pollers from ad-hoc sessions.
- **Watchdog** (`claude-telegram-watchdog.timer`): Checks every 2 minutes that the tmux session is alive; restarts the listener service if it's gone.
- **Heartbeat** (`claude-heartbeat.service` + `.timer`): Oneshot Claude Code that runs every 30 minutes. Checks tasks, memory, and sends proactive Telegram messages via curl/Bot API.
- **Outbox** (`memory/pending-outbox.json`): Bridges context between heartbeat and listener. Heartbeat writes entries before sending; listener reads them when handling follow-up replies.
- **Conversation log** (`memory/conversation-log.jsonl`): Append-only JSONL log of all Telegram exchanges. Read at boot, filtered to the active `chat_id`, for session continuity.

## Key Design Decisions

- Only the listener loads the Telegram plugin (via `--settings`) and registers channels (via `--channels`) — prevents HTTP 409 polling conflicts from ad-hoc or heartbeat sessions that share the same project directory
- Heartbeat sends via curl/Bot API (`send_telegram.sh`) — stateless, no polling
- Conversation log filtered by `chat_id` at replay — safe for multi-user deployments; no cross-chat leakage
- Promise tracking as a write-ahead log — outbox entry written *before* the verbal promise is sent, so restarts never lose commitments
- No `RuntimeMaxSec` — avoids SIGTERM mid-task; Claude self-exits via `/loop` when idle
- `OnCalendar` timer (not `OnUnitActiveSec`) — reliable `Persistent=true` catch-up after downtime
- Messages prefixed with `[HEARTBEAT: topic]` for context tracing
