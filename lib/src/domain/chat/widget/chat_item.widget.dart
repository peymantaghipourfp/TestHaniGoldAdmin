import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat.model.dart';
import 'package:hanigold_admin/src/domain/chat/theme/chat_theme.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../../../widget/blinking_svg.widget.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this.controller,
    required this.chat,
  });

  final ChatController controller;
  final ChatModel chat;

  @override
  Widget build(BuildContext context) {
    final theme = context.chatTheme;
    final bool isClosed = chat.status == 1;
    final bool unPicked = chat.status == 3;
    final bool isView = chat.adminRole == 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: theme.threadCardDecoration(
            isClosed: isClosed,
            isView: isView,
          ),
          child: ListTile(
            onTap: () async {
              await controller.openChatConversation(chat);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            title: Row(
              children: [
                if (isView)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    child: SvgPicture.asset(
                      'assets/svg/view-chat.svg',
                      height: 19,
                      colorFilter: ColorFilter.mode(
                        theme.statusView,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                Icon(Icons.topic_outlined, size: 16, color: theme.topicAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    chat.topicTitle ?? 'بدون موضوع',
                    style: AppTextStyle.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chat.lastMessagePreview != null &&
                        chat.lastMessagePreview!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        (chat.lastMessagePreview ?? "").length > 35
                            ? "${(chat.lastMessagePreview ?? "").substring(0, 35)}..."
                            : (chat.lastMessagePreview ?? ""),
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 12,
                          color: isClosed
                              ? theme.onSurfaceMuted
                              : unPicked
                              ? theme.onSurfaceVariant
                              : theme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessageOn?.toPersianDate(
                          twoDigits: true, showTime: true, timeSeprator: '-') ??
                          '',
                      style: AppTextStyle.bodyText.copyWith(
                        fontSize: 11,
                        color: isClosed
                            ? theme.onSurfaceMuted.withAlpha(160)
                            : unPicked
                            ? theme.onSurfaceMuted
                            : theme.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((chat.unreadMentionCount ?? 0) > 0)
                      _ChatThreadUnreadMentionBadge(
                        count: chat.unreadMentionCount ?? 0,
                        theme: theme,
                      ),
                    SizedBox(width: 10,),
                    if ((chat.unreadMessageCount ?? 0) > 0)
                      _ChatThreadUnreadBadge(
                        count: chat.unreadMessageCount ?? 0,
                        theme: theme,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _ChatThreadUnreadBadge extends StatelessWidget {
  const _ChatThreadUnreadBadge({
    required this.count,
    required this.theme,
  });

  final int count;
  final ChatThemeData theme;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '+99' : count.toString();
    return Badge(
      label: Text(
        label,
        style: AppTextStyle.bodyText.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.onSurface,
        ),
      ),
      backgroundColor: theme.unreadBadge,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

class _ChatThreadUnreadMentionBadge extends StatelessWidget {
  const _ChatThreadUnreadMentionBadge({
    required this.count,
    required this.theme,
  });

  final int count;
  final ChatThemeData theme;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '+99' : count.toString();
    return Badge(
      label: Row(
        children: [
          Text(
            label,
            style: AppTextStyle.bodyText.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.accent,
            ),
          ),
          BlinkingSvg(
            assetPath: 'assets/svg/mention.svg',
            color: theme.accent,
            size: 20,
          ),
        ],
      ),
      backgroundColor: AppColor.secondary200Color,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}
