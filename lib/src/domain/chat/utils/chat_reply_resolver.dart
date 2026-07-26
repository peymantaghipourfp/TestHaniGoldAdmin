import 'package:hanigold_admin/src/domain/chat/model/chat_message.model.dart';

import 'chat_attachment_utils.dart';
import 'chat_forward_outbound.dart';
/// Normalizes a message GUID for stable reply-parent matching.
String? normalizeReplyGuid(String? guid) {
  final t = guid?.trim();
  if (t == null || t.isEmpty) return null;
  return t.toLowerCase();
}

/// Finds the parent message row for [reply] using [reply.replyMessage] only.
ChatMessageModel? findReplyParentInList(
    List<ChatMessageModel> messages,
    ChatMessageModel reply,
    ) {
  final chatId = reply.chatId?.toString().trim();
  if (chatId == null || chatId.isEmpty) return null;

  final embedded = reply.replyMessage;
  if (embedded == null) return null;

  final embeddedGuid = normalizeReplyGuid(embedded.messageGuid);
  if (embeddedGuid != null) {
    for (final m in messages) {
      if (m.chatId?.toString().trim() != chatId) continue;
      if (normalizeReplyGuid(m.messageGuid) == embeddedGuid) return m;
    }
  }

  final embeddedSeq = embedded.seq;
  if (embeddedSeq != null) {
    for (final m in messages) {
      if (m.chatId?.toString().trim() == chatId && m.seq == embeddedSeq) {
        return m;
      }
    }
  }
  return null;
}

ReplyMessage? replySnapshotForParentGuid(
    String? replyToMessageGuid,
    List<ChatMessageModel> threadMessages,
    ) {
  final guid = normalizeReplyGuid(replyToMessageGuid);
  if (guid == null) return null;
  for (final m in threadMessages) {
    if (normalizeReplyGuid(m.messageGuid) == guid) {
      return m.toReplyMessageSnapshot();
    }
  }
  return null;
}

ReplyMessage? forwardSnapshotForSourceGuid(
    String? forwardFromMessageGuid,
    List<ChatMessageModel> threadMessages,
    ) {
  return replySnapshotForParentGuid(forwardFromMessageGuid, threadMessages);
}

String? forwardSenderNameForSource(
    ChatMessageModel incoming,
    List<ChatMessageModel> threadMessages,
    ) {
  final explicit = incoming.forwardFromSenderName?.trim();
  if (explicit != null && explicit.isNotEmpty) return explicit;
  final embedded = incoming.forwardMessage?.senderAccountName?.trim();
  if (embedded != null && embedded.isNotEmpty) return embedded;
  final guid = normalizeReplyGuid(incoming.forwardFromMessageGuid);
  if (guid == null) return null;
  for (final m in threadMessages) {
    if (normalizeReplyGuid(m.messageGuid) == guid) {
      final name = m.senderAccountName?.trim();
      if (name != null && name.isNotEmpty) return name;
    }
  }
  return null;
}

/// Merges embedded forward attachment ids from an optimistic outbound send
/// into the server echo's [forwardMessage] (mirrors [mergeChatFilesJsonFromOutbound]).
ReplyMessage? mergeForwardMessageFilesFromOutbound(
    ReplyMessage? incoming,
    ReplyMessage? optimistic,
    ) {
  if (incoming == null) return optimistic;
  if (optimistic == null) return incoming;

  final mergedFiles = mergeChatFilesJsonFromOutbound(
    incoming.filesJson,
    optimistic.filesJson,
  );
  if (mergedFiles == incoming.filesJson) return incoming;

  return ReplyMessage(
    chatId: incoming.chatId,
    messageGuid: incoming.messageGuid,
    seq: incoming.seq,
    senderType: incoming.senderType,
    senderAccountId: incoming.senderAccountId,
    senderUserId: incoming.senderUserId,
    messageType: incoming.messageType,
    text: incoming.text,
    replyToMessageGuid: incoming.replyToMessageGuid,
    filesJson: mergedFiles,
    createdOnUtc: incoming.createdOnUtc,
    isDeleted: incoming.isDeleted,
    senderAccountName: incoming.senderAccountName,
  );
}

ReplyMessage _replyMessageWithFiles(ReplyMessage source, String filesJson) {
  return ReplyMessage(
    chatId: source.chatId,
    messageGuid: source.messageGuid,
    seq: source.seq,
    senderType: source.senderType,
    senderAccountId: source.senderAccountId,
    senderUserId: source.senderUserId,
    messageType: source.messageType,
    text: source.text,
    replyToMessageGuid: source.replyToMessageGuid,
    filesJson: filesJson,
    createdOnUtc: source.createdOnUtc,
    isDeleted: source.isDeleted,
    senderAccountName: source.senderAccountName,
  );
}

