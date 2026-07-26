import 'dart:typed_data';

/// A file extracted from a browser paste event.
class ChatWebPastedFile {
  ChatWebPastedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// No-op on non-web platforms.
class ChatWebClipboardPasteListener {
  void start(void Function(List<ChatWebPastedFile>) onFiles) {}

  void stop() {}
}
