# Task 1: Reconcile API + self-seen scheduling

**Plan:** FAB cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-fab-cross-tab-unread.md`)

## Goal

Defense-in-depth inside `ChatFabController` only: on self `chat.seen`, keep applying `totalUnreadMessageCount` when present, and **always** schedule a debounced server reconcile so other windows converge even when the broadcast omits the total or races.

## Interfaces (exact)

- `Future<void> requestChatUnreadTotal()` — same pattern as existing `requestChatUnreadMentionTotal()`:
  - Guard `Get.isRegistered<SocketService>()`
  - `ensureConnected(clientId: userId from box)`
  - `Uuid.v4()` → `registerUnreadTotalRequest(reqId)`
  - `SocketService.to.send(SocketChatUnreadTotalRequest(reqId: reqId).toJson())`
  - try/catch with `Get.log` (do not throw)
- `void scheduleFabUnreadReconcile()`:
  - Cancel prior `Timer`
  - Schedule ~300ms delay, then call both `requestChatUnreadTotal()` and `requestChatUnreadMentionTotal()` (unawaited / fire-and-forget)
  - `@visibleForTesting int fabUnreadReconcileScheduleCount` increments on **each** call to `scheduleFabUnreadReconcile` (test hook)
- Cancel `_fabUnreadReconcileTimer` in `onClose`

## Wire into `updateChatFabFromSeenBroadcast`

On **self** `chat.seen` (`byUserId` matches stored `id`):

1. If `totalUnreadMessageCount` parses → `applyChatFabUnreadCount` (and clear mention when total is 0) — **keep current behavior**.
2. **Always** call `scheduleFabUnreadReconcile()` after the self-user check succeeds (even when total is missing / unparsable — do **not** return before scheduling once self is confirmed).
3. Empty/`null`/`{}` data, other users, non-map data → no-op, no throw, **do not** schedule (keep existing early returns before self check).
4. Parse failures for total → do not change FAB, but still schedule reconcile if self matched.

Suggested control flow (preserve fail-safes):

```
try {
  rawData not Map → return
  data empty → return
  byUserId / myUserId missing or mismatch → return
  // self confirmed:
  if totalRaw present and parses → apply (+ clear mention if 0)
  scheduleFabUnreadReconcile()  // ALWAYS for self
} catch → log
```

## TDD steps

Write failing tests in `test/chat_fab_controller_test.dart` first, then implement:

1. Self seen **with** total → FAB updates **and** `fabUnreadReconcileScheduleCount` increments.
2. Self seen **without** total → FAB unchanged **and** schedule count increments.
3. Empty data / other `byUserId` → schedule count does **not** increment; FAB unchanged; no throw.
4. `scheduleFabUnreadReconcile` cancels prior timer (use `fake_async` / `FakeAsync` — two rapid schedules, only one fire after 300ms; or assert second call cancels first — debounce behavior).
5. Existing fail-safe tests must still pass (empty data, other admin, missing total does not clear blindly).

Run: `flutter test test/chat_fab_controller_test.dart` → PASS.

## Files to change

- `lib/src/domain/chat/controller/chat_fab.controller.dart`
- `test/chat_fab_controller_test.dart`

## Fail-safe rules (non-negotiable)

- Never apply FAB = 0 because `data` is empty or `totalUnreadMessageCount` is absent.
- All socket handlers stay in try/catch.
- No second global socket subscription.
- Do **not** clear FAB from conversation-level `unreadMessageCount` alone.
- Do **not** touch `main.dart` (Task 2) or run graphify (Task 3).

## Workspace note

No git repository — **do not attempt commits**. Implement, test, write report only.
