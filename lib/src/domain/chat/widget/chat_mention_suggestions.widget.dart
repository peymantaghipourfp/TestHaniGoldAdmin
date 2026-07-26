import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
import 'package:hanigold_admin/src/domain/chat/theme/chat_theme.dart';

/// Telegram-style mention suggestion list shown above the composer input.
class ChatMentionSuggestions extends StatelessWidget {
  const ChatMentionSuggestions({
    super.key,
    required this.controller,
  });

  final ChatController controller;

  static const double _rowHeight = 44;
  static const int _maxVisibleRows = 5;

  @override
  Widget build(BuildContext context) {
    final theme = context.chatTheme;

    return Obx(() {
      if (!controller.isMentionPopupVisible.value) {
        return const SizedBox.shrink();
      }

      final suggestions = controller.mentionSuggestions;
      final loading = controller.isLoadingMentions.value;
      final highlighted = controller.mentionHighlightedIndex.value;

      if (!loading && suggestions.isEmpty) {
        return const SizedBox.shrink();
      }

      final visibleCount = suggestions.isEmpty ? 1 : suggestions.length;
      final height = (visibleCount.clamp(1, _maxVisibleRows) * _rowHeight)
          .toDouble();

      return Material(
        elevation: 6,
        color: theme.composerSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.composerBorder),
            ),
          ),
          child: loading && suggestions.isEmpty
              ? Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.bubbleReplyAccent,
              ),
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final candidate = suggestions[index];
              final name = candidate.name?.trim() ?? '';
              final type = candidate.type?.trim();
              final isHighlighted = index == highlighted;

              return Material(
                color: isHighlighted
                    ? theme.bubbleReplyAccent.withAlpha(36)
                    : Colors.transparent,
                child: InkWell(
                  onTap: () => controller.selectMention(candidate),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                          theme.bubbleReplyAccent.withAlpha(48),
                          child: Text(
                            name.isNotEmpty
                                ? name.characters.first
                                : '@',
                            style: AppTextStyle.bodyText.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.bubbleReplyAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            name.isEmpty ? 'کاربر' : name,
                            style: AppTextStyle.bodyText.copyWith(
                              fontSize: 14,
                              fontWeight: isHighlighted
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: theme.onBubble,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (type != null && type.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            type,
                            style: AppTextStyle.bodyText.copyWith(
                              fontSize: 11,
                              color: theme.onBubbleMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
