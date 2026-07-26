# Task 2 Report: Implement `chat.seen` → FAB (GREEN)

## What I Did

1. Read the task brief at `.superpowers/sdd/chat-fab-sync/task-2-brief.md`.
2. Added a dedicated `chat.seen` branch in `handleSocketEnvelope` (before generic `chat.*`).
3. Implemented `updateChatFabFromSeenBroadcast` with defensive map access and fail-safe try/catch.
4. Re-ran tests, static analysis, and `graphify update .`.

## TDD RED Reference (Task 1 Baseline)

From Task 1 report (`.superpowers/sdd/chat-fab-sync/task-1-report.md`):

- **Command:** `flutter test test/chat_fab_controller_test.dart`
- **Result:** 3 passed, 2 failed (exit code 1)
- **Failing tests:**
  - `local admin read applies totalUnreadMessageCount to FAB` — expected unread 0, actual 5
  - `self seen with totalUnread 0 also clears mention badge` — expected unread 0, actual 4
- **Root cause:** `chat.seen` fell into generic `chat.*` forward-only branch; no FAB update logic existed.

## Implementation

### `handleSocketEnvelope` — new branch

```dart
} else if (channel == 'chat.seen') {
  updateChatFabFromSeenBroadcast(envelope);
  _forwardChatSocketEnvelope(envelope);
} else if (channel is String && channel.startsWith('chat.')) {
  _forwardChatSocketEnvelope(envelope);
```

### `updateChatFabFromSeenBroadcast`

- Defensive parsing of `envelope['data']` (Map check, empty guard).
- Only applies when `byUserId` matches `_currentUserIdFromStorage()`.
- Requires `totalUnreadMessageCount` to be present (does not clear blindly).
- Calls `applyChatFabUnreadCount(totalUnread)`.
- When `totalUnread == 0`, also calls `applyChatFabUnreadMentionCount(0)`.
- Inner try/catch logs via `AppLogger.e` — never crashes the stream listener.
- Does **not** touch `_pendingUnreadTotalReqIds` or request unread totals.

Placed immediately after `updateChatFabFromChatMessage`, near other FAB update helpers.

## GREEN — Test Command & Output

```bash
flutter test test/chat_fab_controller_test.dart
```

```
00:00 +0: loading D:/curserAi project/test/chat_fab_controller_test.dart
00:00 +0: (setUpAll)
00:00 +0: ChatFabController chat.seen local admin read applies totalUnreadMessageCount to FAB
00:00 +1: ChatFabController chat.seen another admin read does not change FAB
00:00 +2: ChatFabController chat.seen empty or non-map data does not throw or change FAB
00:00 +3: ChatFabController chat.seen self seen with totalUnread 0 also clears mention badge
00:00 +4: ChatFabController chat.seen self seen with missing totalUnread does not clear unread blindly
00:00 +5: (tearDownAll)
00:00 +5: All tests passed!
```

**Summary:** 5 passed, 0 failed (exit code 0). RED → GREEN confirmed.

## Static Analysis

```bash
flutter analyze lib/src/domain/chat/controller/chat_fab.controller.dart
```

```
Analyzing chat_fab.controller.dart...
No issues found! (ran in 14.2s)
```

## Graphify

```bash
graphify update .
```

```
Re-extracting code files in . (no LLM needed)...
  AST extraction: 731/731 files (100%)
[graphify watch] Rebuilt: 8447 nodes, 15696 edges, 494 communities
[graphify watch] graph.json and GRAPH_REPORT.md updated in graphify-out
Code graph updated.
```

Done.

## Files Changed

| File | Change |
| --- | --- |
| `lib/src/domain/chat/controller/chat_fab.controller.dart` | Added `chat.seen` branch + `updateChatFabFromSeenBroadcast` |

**Not modified:** `test/chat_fab_controller_test.dart` (kept as-is per brief).

## Self-Review

- **Brief compliance:** Implementation matches verbatim code from task brief.
- **Self-seen guard:** Other admins' reads correctly no-op (byUserId != myUserId).
- **Fail-safe:** Empty/null/non-map data handled without throw; outer + inner catch in place.
- **No ack storms:** No unread-total requests or `_pendingUnreadTotalReqIds` changes.
- **Forward preserved:** `_forwardChatSocketEnvelope` still called after FAB update.
- **Mention clear rule:** Only clears mention badge when `totalUnread == 0` (not on partial payloads).
- **Style:** Matches existing indentation, logging (`AppLogger.e`), and helper placement.

## Concerns

1. **Mention count on partial zero-unread:** When `totalUnread > 0`, mention badge is not updated from `chat.seen` (only cleared when total hits 0). This matches the brief and tests; if server sends `unreadMentionCount` in seen payloads for non-zero totals, a future task may need to handle it.
2. **Doc comment reference:** `updateChatFabFromSeenBroadcast` doc mentions `SocketChatSeenBroadcastModel` but uses defensive map access instead of `fromJson` — intentional per brief; no import added.

## Commits

None (no git repository in workspace).
