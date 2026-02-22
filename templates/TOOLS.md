# TOOLS.md - Local Notes

### Gemini CLI
- **Installed at:** `~/.local/bin/gemini`
- **Version:** 0.27.3
- **Usage:** `gemini [query]` (interactive) or `gemini -p "prompt"` (headless)
- **Notes:** Use `-y` for YOLO mode (auto-approve all tools)

### ClawHub CLI
- **Installed at:** `~/.local/bin/clawhub`
- **Version:** 0.5.0
- **Usage:**
  - `clawhub search <query>` — find skills
  - `clawhub install <slug>` — install a skill
  - `clawhub list` — show installed skills
  - `clawhub explore` — browse latest skills
- **Notes:** Need to `clawhub login` first for publish/personal features

### gog (Google Workspace CLI)
- **Skill:** `gog` — Gmail, Calendar, Drive, Contacts, Sheets, Docs
- **Binary:** `/usr/local/bin/gog` (already installed)
- **Account:** <YOUR_EMAIL> (authenticated)
- **Services:** gmail, calendar, drive, contacts, sheets, docs
- **Usage:**
  - `gog gmail search 'query'` — search emails
  - `gog calendar events <calendarId>` — list events
  - `gog drive search "query"` — find files

### Cron Jobs

| Job | Schedule | Purpose |
|:---|:---|:---|
| `openclaw-compact-12h` | 00:00 & 12:00 UTC | Session cleanup |
| `openclaw-nightly-reflection` | 03:00 UTC | Strategist review |

**Management:**
```bash
openclaw cron list      # List all jobs
openclaw cron runs <id> # View run history
```

---

### Custom Skills

| Skill | Location | Purpose |
|:---|:---|:---|
| **task-orchestrator** | `~/.openclaw/skills/task-orchestrator/` | `runParallel()` scatter-gather for concurrent sub-agents |
| **plan** | `~/.openclaw/skills/plan/` | Actor-Critic architecture (Strategist + Reviewer) |
| **agent-personas** | `~/.openclaw/skills/agent-personas/` | Sub-agent personas for delegation |
| **clawddocs** | `./skills/clawddocs` | Claw documentation and guides |
| **n8n-workflow-automation** | `./skills/n8n-workflow-automation` | n8n workflow automation integration |