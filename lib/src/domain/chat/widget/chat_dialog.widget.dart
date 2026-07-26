import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
import 'package:hanigold_admin/src/domain/chat/theme/chat_theme.dart';
import 'package:hanigold_admin/src/domain/chat/widget/chat_list_content.widget.dart';
import 'package:hanigold_admin/src/domain/chat/widget/chat_list_panel.widget.dart';
import 'package:hanigold_admin/src/domain/chat/widget/conversation_panel.widget.dart';
import 'package:hanigold_admin/src/domain/chat/widget/dialogs/add_user_dialog.dart';
import 'package:hanigold_admin/src/domain/chat/widget/empty_side_panel.widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/session_bootstrap.dart';
import '../../../widget/socket_status_indicator.widget.dart';

class ChatDialog extends StatefulWidget {
  const ChatDialog({super.key});

  static Future<void> show() {
    return Get.dialog(
      const ChatDialog(),
      barrierDismissible: false,
    );
  }

  @override
  State<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  late final ChatController _controller;

  @override
  void initState() {
    super.initState();
    registerChatControllerIfNeeded();
    _controller = Get.find<ChatController>();
    unawaited(_controller.ensureChatAccountsLoaded());
  }
  @override
  Widget build(BuildContext context) {
    return ChatThemeScope(
      child: Builder(
        builder: (context) => _ChatDialogBody(
          controller: _controller,
          isDesktop: ResponsiveBreakpoints.of(context).largerThan(TABLET),
        ),
      ),
    );
  }
}

class _ChatDialogBody extends StatelessWidget {
  const _ChatDialogBody({
    required this.controller,
    required this.isDesktop,
  });

  final ChatController controller;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final theme = context.chatTheme;

    return Dialog(
      backgroundColor: theme.shellBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width:isDesktop ? Get.width * 0.8 : Get.width * 0.95,
        height:isDesktop ? Get.height * 0.8 : Get.height * 0.85,
        padding: EdgeInsets.all(isDesktop ? 20 : 5),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'گفتگوها',
                  style: AppTextStyle.bodyText.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SocketStatusIndicator(),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      controller.loadChatAccountList(refresh: true),
                  icon: Icon(Icons.refresh_rounded, color: theme.accent),
                  tooltip: 'تازه‌سازی لیست',
                ),
                IconButton(
                  onPressed: () => showAddUserDialog(context, controller),
                  icon: Icon(Icons.person_add_alt_1_rounded, color: theme.accent),
                  tooltip: 'افزودن کاربر جدید',
                ),
                IconButton(
                  onPressed: () {
                    controller.resetChatState();
                    Get.back();
                  },
                  icon: Icon(Icons.close_rounded, color: theme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: theme.divider),
            const SizedBox(height: 20),
            isDesktop
                ? Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 1,
                    child: ChatListContent(controller: controller),
                  ),
                  Expanded(
                    flex: 2,
                    child: Obx(() {
                      if (controller.selectedChat.value != null) {
                        return ConversationPanel(controller: controller);
                      }
                      if (controller.selectedAccount.value != null &&
                          controller.selectedTopic.value != null &&
                          controller.selectedChat.value == null) {
                        return ConversationPanel(controller: controller);
                      }
                      if (controller.selectedChatAccount.value != null) {
                        return ChatListPanel(controller: controller);
                      }
                      return const EmptySidePanel();
                    }),
                  ),
                ],
              ),
            )
                : Expanded(
              child: Obx(() {
                if (controller.selectedChat.value != null) {
                  return ConversationPanel(controller: controller);
                }
                if (controller.selectedAccount.value != null &&
                    controller.selectedTopic.value != null &&
                    controller.selectedChat.value == null) {
                  return ConversationPanel(controller: controller);
                }
                if (controller.selectedChatAccount.value != null) {
                  return ChatListPanel(controller: controller);
                }
                return ChatListContent(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

