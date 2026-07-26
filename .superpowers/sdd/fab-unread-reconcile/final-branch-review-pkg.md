# Final whole-branch review package — FAB unread reconcile (no git)

Plan: docs/superpowers/plans/2026-07-11-chat-fab-cross-tab-unread.md
Merge base: N/A (no git) — review full feature delta vs pre-plan state

## Production files changed (Tasks 1–2)

### lib/src/domain/chat/controller/chat_fab.controller.dart
- Fields: `_fabUnreadReconcileTimer`, `@visibleForTesting fabUnreadReconcileScheduleCount`
- `scheduleFabUnreadReconcile()` — cancel prior timer, ~300ms, then `requestChatUnreadTotal` + `requestChatUnreadMentionTotal`
- `requestChatUnreadTotal()` — mirrors mention request pattern
- `updateChatFabFromSeenBroadcast` — self match → apply total if present; always schedule reconcile; fail-safes preserved
- `onClose` — cancel reconcile timer

### lib/main.dart
- `AppLifecycleState.resumed`: after socket resume, if ChatFabController registered → `scheduleFabUnreadReconcile()` in try/catch

### test/chat_fab_controller_test.dart
- Schedule-count assertions on existing fail-safes
- Self with/without total schedules reconcile
- Non-self/empty does not schedule
- fake_async debounce test with `_RecordingSocketService`

## Validation artifacts (Task 3)
- `.superpowers/sdd/fab-unread-reconcile/task-3-manual-checklist.md` — steps 1–5 Pending (human)
- graphify update ran successfully

## Minor carry-forward from task reviews
- T1: no explicit unparsable-total test
- T2: no lifecycle unit test for resume hook
- T3: human E2E steps 1–5 still Pending
- Stale parallel chat-fab-sync checklist docs

## Test evidence
`flutter test test/chat_fab_controller_test.dart` → 9/9 PASS (Task 1 + Task 3)

Read full sources as needed:
- lib/src/domain/chat/controller/chat_fab.controller.dart
- lib/main.dart (didChangeAppLifecycleState)
- test/chat_fab_controller_test.dart