/// Fills missing [ReplyMessage.filesJson] on an embedded forward snapshot.
ReplyMessage enrichForwardMessageSnapshot(
    ReplyMessage embedded,
    ChatMessageModel message,
    List<ChatMessageModel> threadMessages,
    ) {
  if (normalizeChatMessageFilesJson(embedded.filesJson) != null) {
    return embedded;
  }

  final fromTop = normalizeChatMessageFilesJson(message.filesJson);
  if (fromTop != null) {
    return _replyMessageWithFiles(embedded, fromTop);
  }

  final fromThread = forwardSnapshotForSourceGuid(
    message.forwardFromMessageGuid,
    threadMessages,
  );
  final fromThreadFiles = normalizeChatMessageFilesJson(fromThread?.filesJson);
  if (fromThreadFiles != null) {
    return _replyMessageWithFiles(embedded, fromThreadFiles);
  }

  return embedded;
}

/// Ensures [ChatMessageModel.forwardMessage] carries attachment metadata before
/// outbound re-forward or history display.
ChatMessageModel enrichForwardSourceForOutbound(
    ChatMessageModel source,
    List<ChatMessageModel> threadMessages,
    ) {
  final embedded = source.forwardMessage;
  if (embedded == null) return source;

  final enriched =
  enrichForwardMessageSnapshot(embedded, source, threadMessages);
  if (enriched.filesJson == embedded.filesJson) return source;

  return ChatMessageModel(
    rowNum: source.rowNum,
    chatId: source.chatId,
    messageGuid: source.messageGuid,
    replyToMessageGuid: source.replyToMessageGuid,
    replyMessage: source.replyMessage,
    forwardFromMessageGuid: source.forwardFromMessageGuid,
    forwardFromSenderName: source.forwardFromSenderName,
    forwardMessage: enriched,
    seq: source.seq,
    senderType: source.senderType,
    senderAccountId: source.senderAccountId,
    senderUserId: source.senderUserId,
    messageType: source.messageType,
    text: source.text,
    createdOnUtc: source.createdOnUtc,
    isDeleted: source.isDeleted,
    deliveredOnUtc: source.deliveredOnUtc,
    seenOnUtc: source.seenOnUtc,
    seen: source.seen,
    senderAccountName: source.senderAccountName,
    replyToSeq: source.replyToSeq,
    forwardFromSeq: source.forwardFromSeq,
    filesJson: source.filesJson,
    mentions: source.mentions,
  );
}


