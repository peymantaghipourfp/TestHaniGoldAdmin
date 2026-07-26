# Review package: Task 1 (ChatAccountItem unread helpers)
**Base:** pre-task working tree (no git)
**Head:** post-Task-1 working tree
**Note:** No git repository — full file contents of changed files below (not a unified diff).

## Commits
(none — no git)

## Files changed (from implementer report)
# Task 1 Report: Pure helpers + account reconcile semantics

**Status:** DONE  
**Date:** 2026-07-11  
**Plan:** ChatAccountItem cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-account-item-cross-tab-unread.md`)

---

## What was implemented

Restored four pure helpers in `chat_conversation_unread.dart` and added tests locking absent-thread `threadJustRead` semantics for Task 2 controller wiring.

### Restored helpers

1. **`seenBroadcastAffectsLocalUnread`** â€” returns `true` only when both `broadcastByUserId` and `localUserId` are non-null and equal; `false` on mismatch or either null.

2. **`resolveThreadUnreadFromSocket`** â€” prefers authoritative `serverCount` when present (clamps negatives to 0); when `serverCount` is absent, increments local by 1 if `incrementFallback`, else keeps local. Does not invent zero from absent server data.

3. **`mergeSocketMentionIntoUnreadList`** â€” inserts a mention sorted by `seq`, deduped by `messageGuid`. Helper-only this task (not wired into message path).

4. **`threadJustReadFromSeenBroadcast`** â€” new helper for Task 2:
   - `true` when `newChatUnread == 0` and (`previousChatUnread > 0` OR chat was **not** in local list)
   - `false` when `newChatUnread` is null, positive, or chat was already read in list (`previousChatUnread == 0` and `chatWasInLocalList`)

### Absent-thread reconcile tests

Added integration test proving: chat absent from loaded list + authoritative unread `0` â†’ `threadJustReadFromSeenBroadcast` is `true` â†’ `reconcileAccountUnreadChatCount` drops account count by at least one (`3 â†’ 2` with `reconciled: null`).

---

## TDD Evidence RED

### Step 1 â€” Existing tests fail to compile (missing symbols)

**Command:**

```powershell
cd "d:\curserAi project"; flutter test test/chat_conversation_unread_test.dart
```

**Result:** EXIT 1 (compilation failure)

```
Error: Method not found: 'seenBroadcastAffectsLocalUnread'.
Error: Method not found: 'resolveThreadUnreadFromSocket'.
Error: Method not found: 'mergeSocketMentionIntoUnreadList'.
```

**Why expected:** Helpers were referenced by existing tests but not yet implemented in `chat_conversation_unread.dart`.

---

## TDD Evidence GREEN

### Step 2 â€” Implement helpers + absent-thread tests

Updated `lib/src/domain/chat/utils/chat_conversation_unread.dart` with all four helpers.  
Extended `test/chat_conversation_unread_test.dart` with `threadJustReadFromSeenBroadcast` group (5 cases) and `absent-thread account reconcile` integration test.

**Command:**

```powershell
cd "d:\curserAi project"; flutter test test/chat_conversation_unread_test.dart
```

**Result:** EXIT 0 â€” **28/28 passed**

```
conversationUnreadAfterSeen (3)
seenBroadcastAffectsLocalUnread (3)
conversationUnreadAfterSeenBroadcast (3)
messageMentionsAccount (3)
unreadMentionsAfterSeen (1)
shouldIncrementAccountUnreadChatCount (2)
reconcileAccountUnreadChatCount (2)
resolveThreadUnreadFromSocket (4)
threadJustReadFromSeenBroadcast (5)
absent-thread account reconcile (1)
mergeSocketMentionIntoUnreadList (1)
All tests passed!

## FILE: lib/src/domain/chat/utils/chat_conversation_unread.dart
import 'package:hanigold_admin/src/domain/chat/model/chat.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat_message.model.dart';
import 'package:hanigold_admin/src/domain/chat/widget/chat_row.dart';

import '../model/chat_unread_mentions.model.dart';

/// [Scrollable.ensureVisible] alignment that pins a bubble to the viewport bottom
/// in a reversed vertical [ListView] (leading edge).
const double kLastReadAnchorAlignment = 0.0;

/// Seq of the last message the admin has read (prefers [ChatModel.clientSeenSeq]).
int lastReadAnchorSeq(ChatModel chat) {
  final client = chat.clientSeenSeq ?? 0;
  final lastSeen = chat.lastSeenSeq ?? 0;
  final lastMsg = chat.lastMessageSeq ?? 0;
  final unread = chat.unreadMessageCount ?? 0;

  if (unread > 0 && lastMsg > 0) {
    final inferredLastRead = lastMsg - unread;
    if (inferredLastRead > 0 &&
        (client <= 0 || client + unread > lastMsg)) {
      return inferredLastRead;
    }
  }

  if (client > 0) return client;
  return lastSeen;
}

