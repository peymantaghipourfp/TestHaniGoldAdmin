# Review package: Task 3 (merge-refresh + validation)
**Base:** post-Task-2 | **Head:** post-Task-3 | No git

## Implementer report
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

## Manual checklist
# Task 3 â€” Manual validation checklist

Dual-window / cross-tab `ChatAccountItem` unread badge sync.

## Prerequisites

- Two app instances (tear-off tabs on Windows **or** two browser windows on web)
- Same admin account logged in on both
- Chat account list visible in both windows

## Steps

| # | Scenario | Expected | Result |
|---|----------|----------|--------|
| 1 | Send/receive a message so an account has unread | Both windows show unread badge on `ChatAccountItem` without opening that chat | **Pending (human)** |
| 2 | Mark read in window A (open chat, scroll/read) | Window B's `ChatAccountItem` badge clears without opening that chat in B | **Pending (human)** |
| 3 | Self-seen with incomplete payload (if reproducible) | Badge eventually converges via debounced reconcile (~300ms) | **Pending (human)** |
| 4 | Empty/malformed `chat.seen` payload | No white screen; existing badges unchanged | **Pending (human)** |

## Notes

- Reconcile is debounced 300ms; allow a short pause before judging step 3.
- Automated unit tests cover schedule hooks and fail-safe badge rules; this checklist requires a human on dual windows.

## FILE: test/chat_account_seen_sync_test.dart (full)
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hanigold_admin/src/config/const/socket.service.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat_account.model.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakeSocketService extends SocketService {
  @override
  void onInit() {}

  @override
  Future<void> ensureConnected({String? clientId, String? sessionId}) async {}
}

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';
}

