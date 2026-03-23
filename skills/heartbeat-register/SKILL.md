---
name: heartbeat-register
description: Register /loop self-exit cycle — set up the listener to gracefully exit when idle so systemd can restart it fresh.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(date *)
  - Skill
---

# /remystack:heartbeat-register — Register Self-Exit Loop

Set up the `/loop` self-exit cycle for the Telegram listener session.

Arguments passed: `$ARGUMENTS`

## Purpose

Claude Code sessions accumulate context over time. To keep the listener fresh:
1. Register a `/loop` that fires every 3h55m (just under the 4h mark).
2. On each loop tick, check if the session has been idle (no messages in last 30 min).
3. If idle, write `memory/session-handoff.md` with current context summary.
4. Exit cleanly — systemd `Restart=always` will restart the service.

## Process

1. Invoke `/loop 3h55m` with this prompt:
   ```
   Check if this session has been idle for 30+ minutes.
   If idle:
   - Write a brief context summary to memory/session-handoff.md
   - Log "session recycled" to memory/heartbeat-log.md with timestamp
   - Exit with: "Session recycled for freshness."
   If not idle:
   - Do nothing, wait for next loop tick.
   ```

2. Confirm the loop is registered.

## Notes
- The 3h55m interval avoids edge cases with exactly 4h timeouts.
- `session-handoff.md` gives the next session startup context.
- This is for the listener service only, not the heartbeat oneshot.
