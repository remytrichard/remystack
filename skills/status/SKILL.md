---
name: status
description: Check systemd health + heartbeat log — report on listener, heartbeat timer, and recent activity.
user-invocable: true
allowed-tools:
  - Read
  - Bash(systemctl --user *)
  - Bash(journalctl --user *)
  - Bash(date *)
  - Glob
---

# /remystack:status — System Health Check

Check the health of all remystack services and report status.

Arguments passed: `$ARGUMENTS`

## Checks

1. **Listener Service**:
   ```bash
   systemctl --user is-active claude-telegram.service
   systemctl --user show claude-telegram.service --property=ActiveEnterTimestamp,NRestarts
   ```

2. **Heartbeat Timer**:
   ```bash
   systemctl --user is-active claude-heartbeat.timer
   systemctl --user list-timers claude-heartbeat.timer
   ```

3. **Heartbeat Service** (last run):
   ```bash
   systemctl --user show claude-heartbeat.service --property=ActiveEnterTimestamp,ExecMainStatus
   ```

4. **Recent Heartbeat Log**:
   - Read last 10 lines of `memory/heartbeat-log.md`

5. **Pending Outbox**:
   - Read `memory/pending-outbox.json` and count unhandled entries

6. **Memory Health**:
   - List files in `memory/` with sizes
   - Check MEMORY.md index consistency

## Output Format

```
## Remystack Status

| Component | Status | Details |
|-----------|--------|---------|
| Listener  | ✅ active | Running since ... |
| Heartbeat Timer | ✅ active | Next: ... |
| Last Heartbeat  | ✅ success | ... ago |
| Pending Outbox  | 0 items | |
| Memory Files    | N files | ... |
```

If any component is unhealthy, provide remediation suggestions.
