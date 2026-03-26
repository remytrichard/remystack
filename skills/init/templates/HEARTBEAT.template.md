# HEARTBEAT

## Rate Limits
- Maximum 3 unsolicited Telegram messages per day.
- If nothing noteworthy, stay quiet — silence is fine.
- Log every heartbeat run to `memory/heartbeat-log.md`.

## Notification Priority Tiers

### Immediate (send now, any hour)
- Task failures, errors, or blocked tasks that require user action
- Security or system alerts
- Completions of tasks the user explicitly asked about in the last 24 hours

### Soon (send on next user interaction, or after max 2 hours)
- Autonomous task completions not recently asked about
- Status changes the user will want to know about

### Digest (defer to morning briefing at 09:00 {{user_timezone}})
- Routine summaries, housekeeping, low-urgency updates
- Anything with no pending action required

## Night Quiet Hours
- Only **Immediate**-priority alerts are allowed during the user's night hours (configure in USER.md).
- Everything else (Soon + Digest) must be deferred to the morning briefing.
- Do not wake the user for non-critical, non-urgent notifications.
- If an Immediate alert fires during night hours, send it — failures don't wait.

## Every Run (every 30 minutes)
1. Check `memory/active-tasks.md` for anything overdue or marked "stuck".
2. Check `memory/pending-outbox.json` for unhandled items older than 1 hour.
3. If the user sent a message in the last 30 minutes, skip proactive messaging.

## Daily (first run after 9:00 {{user_timezone}})
4. Review `memory/` files for notable patterns or themes.
5. Check if any tasks have been idle for more than 48 hours.
6. Compose a brief morning briefing if there's anything actionable.

## Weekly (first run on Monday)
7. Run a memory cleanup pass:
   - Deduplicate entries in `memory/*.md`
   - Archive resolved items
   - Update `MEMORY.md` index
8. Summarize the week's activity and send a digest.
