---
name: update
description: Regenerate systemd/config after changes — stop services, rebuild units from templates, reinstall, and restart.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(systemctl --user *)
  - Bash(cp *)
  - Bash(which *)
  - Bash(chmod *)
  - AskUserQuestion
---

# /remystack:update — Update & Redeploy

Stop services, regenerate configuration from templates, reinstall, and restart.

Arguments passed: `$ARGUMENTS`

## Process

1. **Stop services** (gracefully):
   ```bash
   systemctl --user stop claude-telegram.service
   systemctl --user stop claude-heartbeat.timer
   ```

2. **Regenerate files** from templates:
   - Re-read all templates from `projects/remystack/skills/init/templates/`
   - Detect current system values (claude path, working dir, bot token, etc.)
   - Re-render systemd units and send_telegram.sh with current values
   - Write updated files to working directory

3. **Reinstall systemd units**:
   ```bash
   cp claude-telegram.service claude-heartbeat.service claude-heartbeat.timer ~/.config/systemd/user/
   systemctl --user daemon-reload
   ```

4. **Restart services**:
   ```bash
   systemctl --user start claude-telegram.service
   systemctl --user enable --now claude-heartbeat.timer
   ```

5. **Verify** using the same checks as `/remystack:status`.

## Notes
- Always stop before updating to avoid stale processes.
- If the user only changed identity files (SOUL.md, IDENTITY.md), a service restart is sufficient — no need to regenerate units.
- Ask before proceeding with service restart.
