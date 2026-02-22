# HEARTBEAT.md

This file controls what I check during heartbeats. Edit it to change my behavior.

## Default Behavior
If this file exists, read it and follow instructions.
If nothing needs attention, reply `HEARTBEAT_OK`.

## <USER_NAME>'s Current Priorities
- [ ] Any pending tasks in `/app/.openclaw/workspace/tasks/`

## Agent Status Check (NEW)

### Check Running Agents
Poll `sessions_list` for sub-agents with `activeMinutes: 30`:

**If agents complete successfully:**
- Review their findings
- Archive to `/app/.openclaw/workspace/tasks/completed/`
- Update backlog status
- **DO NOT notify <USER_NAME>** — silent completion

**If agents fail or error:**
- Capture error message
- Analyze failure pattern
- Apply corrective strategy:
  - **Verification failure** → Add stricter protocol
  - **Timeout** → Increase limits.timeoutMinutes
  - **False complete** → Require `ls -la` output in findings
  - **Coverage not improving** → Add rendering requirements
- Redeploy with fixed parameters
- Log to `/app/.openclaw/workspace/tasks/agent-errors.log`

**If agents stuck > 30 min:**
- Check `process` for hung exec
- Kill if unresponsive
- Mark as FAILED, redeploy

## System Alerts
Only alert if critical:
- Disk >90% full
- Memory >90% used
- Agent failures > 3 consecutive

## Silent Operations
- Agents complete without notification
- Batch reports only on heartbeat
- Error handling automatic, logged
- Only notify <USER_NAME> on escalation

EOF