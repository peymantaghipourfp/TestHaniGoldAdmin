import 'package:hanigold_admin/src/domain/chat/model/chat_message.model.dart';

/// Wire + optimistic fields for a forward reference.
///
/// When [source] is itself a forward, the server rebuilds `forwardMessage` from
/// [messageGuid] only — so re-forwards must reference the root original (embedded
/// body), not the immediate parent row whose top-level `filesJson` may be empty.
class ForwardOutboundReference {
  const ForwardOutboundReference({
    required this.messageGuid,
    required this.seq,
    required this.senderAccountName,
    required this.body,
  });

  final String? messageGuid;
  final int? seq;
  final String? senderAccountName;
  final ReplyMessage? body;
}

/// Resolves the message row the server should use for a forward reference.
ForwardOutboundReference resolveForwardOutboundReference(
    ChatMessageModel source,
    ) {
  final embedded = source.forwardMessage;
  final rootGuid = embedded?.messageGuid?.trim();
  if (embedded != null && rootGuid != null && rootGuid.isNotEmpty) {
    return ForwardOutboundReference(
      messageGuid: rootGuid,
      seq: embedded.seq,
      senderAccountName: embedded.senderAccountName,
      body: source.toForwardMessageSnapshot() ?? embedded,
    );
  }

  return ForwardOutboundReference(
    messageGuid: source.messageGuid,
    seq: source.seq,
    senderAccountName: source.senderAccountName,
    body: source.toForwardMessageSnapshot(),
  );
}

/// Display / wire sender name for a forward reference (root author on re-forward).
String? forwardOutboundSenderName(
    ChatMessageModel source, {
      String? currentUserNameFallback,
    }) {
  final ref = resolveForwardOutboundReference(source);
  final name = ref.senderAccountName?.trim();
  if (name != null && name.isNotEmpty) return name;
  if (source.forwardMessage == null && source.senderType == 1) {
    return currentUserNameFallback;
  }
  return 'کاربر';
}

/// Outbound `chat.admin.send` body fields after applying forward fallbacks.
class ForwardAdminSendPayload {
  const ForwardAdminSendPayload({
    this.text,
    this.filesJson,
    this.forwardSnapshot,
  });

  final String? text;
  final String? filesJson;
  /// Embedded source body for wire `ForwardMessage` (files live here, not in [filesJson]).
  final ReplyMessage? forwardSnapshot;
}

bool forwardSnapshotHasBody(ReplyMessage? snapshot) {
  if (snapshot == null) return false;
  if (snapshot.text?.trim().isNotEmpty == true) return true;
  return normalizeChatMessageFilesJson(snapshot.filesJson) != null;
}

/// Server requires non-null [text] or [filesJson] for plain sends. For forwards,
/// source body is sent once via [forwardSnapshot]; top-level [filesJson] stays empty.
ForwardAdminSendPayload resolveForwardAdminSendPayload({
  required String? userCaption,
  required String? userFilesJson,
  required ChatMessageModel? forwardSource,
}) {
  var text = userCaption?.trim();
  final filesJson = normalizeChatMessageFilesJson(userFilesJson?.trim());

  if (forwardSource == null) {
    return ForwardAdminSendPayload(
      text: (text != null && text.isNotEmpty) ? text : null,
      filesJson: filesJson,
    );
  }

  final snapshot = forwardSource.toForwardMessageSnapshot();
  final sourceText = snapshot?.text?.trim();

  if ((text == null || text.isEmpty) &&
      sourceText != null &&
      sourceText.isNotEmpty) {
    text = sourceText;
  }

  return ForwardAdminSendPayload(
    text: (text != null && text.isNotEmpty) ? text : null,
    filesJson: null,
    forwardSnapshot: snapshot,
  );
}

/// Hides duplicate top-level [ChatMessageModel.text] when the server echoes
/// source body in `text` for a caption-less forward transport.
ChatMessageModel finalizeCaptionlessForwardDisplay(
    ChatMessageModel message, {
      ChatMessageModel? optimisticFallback,
    }) {
  if (!message.isForwarded || message.forwardMessage == null) return message;

  final hadUserCaption = optimisticFallback?.text?.trim().isNotEmpty == true;
  if (hadUserCaption) return message;

  final top = message.text?.trim();
  final embedded = message.forwardMessage!.text?.trim();
  if (top == null || top.isEmpty || embedded == null || top != embedded) {
    return message;
  }

  return ChatMessageModel(
    rowNum: message.rowNum,
    chatId: message.chatId,
    messageGuid: message.messageGuid,
    replyToMessageGuid: message.replyToMessageGuid,
    replyMessage: message.replyMessage,
    forwardFromMessageGuid: message.forwardFromMessageGuid,
    forwardFromSenderName: message.forwardFromSenderName,
    forwardMessage: message.forwardMessage,
    seq: message.seq,
    senderType: message.senderType,
    senderAccountId: message.senderAccountId,
    senderUserId: message.senderUserId,
    messageType: message.messageType,
    text: null,
    createdOnUtc: message.createdOnUtc,
    isDeleted: message.isDeleted,
    deliveredOnUtc: message.deliveredOnUtc,
    seenOnUtc: message.seenOnUtc,
    seen: message.seen,
    senderAccountName: message.senderAccountName,
    replyToSeq: message.replyToSeq,
    forwardFromSeq: message.forwardFromSeq,
    filesJson: message.filesJson,
    mentions: message.mentions,
  );
}