/// Whether opening the thread should land on the last-read bubble, not the latest.
bool shouldAnchorConversationToLastRead(ChatModel chat) {
  final anchor = lastReadAnchorSeq(chat);
  if (anchor <= 0) return false;
  final unread = chat.unreadMessageCount ?? 0;
  if (unread > 0) return true;
  final lastMsgSeq = chat.lastMessageSeq ?? 0;
  return lastMsgSeq > anchor;
}

/// Pre-scroll fraction for a reversed [ListView] (row 0 = newest at offset 0).
double estimateReversedListPreJumpFraction(int rowIndex, int rowCount) {
  if (rowCount <= 1 || rowIndex <= 0) return 0;
  return (rowIndex / rowCount).clamp(0.0, 1.0);
}
/// Messages in [messages] with [seq] strictly greater than [seenUpToSeq].
int countMessagesWithSeqAbove(
    Iterable<ChatMessageModel> messages,
    int seenUpToSeq,
    ) {
  var n = 0;
  for (final m in messages) {
    final s = m.seq;
    if (s != null && s > seenUpToSeq) n++;
  }
  return n;
}

/// Pill badge count after the admin has read up to [newSeenSeq].
///
/// Uses loaded messages when they cover the thread tail; otherwise decrements
/// [serverUnread] by how far [newSeenSeq] advanced past [anchorSeenSeq].
int conversationUnreadAfterSeen({
  required int serverUnread,
  required int anchorSeenSeq,
  required int newSeenSeq,
  required Iterable<ChatMessageModel> loadedMessages,
  required int lastMessageSeq,
  required int maxLoadedSeq,
}) {
  if (newSeenSeq <= anchorSeenSeq) {
    return serverUnread.clamp(0, 999999);
  }

  if (maxLoadedSeq >= lastMessageSeq && lastMessageSeq > 0) {
    return countMessagesWithSeqAbove(loadedMessages, newSeenSeq);
  }

  final progressed = (newSeenSeq - anchorSeenSeq).clamp(0, serverUnread);
  return (serverUnread - progressed).clamp(0, serverUnread);
}

/// Estimates the highest message [seq] visible in a reversed [ListView].
int? maxVisibleSeqInReversedRows({
  required List<ChatRow> rows,
  required double scrollPixels,
  required double viewportDimension,
  double estimatedRowExtent = 72,
}) {
  if (rows.isEmpty || estimatedRowExtent <= 0) return null;

  final firstIndex = (scrollPixels / estimatedRowExtent).floor();
  final lastIndex = (firstIndex + (viewportDimension / estimatedRowExtent).ceil())
      .clamp(0, rows.length - 1);

  var maxSeq = 0;
  var found = false;
  for (var i = firstIndex; i <= lastIndex; i++) {
    final row = rows[i];
    if (row is! BubbleRow) continue;
    final seq = row.msg.seq;
    if (seq == null) continue;
    found = true;
    if (seq > maxSeq) maxSeq = seq;
  }
  return found ? maxSeq : null;
}

/// Whether [mentions] target the logged-in admin ([currentUserId]).
bool messageMentionsAccount(
    Iterable<MessageMention>? mentions,
    int? currentUserId,
    ) {
  if (mentions == null || currentUserId == null) return false;
  return mentions.any((m) =>
  m.mentionedUserId == currentUserId ||
      m.mentionedAccountId == currentUserId);
}

/// Mentions still unread after the read cursor advanced to [seenUpToSeq].
/// Drops only mentions with a known [seq] at or below the seen cursor.
/// Mentions with a null [seq] are kept because their position is unknown.
List<ChatUnreadMentionsModel> unreadMentionsAfterSeen(
    Iterable<ChatUnreadMentionsModel> mentions,
    int seenUpToSeq,
    ) {
  return mentions.where((m) => m.seq == null || m.seq! > seenUpToSeq).toList();
}

/// Whether a realtime message should raise account [unreadChatCount] by one thread.
bool shouldIncrementAccountUnreadChatCount({
  required bool incrementUnread,
  required int threadUnreadBefore,
  required bool threadRowInList,
  required String? accountLastChatId,
  required String chatId,
  required int accountUnreadChatCount,
}) {
  if (!incrementUnread) return false;
  if (threadRowInList) {
    return threadUnreadBefore == 0;
  }
  return accountLastChatId != chatId || accountUnreadChatCount == 0;
}

