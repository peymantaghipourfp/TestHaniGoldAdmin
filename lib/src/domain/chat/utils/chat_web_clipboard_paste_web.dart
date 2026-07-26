import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'chat_web_clipboard_paste_stub.dart';

export 'chat_web_clipboard_paste_stub.dart' show ChatWebPastedFile;

/// Listens for browser paste events and extracts file payloads from clipboard.
class ChatWebClipboardPasteListener {
  JSFunction? _listener;

  void start(void Function(List<ChatWebPastedFile>) onFiles) {
    stop();

    void handler(web.Event event) {
      final clipboardEvent = event as web.ClipboardEvent;
      final data = clipboardEvent.clipboardData;
      if (data == null) return;

      final items = data.items;
      final fileItems = <web.DataTransferItem>[];
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item.kind == 'file') {
          fileItems.add(item);
        }
      }

      if (fileItems.isEmpty) return;

      event.preventDefault();
      unawaited(_readFiles(fileItems, onFiles));
    }

    _listener = handler.toJS;
    web.document.addEventListener('paste', _listener!);
  }

  Future<void> _readFiles(
      List<web.DataTransferItem> items,
      void Function(List<ChatWebPastedFile>) onFiles,
      ) async {
    final pasted = <ChatWebPastedFile>[];
    for (final item in items) {
      final file = item.getAsFile();
      if (file == null) continue;

      final name = file.name.trim();
      if (name.isEmpty) continue;

      try {
        final buffer = await file.arrayBuffer().toDart;
        final bytes = buffer.toDart.asUint8List();
        if (bytes.isEmpty) continue;
        pasted.add(ChatWebPastedFile(name: name, bytes: bytes));
      } catch (_) {}
    }

    if (pasted.isNotEmpty) {
      onFiles(pasted);
    }
  }

  void stop() {
    final listener = _listener;
    if (listener != null) {
      web.document.removeEventListener('paste', listener);
      _listener = null;
    }
  }
}
