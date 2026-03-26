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
4. **Weather report** — always fetch and include, even if nothing else is noteworthy. Use wttr.in or Open-Meteo for the user's location (see USER.md). Format:

   ```
   [City] — [Day], [DD] [Mon] [YYYY]

   Current ([HH:MM] local): [ICON] [Condition] · [Temp]°C (feels like [Feels]°C)[, [Precipitation]]

   Morning: [Condition], [TempRange]°C (feels like [FeelsRange]°C)[, [Precipitation]]
   Afternoon: [Condition], [TempRange]°C (feels like [FeelsRange]°C)[, [Precipitation]]
   Evening: [Condition], [TempRange]°C (feels like [FeelsRange]°C)[, [Precipitation]]

   Sun: Rise [HH:MM AM/PM] · Set [HH:MM AM/PM]
   ```

   Rules:
   - All times in the user's local timezone
   - Icons: ☀️ sunny/clear · ⛅ partly cloudy · ☁️ cloudy · 🌧️ rain · ⛈️ thunderstorm · 🌨️ snow · 🌫️ fog · 💨 windy
   - Include precipitation if >0% chance or >0mm (e.g., "2mm rain", "40% chance")
   - Add any severe weather alerts or warnings from local meteorological authority
   - Use Evening/Night time periods if briefing fires outside 6 AM–6 PM
   - Keep concise — no extra commentary
   - **This is the only item guaranteed to send every day.** Weather alone justifies the briefing.

5. Review `memory/` files for notable patterns or themes.
6. Check if any tasks have been idle for more than 48 hours.
7. Compose the morning briefing: weather first, then any actionable items.

## Weekly (first run on Monday)
7. Run a memory cleanup pass:
   - Deduplicate entries in `memory/*.md`
   - Archive resolved items
   - Update `MEMORY.md` index
8. Summarize the week's activity and send a digest.
