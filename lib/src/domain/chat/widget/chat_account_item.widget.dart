import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat_account.model.dart';
import 'package:hanigold_admin/src/domain/chat/theme/chat_theme.dart';
import 'package:hanigold_admin/src/widget/blinking_svg.widget.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class ChatAccountItem extends StatelessWidget {
  const ChatAccountItem({
    super.key,
    required this.controller,
    required this.chatAccount,
  });

  final ChatController controller;
  final ChatAccountModel chatAccount;

  @override
  Widget build(BuildContext context) {
    final theme = context.chatTheme;

    return Obx(() {
      final isSelected = controller.selectedChatAccount.value?.accountId ==
          chatAccount.accountId;
      final unreadChatCount = controller.liveUnreadChatCountForAccount(
        chatAccount.accountId,
      );
      final hasUnreadMention = controller.liveUnreadMentionCountForAccount(
        chatAccount.accountId,
      );
      final query = controller.searchText.value.trim();
      final preview = chatAccount.lastMessagePreview?.trim() ?? '';
      final showPreview = query.isNotEmpty && preview.isNotEmpty;

      return Padding(
        padding: const EdgeInsets.only(bottom: 4, left: 1, right: 1),
        child: Material(
          color: isSelected
              ? theme.listItemSelectedFill
              : Colors.transparent,
          elevation: isSelected ? 2 : 0,
          shadowColor: theme.listItemSelectedGlow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.listItemSelectedBorder
                  : theme.panelBorder.withAlpha(80),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              controller.selectChatUserForExistingChat(chatAccount);
            },
            title: Text(
              chatAccount.accountName ?? 'کاربر ناشناس',
              style: AppTextStyle.bodyText.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.onSurface,
              ),
            ),
            subtitle: showPreview
                ? _buildPreview(theme, preview, query)
                : Text(
              chatAccount.lastMessageOn?.toPersianDate(
                  twoDigits: true,
                  showTime: true,
                  timeSeprator: '-') ??
                  '',
              style: AppTextStyle.bodyText.copyWith(
                fontSize: 12,
                color: theme.onSurfaceMuted,
              ),
            ),
            trailing: (unreadChatCount > 0 || hasUnreadMention == true)
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasUnreadMention == true)
                /*SvgPicture.asset(
                    'assets/svg/mention.svg',
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      theme.accent,
                      BlendMode.srcIn,
                    ),
                  ),*/
                  BlinkingSvg(
                    assetPath: 'assets/svg/mention.svg',
                    color: theme.accent,
                  ),
                if (hasUnreadMention == true && unreadChatCount > 0)
                  const SizedBox(width: 8),
                if (unreadChatCount > 0)
                  Badge(
                    label: Text(
                      unreadChatCount > 99
                          ? '+99'
                          : unreadChatCount.toString(),
                      style: AppTextStyle.bodyText.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.onSurface,
                      ),
                    ),
                    backgroundColor: theme.unreadBadge,
                  ),
              ],
            )
                : null,
          ),
        ),
      );
    });
  }
}

Widget _buildPreview(ChatThemeData theme, String preview, String query) {
  final base = AppTextStyle.bodyText.copyWith(
    fontSize: 12,
    color: theme.onSurfaceVariant,
  );
  final lower = preview.toLowerCase();
  final q = query.toLowerCase();
  final matchIndex = lower.indexOf(q);
  if (q.isEmpty || matchIndex < 0) {
    return Text(
      preview,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: base,
    );
  }
  final highlight = base.copyWith(
    color: theme.accent,
    fontWeight: FontWeight.w700,
  );
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(text: preview.substring(0, matchIndex), style: base),
        TextSpan(
          text: preview.substring(matchIndex, matchIndex + q.length),
          style: highlight,
        ),
        TextSpan(
          text: preview.substring(matchIndex + q.length),
          style: base,
        ),
      ],
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}
