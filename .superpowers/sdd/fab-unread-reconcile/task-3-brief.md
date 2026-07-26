# Task 3: Validation

**Plan:** FAB cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-fab-cross-tab-unread.md`)

## Goal

Validate unit tests, document manual dual-window checklist status, run `graphify update .` after code edits.

## Steps (exact)

1. Run: `flutter test test/chat_fab_controller_test.dart` → expect PASS. Record output in report.
2. Manual checklist — use / update items 1–4 from `.superpowers/sdd/chat-fab-sync/task-3-manual-checklist.md` (and sync `.superpowers/sdd/task-3-manual-checklist.md` if it redirects/duplicates). Document status:
   - If you cannot run dual tear-off / web tabs in this environment, mark steps **Pending (human)** with clear instructions — do **not** invent Pass.
   - Add any new notes relevant to resume reconcile (focus other window after read → badge catches up).
3. After code edits in this overall plan: run `graphify update .` from project root. Record result.
4. Write report to: `.superpowers/sdd/fab-unread-reconcile/task-3-report.md`

## Do NOT

- Change production reconcile logic unless a test fails and a tiny fix is required (then note it).
- Commit (no git).
- Claim manual E2E Pass without running it.

## Workspace

Work from: `d:\curserAi project`
