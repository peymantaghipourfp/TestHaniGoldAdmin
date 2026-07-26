import 'package:flutter/foundation.dart';
import 'package:pasteboard/pasteboard.dart';

/// Clipboard content relevant to the chat composer paste handler.
class ClipboardPasteContent {
  const ClipboardPasteContent({
    this.imageBytes,
    this.filePaths = const [],
  });

  final Uint8List? imageBytes;
  final List<String> filePaths;

  bool get hasBinaryContent =>
      (imageBytes != null && imageBytes!.isNotEmpty) || filePaths.isNotEmpty;
}

/// Desktop, web, and mobile targets supported by [pasteboard].
bool get isChatClipboardFilePasteSupported {
  if (kIsWeb) return true;
  return switch (defaultTargetPlatform) {
    TargetPlatform.windows ||
    TargetPlatform.macOS ||
    TargetPlatform.linux ||
    TargetPlatform.android ||
    TargetPlatform.iOS =>
    true,
    _ => false,
  };
}

/// Reads image bytes and/or file paths from the system clipboard.
///
/// Returns empty content on unsupported platforms or when clipboard access fails.
Future<ClipboardPasteContent> readClipboardForComposer() async {
  if (!isChatClipboardFilePasteSupported) {
    return const ClipboardPasteContent();
  }

  List<String> rawFilePaths = const [];
  try {
    rawFilePaths = await Pasteboard.files();
  } catch (_) {}

  Uint8List? imageBytes;
  try {
    imageBytes = await Pasteboard.image;
  } catch (_) {}

  final normalizedPaths = rawFilePaths
      .map((path) => path.trim())
      .where((path) => path.isNotEmpty)
      .toList(growable: false);

  if (normalizedPaths.isNotEmpty) {
    return ClipboardPasteContent(
      filePaths: normalizedPaths,
      imageBytes: imageBytes,
    );
  }

  if (imageBytes != null && imageBytes.isNotEmpty) {
    return ClipboardPasteContent(imageBytes: imageBytes);
  }

  return const ClipboardPasteContent();
}

/// Stable file name for a pasted clipboard image (used for dedup).
String clipboardImageFileName(Uint8List bytes) {
  final ext = _clipboardImageExtension(bytes);
  final checksum = bytes.fold<int>(0, (sum, byte) => (sum + byte) & 0xFFFFFFFF);
  return 'clipboard-${bytes.length}-$checksum.$ext';
}

String _clipboardImageExtension(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF) {
    return 'jpg';
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return 'png';
  }
  if (bytes.length >= 6 &&
      bytes[0] == 0x47 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46) {
    return 'gif';
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return 'webp';
  }
  if (bytes.length >= 2 && bytes[0] == 0x42 && bytes[1] == 0x4D) {
    return 'bmp';
  }
  return 'png';
}
