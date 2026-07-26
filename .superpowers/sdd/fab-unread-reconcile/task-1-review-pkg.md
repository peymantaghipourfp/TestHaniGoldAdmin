# Review package — Task 1 (no git; full file snapshots)

Base: pre-Task-1 working tree (prior chat.seen fail-safe only)
Head: post-Task-1 working tree (reconcile API)

## Files changed
- lib/src/domain/chat/controller/chat_fab.controller.dart
- test/chat_fab_controller_test.dart

## Summary of change

Added `requestChatUnreadTotal`, debounced `scheduleFabUnreadReconcile` (+ `fabUnreadReconcileScheduleCount` test hook), wired always-schedule on self `chat.seen`, cancel timer in `onClose`. Extended unit tests including fake_async debounce.

## Diff (logical) — chat_fab.controller.dart

### New fields (class body)
```dart
  Timer? _fabUnreadReconcileTimer;

  /// Test hook: increments each time [scheduleFabUnreadReconcile] is called.
  @visibleForTesting
  int fabUnreadReconcileScheduleCount = 0;
```

### updateChatFabFromSeenBroadcast (changed)
After self-user match, apply total when present/parsable; **always** `scheduleFabUnreadReconcile()` (no early return on missing total before schedule).

```dart
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
      if (totalRaw != null) {
        final totalUnread = totalRaw is int
            ? totalRaw
            : totalRaw is num
                ? totalRaw.toInt()
                : int.tryParse('$totalRaw');
        if (totalUnread != null) {
          applyChatFabUnreadCount(totalUnread);
          if (totalUnread == 0) {
            applyChatFabUnreadMentionCount(0);
          }
        }
      }

      scheduleFabUnreadReconcile();
    } catch (e, s) {
      AppLogger.e('updateChatFabFromSeenBroadcast failed', e, s);
    }
  }
```

### New methods
```dart
  void scheduleFabUnreadReconcile() {
    _fabUnreadReconcileTimer?.cancel();
    fabUnreadReconcileScheduleCount++;
    _fabUnreadReconcileTimer = Timer(const Duration(milliseconds: 300), () {
      unawaited(requestChatUnreadTotal());
      unawaited(requestChatUnreadMentionTotal());
    });
  }

  Future<void> requestChatUnreadTotal() async {
    if (!Get.isRegistered<SocketService>()) return;
    try {
      final userId = box.read('id')?.toString();
      await SocketService.to.ensureConnected(clientId: userId);
      final reqId = _uuid.v4();
      registerUnreadTotalRequest(reqId);
      SocketService.to.send(
        SocketChatUnreadTotalRequest(reqId: reqId).toJson(),
      );
    } catch (e) {
      Get.log('requestChatUnreadTotal (fab): $e');
    }
  }
```

### onClose
```dart
  void onClose() {
    _socketSubscription?.cancel();
    _fabUnreadReconcileTimer?.cancel();
    super.onClose();
  }
```

## Diff (logical) — test/chat_fab_controller_test.dart

Full file after Task 1 (224 lines): adds schedule-count assertions to existing fail-safe tests; adds tests for self with/without total scheduling; non-self/empty no schedule; fake_async debounce with `_RecordingSocketService`.

Key new assertions:
- self with total → FAB updates + scheduleCount 1
- self without total → FAB unchanged + scheduleCount 1
- other user / empty → scheduleCount 0
- two rapid schedules → scheduleCount 2, only 2 socket sends after 300ms (not 4)

Read full test file if needed: `test/chat_fab_controller_test.dart`