/// Derives account [unreadChatCount] from loaded [chats], or null when none match.
int? accountUnreadChatCountFromLoadedChats(
    Iterable<ChatModel> chats,
    int accountId,
    ) {
  final forAccount = chats.where((c) => c.accountId == accountId);
  if (forAccount.isEmpty) return null;
  return forAccount.where((c) => (c.unreadMessageCount ?? 0) > 0).length;
}

/// Derives account [hasUnreadMention] from loaded [chats], or null when none match.
bool? accountHasUnreadMentionFromLoadedChats(
    Iterable<ChatModel> chats,
    int accountId,
    ) {
  final forAccount = chats.where((c) => c.accountId == accountId);
  if (forAccount.isEmpty) return null;
  return forAccount.any((c) => (c.unreadMentionCount ?? 0) > 0);
}

/// Reconciles account [unreadChatCount] after a thread read event.
///
/// When [threadJustRead] is true, the count drops by at least one even if
/// [reconciled] from a partial [chatList] still matches [currentCount].
int reconcileAccountUnreadChatCount({
  required int currentCount,
  required int? reconciled,
  required bool threadJustRead,
}) {
  var result = reconciled ?? currentCount;
  if (threadJustRead) {
    final afterRead = currentCount > 0 ? currentCount - 1 : 0;
    if (result > afterRead) result = afterRead;
  }
  return result.clamp(0, currentCount);
}

/// Reconciles account [hasUnreadMention] after a thread read event.
///
/// Trusts [reconciled] when present; otherwise clears on [threadJustRead].
bool reconcileAccountHasUnreadMention({
  required bool current,
  required bool? reconciled,
  required bool threadJustRead,
}) {
  if (reconciled != null) return reconciled;
  if (threadJustRead) return false;
  return current;
}

/// Whether a `chat.seen` broadcast was emitted by the logged-in admin.
bool seenBroadcastAffectsLocalUnread({
  required int? broadcastByUserId,
  required int? localUserId,
}) {
  if (broadcastByUserId == null || localUserId == null) return false;
  return broadcastByUserId == localUserId;
}

/// Thread pill count from a socket payload, without inventing zero when absent.
int resolveThreadUnreadFromSocket({
  required int localCount,
  required int? serverCount,
  required bool incrementFallback,
}) {
  if (serverCount != null) {
    return serverCount < 0 ? 0 : serverCount;
  }
  if (incrementFallback) return localCount + 1;
  return localCount;
}

/// Inserts a socket mention into [current], sorted by [seq], deduped by [messageGuid].
List<ChatUnreadMentionsModel> mergeSocketMentionIntoUnreadList(
  List<ChatUnreadMentionsModel> current, {
  required String messageGuid,
  required int? seq,
}) {
  final merged = current
      .where((m) => m.messageGuid != messageGuid)
      .toList()
    ..add(ChatUnreadMentionsModel(messageGuid: messageGuid, seq: seq));
  merged.sort((a, b) {
    final aSeq = a.seq;
    final bSeq = b.seq;
    if (aSeq == null && bSeq == null) return 0;
    if (aSeq == null) return 1;
    if (bSeq == null) return -1;
    return aSeq.compareTo(bSeq);
  });
  return merged;
}

/// True when a self-seen broadcast should treat the thread as just-read for
/// account badge sync, even if the chat row was never in local [chatList].
bool threadJustReadFromSeenBroadcast({
  required int previousChatUnread,
  required int? newChatUnread,
  required bool chatWasInLocalList,
}) {
  if (newChatUnread != 0) return false;
  return previousChatUnread > 0 || !chatWasInLocalList;
}

/// Open-conversation unread after a `chat.seen` broadcast.
///
/// A seen event can only lower the admin's pill, never raise it (new unread
/// arrives via `chat.message`). A customer reading the admin's messages must
/// not change the admin's unread at all. Guards against late/out-of-order acks.
int conversationUnreadAfterSeenBroadcast({
  required int currentUnread,
  required int broadcastUnread,
  required bool readerIsCustomer,
}) {
  if (readerIsCustomer) return currentUnread;
  return broadcastUnread < currentUnread ? broadcastUnread : currentUnread;
}

## FILE: test/chat_conversation_unread_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat_message.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat_unread_mentions.model.dart';
import 'package:hanigold_admin/src/domain/chat/utils/chat_conversation_unread.dart';

