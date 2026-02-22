# Compact Protocol

## Trigger
User sends `/compact` in Telegram

## Actions

### 1. Summarize Last 7 Messages

Retrieve recent session history:
```
sessions_history(sessionKey="agent:main:main", limit=7)
```

Generate concise summary capturing:
- Key decisions made
- Files modified
- Outstanding tasks
- Blockers or issues

### 2. Append to Daily Log

Write summary to `/app/.openclaw/workspace/logs/YYYY-MM-DD-log.md`:

```markdown
## Compact Summary - {HH:MM UTC}

**Messages summarized:** {n}

### Key Points:
{summary}

### Files Modified:
{list}

### Outstanding:
{tasks}

---
```

### 3. Create Logs Directory

Ensure `/app/.openclaw/workspace/logs/` exists

### 4. Acknowledge Completion

Reply to user:
```
🧹 Compacted. Summary appended to logs/YYYY-MM-DD-log.md
```

### 5. Context Reset

Note: Context clearing happens automatically or user runs `/reset` separately.

EOF