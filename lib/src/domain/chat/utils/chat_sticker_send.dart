import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hanigold_admin/src/config/repository/chat_attachment.repository.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'chat_attachment_utils.dart';

/// Result of uploading a bundled sticker asset, ready for socket dispatch.
class ChatStickerPreparedSend {
  const ChatStickerPreparedSend({
    required this.reqId,
    required this.recordId,
    required this.fileName,
    required this.bytes,
    required this.filesJson,
  });

  final String reqId;
  final String recordId;
  final String fileName;
  final Uint8List bytes;
  final String filesJson;
}

/// Uploads chat sticker assets and builds the outbound `filesJson` payload.
///
/// Intentionally separate from [ChatController.sendMessage] and the composer
/// attachment pipeline.
class ChatStickerSendService {
  ChatStickerSendService({
    ChatAttachmentRepository? attachmentRepository,
    Uuid? uuid,
  })  : _attachmentRepository =
      attachmentRepository ?? ChatAttachmentRepository(),
        _uuid = uuid ?? const Uuid();

  final ChatAttachmentRepository _attachmentRepository;
  final Uuid _uuid;

  Future<ChatStickerPreparedSend> prepareAndUpload(String assetPath) async {
    final normalizedPath = assetPath.trim();
    if (normalizedPath.isEmpty) {
      throw ArgumentError.value(assetPath, 'assetPath', 'must not be empty');
    }

    final bundle = await rootBundle.load(normalizedPath);
    final bytes = bundle.buffer.asUint8List();
    if (bytes.isEmpty) {
      throw StateError('Sticker asset is empty: $normalizedPath');
    }

    final fileName = p.basename(normalizedPath);
    final recordId = _uuid.v4();

    await _attachmentRepository.uploadChatAttachment(
      bytes: bytes,
      fileName: fileName,
      recordId: recordId,
      mimeType: 'image/png',
    );

    final entry = <String, dynamic>{
      'recordId': recordId,
      'fileType': 'image',
      'fileName': fileName,
    };
    final dims = await decodeChatImagePixelSizeFromBytes(bytes);
    if (dims != null) {
      entry['size'] = formatChatImageSizeField(dims.width, dims.height);
    }

    return ChatStickerPreparedSend(
      reqId: _uuid.v4(),
      recordId: recordId,
      fileName: fileName,
      bytes: bytes,
      filesJson: jsonEncode([entry]),
    );
  }
}
