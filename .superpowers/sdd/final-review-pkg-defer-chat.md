# Final review package — Defer Chat API Loads
Merge base: pre-feature working tree | Head: post-Task-1+2 (no git)

## Commits
(none — no git repository)

## Stat
 M lib/src/domain/chat/controller/chat.controller.dart
 M lib/src/domain/chat/widget/chat_dialog.widget.dart
 M lib/src/domain/chat/widget/dialogs/add_user_dialog.dart
 A test/chat_controller_lazy_load_test.dart

## Minor findings carried from task reviews
- TOCTOU on concurrent ensure* before isLoading flips
- Brief loading-state flash possible with unawaited ensure*
- Manual E2E validation (login/home/chat) not executed by agents

## File: test/chat_controller_lazy_load_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';

void main() {
  group('ChatController lazy-load predicates', () {
    test('shouldFetchChatAccounts only when empty and idle', () {
      expect(shouldFetchChatAccounts(listLength: 0, isLoading: false), isTrue);
      expect(shouldFetchChatAccounts(listLength: 0, isLoading: true), isFalse);
      expect(shouldFetchChatAccounts(listLength: 3, isLoading: false), isFalse);
    });

    test('shouldFetchAccountList only when empty and idle', () {
      expect(shouldFetchAccountList(listLength: 0, isLoading: false), isTrue);
      expect(shouldFetchAccountList(listLength: 1, isLoading: false), isFalse);
    });
  });
}

