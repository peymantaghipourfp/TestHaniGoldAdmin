# Task 1 Report: Confirm RED Baseline

## What I Did

1. Read the task brief at `.superpowers/sdd/chat-fab-sync/task-1-brief.md`.
2. Ran exactly: `flutter test test/chat_fab_controller_test.dart`
3. Compared results against brief expectations (FAIL vs PASS).
4. Verified production code was **not** modified (no implementation of `updateChatFabFromSeenBroadcast`).
5. Inspected `ChatFabController.handleSocketEnvelope` to confirm why tests fail (forward-only for `chat.seen`).

## Test Command

```bash
flutter test test/chat_fab_controller_test.dart
```

## Full Test Output

```
00:00 +0: loading D:/curserAi project/test/chat_fab_controller_test.dart
00:00 +0: (setUpAll)
00:00 +0: ChatFabController chat.seen local admin read applies totalUnreadMessageCount to FAB
00:00 +0 -1: ChatFabController chat.seen local admin read applies totalUnreadMessageCount to FAB [E]
  Expected: <0>
    Actual: <5>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\chat_fab_controller_test.dart 47:7             main.<fn>.<fn>
  
00:00 +0 -1: ChatFabController chat.seen another admin read does not change FAB
00:00 +1 -1: ChatFabController chat.seen empty or non-map data does not throw or change FAB
00:00 +2 -1: ChatFabController chat.seen self seen with totalUnread 0 also clears mention badge
00:00 +2 -2: ChatFabController chat.seen self seen with totalUnread 0 also clears mention badge [E]
  Expected: <0>
    Actual: <4>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\chat_fab_controller_test.dart 104:7            main.<fn>.<fn>
  
00:00 +2 -2: ChatFabController chat.seen self seen with missing totalUnread does not clear unread blindly
00:00 +3 -2: (tearDownAll)
00:00 +3 -2: Some tests failed.

Failing tests:
  D:/curserAi project/test/chat_fab_controller_test.dart: ChatFabController chat.seen local admin read applies totalUnreadMessageCount to FAB
  D:/curserAi project/test/chat_fab_controller_test.dart: ChatFabController chat.seen self seen with totalUnread 0 also clears mention badge
```

**Summary:** 3 passed, 2 failed (exit code 1).

## TDD RED Evidence

### Results vs Brief Expectations

| Test | Brief Expected | Actual | Match? |
| --- | --- | --- | --- |
| `local admin read applies totalUnreadMessageCount to FAB` | FAIL | FAIL | Yes |
| `self seen with totalUnread 0 also clears mention badge` | FAIL | FAIL | Yes |
| `another admin read does not change FAB` | PASS | PASS | Yes |
| `empty or non-map data does not throw or change FAB` | PASS | PASS | Yes |
| `self seen with missing totalUnread does not clear unread blindly` | PASS | PASS | Yes |

All five outcomes match the brief exactly. RED baseline confirmed.

### Failure Details

1. **`local admin read applies totalUnreadMessageCount to FAB`**
   - Setup: FAB unread = 5; socket envelope `chat.seen` with `byUserId: 42` (local admin) and `totalUnreadMessageCount: 0`.
   - Expected: `chatFabUnreadCount` → 0, `chatFabHighlight` → false.
   - Actual: unread stayed at **5** (no FAB update).

2. **`self seen with totalUnread 0 also clears mention badge`**
   - Setup: unread = 4, mention = 2; self `chat.seen` with `totalUnreadMessageCount: 0`.
   - Expected: unread → 0, mention → 0, highlight → false.
   - Actual: unread stayed at **4**, mention unchanged (no FAB update).

### Why Production Is RED (Not Yet Implemented)

In `lib/src/domain/chat/controller/chat_fab.controller.dart`, `handleSocketEnvelope` handles `chat.message` and `ack` with dedicated FAB logic, but `chat.seen` matches only the generic branch:

```dart
} else if (channel is String && channel.startsWith('chat.')) {
  _forwardChatSocketEnvelope(envelope);
}
```

So `chat.seen` is forward-only — no call to any seen-broadcast handler. The three passing tests align with current behavior: other-admin reads, malformed/empty data, and missing `totalUnreadMessageCount` correctly leave FAB state unchanged.

## Files Changed

**None.** No production or test files were modified in this task.

## Concerns

None. Test suite behavior matches the brief; RED baseline is ready for Task 2 (implement `updateChatFabFromSeenBroadcast` and wire it in `handleSocketEnvelope`).
