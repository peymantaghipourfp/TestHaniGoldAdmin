# Final branch review package — Chat FAB Cross-Tab Sync

**Plan:** c:\Users\Admin\.cursor\plans\chat_fab_cross-tab_sync_bb16bf29.plan.md
**Merge base:** N/A (no git) — review production + test delta for this plan
**Head:** workspace after Tasks 1–3

## Progress ledger summary
- Task 1: complete — RED baseline 3 pass / 2 fail confirmed
- Task 2: complete — updateChatFabFromSeenBroadcast + chat.seen branch; 5/5 GREEN; analyze clean
- Task 3: complete — manual checklist authored; dual-tab Pending for human

## Minor carry-forward (from task reviews)
- Doc comment references SocketChatSeenBroadcastModel without import (intentional defensive maps)
- No unit test for non-zero self-read total (e.g. 5→3)
- Mention badge only cleared when totalUnread == 0 (plan-mandated)
- Dual-tab E2E still Pending (human)
- Stale checklist redirected to chat-fab-sync path

## Production diff (full)

File: lib/src/domain/chat/controller/chat_fab.controller.dart

1) In handleSocketEnvelope, before generic chat.*:

```dart
} else if (channel == 'chat.seen') {
  updateChatFabFromSeenBroadcast(envelope);
  _forwardChatSocketEnvelope(envelope);
}
```

2) New method:

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

## Tests
test/chat_fab_controller_test.dart — group ChatFabController chat.seen (pre-existing; now GREEN)
Claimed: flutter test → 5/5 All tests passed

## Docs
.superpowers/sdd/chat-fab-sync/task-3-manual-checklist.md