ChatAccountModel _accountRow({
  required int accountId,
  int unreadChatCount = 3,
  bool hasUnreadMention = true,
}) {
  return ChatAccountModel(
    rowNum: 1,
    accountId: accountId,
    accountName: 'Test Account',
    lastChatId: 'c1',
    lastMessageOn: null,
    lastMessagePreview: 'hello',
    totalMessageCount: 10,
    unreadMessageCount: 5,
    unreadChatCount: unreadChatCount,
    adminChatRole: 1,
    hasUnreadMention: hasUnreadMention,
    chatStatus: 1,
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = _FakePathProvider();
    await GetStorage.init();
  });

  late ChatController controller;

  setUp(() {
    Get.testMode = true;
    GetStorage().write('id', 42);
    Get.put<SocketService>(_FakeSocketService(), permanent: true);
    controller = ChatController();
    Get.put(controller);
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('ChatController chat.seen account badge sync', () {
    test('self-seen with absent chatList decrements account unreadChatCount',
        () {
      controller.chatAccountList.assignAll([
        _accountRow(accountId: 100, unreadChatCount: 3, hasUnreadMention: true),
      ]);
      expect(controller.chatList, isEmpty);

      controller.handleSocketChatEnvelope({
        'channel': 'chat.seen',
        'data': {
          'chatId': 'c1',
          'byUserId': 42,
          'customerAccountId': 100,
          'unreadMessageCount': 0,
        },
      });

      expect(controller.chatAccountList.first.unreadChatCount, 2);
      expect(controller.chatAccountList.first.hasUnreadMention, isFalse);
    });

    test('self-seen with absent chatList and upToSeq decrements badge', () {
      controller.chatAccountList.assignAll([
        _accountRow(accountId: 100, unreadChatCount: 3),
      ]);

      controller.handleSocketChatEnvelope({
        'channel': 'chat.seen',
        'data': {
          'chatId': 'c1',
          'byUserId': 42,
          'customerAccountId': 100,
          'unreadMessageCount': 0,
          'upToSeq': 15,
        },
      });

      expect(controller.chatAccountList.first.unreadChatCount, 2);
    });

    test('empty or missing data does not throw or change badges', () {
      controller.chatAccountList.assignAll([
        _accountRow(accountId: 100, unreadChatCount: 3, hasUnreadMention: true),
      ]);

      expect(
        () => controller.handleSocketChatEnvelope(
          {'channel': 'chat.seen', 'data': null},
        ),
        returnsNormally,
      );
      expect(
        () => controller.handleSocketChatEnvelope(
          {'channel': 'chat.seen', 'data': {}},
        ),
        returnsNormally,
      );
      expect(
        () => controller.handleSocketChatEnvelope({'channel': 'chat.seen'}),
        returnsNormally,
      );

      expect(controller.chatAccountList.first.unreadChatCount, 3);
      expect(controller.chatAccountList.first.hasUnreadMention, isTrue);
    });

    test('other admin seen does not change account badges', () {
      controller.chatAccountList.assignAll([
        _accountRow(accountId: 100, unreadChatCount: 3, hasUnreadMention: true),
      ]);

      controller.handleSocketChatEnvelope({
        'channel': 'chat.seen',
        'data': {
          'chatId': 'c1',
          'byUserId': 99,
          'customerAccountId': 100,
          'unreadMessageCount': 0,
        },
      });

      expect(controller.chatAccountList.first.unreadChatCount, 3);
      expect(controller.chatAccountList.first.hasUnreadMention, isTrue);
    });

    test('self seen with missing unreadMessageCount does not clear badge', () {
      controller.chatAccountList.assignAll([
        _accountRow(accountId: 100, unreadChatCount: 3, hasUnreadMention: true),
      ]);

      controller.handleSocketChatEnvelope({
        'channel': 'chat.seen',
        'data': {
          'chatId': 'c1',
          'byUserId': 42,
          'customerAccountId': 100,
        },
      });

      expect(controller.chatAccountList.first.unreadChatCount, 3);
      expect(controller.chatAccountList.first.hasUnreadMention, isTrue);
    });
  });

  group('ChatController account unread reconcile schedule', () {
    test('self seen with unread schedules reconcile', () {
      controller.chatAccountList.assignAll([
        _accountRow(accountId: 100, unreadChatCount: 3),
      ]);

      controller.handleSocketChatEnvelope({
        'channel': 'chat.seen',
        'data': {
          'chatId': 'c1',
          'byUserId': 42,
          'customerAccountId': 100,
          'unreadMessageCount': 0,
        },
      });

      expect(controller.accountUnreadReconcileScheduleCount, 1);
    });

    test('self seen without unreadMessageCount schedules reconcile', () {
      controller.chatAccountList.assignAll([
        _accountRow(accountId: 100, unreadChatCount: 3, hasUnreadMention: true),
      ]);

      controller.handleSocketChatEnvelope({
        'channel': 'chat.seen',
        'data': {
          'chatId': 'c1',
          'byUserId': 42,
          'customerAccountId': 100,
        },
      });

      expect(controller.accountUnreadReconcileScheduleCount, 1);
      expect(controller.chatAccountList.first.unreadChatCount, 3);
      expect(controller.chatAccountList.first.hasUnreadMention, isTrue);
    });

    test('empty or other user seen does not schedule reconcile', () {
      controller.chatAccountList.assignAll([
        _accountRow(accountId: 100, unreadChatCount: 3),
      ]);

      controller.handleSocketChatEnvelope({
        'channel': 'chat.seen',
        'data': {
          'chatId': 'c1',
          'byUserId': 99,
          'customerAccountId': 100,
          'unreadMessageCount': 0,
        },
      });
      controller.handleSocketChatEnvelope({'channel': 'chat.seen', 'data': {}});
      controller.handleSocketChatEnvelope({'channel': 'chat.seen', 'data': null});
      controller.handleSocketChatEnvelope({'channel': 'chat.seen'});

      expect(controller.accountUnreadReconcileScheduleCount, 0);
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

## Controller excerpts: schedule/merge/onClose/_handleSeenBroadcast schedule wires
LINE 155: Timer? _accountUnreadReconcileTimer;
LINE 157: /// Test hook: incremented on each [scheduleAccountUnreadReconcile] call.
LINE 159: int accountUnreadReconcileScheduleCount = 0;
LINE 161: /// Test hook: incremented each time [refreshChatAccountUnreadByMerge] runs.
LINE 747: void onClose() {
LINE 757: _accountUnreadReconcileTimer?.cancel();
LINE 1302: scheduleAccountUnreadReconcile();
LINE 1310: void scheduleAccountUnreadReconcile() {
LINE 1311: _accountUnreadReconcileTimer?.cancel();
LINE 1312: accountUnreadReconcileScheduleCount++;
LINE 1313: _accountUnreadReconcileTimer = Timer(const Duration(milliseconds: 300), () {
LINE 1314: unawaited(refreshChatAccountUnreadByMerge());
LINE 1321: Future<void> refreshChatAccountUnreadByMerge() async {
LINE 1361: AppLogger.e('refreshChatAccountUnreadByMerge failed', e, s);
--- schedule region lines 151-231 ---
  151|  int _conversationUnreadAnchorSeq = 0;
  152|  Timer? _seenScrollDebounce;
  153|  static const Duration _seenScrollDebounceDelay = Duration(milliseconds: 120);
  154|
  155|  Timer? _accountUnreadReconcileTimer;
  156|
  157|  /// Test hook: incremented on each [scheduleAccountUnreadReconcile] call.
  158|  @visibleForTesting
  159|  int accountUnreadReconcileScheduleCount = 0;
  160|
  161|  /// Test hook: incremented each time [refreshChatAccountUnreadByMerge] runs.
  162|  @visibleForTesting
  163|  int accountUnreadMergeRefreshInvokeCount = 0;
  164|
  165|  /// Hides the message list while jumping to the last-read anchor (avoids latest flash).
  166|  final RxBool isAnchoringInitialScroll = false.obs;
  167|
  168|  /// Scroll to last-read [seq] once the reversed [ListView] has mounted.
  169|  int? _pendingConversationAnchorSeq;
  170|  String? _initialScrollAppliedChatId;
  171|  int _initialScrollRetryCount = 0;
  172|  static const int _maxInitialScrollRetries = 24;
  173|  bool _suppressScrollSeenSync = false;
  174|  final RxBool isComposerEmpty = true.obs;
  175|  final RxBool isCustomerTyping = false.obs;
  176|
  177|  // Mention state
  178|  final RxList<ChatMentionCandidatesModel> mentionCandidates =
  179|      <ChatMentionCandidatesModel>[].obs;
  180|  final RxList<ChatMentionCandidatesModel> mentionSuggestions =
  181|      <ChatMentionCandidatesModel>[].obs;
  182|  final RxBool isMentionPopupVisible = false.obs;
  183|  final RxBool isLoadingMentions = false.obs;
  184|  final RxInt mentionHighlightedIndex = 0.obs;
  185|  int? _mentionQueryStart;
  186|  final List<ChatMentionCandidatesModel> selectedMentions =
  187|  <ChatMentionCandidatesModel>[];
  188|  bool _mentionFetchRequested = false;
  189|
  190|  final RxList<ChatUnreadMentionsModel> unreadMentions = <ChatUnreadMentionsModel>[].obs;
  191|  bool _isJumpingToMention = false;
  192|
  193|  Timer? _customerTypingIdleTimer;
  194|  static const Duration _customerTypingIdle = Duration(seconds: 4);
  195|
  196|  // Attachment state
  197|  final RxList<ChatPendingAttachment> pendingAttachments =
  198|      <ChatPendingAttachment>[].obs;
  199|  final RxBool isUploadingAttachments = false.obs;
  200|
  201|  final ChatAttachmentRepository _chatAttachmentRepo = ChatAttachmentRepository();
  202|  final ChatStickerSendService _stickerSendService = ChatStickerSendService();
  203|
  204|  /// When set, exactly one list row uses [_scrollTargetGlobalKey] for ensureVisible.
  205|  final Rx<String?> scrollTargetBubbleId = Rx<String?>(null);
  206|  final GlobalKey _scrollTargetGlobalKey = GlobalKey();
  207|  /// Identity for scroll keys and reply-parent highlight (guid or chatId+seq).
  208|  final Rx<String?> highlightedBubbleId = Rx<String?>(null);
  209|  Timer? _replyHighlightTimer;
  210|  static const Duration _replyHighlightDuration = Duration(milliseconds: 2000);
  211|  static const int _bringMessageIntoViewAttempts = 40;
  212|
  213|  /// Blocks loader-driven [loadMoreMessages] during programmatic scroll jumps.
  214|  bool _suppressMessagePagination = false;
  215|
  216|  void _clearMessageBubbleScrollKeys() {
  217|    scrollTargetBubbleId.value = null;
  218|    _clearReplyHighlight();
  219|  }
  220|
  221|  void _clearReplyHighlight() {
  222|    _replyHighlightTimer?.cancel();
  223|    _replyHighlightTimer = null;
  224|    highlightedBubbleId.value = null;
  225|  }
  226|
  227|  /// Stable id for [bubbleListKey] / [MessageBubble] highlight paint.
  228|  String bubbleIdentity(ChatMessageModel m) => _bubbleScrollKeyId(m);
  229|
  230|  void _highlightReplyParent(ChatMessageModel target) {
  231|    highlightedBubbleId.value = _bubbleScrollKeyId(target);
--- merge method lines 1321-1400 ---
 1321|  Future<void> refreshChatAccountUnreadByMerge() async {
 1322|    accountUnreadMergeRefreshInvokeCount++;
 1323|    try {
 1324|      if (chatAccountList.isEmpty) return;
 1325|
 1326|      final query = searchText.value.trim();
 1327|      final fetched = await chatRepository.getChatAccountList(
 1328|        startIndex: 1,
 1329|        toIndex: pageSize,
 1330|        searchText: query.isNotEmpty ? query : null,
 1331|      );
 1332|
 1333|      for (final fresh in fetched) {
 1334|        final accountId = fresh.accountId;
 1335|        if (accountId == null) continue;
 1336|
 1337|        final accountIndex =
 1338|            chatAccountList.indexWhere((a) => a.accountId == accountId);
 1339|        if (accountIndex == -1) continue;
 1340|
 1341|        final current = chatAccountList[accountIndex];
 1342|        _publishChatAccountRowUpdate(
 1343|          accountIndex,
 1344|          ChatAccountModel(
 1345|            rowNum: current.rowNum,
 1346|            accountId: current.accountId,
 1347|            accountName: current.accountName,
 1348|            lastChatId: current.lastChatId,
 1349|            lastMessageOn: current.lastMessageOn,
 1350|            lastMessagePreview: current.lastMessagePreview,
 1351|            totalMessageCount: current.totalMessageCount,
 1352|            unreadMessageCount: fresh.unreadMessageCount,
 1353|            unreadChatCount: fresh.unreadChatCount,
 1354|            adminChatRole: current.adminChatRole,
 1355|            hasUnreadMention: fresh.hasUnreadMention,
 1356|            chatStatus: current.chatStatus,
 1357|          ),
 1358|        );
 1359|      }
 1360|    } catch (e, s) {
 1361|      AppLogger.e('refreshChatAccountUnreadByMerge failed', e, s);
 1362|    }
 1363|  }
 1364|
 1365|  Future<void> _ensureAnchorMessageLoaded(String chatId, int anchorSeq) async {
 1366|    if (anchorSeq <= 0) return;
 1367|    const maxPages = 24;
 1368|    for (var i = 0; i < maxPages; i++) {
 1369|      if (chatMessages.any((m) => m.seq == anchorSeq)) return;
 1370|      final oldest = chatMessages.isEmpty
 1371|          ? null
 1372|          : chatMessages
 1373|          .map((m) => m.seq)
 1374|          .whereType<int>()
 1375|          .fold<int?>(null, (a, b) => a == null || b < a ? b : a);
 1376|      if (oldest != null && oldest <= anchorSeq) return;
 1377|      if (!hasMoreMessages.value) return;
 1378|      final before = chatMessages.length;
 1379|      await loadChatMessages(chatId);
 1380|      if (chatMessages.length <= before) return;
 1381|    }
 1382|  }
 1383|
 1384|  ChatMessageModel? _messageForSeq(int seq) {
 1385|    final chatId = selectedChat.value?.chatId?.toString().trim();
 1386|    return chatMessages.firstWhereOrNull(
 1387|          (m) => m.seq == seq && m.chatId?.toString().trim() == chatId,
 1388|    );
 1389|  }
 1390|
 1391|  /// Resolves the last-read bubble; falls back to the newest loaded message at or below [anchorSeq].
 1392|  ChatMessageModel? _messageForLastReadAnchor(int anchorSeq) {
 1393|    final exact = _messageForSeq(anchorSeq);
 1394|    if (exact != null) return exact;
 1395|
 1396|    final chatId = selectedChat.value?.chatId?.toString().trim();
 1397|    ChatMessageModel? best;
 1398|    for (final m in chatMessages) {
 1399|      final seq = m.seq;
 1400|      if (seq == null || seq > anchorSeq) continue;
--- _handleSeenBroadcast lines 1166-1365 ---
 1166|  void _handleSeenBroadcast(Map<String, dynamic> data) {
 1167|    try {
 1168|      final payload = seen_bc.SocketChatSeenBroadcastModel(
 1169|        channel: 'chat.seen',
 1170|        sessionId: null,
 1171|        data: seen_bc.Data.fromJson(data),
 1172|      );
 1173|      final d = payload.data;
 1174|      if (d == null) return;
 1175|
 1176|      final chatId = d.chatId?.trim();
 1177|      if (chatId == null || chatId.isEmpty) return;
 1178|
 1179|      final upToSeq = d.upToSeq;
 1180|      final unread = d.unreadMessageCount;
 1181|      final selfAffectsUnread = seenBroadcastAffectsLocalUnread(
 1182|        broadcastByUserId: d.byUserId,
 1183|        localUserId: int.tryParse(currentUserId),
 1184|      );
 1185|
 1186|      if (upToSeq != null) {
 1187|        _mergeSeenIntoChatLists(
 1188|          chatId: chatId,
 1189|          upToSeq: upToSeq,
 1190|          unreadMessageCount: unread,
 1191|          customerAccountId: d.customerAccountId,
 1192|          totalUnreadMessageCount: d.totalUnreadMessageCount,
 1193|          syncAccountBadge: selfAffectsUnread,
 1194|        );
 1195|      } else if (unread != null && selfAffectsUnread) {
 1196|        int? accountId = d.customerAccountId;
 1197|        var previousChatUnread = 0;
 1198|        final idx = chatList.indexWhere((c) => c.chatId == chatId);
 1199|        final chatWasInLocalList =
 1200|            idx != -1 || selectedChat.value?.chatId == chatId;
 1201|        if (idx != -1) {
 1202|          final c = chatList[idx];
 1203|          accountId ??= c.accountId;
 1204|          previousChatUnread = c.unreadMessageCount ?? 0;
 1205|          chatList[idx] = ChatModel(
 1206|            rowNum: c.rowNum,
 1207|            chatId: c.chatId,
 1208|            accountId: c.accountId,
 1209|            topicId: c.topicId,
 1210|            topicCode: c.topicCode,
 1211|            topicTitle: c.topicTitle,
 1212|            status: c.status,
 1213|            createdOn: c.createdOn,
 1214|            lastActivity: c.lastActivity,
 1215|            accountName: c.accountName,
 1216|            lastMessageSeq: c.lastMessageSeq,
 1217|            lastSeenSeq: c.lastSeenSeq,
 1218|            clientSeenSeq: c.clientSeenSeq,
 1219|            lastMessagePreview: c.lastMessagePreview,
 1220|            lastMessageOn: c.lastMessageOn,
 1221|            totalMessageCount: c.totalMessageCount,
 1222|            unreadMessageCount: unread,
 1223|            unreadMentionCount: unread == 0 ? 0 : c.unreadMentionCount,
 1224|            topicKey: c.topicKey,
 1225|            assignedAdminAccountId: c.assignedAdminAccountId,
 1226|            assignedAdminUserId: c.assignedAdminUserId,
 1227|            closedOn: c.closedOn,
 1228|            assignedAdminName: c.assignedAdminName,
 1229|            userId: c.userId,
 1230|            adminRole: c.adminRole,
 1231|            adminRoleTitle: c.adminRoleTitle,
 1232|          );
 1233|        }
 1234|        final sel = selectedChat.value;
 1235|        if (sel?.chatId == chatId) {
 1236|          selectedChat.value = ChatModel(
 1237|            rowNum: sel!.rowNum,
 1238|            chatId: sel.chatId,
 1239|            accountId: sel.accountId,
 1240|            topicId: sel.topicId,
 1241|            topicCode: sel.topicCode,
 1242|            topicTitle: sel.topicTitle,
 1243|            status: sel.status,
 1244|            createdOn: sel.createdOn,
 1245|            lastActivity: sel.lastActivity,
 1246|            accountName: sel.accountName,
 1247|            lastMessageSeq: sel.lastMessageSeq,
 1248|            lastSeenSeq: sel.lastSeenSeq,
 1249|            clientSeenSeq: sel.clientSeenSeq,
 1250|            lastMessagePreview: sel.lastMessagePreview,
 1251|            lastMessageOn: sel.lastMessageOn,
 1252|            totalMessageCount: sel.totalMessageCount,
 1253|            unreadMessageCount: unread,
 1254|            unreadMentionCount: unread == 0 ? 0 : sel.unreadMentionCount,
 1255|            topicKey: sel.topicKey,
 1256|            assignedAdminAccountId: sel.assignedAdminAccountId,
 1257|            assignedAdminUserId: sel.assignedAdminUserId,
 1258|            closedOn: sel.closedOn,
 1259|            assignedAdminName: sel.assignedAdminName,
 1260|            userId: sel.userId,
 1261|            adminRole: sel.adminRole,
 1262|            adminRoleTitle: sel.adminRoleTitle,
 1263|          );
 1264|          accountId ??= sel.accountId;
 1265|          if (idx == -1) {
 1266|            previousChatUnread = sel.unreadMessageCount ?? 0;
 1267|          }
 1268|        }
 1269|
 1270|        _syncAccountUnreadAfterChatSeen(
 1271|          accountId: accountId,
 1272|          previousChatUnread: previousChatUnread,
 1273|          newChatUnread: unread,
 1274|          chatWasInLocalList: chatWasInLocalList,
 1275|          totalUnreadMessageCount: d.totalUnreadMessageCount,
 1276|        );
 1277|      }
 1278|
 1279|      if (selectedChat.value?.chatId == chatId) {
 1280|        final myUserId = int.tryParse(currentUserId);
 1281|        final readerIsCustomer =
 1282|            d.byUserId != null && myUserId != null && d.byUserId != myUserId;
 1283|        if (unread != null) {
 1284|          conversationUnreadCount.value = conversationUnreadAfterSeenBroadcast(
 1285|            currentUnread: conversationUnreadCount.value,
 1286|            broadcastUnread: unread,
 1287|            readerIsCustomer: readerIsCustomer,
 1288|          );
 1289|        }
 1290|        if (upToSeq != null) {
 1291|          if (!readerIsCustomer && upToSeq > _adminMarkedSeenSeq) {
 1292|            _adminMarkedSeenSeq = upToSeq;
 1293|            _pruneUnreadMentionsUpTo(upToSeq);
 1294|          }
 1295|          if (readerIsCustomer) {
 1296|            _applyOutgoingSeenByCustomer(upToSeq: upToSeq);
 1297|          }
 1298|        }
 1299|      }
 1300|
 1301|      if (selfAffectsUnread) {
 1302|        scheduleAccountUnreadReconcile();
 1303|      }
 1304|    } catch (e) {
 1305|      if (kDebugMode) debugPrint('[chat.seen] broadcast parse error: $e');
 1306|    }
 1307|  }
 1308|
 1309|  /// Debounced server reconcile for cross-window account unread badge convergence.
 1310|  void scheduleAccountUnreadReconcile() {
 1311|    _accountUnreadReconcileTimer?.cancel();
 1312|    accountUnreadReconcileScheduleCount++;
 1313|    _accountUnreadReconcileTimer = Timer(const Duration(milliseconds: 300), () {
 1314|      unawaited(refreshChatAccountUnreadByMerge());
 1315|    });
 1316|  }
 1317|
 1318|  /// Re-fetches page-1 account rows and merges unread badge fields by [accountId].
 1319|  ///
 1320|  /// Does not [RxList.clear] [chatAccountList] â€” safe for silent cross-tab reconcile.
 1321|  Future<void> refreshChatAccountUnreadByMerge() async {
 1322|    accountUnreadMergeRefreshInvokeCount++;
 1323|    try {
 1324|      if (chatAccountList.isEmpty) return;
 1325|
 1326|      final query = searchText.value.trim();
 1327|      final fetched = await chatRepository.getChatAccountList(
 1328|        startIndex: 1,
 1329|        toIndex: pageSize,
 1330|        searchText: query.isNotEmpty ? query : null,
 1331|      );
 1332|
 1333|      for (final fresh in fetched) {
 1334|        final accountId = fresh.accountId;
 1335|        if (accountId == null) continue;
 1336|
 1337|        final accountIndex =
 1338|            chatAccountList.indexWhere((a) => a.accountId == accountId);
 1339|        if (accountIndex == -1) continue;
 1340|
 1341|        final current = chatAccountList[accountIndex];
 1342|        _publishChatAccountRowUpdate(
 1343|          accountIndex,
 1344|          ChatAccountModel(
 1345|            rowNum: current.rowNum,
 1346|            accountId: current.accountId,
 1347|            accountName: current.accountName,
 1348|            lastChatId: current.lastChatId,
 1349|            lastMessageOn: current.lastMessageOn,
 1350|            lastMessagePreview: current.lastMessagePreview,
 1351|            totalMessageCount: current.totalMessageCount,
 1352|            unreadMessageCount: fresh.unreadMessageCount,
 1353|            unreadChatCount: fresh.unreadChatCount,
 1354|            adminChatRole: current.adminChatRole,
 1355|            hasUnreadMention: fresh.hasUnreadMention,
 1356|            chatStatus: current.chatStatus,
 1357|          ),
 1358|        );
 1359|      }
 1360|    } catch (e, s) {
 1361|      AppLogger.e('refreshChatAccountUnreadByMerge failed', e, s);
 1362|    }
 1363|  }
 1364|
 1365|  Future<void> _ensureAnchorMessageLoaded(String chatId, int anchorSeq) async {
--- onClose lines 747-771 ---
  747|  void onClose() {
  748|    _clearCustomerTyping();
  749|    _clearReplyHighlight();
  750|    messageController.removeListener(_onMessageComposerTextChanged);
  751|    messagesScrollController.dispose();
  752|    searchController.dispose();
  753|    chatAccountsSearchController.dispose();
  754|    _messageSearchDebounce?.cancel();
  755|    _chatAccountSearchDebounce?.cancel();
  756|    _seenScrollDebounce?.cancel();
  757|    _accountUnreadReconcileTimer?.cancel();
  758|    messagesSearchController.dispose();
  759|    messageFocusNode.dispose();
  760|    super.onClose();
  761|  }
  762|
  763|  void _onMessagesScrollChanged() {
  764|    if (!messagesScrollController.hasClients) return;
  765|    isNearBottom.value = messagesScrollController.position.pixels < 80;
  766|    if (_suppressScrollSeenSync) return;
  767|    _seenScrollDebounce?.cancel();
  768|    _seenScrollDebounce = Timer(_seenScrollDebounceDelay, () {
  769|      unawaited(_syncSeenFromScrollPosition());
  770|    });
  771|  }
