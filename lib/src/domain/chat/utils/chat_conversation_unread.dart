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