/// Keeps [replyMessage] on realtime socket rows when the server only sends
/// [ChatMessageModel.replyToMessageGuid] (history API embeds full [ReplyMessage]).
ChatMessageModel mergeIncomingReplyFields({
  required ChatMessageModel incoming,
  required List<ChatMessageModel> threadMessages,
  ChatMessageModel? fallback,
}) {
  var merged = incoming;

  if (merged.replyMessage == null) {
    final replyMessage = fallback?.replyMessage ??
        replySnapshotForParentGuid(
          merged.replyToMessageGuid ?? fallback?.replyToMessageGuid,
          threadMessages,
        );
    if (replyMessage != null) {
      merged = ChatMessageModel(
        rowNum: merged.rowNum,
        chatId: merged.chatId,
        messageGuid: merged.messageGuid,
        replyToMessageGuid:
        merged.replyToMessageGuid ?? fallback?.replyToMessageGuid,
        replyMessage: replyMessage,
        forwardFromMessageGuid: merged.forwardFromMessageGuid,
        forwardFromSenderName: merged.forwardFromSenderName,
        forwardMessage: merged.forwardMessage,
        seq: merged.seq,
        senderType: merged.senderType,
        senderAccountId: merged.senderAccountId,
        senderUserId: merged.senderUserId,
        messageType: merged.messageType,
        text: merged.text,
        createdOnUtc: merged.createdOnUtc,
        isDeleted: merged.isDeleted,
        deliveredOnUtc: merged.deliveredOnUtc,
        seenOnUtc: merged.seenOnUtc,
        seen: merged.seen,
        senderAccountName: merged.senderAccountName,
        replyToSeq: merged.replyToSeq ?? fallback?.replyToSeq,
        forwardFromSeq: merged.forwardFromSeq,
        filesJson: merged.filesJson,
        mentions: merged.mentions,
      );
    }
  }

  if (merged.forwardMessage != null &&
      (merged.forwardFromSenderName == null ||
          merged.forwardFromSenderName!.trim().isEmpty)) {
    final senderName = forwardSenderNameForSource(merged, threadMessages);
    if (senderName != null) {
      merged = ChatMessageModel(
        rowNum: merged.rowNum,
        chatId: merged.chatId,
        messageGuid: merged.messageGuid,
        replyToMessageGuid: merged.replyToMessageGuid,
        replyMessage: merged.replyMessage,
        forwardFromMessageGuid: merged.forwardFromMessageGuid,
        forwardFromSenderName: senderName,
        forwardMessage: merged.forwardMessage,
        seq: merged.seq,
        senderType: merged.senderType,
        senderAccountId: merged.senderAccountId,
        senderUserId: merged.senderUserId,
        messageType: merged.messageType,
        text: merged.text,
        createdOnUtc: merged.createdOnUtc,
        isDeleted: merged.isDeleted,
        deliveredOnUtc: merged.deliveredOnUtc,
        seenOnUtc: merged.seenOnUtc,
        seen: merged.seen,
        senderAccountName: merged.senderAccountName,
        replyToSeq: merged.replyToSeq,
        forwardFromSeq: merged.forwardFromSeq,
        filesJson: merged.filesJson,
        mentions: merged.mentions,
      );
    }
  }

  if (merged.forwardMessage != null) {
    var mergedForward = mergeForwardMessageFilesFromOutbound(
      merged.forwardMessage,
      fallback?.forwardMessage,
    )!;
    mergedForward = enrichForwardMessageSnapshot(
      mergedForward,
      merged,
      threadMessages,
    );
    if (mergedForward != merged.forwardMessage) {
      merged = ChatMessageModel(
        rowNum: merged.rowNum,
        chatId: merged.chatId,
        messageGuid: merged.messageGuid,
        replyToMessageGuid: merged.replyToMessageGuid,
        replyMessage: merged.replyMessage,
        forwardFromMessageGuid: merged.forwardFromMessageGuid,
        forwardFromSenderName: merged.forwardFromSenderName,
        forwardMessage: mergedForward,
        seq: merged.seq,
        senderType: merged.senderType,
        senderAccountId: merged.senderAccountId,
        senderUserId: merged.senderUserId,
        messageType: merged.messageType,
        text: merged.text,
        createdOnUtc: merged.createdOnUtc,
        isDeleted: merged.isDeleted,
        deliveredOnUtc: merged.deliveredOnUtc,
        seenOnUtc: merged.seenOnUtc,
        seen: merged.seen,
        senderAccountName: merged.senderAccountName,
        replyToSeq: merged.replyToSeq,
        forwardFromSeq: merged.forwardFromSeq,
        filesJson: merged.filesJson,
        mentions: merged.mentions,
      );
    }
    return finalizeCaptionlessForwardDisplay(merged, optimisticFallback: fallback);
  }

  final forwardMessage = fallback?.forwardMessage ??
      forwardSnapshotForSourceGuid(
        merged.forwardFromMessageGuid ?? fallback?.forwardFromMessageGuid,
        threadMessages,
      );
  if (forwardMessage == null &&
      (merged.forwardFromMessageGuid == null ||
          merged.forwardFromMessageGuid!.trim().isEmpty) &&
      merged.forwardFromSeq == null) {
    return merged;
  }

  final forwardFromMessageGuid =
      merged.forwardFromMessageGuid ?? fallback?.forwardFromMessageGuid;
  final forwardFromSenderName = merged.forwardFromSenderName?.trim().isNotEmpty ==
      true
      ? merged.forwardFromSenderName
      : fallback?.forwardFromSenderName ??
      forwardSenderNameForSource(merged, threadMessages) ??
      forwardMessage?.senderAccountName;

  return finalizeCaptionlessForwardDisplay(
    ChatMessageModel(
      rowNum: merged.rowNum,
      chatId: merged.chatId,
      messageGuid: merged.messageGuid,
      replyToMessageGuid: merged.replyToMessageGuid,
      replyMessage: merged.replyMessage,
      forwardFromMessageGuid: forwardFromMessageGuid,
      forwardFromSenderName: forwardFromSenderName,
      forwardMessage: forwardMessage ?? merged.forwardMessage,
      seq: merged.seq,
      senderType: merged.senderType,
      senderAccountId: merged.senderAccountId,
      senderUserId: merged.senderUserId,
      messageType: merged.messageType,
      text: merged.text,
      createdOnUtc: merged.createdOnUtc,
      isDeleted: merged.isDeleted,
      deliveredOnUtc: merged.deliveredOnUtc,
      seenOnUtc: merged.seenOnUtc,
      seen: merged.seen,
      senderAccountName: merged.senderAccountName,
      replyToSeq: merged.replyToSeq,
      forwardFromSeq: merged.forwardFromSeq ?? fallback?.forwardFromSeq,
      filesJson: merged.filesJson,
      mentions: merged.mentions,
    ),
    optimisticFallback: fallback,
  );
}
