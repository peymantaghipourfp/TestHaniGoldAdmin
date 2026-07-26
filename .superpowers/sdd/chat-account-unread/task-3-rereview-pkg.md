# Re-review package: Task 3 fix wave (null-safe merge)
## Report (incl Fix wave)
# Task 3 Report â€” Debounced merge-refresh reconcile + validation

## Status: DONE

## Summary

Added ChatController-owned debounced account unread reconcile (300ms, mirroring FAB pattern):

- `scheduleAccountUnreadReconcile()` â€” cancels prior timer, increments `accountUnreadReconcileScheduleCount`, fires `refreshChatAccountUnreadByMerge()`
- `refreshChatAccountUnreadByMerge()` â€” fetches page 1 via `getChatAccountList`, merges `unreadChatCount` / `hasUnreadMention` / `unreadMessageCount` by `accountId` in-place via `_publishChatAccountRowUpdate`; never clears `chatAccountList`; try/catch + `AppLogger`
- Wired into `_handleSeenBroadcast`: schedules when `selfAffectsUnread` (self admin seen with valid `chatId`); no schedule on empty/malformed/other-user
- Timer cancelled in `onClose`

## Tests

```
flutter test test/chat_account_seen_sync_test.dart test/chat_conversation_unread_test.dart
â†’ 37/37 passed
```

New cases: self-seen schedules (with/without `unreadMessageCount`), non-self/empty does not schedule, `fake_async` debounce (single merge invoke, list length preserved). Task 2 tests remain green.

## graphify

```
graphify update .
â†’ OK â€” 8487 nodes, 15743 edges, 495 communities (graphify-out updated)
```

## Manual checklist

`.superpowers/sdd/chat-account-unread/task-3-manual-checklist.md` â€” all steps **Pending (human)** (dual-window validation not run in CI).

## Commits

None (per task brief).

## Concerns

- Merge refresh only reconciles accounts returned on page 1 (first 20 rows); accounts loaded via pagination beyond page 1 are not updated until a full refresh. Acceptable for defense-in-depth per brief; note if cross-tab heal misses deep-scroll rows.
- Debounce test triggers a real (unauthenticated) API call that 400s; caught safely but logs noise in test output.

## Files changed

- `lib/src/domain/chat/controller/chat.controller.dart`
- `test/chat_account_seen_sync_test.dart`
- `.superpowers/sdd/chat-account-unread/task-3-manual-checklist.md`
- `.superpowers/sdd/chat-account-unread/task-3-report.md`

---

## Fix wave â€” null-safe merge badge fields

### What changed

- Added `mergeChatAccountRowUnreadFields` (`@visibleForTesting`): merges `unreadMessageCount`, `unreadChatCount`, and `hasUnreadMention` using `fresh ?? current` so null API values never clear existing badges (same fail-safe as socket path).
- `refreshChatAccountUnreadByMerge` now uses that helper instead of blindly copying fresh fields.
- Moved `accountUnreadMergeRefreshInvokeCount++` after the empty-list early return so empty reconcile does not count as an invoke.

### Tests

```
flutter test test/chat_account_seen_sync_test.dart
â†’ 11/11 passed
```

New cases: `mergeChatAccountRowUnreadFields` preserves counts when fresh badge fields are null; applies non-null fresh values (including zero/false).

### Files changed (fix wave)

- `lib/src/domain/chat/controller/chat.controller.dart`
- `test/chat_account_seen_sync_test.dart`
- `.superpowers/sdd/chat-account-unread/task-3-report.md`

