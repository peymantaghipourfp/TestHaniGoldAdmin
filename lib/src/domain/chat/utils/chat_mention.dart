import 'package:flutter/painting.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat_mention_candidates.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat_message.model.dart';
import 'package:hanigold_admin/src/domain/chat/utils/chat_emoji_grapheme.dart';

/// Active `@`-query in the composer at [caret].
class MentionQuery {
  const MentionQuery({
    required this.start,
    required this.query,
  });

  final int start;
  final String query;
}

/// A resolved mention span inside message [text].
class MentionMatch {
  const MentionMatch({
    required this.start,
    required this.end,
    required this.candidate,
  });

  final int start;
  final int end;
  final ChatMentionCandidatesModel candidate;
}

/// Detects whether the caret is inside an active `@` mention query.
MentionQuery? detectComposerMentionQuery(String text, int caret) {
  if (text.isEmpty || caret <= 0) return null;

  final clampedCaret = caret.clamp(0, text.length);
  var atIndex = -1;
  for (var i = clampedCaret - 1; i >= 0; i--) {
    final ch = text[i];
    if (ch == '@') {
      atIndex = i;
      break;
    }
    if (ch == '\n') return null;
    if (ch.trim().isEmpty && i != clampedCaret - 1) {
      return null;
    }
  }
  if (atIndex == -1) return null;

  if (atIndex > 0) {
    final before = text[atIndex - 1];
    if (before.trim().isNotEmpty && before != '\n') return null;
  }

  final query = text.substring(atIndex + 1, clampedCaret);
  if (query.contains('\n')) return null;
  if (query.endsWith(' ')) return null;

  return MentionQuery(start: atIndex, query: query);
}

/// Filters [candidates] by [query]; empty query returns all.
List<ChatMentionCandidatesModel> filterMentionCandidates(
    List<ChatMentionCandidatesModel> candidates,
    String query,
    ) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return List<ChatMentionCandidatesModel>.from(candidates);

  final lower = trimmed.toLowerCase();
  final startsWithMatches = <ChatMentionCandidatesModel>[];
  final containsMatches = <ChatMentionCandidatesModel>[];

  for (final c in candidates) {
    final name = c.name?.trim();
    if (name == null || name.isEmpty) continue;
    final lowerName = name.toLowerCase();
    if (lowerName.startsWith(lower)) {
      startsWithMatches.add(c);
    } else if (lowerName.contains(lower)) {
      containsMatches.add(c);
    }
  }

  return [...startsWithMatches, ...containsMatches];
}

List<ChatMentionCandidatesModel> _dedupeCandidatesByName(
    List<ChatMentionCandidatesModel> candidates,
    ) {
  final seen = <String>{};
  final out = <ChatMentionCandidatesModel>[];
  for (final c in candidates) {
    final name = c.name?.trim();
    if (name == null || name.isEmpty) continue;
    final key = name.toLowerCase();
    if (seen.add(key)) out.add(c);
  }
  return out;
}

/// Finds ordered, non-overlapping mention matches using longest-name wins.
List<MentionMatch> findMentionMatches(
    String text,
    List<ChatMentionCandidatesModel> candidates,
    ) {
  if (text.isEmpty || candidates.isEmpty) return const [];

  final deduped = _dedupeCandidatesByName(candidates);
  deduped.sort((a, b) {
    final al = a.name?.length ?? 0;
    final bl = b.name?.length ?? 0;
    return bl.compareTo(al);
  });

  final matches = <MentionMatch>[];
  var searchFrom = 0;

  while (searchFrom < text.length) {
    final atIndex = text.indexOf('@', searchFrom);
    if (atIndex == -1) break;

    if (atIndex > 0) {
      final before = text[atIndex - 1];
      if (before.trim().isNotEmpty && before != '\n') {
        searchFrom = atIndex + 1;
        continue;
      }
    }

    MentionMatch? best;
    for (final c in deduped) {
      final name = c.name?.trim();
      if (name == null || name.isEmpty) continue;
      final mentionText = '@$name';
      if (text.length < atIndex + mentionText.length) continue;
      if (!text.startsWith(mentionText, atIndex)) continue;

      final end = atIndex + mentionText.length;
      if (end < text.length) {
        final after = text[end];
        if (after.trim().isNotEmpty && after != '\n') continue;
      }

      best = MentionMatch(start: atIndex, end: end, candidate: c);
      break;
    }

    if (best != null) {
      matches.add(best);
      searchFrom = best.end;
    } else {
      searchFrom = atIndex + 1;
    }
  }

  return matches;
}