```
## Excerpts: chat.controller.dart
```dart
// --- 80-102 ---
80|
81|@visibleForTesting
82|bool shouldFetchChatAccounts({
83|  required int listLength,
84|  required bool isLoading,
85|}) =>
86|    listLength == 0 && !isLoading;
87|
88|@visibleForTesting
89|bool shouldFetchAccountList({
90|  required int listLength,
91|  required bool isLoading,
92|}) =>
93|    listLength == 0 && !isLoading;
94|
95|class ChatController extends GetxController {
96|  final ChatRepository chatRepository = ChatRepository();
97|  final AccountRepository accountRepository = AccountRepository();
98|  final box = GetStorage();
99|  var uuid = Uuid();
100|  var reqId="".obs;
101|
102|  // Observable variables
// --- 87-109 ---
87|
88|@visibleForTesting
89|bool shouldFetchAccountList({
90|  required int listLength,
91|  required bool isLoading,
92|}) =>
93|    listLength == 0 && !isLoading;
94|
95|class ChatController extends GetxController {
96|  final ChatRepository chatRepository = ChatRepository();
97|  final AccountRepository accountRepository = AccountRepository();
98|  final box = GetStorage();
99|  var uuid = Uuid();
100|  var reqId="".obs;
101|
102|  // Observable variables
103|  RxList<ChatAccountModel> chatAccountList = <ChatAccountModel>[].obs;
104|  RxList<ChatModel> chatList = <ChatModel>[].obs;
105|  RxList<ChatMessageModel> chatMessages = <ChatMessageModel>[].obs;
106|  RxList<AccountModel> accountList = <AccountModel>[].obs;
107|  RxList<TopicModel> topicList = <TopicModel>[].obs;
108|  RxList<AccountModel> filteredAccountList = <AccountModel>[].obs;
109|
// --- 715-737 ---
715|
716|  @override
717|  void onInit() {
718|    _initializeSocketListener();
719|    messageController.addListener(_onMessageComposerTextChanged);
720|    messagesScrollController.addListener(_onMessagesScrollChanged);
721|    super.onInit();
722|  }
723|
724|  @override
725|  void onClose() {
726|    _clearCustomerTyping();
727|    _clearReplyHighlight();
728|    messageController.removeListener(_onMessageComposerTextChanged);
729|    messagesScrollController.dispose();
730|    searchController.dispose();
731|    chatAccountsSearchController.dispose();
732|    _messageSearchDebounce?.cancel();
733|    _chatAccountSearchDebounce?.cancel();
734|    _seenScrollDebounce?.cancel();
735|    messagesSearchController.dispose();
736|    messageFocusNode.dispose();
737|    super.onClose();
// --- 2208-2230 ---
2208|  }
2209|
2210|  Future<void> ensureChatAccountsLoaded() async {
2211|    if (!shouldFetchChatAccounts(
2212|      listLength: chatAccountList.length,
2213|      isLoading: isLoadingChatAccounts.value,
2214|    )) {
2215|      return;
2216|    }
2217|    await loadChatAccountList(refresh: true);
2218|  }
2219|
2220|  Future<void> ensureAccountListLoaded() async {
2221|    if (!shouldFetchAccountList(
2222|      listLength: accountList.length,
2223|      isLoading: isLoadingAccounts.value,
2224|    )) {
2225|      return;
2226|    }
2227|    await loadAccountList();
2228|  }
2229|
2230|  // â”€â”€â”€ Load chat account list â”€â”€â”€
// --- 2209-2231 ---
2209|
2210|  Future<void> ensureChatAccountsLoaded() async {
2211|    if (!shouldFetchChatAccounts(
2212|      listLength: chatAccountList.length,
2213|      isLoading: isLoadingChatAccounts.value,
2214|    )) {
2215|      return;
2216|    }
2217|    await loadChatAccountList(refresh: true);
2218|  }
2219|
2220|  Future<void> ensureAccountListLoaded() async {
2221|    if (!shouldFetchAccountList(
2222|      listLength: accountList.length,
2223|      isLoading: isLoadingAccounts.value,
2224|    )) {
2225|      return;
2226|    }
2227|    await loadAccountList();
2228|  }
2229|
2230|  // â”€â”€â”€ Load chat account list â”€â”€â”€
2231|  Future<void> loadChatAccountList({
// --- 2218-2240 ---
2218|  }
2219|
2220|  Future<void> ensureAccountListLoaded() async {
2221|    if (!shouldFetchAccountList(
2222|      listLength: accountList.length,
2223|      isLoading: isLoadingAccounts.value,
2224|    )) {
2225|      return;
2226|    }
2227|    await loadAccountList();
2228|  }
2229|
2230|  // â”€â”€â”€ Load chat account list â”€â”€â”€
2231|  Future<void> loadChatAccountList({
2232|    bool refresh = false,
2233|    bool fromSearch = false,
2234|  }) async {
2235|    final query = searchText.value.trim();
2236|    final isSearchRequest = refresh && (fromSearch || query.isNotEmpty);
2237|    final seq =
2238|    isSearchRequest ? ++_chatAccountSearchSeq : _chatAccountSearchSeq;
2239|    try {
2240|      if (refresh) {
// --- 2219-2241 ---
2219|
2220|  Future<void> ensureAccountListLoaded() async {
2221|    if (!shouldFetchAccountList(
2222|      listLength: accountList.length,
2223|      isLoading: isLoadingAccounts.value,
2224|    )) {
2225|      return;
2226|    }
2227|    await loadAccountList();
2228|  }
2229|
2230|  // â”€â”€â”€ Load chat account list â”€â”€â”€
2231|  Future<void> loadChatAccountList({
2232|    bool refresh = false,
2233|    bool fromSearch = false,
2234|  }) async {
2235|    final query = searchText.value.trim();
2236|    final isSearchRequest = refresh && (fromSearch || query.isNotEmpty);
2237|    final seq =
2238|    isSearchRequest ? ++_chatAccountSearchSeq : _chatAccountSearchSeq;
2239|    try {
2240|      if (refresh) {
2241|        chatAccountPage = 1;
```
## Excerpts: lib/src/domain/chat/widget/chat_dialog.widget.dart
```dart
// --- 1-11 ---
1|import 'dart:async';
2|
3|import 'package:flutter/material.dart';
4|import 'package:get/get.dart';
5|import 'package:hanigold_admin/src/config/const/app_text_style.dart';
6|import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
7|import 'package:hanigold_admin/src/domain/chat/theme/chat_theme.dart';
8|import 'package:hanigold_admin/src/domain/chat/widget/chat_list_content.widget.dart';
9|import 'package:hanigold_admin/src/domain/chat/widget/chat_list_panel.widget.dart';
10|import 'package:hanigold_admin/src/domain/chat/widget/conversation_panel.widget.dart';
11|import 'package:hanigold_admin/src/domain/chat/widget/dialogs/add_user_dialog.dart';
// --- 33-46 ---
33|  late final ChatController _controller;
34|
35|  @override
36|  void initState() {
37|    super.initState();
38|    registerChatControllerIfNeeded();
39|    _controller = Get.find<ChatController>();
40|    unawaited(_controller.ensureChatAccountsLoaded());
41|  }
42|  @override
43|  Widget build(BuildContext context) {
44|    return ChatThemeScope(
45|      child: Builder(
46|        builder: (context) => _ChatDialogBody(
// --- 37-50 ---
37|    super.initState();
38|    registerChatControllerIfNeeded();
39|    _controller = Get.find<ChatController>();
40|    unawaited(_controller.ensureChatAccountsLoaded());
41|  }
42|  @override
43|  Widget build(BuildContext context) {
44|    return ChatThemeScope(
45|      child: Builder(
46|        builder: (context) => _ChatDialogBody(
47|          controller: _controller,
48|          isDesktop: ResponsiveBreakpoints.of(context).largerThan(TABLET),
49|        ),
50|      ),
```
## Excerpts: lib/src/domain/chat/widget/dialogs/add_user_dialog.dart
```dart
// --- 1-11 ---
1|import 'dart:async';
2|
3|import 'package:flutter/material.dart';
4|import 'package:get/get.dart';
5|import 'package:hanigold_admin/src/config/const/app_text_style.dart';
6|import 'package:hanigold_admin/src/domain/account/model/account.model.dart';
7|import 'package:hanigold_admin/src/domain/chat/theme/chat_theme.dart';
8|import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
9|import 'package:hanigold_admin/src/domain/chat/model/chat_account.model.dart';
10|import 'package:hanigold_admin/src/domain/chat/model/chat_message.model.dart';
11|import 'package:hanigold_admin/src/domain/chat/widget/dialogs/topic_selection_dialog.dart';
// --- 22-35 ---
22|  showAddUserDialog(context, controller);
23|}
24|
25|void showAddUserDialog(BuildContext context, ChatController controller) {
26|  unawaited(controller.ensureAccountListLoaded());
27|  final theme = context.chatTheme;
28|  final forwardMsg = controller.pendingForwardMessage.value;
29|  Get.dialog(
30|    chatThemedDialog(
31|      Dialog(
32|      backgroundColor: theme.shellBackground,
33|      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
34|      child: Container(
35|        decoration: theme.dialogDecoration(),
// --- 23-36 ---
23|}
24|
25|void showAddUserDialog(BuildContext context, ChatController controller) {
26|  unawaited(controller.ensureAccountListLoaded());
27|  final theme = context.chatTheme;
28|  final forwardMsg = controller.pendingForwardMessage.value;
29|  Get.dialog(
30|    chatThemedDialog(
31|      Dialog(
32|      backgroundColor: theme.shellBackground,
33|      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
34|      child: Container(
35|        decoration: theme.dialogDecoration(),
36|        width: Get.width * 0.6,
```

