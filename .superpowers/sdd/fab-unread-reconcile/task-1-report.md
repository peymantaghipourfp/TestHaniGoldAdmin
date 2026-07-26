# Task 1 Report: Reconcile API + self-seen scheduling

**Status:** DONE  
**Date:** 2026-07-11  
**Plan:** FAB cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-fab-cross-tab-unread.md`)

---

## What was implemented

Defense-in-depth inside `ChatFabController` only:

1. **`requestChatUnreadTotal()`** — mirrors `requestChatUnreadMentionTotal()`: guards `SocketService` registration, `ensureConnected(clientId: userId)`, `Uuid.v4()` + `registerUnreadTotalRequest`, sends `SocketChatUnreadTotalRequest`, try/catch with `Get.log`.
2. **`scheduleFabUnreadReconcile()`** — cancels prior `Timer`, increments `fabUnreadReconcileScheduleCount`, schedules ~300ms then fires both unread-total and mention-total requests (unawaited).
3. **`updateChatFabFromSeenBroadcast`** — on self `chat.seen`: applies `totalUnreadMessageCount` when present/parsable (clears mention when total is 0); **always** schedules reconcile after self-user match; early returns unchanged for empty/non-map/other-user data.
4. **`onClose`** — cancels `_fabUnreadReconcileTimer`.

---

## TDD Evidence RED

### Step 1 — Failing tests written first

Added/extended tests in `test/chat_fab_controller_test.dart` referencing `fabUnreadReconcileScheduleCount`, `scheduleFabUnreadReconcile`, and debounce behavior before any production changes.

**Command:**

```bash
flutter test test/chat_fab_controller_test.dart
```

**Result:** EXIT 1 (compilation failure)

```
Error: The getter 'fabUnreadReconcileScheduleCount' isn't defined for the type 'ChatFabController'.
Error: The method 'scheduleFabUnreadReconcile' isn't defined for the type 'ChatFabController'.
```

**Why expected:** New API surface and reconcile scheduling not yet implemented. Tests could not load until controller was updated.

---

## TDD Evidence GREEN

### Step 2 — Implementation

Updated `lib/src/domain/chat/controller/chat_fab.controller.dart` with reconcile API, debounced scheduler, self-seen wiring, and timer cleanup in `onClose`.

**Command:**

```bash
flutter test test/chat_fab_controller_test.dart
```

**Result:** EXIT 0 — **9/9 passed**

```
ChatFabController chat.seen local admin read applies totalUnreadMessageCount to FAB
ChatFabController chat.seen another admin read does not change FAB
ChatFabController chat.seen empty or non-map data does not throw or change FAB
ChatFabController chat.seen self seen with totalUnread 0 also clears mention badge
ChatFabController chat.seen self seen with missing totalUnread does not clear unread blindly
ChatFabController chat.seen self seen with total schedules reconcile and updates FAB
ChatFabController chat.seen self seen without total schedules reconcile without changing FAB
ChatFabController chat.seen non-self or empty seen data does not schedule reconcile
ChatFabController scheduleFabUnreadReconcile debounces rapid schedules so reconcile fires once
All tests passed!
```

---

## Test coverage matrix

| Test | FAB behavior | `fabUnreadReconcileScheduleCount` | Debounce |
| --- | --- | --- | --- |
| local admin read applies total | 5 → 0 | 1 | — |
| another admin read | stays 5 | 0 | — |
| empty / non-map data | stays 3 / mention 2 | 0 | — |
| self seen total 0 clears mention | unread+mention → 0 | 1 | — |
| self seen missing total | stays 7 | 1 | — |
| self seen with total | 5 → 2 | 1 | — |
| self seen without total | stays 7 | 1 | — |
| non-self or empty | stays 3 | 0 | — |
| rapid `scheduleFabUnreadReconcile` | — | 2 | 2 socket sends after 400ms (not 4) |

---

## Files changed

| File | Change |
| --- | --- |
| `lib/src/domain/chat/controller/chat_fab.controller.dart` | `requestChatUnreadTotal`, `scheduleFabUnreadReconcile`, `fabUnreadReconcileScheduleCount`, self-seen reconcile wiring, timer cancel in `onClose` |
| `test/chat_fab_controller_test.dart` | New reconcile/debounce tests; schedule-count assertions on existing fail-safe tests; `_RecordingSocketService` + `fake_async` for debounce |
| `.superpowers/sdd/fab-unread-reconcile/task-1-report.md` | This report |

**Not changed:** `main.dart`, graphify, ChatController, other plan tasks.

**Commits:** none (no git repository in workspace).

---

## Self-review

- [x] TDD order: failing tests first, then implementation, then green run
- [x] `requestChatUnreadTotal` mirrors mention pattern on `ChatFabController` (not delegated to `ChatController`)
- [x] Self `chat.seen` always schedules reconcile; missing/unparsable total does not blind-clear FAB
- [x] Empty/non-map/other-user paths do not schedule; no throw
- [x] Debounce cancels prior timer (~300ms); fires unread + mention requests once
- [x] `_fabUnreadReconcileTimer` cancelled in `onClose`
- [x] No second global socket subscription
- [x] All socket handlers remain in try/catch
- [x] `flutter test test/chat_fab_controller_test.dart` → 9/9 PASS
- [x] No commit attempted

---

## Concerns

1. **Debounce test uses `_RecordingSocketService` subclass** with empty `onInit` — adequate for unit scope; integration with real `SocketService` lifecycle is Task 2+ territory.
2. **Reconcile fires even when broadcast total is applied** — intentional per brief (defense-in-depth for tear-off windows); may cause extra server round-trips on every self-seen (debounced).
3. **No git commit** — working tree only.

None block Task 2 (`main.dart` wiring) or manual cross-window verification.