List<MentionMatch> _fallbackMentionTokenMatches(String text) {
  final matches = <MentionMatch>[];
  final pattern = RegExp(r'@\S+');
  for (final m in pattern.allMatches(text)) {
    matches.add(
      MentionMatch(
        start: m.start,
        end: m.end,
        candidate: ChatMentionCandidatesModel(
          accountId: null,
          userId: null,
          name: text.substring(m.start + 1, m.end),
          type: null,
        ),
      ),
    );
  }
  return matches;
}

/// Whether [match] refers to the logged-in admin ([currentUserId] / [currentUserName]).
bool isCurrentUserMention(
    MentionMatch match, {
      int? currentUserId,
      String? currentUserName,
    }) {
  if (currentUserId != null) {
    if (match.candidate.userId == currentUserId) return true;
    if (match.candidate.accountId == currentUserId) return true;
  }

  final name = match.candidate.name?.trim().toLowerCase();
  final selfName = currentUserName?.trim().toLowerCase();
  if (name != null && selfName != null && name == selfName) return true;

  return false;
}

List<ChatMentionCandidatesModel> mentionCandidatesIncludingCurrentUser({
  required List<ChatMentionCandidatesModel> candidates,
  int? currentUserId,
  String? currentUserName,
}) {
  final name = currentUserName?.trim();
  if (currentUserId == null || name == null || name.isEmpty) {
    return candidates;
  }

  final alreadyPresent = candidates.any(
        (c) => c.userId == currentUserId || c.accountId == currentUserId,
  );
  if (alreadyPresent) return candidates;

  return [
    ...candidates,
    ChatMentionCandidatesModel(
      accountId: currentUserId,
      userId: currentUserId,
      name: name,
      type: null,
    ),
  ];
}

/// Builds rich text spans with emoji + mention styling.
List<InlineSpan> buildMentionAwareTextSpans(
    String input,
    TextStyle baseStyle,
    TextStyle emojiStyle,
    TextStyle mentionStyle,
    List<ChatMentionCandidatesModel> candidates, {
    TextStyle? selfMentionStyle,
    int? currentUserId,
    String? currentUserName,
    }) {
  if (input.isEmpty) return const [];

  final resolvedCandidates = mentionCandidatesIncludingCurrentUser(
    candidates: candidates,
    currentUserId: currentUserId,
    currentUserName: currentUserName,
  );

  final matches = resolvedCandidates.isNotEmpty
      ? findMentionMatches(input, resolvedCandidates)
      : _fallbackMentionTokenMatches(input);

  if (matches.isEmpty) {
    return buildEmojiAwareTextSpans(input, baseStyle, emojiStyle);
  }

  final spans = <InlineSpan>[];
  var cursor = 0;

  for (final match in matches) {
    if (match.start > cursor) {
      spans.addAll(
        buildEmojiAwareTextSpans(
          input.substring(cursor, match.start),
          baseStyle,
          emojiStyle,
        ),
      );
    }

    final isSelf = isCurrentUserMention(
      match,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
    );
    final resolvedMentionStyle =
    isSelf && selfMentionStyle != null ? selfMentionStyle : mentionStyle;

    spans.add(
      TextSpan(
        text: input.substring(match.start, match.end),
        style: resolvedMentionStyle,
      ),
    );
    cursor = match.end;
  }

  if (cursor < input.length) {
    spans.addAll(
      buildEmojiAwareTextSpans(
        input.substring(cursor),
        baseStyle,
        emojiStyle,
      ),
    );
  }

  return spans;
}

/// Converts resolved matches into outbound socket [MessageMention] payloads.
List<MessageMention> buildOutboundMentions(
    String text,
    List<ChatMentionCandidatesModel> candidates,
    ) {
  final matches = findMentionMatches(text, candidates);
  return matches
      .map(
        (m) => MessageMention(
      mentionedAccountId: m.candidate.accountId,
      mentionedUserId: m.candidate.userId,
    ),
  )
      .where(
        (m) => m.mentionedAccountId != null || m.mentionedUserId != null,
  )
      .toList();
}
