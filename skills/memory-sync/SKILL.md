---
name: memory-sync
description: Persist facts to memory files — identify a fact from context, write it to the appropriate memory file, and update MEMORY.md index.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# /remystack:memory-sync — Persist Facts to Memory

Identify facts worth remembering from the current conversation context and persist them.

Arguments passed: `$ARGUMENTS`

## Process

1. **Read `MEMORY.md`** to understand existing memory structure.
2. **Identify the fact** to remember:
   - If `$ARGUMENTS` contains a specific fact, use that.
   - Otherwise, scan recent conversation for stable facts worth persisting.
3. **Determine target file**:
   - Match the fact to an existing `memory/*.md` file by topic.
   - If no file fits, create a new topic file and add it to `MEMORY.md`.
4. **Append a dated bullet** to the target file:
   ```
   - 2026-03-21: [the fact]
   ```
5. **Update `MEMORY.md`** index if a new file was created.
6. **Confirm** what was saved and where.

## Rules
- Never duplicate an existing entry. Check for similar content first.
- Keep entries concise — one line per fact.
- Use ISO dates (YYYY-MM-DD).
- Don't persist ephemeral information (debugging sessions, temp state).
