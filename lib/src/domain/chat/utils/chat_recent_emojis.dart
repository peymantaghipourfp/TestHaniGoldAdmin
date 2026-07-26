import 'package:get_storage/get_storage.dart';

/// [GetStorage] key for MRU chat emoji strings (most recent first).
const String kChatRecentEmojisStorageKey = 'chatRecentEmojis';

/// Maximum number of emojis kept in the recent list.
const int kChatRecentEmojisMaxCount = 30;

/// Inserts [emoji] at the front, removes prior duplicates, and caps at [maxCount].
List<String> recordRecentEmoji(
    List<String> current,
    String emoji, {
      int maxCount = kChatRecentEmojisMaxCount,
    }) {
  if (emoji.isEmpty) return List<String>.from(current);
  final next = [emoji, ...current.where((e) => e != emoji)];
  if (next.length <= maxCount) return next;
  return next.sublist(0, maxCount);
}

List<String> readRecentEmojisFromStorage(GetStorage box) {
  final raw = box.read(kChatRecentEmojisStorageKey);
  if (raw is! List) return const [];
  return raw.whereType<String>().where((e) => e.isNotEmpty).toList();
}

void writeRecentEmojisToStorage(GetStorage box, List<String> emojis) {
  box.write(kChatRecentEmojisStorageKey, emojis);
}
