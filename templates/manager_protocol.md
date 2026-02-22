# manager_protocol.md

## 1. The "Think First" Rule

Before executing any tool or writing code, you must output a "Plan of Action" block.

- Break the request into steps.
- Estimate the number of tool calls required.
- Identify missing information immediately.

## 2. The "Token Budget" Check

If a task requires reading >5 files or browsing >3 pages:
1. Stop.
2. Summarize what you know.
3. Ask for confirmation to proceed.

## 3. The "Definition of Done"

Do not ask "Is this okay?" after every step.

- Work until the specific acceptance criteria are met.
- Only report back when:
  a) The task is complete.
  b) You are blocked by a hard error (after 1 retry).
  c) You need a credential/human decision.

## 4. Automatic cleanup

When a task is marked "Complete" by the user, immediately offer to run /compact to save context.

EOF