ChatMessageModel _msg(int seq) => ChatMessageModel(
      rowNum: seq,
      chatId: 'c1',
      messageGuid: 'g$seq',
      replyToMessageGuid: null,
      replyMessage: null,
      forwardFromMessageGuid: null,
      forwardFromSenderName: null,
      forwardMessage: null,
      seq: seq,
      senderType: 2,
      senderAccountId: 10,
      senderUserId: null,
      messageType: 1,
      text: 'hi',
      createdOnUtc: DateTime.utc(2026, 1, 1),
      isDeleted: false,
      deliveredOnUtc: null,
      seenOnUtc: null,
      seen: null,
      senderAccountName: 'User',
      replyToSeq: null,
      forwardFromSeq: null,
    );

void main() {
  group('conversationUnreadAfterSeen', () {
    test('uses loaded messages when tail is fully loaded', () {
      final messages = [_msg(8), _msg(7), _msg(6)];
      expect(
        conversationUnreadAfterSeen(
          serverUnread: 3,
          anchorSeenSeq: 5,
          newSeenSeq: 7,
          loadedMessages: messages,
          lastMessageSeq: 8,
          maxLoadedSeq: 8,
        ),
        1,
      );
    });

    test('decrements by seen progress when tail not loaded', () {
      expect(
        conversationUnreadAfterSeen(
          serverUnread: 5,
          anchorSeenSeq: 10,
          newSeenSeq: 13,
          loadedMessages: const [],
          lastMessageSeq: 20,
          maxLoadedSeq: 12,
        ),
        2,
      );
    });

    test('returns unchanged when newSeenSeq does not advance', () {
      expect(
        conversationUnreadAfterSeen(
          serverUnread: 4,
          anchorSeenSeq: 10,
          newSeenSeq: 10,
          loadedMessages: const [],
          lastMessageSeq: 20,
          maxLoadedSeq: 20,
        ),
        4,
      );
    });
  });

  group('seenBroadcastAffectsLocalUnread', () {
    test('true when reader is local admin', () {
      expect(
        seenBroadcastAffectsLocalUnread(broadcastByUserId: 42, localUserId: 42),
        isTrue,
      );
    });

    test('false when reader is another admin', () {
      expect(
        seenBroadcastAffectsLocalUnread(broadcastByUserId: 10, localUserId: 42),
        isFalse,
      );
    });

    test('false when reader or local id is null', () {
      expect(
        seenBroadcastAffectsLocalUnread(broadcastByUserId: null, localUserId: 42),
        isFalse,
      );
      expect(
        seenBroadcastAffectsLocalUnread(broadcastByUserId: 10, localUserId: null),
        isFalse,
      );
    });
  });

  group('conversationUnreadAfterSeenBroadcast', () {
    test('customer read does not change admin unread', () {
      expect(
        conversationUnreadAfterSeenBroadcast(
          currentUnread: 5,
          broadcastUnread: 0,
          readerIsCustomer: true,
        ),
        5,
      );
    });

    test('admin read lowers unread to broadcast when lower', () {
      expect(
        conversationUnreadAfterSeenBroadcast(
          currentUnread: 5,
          broadcastUnread: 2,
          readerIsCustomer: false,
        ),
        2,
      );
    });

    test('admin read never raises unread', () {
      expect(
        conversationUnreadAfterSeenBroadcast(
          currentUnread: 2,
          broadcastUnread: 5,
          readerIsCustomer: false,
        ),
        2,
      );
    });
  });

  group('messageMentionsAccount', () {
    test('returns true when mentioned user matches', () {
      final mentions = [
        MessageMention(mentionedAccountId: null, mentionedUserId: 42),
      ];
      expect(messageMentionsAccount(mentions, 42), isTrue);
    });

    test('returns false when no mention matches', () {
      final mentions = [
        MessageMention(mentionedAccountId: 99, mentionedUserId: null),
      ];
      expect(messageMentionsAccount(mentions, 42), isFalse);
    });

    test('returns false for null mentions or user id', () {
      expect(messageMentionsAccount(null, 42), isFalse);
      expect(messageMentionsAccount(const [], null), isFalse);
    });
  });

  group('unreadMentionsAfterSeen', () {
    test('drops mentions at or below seen cursor', () {
      final mentions = [
        ChatUnreadMentionsModel(messageGuid: 'a', seq: 5),
        ChatUnreadMentionsModel(messageGuid: 'b', seq: 10),
        ChatUnreadMentionsModel(messageGuid: 'c', seq: null),
      ];
      final result = unreadMentionsAfterSeen(mentions, 8);
      expect(result.map((m) => m.messageGuid), ['b', 'c']);
    });
  });

  group('shouldIncrementAccountUnreadChatCount', () {
    test('false when incrementUnread is false', () {
      expect(
        shouldIncrementAccountUnreadChatCount(
          incrementUnread: false,
          threadUnreadBefore: 0,
          threadRowInList: true,
          accountLastChatId: 'c1',
          chatId: 'c1',
          accountUnreadChatCount: 1,
        ),
        isFalse,
      );
    });

    test('true when thread was unread-zero in list', () {
      expect(
        shouldIncrementAccountUnreadChatCount(
          incrementUnread: true,
          threadUnreadBefore: 0,
          threadRowInList: true,
          accountLastChatId: 'c1',
          chatId: 'c1',
          accountUnreadChatCount: 2,
        ),
        isTrue,
      );
    });
  });

  group('reconcileAccountUnreadChatCount', () {
    test('drops by at least one when threadJustRead', () {
      expect(
        reconcileAccountUnreadChatCount(
          currentCount: 3,
          reconciled: 3,
          threadJustRead: true,
        ),
        2,
      );
    });

    test('uses reconciled when lower than current after read', () {
      expect(
        reconcileAccountUnreadChatCount(
          currentCount: 5,
          reconciled: 1,
          threadJustRead: true,
        ),
        1,
      );
    });
  });

  group('resolveThreadUnreadFromSocket', () {
    test('prefers authoritative server count', () {
      expect(
        resolveThreadUnreadFromSocket(
          localCount: 3,
          serverCount: 7,
          incrementFallback: true,
        ),
        7,
      );
    });

    test('increments local when server absent and fallback enabled', () {
      expect(
        resolveThreadUnreadFromSocket(
          localCount: 2,
          serverCount: null,
          incrementFallback: true,
        ),
        3,
      );
    });

    test('keeps local when server absent and fallback disabled', () {
      expect(
        resolveThreadUnreadFromSocket(
          localCount: 2,
          serverCount: null,
          incrementFallback: false,
        ),
        2,
      );
    });

    test('clamps negative server counts to zero', () {
      expect(
        resolveThreadUnreadFromSocket(
          localCount: 2,
          serverCount: -1,
          incrementFallback: false,
        ),
        0,
      );
    });
  });

  group('threadJustReadFromSeenBroadcast', () {
    test('true when thread had unread and broadcast clears', () {
      expect(
        threadJustReadFromSeenBroadcast(
          previousChatUnread: 3,
          newChatUnread: 0,
          chatWasInLocalList: true,
        ),
        isTrue,
      );
    });

    test('true when chat absent from list and authoritative unread is zero', () {
      expect(
        threadJustReadFromSeenBroadcast(
          previousChatUnread: 0,
          newChatUnread: 0,
          chatWasInLocalList: false,
        ),
        isTrue,
      );
    });

    test('false when chat in list was already read', () {
      expect(
        threadJustReadFromSeenBroadcast(
          previousChatUnread: 0,
          newChatUnread: 0,
          chatWasInLocalList: true,
        ),
        isFalse,
      );
    });

    test('false when authoritative unread absent', () {
      expect(
        threadJustReadFromSeenBroadcast(
          previousChatUnread: 3,
          newChatUnread: null,
          chatWasInLocalList: true,
        ),
        isFalse,
      );
    });

    test('false when broadcast unread still positive', () {
      expect(
        threadJustReadFromSeenBroadcast(
          previousChatUnread: 5,
          newChatUnread: 2,
          chatWasInLocalList: true,
        ),
        isFalse,
      );
    });
  });

  group('absent-thread account reconcile', () {
    test('decrements account count when chat absent and self-seen clears', () {
      final threadJustRead = threadJustReadFromSeenBroadcast(
        previousChatUnread: 0,
        newChatUnread: 0,
        chatWasInLocalList: false,
      );
      expect(
        reconcileAccountUnreadChatCount(
          currentCount: 3,
          reconciled: null,
          threadJustRead: threadJustRead,
        ),
        2,
      );
    });
  });

  group('mergeSocketMentionIntoUnreadList', () {
    test('adds mention sorted by seq and dedupes', () {
      final current = [
        ChatUnreadMentionsModel(messageGuid: 'b', seq: 10),
      ];
      final merged = mergeSocketMentionIntoUnreadList(
        current,
        messageGuid: 'a',
        seq: 5,
      );
      expect(merged.map((m) => m.seq), [5, 10]);
      final again = mergeSocketMentionIntoUnreadList(
        merged,
        messageGuid: 'a',
        seq: 5,
      );
      expect(again.length, 2);
    });
  });
}
