import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
import 'package:hanigold_admin/src/domain/chat/theme/chat_theme.dart';

class JumpToLatestMention extends StatelessWidget {
  const JumpToLatestMention({super.key, required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final theme = context.chatTheme;

    return GestureDetector(
      onTap: () => controller.jumpToNextMention(),
      child: Obx(() {
        final badgeCount = controller.unreadMentions.length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.accent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.panelShadow.withAlpha(150),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.alternate_email,
                color: theme.onAccent,
                size: 18,
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: -6,
                left: -4,
                child: _MentionPillUnreadBadge(
                  count: badgeCount,
                  theme: theme,
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _MentionPillUnreadBadge extends StatelessWidget {
  const _MentionPillUnreadBadge({
    required this.count,
    required this.theme,
  });

  final int count;
  final ChatThemeData theme;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '+99' : count.toString();
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.unreadBadge,
        shape: BoxShape.circle,
        border: Border.all(color: theme.accent, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyle.bodyText.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.onSurface,
        ),
      ),
    );
  }
}
