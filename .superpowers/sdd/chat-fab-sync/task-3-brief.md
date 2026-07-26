# Task 3: Manual verification checklist (human)

Not automated. After Task 2:

1. Open two web tabs (or two Windows tear-off windows) logged in as the same admin.
2. Receive a new chat message → both FABs show unread (and mention if applicable).
3. In tab/window A only: open chat FAB → open conversation → scroll/mark read until local FAB clears.
4. **Pass:** tab/window B FAB unread/mention clears (or updates to server `totalUnreadMessageCount`) without opening chat.
5. Confirm other-admin read of a chat does not clear this user's FAB (if two admins available).
6. Confirm no white screen / crash when socket sends `chat.seen` with `data: null` or `{}` (server or proxy glitch).

**Your job as implementer (agent):**
- Create/update a durable checklist file at: `d:\curserAi project\.superpowers\sdd\chat-fab-sync\task-3-manual-checklist.md`
- Include steps 1–6 with a Status column (Pending / Pass / Fail / N/A)
- Map which steps are covered by unit tests vs require human E2E
- Do NOT change production code
- Do NOT claim E2E Pass unless you actually ran dual-tab verification (you cannot in this environment — leave dual-tab steps Pending)
- Write report to: `d:\curserAi project\.superpowers\sdd\chat-fab-sync\task-3-report.md`
- Skip git commit
