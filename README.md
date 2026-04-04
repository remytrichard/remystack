# TruClaw

**OpenClaw, but on a pure Anthropic harness — always on, zero ban risk, one skill to install.**

TruClaw turns your VPS or Mac Mini into an always-on AI agent that works while you sleep. It runs on Claude Code (the official CLI) and your existing Claude subscription, so there's no risk of getting banned. Message it from Telegram, go to bed — it keeps going.

> Think of it as OpenClaw with Opus, using the subscription you already pay for, without the account ban risk.

---

## Why TruClaw?

Tools like OpenClaw work — until Anthropic bans your account for using your subscription through an unofficial harness.

TruClaw is built on three official Anthropic pieces: **Claude Code** (the CLI), **Channels** (the Telegram plugin), and a **Telegram bot**. That's it. No scraping, no unofficial API access, no ToS violations.

On top of that foundation, TruClaw adds everything OpenClaw doesn't have:

- **Always on** — runs as a systemd service (or launchd on macOS) 24/7 on your server. No open laptop required.
- **Remembers you** — persistent identity and long-term memory across every session restart.
- **Works while you sleep** — proactive heartbeats check on tasks and send you updates without being asked.
- **Keeps promises** — if it says "I'll let you know when it's done", it will, even if the session restarts.
- **Plans your day** — daily ranked task list, generated at 17:00 and executed autonomously at 02:00.

## Quick Start

One skill to install:

```
/truclaw:init
```

The wizard checks your prerequisites, asks a few questions about your companion's name and personality, and installs everything — systemd services, Telegram bot wiring, memory scaffolding. You'll be running in under 10 minutes.

## Prerequisites

- **Claude Code** (v2.1.80+) with a Claude Pro or Max subscription
- **A Telegram bot token** — create one via [@BotFather](https://t.me/BotFather) in 2 minutes
- **A VPS, Mac Mini, or any always-on Linux/macOS machine**
- **tmux**, **curl**, **jq** — the init wizard will install any that are missing

That's it. Bun, systemd units, and the Channels plugin are handled automatically by `/truclaw:init`.

## Skills

| Skill | Description |
|-------|-------------|
| `/truclaw:init` | Guided setup wizard |
| `/truclaw:status` | Check health of all services |
| `/truclaw:update` | Regenerate config and restart services |
| `/truclaw:memory-sync` | Persist facts to memory files |
| `/truclaw:outbox-check` | Check heartbeat context before replying |
| `/truclaw:heartbeat-register` | Register /loop self-exit cycle |

## Architecture

- **Listener** (`claude-telegram.service`): Long-running Claude Code with `--settings '{"enabledPlugins":...}'` + `--channels plugin:telegram@claude-plugins-official`, running inside a tmux session. The plugin is loaded exclusively here to prevent competing `getUpdates` pollers from ad-hoc or heartbeat sessions.
- **Watchdog** (`claude-telegram-watchdog.timer`): Checks every 2 minutes that the tmux session is alive; restarts the listener service if not.
- **Heartbeat** (`claude-heartbeat.service` + `.timer`): Oneshot Claude Code every 30 minutes. Checks tasks, memory, and sends proactive Telegram messages via curl/Bot API — no polling.
- **Outbox** (`memory/pending-outbox.json`): Bridges context between heartbeat and listener. Written before sending; read at session boot.
- **Conversation log** (`memory/conversation-log.jsonl`): Append-only JSONL of all Telegram exchanges. Read at boot, filtered to `chat_id`, for session continuity.

## Key Design Decisions

- Only the listener polls Telegram (via `--channels`) — prevents HTTP 409 conflicts from concurrent sessions sharing the same project directory
- Heartbeat sends via curl/Bot API (`send_telegram.sh`) — stateless, no polling, safe to run in parallel with the listener
- Conversation log filtered by `chat_id` at replay — safe for multi-user deployments; no cross-chat leakage
- Promise tracking as write-ahead log — outbox entry written *before* the verbal promise is sent, so restarts never lose commitments
- `OnCalendar` timer (not `OnUnitActiveSec`) — reliable `Persistent=true` catch-up after system downtime
- No `RuntimeMaxSec` — avoids SIGTERM mid-task; Claude self-exits via `/loop` when idle
- Heartbeat messages prefixed with `[HEARTBEAT: topic]` for easy filtering in Telegram

## License

Apache 2.0
