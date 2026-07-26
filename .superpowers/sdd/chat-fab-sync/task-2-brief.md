# Task 2: Implement `chat.seen` → FAB (GREEN)

**Files:**
- Modify: [`lib/src/domain/chat/controller/chat_fab.controller.dart`](lib/src/domain/chat/controller/chat_fab.controller.dart)
- Test: [`test/chat_fab_controller_test.dart`](test/chat_fab_controller_test.dart)

**Interfaces:**
- Consumes: `_currentUserIdFromStorage()`, `applyChatFabUnreadCount`, `applyChatFabUnreadMentionCount`, existing socket envelope shape
- Produces: `void updateChatFabFromSeenBroadcast(Map<String, dynamic> envelope)`

- [ ] **Step 1: Add `chat.seen` branch in `handleSocketEnvelope` (before generic `chat.*`)**

```dart
} else if (channel == 'chat.seen') {
  updateChatFabFromSeenBroadcast(envelope);
  _forwardChatSocketEnvelope(envelope);
} else if (channel is String && channel.startsWith('chat.')) {
  _forwardChatSocketEnvelope(envelope);
}
```

- [ ] **Step 2: Implement `updateChatFabFromSeenBroadcast` (fail-safe)**

```dart
/// Updates FAB from self `chat.seen` when [SocketChatSeenBroadcastModel.data.totalUnreadMessageCount] is present.
void updateChatFabFromSeenBroadcast(Map<String, dynamic> envelope) {
  try {
    final rawData = envelope['data'];
    if (rawData is! Map) return;
    final data = Map<String, dynamic>.from(rawData);
    if (data.isEmpty) return;

    final byUserIdRaw = data['byUserId'];
    final byUserId = byUserIdRaw is int
        ? byUserIdRaw
        : byUserIdRaw is num
            ? byUserIdRaw.toInt()
            : int.tryParse('$byUserIdRaw');
    final myUserId = _currentUserIdFromStorage();
    if (byUserId == null || myUserId == null || byUserId != myUserId) {
      return;
    }

    final totalRaw = data['totalUnreadMessageCount'];
    if (totalRaw == null) return; // do not clear blindly
    final totalUnread = totalRaw is int
        ? totalRaw
        : totalRaw is num
            ? totalRaw.toInt()
            : int.tryParse('$totalRaw');
    if (totalUnread == null) return;

    applyChatFabUnreadCount(totalUnread);
    if (totalUnread == 0) {
      applyChatFabUnreadMentionCount(0);
    }
  } catch (e, s) {
    AppLogger.e('updateChatFabFromSeenBroadcast failed', e, s);
  }
}
```

Notes for implementer:
- Prefer defensive map access (as above) over forcing full `SocketChatSeenBroadcastModel.fromJson` if incomplete envelopes would throw — tests use partial `data` maps.
- Outer `handleSocketEnvelope` try/catch remains; this method must also catch so bad payloads never crash the stream listener.
- Do **not** register/request unread totals inside this handler (avoids ack storms across tabs).
- Do **not** touch `_pendingUnreadTotalReqIds` here.

- [ ] **Step 3: Re-run tests — expect all PASS**

```bash
flutter test test/chat_fab_controller_test.dart
```

Expected: All tests in group `ChatFabController chat.seen` PASS.

- [ ] **Step 4: Static analysis on touched file**

```bash
flutter analyze lib/src/domain/chat/controller/chat_fab.controller.dart
```

Expected: no new errors.

- [ ] **Step 5: `graphify update .`** (workspace rule after code changes)

- [ ] **Step 6: Commit** only if the user asks. (No git in this workspace — skip commits.)
