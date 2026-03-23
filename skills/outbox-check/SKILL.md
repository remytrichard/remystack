---
name: outbox-check
description: Read pending-outbox.json before replying — check for heartbeat context that matches the current conversation.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /remystack:outbox-check — Check Pending Outbox

Read `memory/pending-outbox.json` and provide context from recent heartbeat messages.

Arguments passed: `$ARGUMENTS`

## Process

1. **Read `memory/pending-outbox.json`**.
2. **Filter** for entries where `"handled"` is not `true`.
3. **Match** entries against the current conversation:
   - Check if the user is replying to a heartbeat message (look for `[HEARTBEAT:` prefix).
   - Check if the topic matches what the user is asking about.
4. **Output** matched context as a brief summary for the agent to incorporate.
5. **Mark matched entries** as `"handled": true` and write back the file.

## Outbox Entry Format

```json
[
  {
    "timestamp": "2026-03-21T10:30:00Z",
    "topic": "task-check",
    "summary": "Found 2 overdue tasks in active-tasks.md",
    "details": "...",
    "telegram_message": "...",
    "handled": false
  }
]
```

## Notes
- If no unhandled entries exist, return empty context.
- Keep the outbox file clean — remove entries older than 7 days.
- The heartbeat service writes entries; the listener service reads and marks them.
