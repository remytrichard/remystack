---
name: init
description: Guided setup wizard — scaffold identity, memory, systemd units, and send_telegram.sh into the working directory. Run this first to initialize your companion.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(mkdir *)
  - Bash(ls *)
  - Bash(which *)
  - Bash(uname *)
  - Bash(chmod *)
  - Bash(systemctl --user *)
  - Bash(loginctl *)
  - AskUserQuestion
---

# /remystack:init — Companion Setup Wizard

You are running the remystack init wizard. Guide the user through setting up their persistent Telegram AI companion.

Arguments passed: `$ARGUMENTS`

## Step 0: Check Prerequisites

Before anything else, verify that required tools are installed. For each missing tool, detect the OS and package manager, then offer to install it. Use the best available method for the platform (e.g. `apt` on Debian/Ubuntu, `brew` on macOS, `dnf` on Fedora, `pacman` on Arch, etc.). If the user lacks root/sudo, suggest alternatives or ask them to install manually.

Required tools:
- **tmux** — used to run the listener in an attachable session
- **curl** — used by `send_telegram.sh` for Bot API calls
- **jq** — used by `send_telegram.sh` to parse API responses
- **systemd (user units)** — required for service management (`systemctl --user`). If not available (e.g. macOS), warn the user that the systemd services won't work and suggest running the listener manually instead.

Check each with `which <tool>`. For any missing tool:
1. Detect OS: `uname -s`, and if Linux check `/etc/os-release` for the distro
2. Propose the install command (e.g. `sudo apt install -y tmux curl jq`)
3. Ask the user for confirmation before running
4. Verify installation succeeded

Only proceed to Step 1 once all prerequisites are satisfied.

## Step 1: Gather Identity

Ask the user for the following (suggest sensible defaults):

1. **Agent name** — What should your companion be called? (default: "Remy")
2. **Agent tagline** — A short tagline (default: "Your persistent engineering co-pilot.")
3. **Agent vibe** — Personality in a few words (default: "Calm, confident, slightly playful.")
4. **Communication style** — How should it talk? (default: "Clear, direct, low-fluff.")
5. **Core values** — What matters most? (default: "deep reasoning, honest trade-offs, practical automation")
6. **Working style extras** — Any special working preferences? (default: "")
7. **Primary focus** — What do you work on? (default: "engineering, automation, and technical projects")

## Step 2: Gather User Profile

1. **Your name** — (required)
2. **Timezone** — (default: detect from system)
3. **Role** — (default: "Engineer")
4. **Telegram user ID** — (default: check access.json)
5. **Preferences** — What kind of answers do you like? (default: "Deep, technically rich answers with practical focus")
6. **Constraints** — Any limitations on availability? (default: "")

## Step 3: Scaffold Files

Read each template from `projects/remystack/skills/init/templates/` and replace `{{placeholders}}` with the user's answers. Write the following files to the working directory root:

- `SOUL.md` (from SOUL.template.md)
- `IDENTITY.md` (from IDENTITY.template.md)
- `USER.md` (from USER.template.md)
- `HEARTBEAT.md` (from HEARTBEAT.template.md)
- `CLAUDE.md` — **append** the template content to any existing CLAUDE.md (from CLAUDE.template.md)
- `MEMORY.md` (from MEMORY.template.md)
- `heartbeat-prompt.md` (from heartbeat-prompt.template.md)

Create the memory directory and starter files:
```
memory/
  general.md        — "# General Knowledge\n\n(Empty — will be populated as you learn.)"
  projects.md       — "# Projects\n\n(Empty — will be populated as you learn.)"
  active-tasks.md   — "# Active Tasks\n\n(Empty — add tasks as they come up.)"
  heartbeat-log.md  — "# Heartbeat Log\n\n"
  pending-outbox.json — "[]"
```

## Step 4: Generate Systemd Units & Send Script

Detect system values:
- `claude_path`: run `which claude`
- `home_directory`: use `$HOME`
- `working_directory`: use current working directory (pwd)
- `path`: use current `$PATH`
- `bot_token`: read from `~/.claude/channels/telegram/.env` (TELEGRAM_BOT_TOKEN)
- `chat_id`: read from `~/.claude/channels/telegram/access.json` (first entry in allowFrom)
- `tmux_session_name`: derive from agent name, lowercased and hyphenated (e.g. "Jarvis" → "jarvis-telegram")

Generate from templates:
- `send_telegram.sh` — make executable with `chmod u+x`
- `claude-telegram.service` — write to working directory (runs listener inside tmux for attach/detach)
- `claude-telegram-watchdog.service` — write to working directory (restarts listener if tmux session dies)
- `claude-telegram-watchdog.timer` — write to working directory (checks every 2 minutes)
- `claude-heartbeat.service` — write to working directory
- `claude-heartbeat.timer` — write to working directory

## Step 5: Install Systemd (ask first)

Ask: "Ready to install systemd services? This will:"
- Copy service/timer files to `~/.config/systemd/user/`
- Run `systemctl --user daemon-reload`
- Enable and start `claude-telegram.service`
- Enable and start `claude-telegram-watchdog.timer`
- Enable and start `claude-heartbeat.timer`
- Run `loginctl enable-linger $USER` for persistence

Only proceed if user confirms.

## Step 6: Verify

- Check `systemctl --user is-active claude-telegram.service`
- Check `systemctl --user is-active claude-telegram-watchdog.timer`
- Check `systemctl --user is-active claude-heartbeat.timer`
- Test `./send_telegram.sh "🚀 Companion initialized! I'm online."`
- Report status to the user

## Notes
- If any file already exists, ask before overwriting.
- If CLAUDE.md exists, append rather than replace.
- Template placeholders use `{{double_braces}}` syntax.