## Grep: mergeChatAccountRowUnreadFields
chat.controller.dart:98:ChatAccountModel mergeChatAccountRowUnreadFields(
chat.controller.dart:111:unreadChatCount: fresh.unreadChatCount ?? current.unreadChatCount,
chat.controller.dart:1119:/// Keeps [chatAccountList] / [selectedChatAccount] [unreadChatCount] in sync when a thread is read.
chat.controller.dart:1139:final unreadChatCount = reconcileAccountUnreadChatCount(
chat.controller.dart:1140:currentCount: current.unreadChatCount ?? 0,
chat.controller.dart:1141:reconciled: accountUnreadChatCountFromLoadedChats(chatList, accountId),
chat.controller.dart:1149:if (unreadChatCount == 0) {
chat.controller.dart:1163:unreadChatCount: unreadChatCount,
chat.controller.dart:1172:int liveUnreadChatCountForAccount(int? accountId) {
chat.controller.dart:1177:return row?.unreadChatCount ?? 0;
chat.controller.dart:1367:mergeChatAccountRowUnreadFields(current, fresh),
chat.controller.dart:2121:final bumpUnreadChatCount = shouldIncrementAccountUnreadChatCount(
chat.controller.dart:2127:accountUnreadChatCount: current.unreadChatCount ?? 0,
chat.controller.dart:2140:unreadChatCount: bumpUnreadChatCount
chat.controller.dart:2141:? ((current.unreadChatCount ?? 0) + 1)
chat.controller.dart:2142:: current.unreadChatCount,
chat.controller.dart:3448:unreadChatCount: null,
chat_account_seen_sync_test.dart:28:int unreadChatCount = 3,
chat_account_seen_sync_test.dart:40:unreadChatCount: unreadChatCount,
chat_account_seen_sync_test.dart:71:test('self-seen with absent chatList decrements account unreadChatCount',
chat_account_seen_sync_test.dart:74:_accountRow(accountId: 100, unreadChatCount: 3, hasUnreadMention: true),
chat_account_seen_sync_test.dart:88:expect(controller.chatAccountList.first.unreadChatCount, 2);
chat_account_seen_sync_test.dart:94:_accountRow(accountId: 100, unreadChatCount: 3),
chat_account_seen_sync_test.dart:108:expect(controller.chatAccountList.first.unreadChatCount, 2);
chat_account_seen_sync_test.dart:113:_accountRow(accountId: 100, unreadChatCount: 3, hasUnreadMention: true),
chat_account_seen_sync_test.dart:133:expect(controller.chatAccountList.first.unreadChatCount, 3);
chat_account_seen_sync_test.dart:139:_accountRow(accountId: 100, unreadChatCount: 3, hasUnreadMention: true),
chat_account_seen_sync_test.dart:152:expect(controller.chatAccountList.first.unreadChatCount, 3);
chat_account_seen_sync_test.dart:158:_accountRow(accountId: 100, unreadChatCount: 3, hasUnreadMention: true),
chat_account_seen_sync_test.dart:170:expect(controller.chatAccountList.first.unreadChatCount, 3);
chat_account_seen_sync_test.dart:178:_accountRow(accountId: 100, unreadChatCount: 3),
chat_account_seen_sync_test.dart:196:_accountRow(accountId: 100, unreadChatCount: 3, hasUnreadMention: true),
chat_account_seen_sync_test.dart:209:expect(controller.chatAccountList.first.unreadChatCount, 3);
chat_account_seen_sync_test.dart:215:_accountRow(accountId: 100, unreadChatCount: 3),
chat_account_seen_sync_test.dart:235:group('mergeChatAccountRowUnreadFields', () {
chat_account_seen_sync_test.dart:239:unreadChatCount: 3,
chat_account_seen_sync_test.dart:251:unreadChatCount: null,
chat_account_seen_sync_test.dart:257:final merged = mergeChatAccountRowUnreadFields(current, fresh);
chat_account_seen_sync_test.dart:259:expect(merged.unreadChatCount, 3);
chat_account_seen_sync_test.dart:267:unreadChatCount: 3,
chat_account_seen_sync_test.dart:279:unreadChatCount: 0,
chat_account_seen_sync_test.dart:285:final merged = mergeChatAccountRowUnreadFields(current, fresh);
chat_account_seen_sync_test.dart:287:expect(merged.unreadChatCount, 0);
chat_account_seen_sync_test.dart:303:_accountRow(accountId: 100, unreadChatCount: 3),
--- chat.controller.dart 96-137 ---
   96|/// preserve existing row data (never clear badges solely because API omitted them).
   97|@visibleForTesting
   98|ChatAccountModel mergeChatAccountRowUnreadFields(
   99|  ChatAccountModel current,
  100|  ChatAccountModel fresh,
  101|) {
  102|  return ChatAccountModel(
  103|    rowNum: current.rowNum,
  104|    accountId: current.accountId,
  105|    accountName: current.accountName,
  106|    lastChatId: current.lastChatId,
  107|    lastMessageOn: current.lastMessageOn,
  108|    lastMessagePreview: current.lastMessagePreview,
  109|    totalMessageCount: current.totalMessageCount,
  110|    unreadMessageCount: fresh.unreadMessageCount ?? current.unreadMessageCount,
  111|    unreadChatCount: fresh.unreadChatCount ?? current.unreadChatCount,
  112|    adminChatRole: current.adminChatRole,
  113|    hasUnreadMention: fresh.hasUnreadMention ?? current.hasUnreadMention,
  114|    chatStatus: current.chatStatus,
  115|  );
  116|}
  117|
  118|class ChatController extends GetxController {
  119|  final ChatRepository chatRepository = ChatRepository();
  120|  final AccountRepository accountRepository = AccountRepository();
  121|  final box = GetStorage();
  122|  var uuid = Uuid();
  123|  var reqId="".obs;
  124|
  125|  // Observable variables
  126|  RxList<ChatAccountModel> chatAccountList = <ChatAccountModel>[].obs;
  127|  RxList<ChatModel> chatList = <ChatModel>[].obs;
  128|  RxList<ChatMessageModel> chatMessages = <ChatMessageModel>[].obs;
  129|  RxList<AccountModel> accountList = <AccountModel>[].obs;
  130|  RxList<TopicModel> topicList = <TopicModel>[].obs;
  131|  RxList<AccountModel> filteredAccountList = <AccountModel>[].obs;
  132|
  133|  // Selected items
  134|  Rxn<ChatAccountModel> selectedChatAccount = Rxn<ChatAccountModel>();
  135|  Rxn<ChatModel> selectedChat = Rxn<ChatModel>();          // â† NEW
  136|  Rxn<AccountModel> selectedAccount = Rxn<AccountModel>();
  137|  Rxn<TopicModel> selectedTopic = Rxn<TopicModel>();

## Test file (tail - merge tests)
        accountName: 'API row',
        lastChatId: 'c1',
        lastMessageOn: null,
        lastMessagePreview: 'hello',
        totalMessageCount: 10,
        unreadMessageCount: null,
        unreadChatCount: null,
        adminChatRole: 1,
        hasUnreadMention: null,
        chatStatus: 1,
      );

      final merged = mergeChatAccountRowUnreadFields(current, fresh);

      expect(merged.unreadChatCount, 3);
      expect(merged.unreadMessageCount, 5);
      expect(merged.hasUnreadMention, isTrue);
    });

    test('non-null fresh badge fields replace existing counts', () {
      final current = _accountRow(
        accountId: 100,
        unreadChatCount: 3,
        hasUnreadMention: true,
      );
      final fresh = ChatAccountModel(
        rowNum: 1,
        accountId: 100,
        accountName: 'API row',
        lastChatId: 'c1',
        lastMessageOn: null,
        lastMessagePreview: 'hello',
        totalMessageCount: 10,
        unreadMessageCount: 0,
        unreadChatCount: 0,
        adminChatRole: 1,
        hasUnreadMention: false,
        chatStatus: 1,
      );

      final merged = mergeChatAccountRowUnreadFields(current, fresh);

      expect(merged.unreadChatCount, 0);
      expect(merged.unreadMessageCount, 0);
      expect(merged.hasUnreadMention, isFalse);
    });
  });

  group('ChatController scheduleAccountUnreadReconcile', () {
    test('debounces rapid schedules so merge refresh fires once', () {
      fakeAsync((async) {
        Get.testMode = true;
        GetStorage().write('id', 42);
        Get.put<SocketService>(_FakeSocketService(), permanent: true);
        final localController = ChatController();
        Get.put(localController);
        localController.onInit();
        localController.chatAccountList.assignAll([
          _accountRow(accountId: 100, unreadChatCount: 3),
        ]);

        localController.scheduleAccountUnreadReconcile();
        async.elapse(const Duration(milliseconds: 100));
        localController.scheduleAccountUnreadReconcile();
        expect(localController.accountUnreadReconcileScheduleCount, 2);
        expect(localController.chatAccountList.length, 1);

        async.elapse(const Duration(milliseconds: 299));
        expect(localController.accountUnreadMergeRefreshInvokeCount, 0);

        async.elapse(const Duration(milliseconds: 1));
        expect(localController.accountUnreadMergeRefreshInvokeCount, 1);
        expect(localController.chatAccountList.length, 1);

        localController.onClose();
        Get.reset();
      });
    });
  });
}
