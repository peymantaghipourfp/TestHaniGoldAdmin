# Review package — Task 2 (Chat FAB Cross-Tab Sync)

**Base:** Task 1 complete (no chat.seen FAB handler)
**Head:** Task 2 implementation (no git SHAs)

## Commits
none (no git repository)

## Stat summary
```
 lib/src/domain/chat/controller/chat_fab.controller.dart | +~40 lines
 1 file changed
 test/chat_fab_controller_test.dart | unchanged
```

## Full diff (reconstructed)

### handleSocketEnvelope — insert chat.seen branch before generic chat.*

```diff
--- a/lib/src/domain/chat/controller/chat_fab.controller.dart
+++ b/lib/src/domain/chat/controller/chat_fab.controller.dart
@@ handleSocketEnvelope
       } else if (channel == 'ack') {
         updateChatFabFromSocketAck(envelope);
         _deferChatControllerCall(
               (controller) => controller.handleSocketAckEnvelope(envelope),
         );
+      } else if (channel == 'chat.seen') {
+        updateChatFabFromSeenBroadcast(envelope);
+        _forwardChatSocketEnvelope(envelope);
       } else if (channel is String && channel.startsWith('chat.')) {
         _forwardChatSocketEnvelope(envelope);
       } else if (channel == 'error') {
```

### New method after updateChatFabFromChatMessage

```diff
+  /// Updates FAB from self `chat.seen` when [SocketChatSeenBroadcastModel.data.totalUnreadMessageCount] is present.
+  void updateChatFabFromSeenBroadcast(Map<String, dynamic> envelope) {
+    try {
+      final rawData = envelope['data'];
+      if (rawData is! Map) return;
+      final data = Map<String, dynamic>.from(rawData);
+      if (data.isEmpty) return;
+
+      final byUserIdRaw = data['byUserId'];
+      final byUserId = byUserIdRaw is int
+          ? byUserIdRaw
+          : byUserIdRaw is num
+              ? byUserIdRaw.toInt()
+              : int.tryParse('$byUserIdRaw');
+      final myUserId = _currentUserIdFromStorage();
+      if (byUserId == null || myUserId == null || byUserId != myUserId) {
+        return;
+      }
+
+      final totalRaw = data['totalUnreadMessageCount'];
+      if (totalRaw == null) return; // do not clear blindly
+      final totalUnread = totalRaw is int
+          ? totalRaw
+          : totalRaw is num
+              ? totalRaw.toInt()
+              : int.tryParse('$totalRaw');
+      if (totalUnread == null) return;
+
+      applyChatFabUnreadCount(totalUnread);
+      if (totalUnread == 0) {
+        applyChatFabUnreadMentionCount(0);
+      }
+    } catch (e, s) {
+      AppLogger.e('updateChatFabFromSeenBroadcast failed', e, s);
+    }
+  }
```

## Implementer test claims
- flutter test test/chat_fab_controller_test.dart → 5/5 All tests passed
- flutter analyze …chat_fab.controller.dart → No issues found
- graphify update . → done
