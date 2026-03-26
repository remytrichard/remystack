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
2. Check `memory/pending-outbox.json` for unhandled items older than 1 hour:
   - `type: "notify-on-complete"`: check if the associated work is done (read active-tasks.md or daily log). If done, send completion notification to `chat_id` and mark `"handled": true`. If still in progress, leave it.
   - All other types: surface in next Telegram message or send proactively if urgent.
3. If the user sent a message in the last 30 minutes, skip proactive messaging.

## Evening Planning (first run after {{ivy_lee_send_time}} {{user_timezone}})
Generate tomorrow's Ivy Lee plan:

1. **Review today**: read `memory/ivy-lee.md` — note uncompleted tasks (they carry forward first).
2. **Gather candidates**: read `memory/active-tasks.md`, today's daily log open loops, and `memory/ivy-lee-backlog.md`.
3. **Decompose**: break multi-session projects into the next concrete milestone. Never put a project title on the list.
4. **Rank 6**: prioritize by urgency × impact. Carry-forward tasks rank first unless superseded.
5. **Fill to 6**: pull from `memory/ivy-lee-backlog.md` if needed. Never invent tasks.
6. **Write `memory/ivy-lee.md`** (archive previous plan to today's daily log first):
   ```markdown
   # Ivy Lee Plan

   **Generated**: <ISO8601>
   **For**: YYYY-MM-DD (tomorrow)
   **Status**: pending-approval
   **Executes**: YYYY-MM-DD at {{ivy_lee_execution_time}} {{user_timezone}} (unless feedback received before then)

   1. [ ] Task — *rationale* (carry: 0)
   2. [ ] Task — *rationale* (carry: 1)
   ...
   ```
   Increment `carry: N` for tasks brought forward. Flag `carry: 3+` — break down or drop.
   Mark tasks needing user input with `[needs-input]`.
7. **Send to user** via Telegram with "reply to adjust or silence = go" framing.
8. Write a `notify-on-complete` outbox entry so the execution heartbeat knows to begin.

## Overnight Execution (first run after {{ivy_lee_execution_time}} {{user_timezone}})
Execute today's approved Ivy Lee plan:

1. Read `memory/ivy-lee.md`. If `pending-approval`, set to `approved` (silence = approved). If `in-progress` or `done`, skip.
2. Set status to `in-progress`.
3. Work through tasks in ranked order, **skipping `[needs-input]` tasks** — they do not block. Complete all autonomous tasks first, regardless of position in the list.
4. `[needs-input]` tasks go in the morning briefing with exactly what input is needed.
5. Check off each completed task: `[x] Task — completed HH:MM local`.
6. When done: set status to `done` (or leave `in-progress` if continuing). Write results to daily log.

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

5. **Ivy Lee status**: read `memory/ivy-lee.md`. List overnight completions and any `[needs-input]` tasks with exactly what input is needed.
6. Review `memory/` files for notable patterns or themes.
7. Check if any tasks have been idle for more than 48 hours.
8. Compose the morning briefing: weather first, then Ivy Lee overnight results + input-required items, then any other actionable items.
9. **Write daily log entry**: append any autonomous completions, installs, or notable decisions to `memory/YYYY-MM-DD.md` (create if needed). Format: `## Heartbeat [HH:MM]\n- <item>`. Do not write routine no-op runs.

## Weekly (first run on Monday)
7. Run a memory cleanup pass:
   - Deduplicate entries in `memory/*.md`
   - Archive resolved items
   - Update `MEMORY.md` index
8. Summarize the week's activity and send a digest.
