# Review package: Task 2 (ChatAccountItem seen sync)
**Base:** post-Task-1 | **Head:** post-Task-2 | No git — excerpts + full new test

## Implementer report
# Task 2 Report: Fail-safe `_handleSeenBroadcast` + absent-thread account sync

**Status:** DONE  
**Date:** 2026-07-11

## What was implemented

Wired Task 1 helpers into `ChatController` so Tab B `ChatAccountItem` badges clear on self `chat.seen`, including when the thread was never in local `chatList`.

### `_handleSeenBroadcast`
- Removed blind `unreadMessageCount ?? 0`; keeps nullable `unread`.
- Gates account-badge mutations with `seenBroadcastAffectsLocalUnread` (self admin only).
- Skips thread-unread application and account sync when `unread` is absent.
- Preserves `readerIsCustomer` handling for open-conversation pill/tick.

### `_syncAccountUnreadAfterChatSeen`
- Uses `threadJustReadFromSeenBroadcast` (fixes absent-`chatList` stale badge).
- Accepts `chatWasInLocalList`; `newChatUnread` is `int?`.
- Clears `hasUnreadMention` when `unreadChatCount` reaches 0.

### `_mergeSeenIntoChatLists`
- `unreadMessageCount` now nullable; preserves local unread when server omits it.
- `syncAccountBadge` flag; account sync only when self-seen and unread present.

## TDD

**RED:** `flutter test test/chat_account_seen_sync_test.dart` â€” 2/5 failed (absent-chatList cases stayed at 3).

**GREEN:** 5/5 new + 28/28 existing helper tests pass (33 total).

## Tests added

`test/chat_account_seen_sync_test.dart`:
- Absent-`chatList` self-seen â†’ account `unreadChatCount` 3â†’2, mention cleared
- Same with `upToSeq`
- Empty/null/`{}` data â†’ no throw, badges unchanged
- Other admin â†’ badges unchanged
- Self-seen missing `unreadMessageCount` â†’ no blind clear

## Files changed

- `lib/src/domain/chat/controller/chat.controller.dart`
- `test/chat_account_seen_sync_test.dart` (new)

## Commits

None (no git repository).

## Concerns

None. Task 3 can add debounced merge-refresh reconcile.

## FILE: test/chat_account_seen_sync_test.dart (full)
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
}

## FILE excerpts: chat.controller.dart (_mergeSeenIntoChatLists, _syncAccountUnreadAfterChatSeen, _handleSeenBroadcast)
FOUND at 976 :   void _mergeSeenIntoChatLists({
FOUND at 1086 :   void _syncAccountUnreadAfterChatSeen({
FOUND at 1155 :   void _handleSeenBroadcast(Map<String, dynamic> data) {
--- lines 976-1326 ---
  976|  void _mergeSeenIntoChatLists({
  977|    required String chatId,
  978|    required int upToSeq,
  979|    int? unreadMessageCount,
  980|    int? customerAccountId,
  981|    int? totalUnreadMessageCount,
  982|    bool syncAccountBadge = true,
  983|  }) {
  984|    int? accountId = customerAccountId;
  985|    var previousChatUnread = 0;
  986|    final idx = chatList.indexWhere((c) => c.chatId == chatId);
  987|    final chatWasInLocalList = idx != -1 || selectedChat.value?.chatId == chatId;
  988|    if (idx != -1) {
  989|      final c = chatList[idx];
  990|      accountId ??= c.accountId;
  991|      previousChatUnread = c.unreadMessageCount ?? 0;
  992|      final appliedUnread = unreadMessageCount ?? c.unreadMessageCount;
  993|      chatList[idx] = ChatModel(
  994|        rowNum: c.rowNum,
  995|        chatId: c.chatId,
  996|        accountId: c.accountId,
  997|        topicId: c.topicId,
  998|        topicCode: c.topicCode,
  999|        topicTitle: c.topicTitle,
 1000|        status: c.status,
 1001|        createdOn: c.createdOn,
 1002|        lastActivity: c.lastActivity,
 1003|        accountName: c.accountName,
 1004|        lastMessageSeq: c.lastMessageSeq,
 1005|        lastSeenSeq: c.lastSeenSeq,
 1006|        clientSeenSeq: upToSeq,
 1007|        lastMessagePreview: c.lastMessagePreview,
 1008|        lastMessageOn: c.lastMessageOn,
 1009|        totalMessageCount: c.totalMessageCount,
 1010|        unreadMessageCount: appliedUnread,
 1011|        unreadMentionCount:
 1012|            appliedUnread == 0 ? 0 : c.unreadMentionCount,
 1013|        topicKey: c.topicKey,
 1014|        assignedAdminAccountId: c.assignedAdminAccountId,
 1015|        assignedAdminUserId: c.assignedAdminUserId,
 1016|        closedOn: c.closedOn,
 1017|        assignedAdminName: c.assignedAdminName,
 1018|        userId: c.userId,
 1019|        adminRole: c.adminRole,
 1020|        adminRoleTitle: c.adminRoleTitle,
 1021|      );
 1022|    }
 1023|
 1024|    final sel = selectedChat.value;
 1025|    if (sel?.chatId == chatId) {
 1026|      final appliedUnread = unreadMessageCount ?? sel!.unreadMessageCount;
 1027|      selectedChat.value = ChatModel(
 1028|        rowNum: sel!.rowNum,
 1029|        chatId: sel.chatId,
 1030|        accountId: sel.accountId,
 1031|        topicId: sel.topicId,
 1032|        topicCode: sel.topicCode,
 1033|        topicTitle: sel.topicTitle,
 1034|        status: sel.status,
 1035|        createdOn: sel.createdOn,
 1036|        lastActivity: sel.lastActivity,
 1037|        accountName: sel.accountName,
 1038|        lastMessageSeq: sel.lastMessageSeq,
 1039|        lastSeenSeq: sel.lastSeenSeq,
 1040|        clientSeenSeq: upToSeq,
 1041|        lastMessagePreview: sel.lastMessagePreview,
 1042|        lastMessageOn: sel.lastMessageOn,
 1043|        totalMessageCount: sel.totalMessageCount,
 1044|        unreadMessageCount: appliedUnread,
 1045|        unreadMentionCount:
 1046|            appliedUnread == 0 ? 0 : sel.unreadMentionCount,
 1047|        topicKey: sel.topicKey,
 1048|        assignedAdminAccountId: sel.assignedAdminAccountId,
 1049|        assignedAdminUserId: sel.assignedAdminUserId,
 1050|        closedOn: sel.closedOn,
 1051|        assignedAdminName: sel.assignedAdminName,
 1052|        userId: sel.userId,
 1053|        adminRole: sel.adminRole,
 1054|        adminRoleTitle: sel.adminRoleTitle,
 1055|      );
 1056|      accountId ??= sel.accountId;
 1057|      if (idx == -1) {
 1058|        previousChatUnread = sel.unreadMessageCount ?? 0;
 1059|      }
 1060|    }
 1061|
 1062|    if (syncAccountBadge && unreadMessageCount != null) {
 1063|      _syncAccountUnreadAfterChatSeen(
 1064|        accountId: accountId,
 1065|        previousChatUnread: previousChatUnread,
 1066|        newChatUnread: unreadMessageCount,
 1067|        chatWasInLocalList: chatWasInLocalList,
 1068|        totalUnreadMessageCount: totalUnreadMessageCount,
 1069|      );
 1070|    }
 1071|  }
 1072|
 1073|  /// Publishes an in-place account-row change so [Obx] listeners rebuild.
 1074|  void _publishChatAccountRowUpdate(
 1075|      int accountIndex,
 1076|      ChatAccountModel updatedAccount,
 1077|      ) {
 1078|    chatAccountList[accountIndex] = updatedAccount;
 1079|    chatAccountList.refresh();
 1080|    if (selectedChatAccount.value?.accountId == updatedAccount.accountId) {
 1081|      selectedChatAccount.value = updatedAccount;
 1082|    }
 1083|  }
 1084|
 1085|  /// Keeps [chatAccountList] / [selectedChatAccount] [unreadChatCount] in sync when a thread is read.
 1086|  void _syncAccountUnreadAfterChatSeen({
 1087|    required int? accountId,
 1088|    required int previousChatUnread,
 1089|    required int? newChatUnread,
 1090|    required bool chatWasInLocalList,
 1091|    int? totalUnreadMessageCount,
 1092|  }) {
 1093|    if (accountId == null) return;
 1094|
 1095|    final accountIndex =
 1096|    chatAccountList.indexWhere((a) => a.accountId == accountId);
 1097|    if (accountIndex == -1) return;
 1098|
 1099|    final current = chatAccountList[accountIndex];
 1100|    final threadJustRead = threadJustReadFromSeenBroadcast(
 1101|      previousChatUnread: previousChatUnread,
 1102|      newChatUnread: newChatUnread,
 1103|      chatWasInLocalList: chatWasInLocalList,
 1104|    );
 1105|    final unreadChatCount = reconcileAccountUnreadChatCount(
 1106|      currentCount: current.unreadChatCount ?? 0,
 1107|      reconciled: accountUnreadChatCountFromLoadedChats(chatList, accountId),
 1108|      threadJustRead: threadJustRead,
 1109|    );
 1110|    var hasUnreadMention = reconcileAccountHasUnreadMention(
 1111|      current: current.hasUnreadMention ?? false,
 1112|      reconciled: accountHasUnreadMentionFromLoadedChats(chatList, accountId),
 1113|      threadJustRead: threadJustRead,
 1114|    );
 1115|    if (unreadChatCount == 0) {
 1116|      hasUnreadMention = false;
 1117|    }
 1118|
 1119|    final updatedAccount = ChatAccountModel(
 1120|      rowNum: current.rowNum,
 1121|      accountId: current.accountId,
 1122|      accountName: current.accountName,
 1123|      lastChatId: current.lastChatId,
 1124|      lastMessageOn: current.lastMessageOn,
 1125|      lastMessagePreview: current.lastMessagePreview,
 1126|      totalMessageCount: current.totalMessageCount,
 1127|      unreadMessageCount:
 1128|      totalUnreadMessageCount ?? current.unreadMessageCount,
 1129|      unreadChatCount: unreadChatCount,
 1130|      adminChatRole: current.adminChatRole,
 1131|      hasUnreadMention: hasUnreadMention,
 1132|      chatStatus: current.chatStatus,
 1133|    );
 1134|    _publishChatAccountRowUpdate(accountIndex, updatedAccount);
 1135|  }
 1136|
 1137|  /// Live unread-thread count for an account row; use inside [Obx].
 1138|  int liveUnreadChatCountForAccount(int? accountId) {
 1139|    if (accountId == null) return 0;
 1140|    final accounts = chatAccountList.toList();
 1141|    chatAccountList.length;
 1142|    final row = accounts.firstWhereOrNull((a) => a.accountId == accountId);
 1143|    return row?.unreadChatCount ?? 0;
 1144|  }
 1145|
 1146|  /// Live unread-mention-thread count for an account row; use inside [Obx].
 1147|  bool liveUnreadMentionCountForAccount(int? accountId) {
 1148|    if (accountId == null) return false;
 1149|    final accounts = chatAccountList.toList();
 1150|    chatAccountList.length;
 1151|    final row = accounts.firstWhereOrNull((a) => a.accountId == accountId);
 1152|    return row?.hasUnreadMention ?? false;
 1153|  }
 1154|
 1155|  void _handleSeenBroadcast(Map<String, dynamic> data) {
 1156|    try {
 1157|      final payload = seen_bc.SocketChatSeenBroadcastModel(
 1158|        channel: 'chat.seen',
 1159|        sessionId: null,
 1160|        data: seen_bc.Data.fromJson(data),
 1161|      );
 1162|      final d = payload.data;
 1163|      if (d == null) return;
 1164|
 1165|      final chatId = d.chatId?.trim();
 1166|      if (chatId == null || chatId.isEmpty) return;
 1167|
 1168|      final upToSeq = d.upToSeq;
 1169|      final unread = d.unreadMessageCount;
 1170|      final selfAffectsUnread = seenBroadcastAffectsLocalUnread(
 1171|        broadcastByUserId: d.byUserId,
 1172|        localUserId: int.tryParse(currentUserId),
 1173|      );
 1174|
 1175|      if (upToSeq != null) {
 1176|        _mergeSeenIntoChatLists(
 1177|          chatId: chatId,
 1178|          upToSeq: upToSeq,
 1179|          unreadMessageCount: unread,
 1180|          customerAccountId: d.customerAccountId,
 1181|          totalUnreadMessageCount: d.totalUnreadMessageCount,
 1182|          syncAccountBadge: selfAffectsUnread,
 1183|        );
 1184|      } else if (unread != null && selfAffectsUnread) {
 1185|        int? accountId = d.customerAccountId;
 1186|        var previousChatUnread = 0;
 1187|        final idx = chatList.indexWhere((c) => c.chatId == chatId);
 1188|        final chatWasInLocalList =
 1189|            idx != -1 || selectedChat.value?.chatId == chatId;
 1190|        if (idx != -1) {
 1191|          final c = chatList[idx];
 1192|          accountId ??= c.accountId;
 1193|          previousChatUnread = c.unreadMessageCount ?? 0;
 1194|          chatList[idx] = ChatModel(
 1195|            rowNum: c.rowNum,
 1196|            chatId: c.chatId,
 1197|            accountId: c.accountId,
 1198|            topicId: c.topicId,
 1199|            topicCode: c.topicCode,
 1200|            topicTitle: c.topicTitle,
 1201|            status: c.status,
 1202|            createdOn: c.createdOn,
 1203|            lastActivity: c.lastActivity,
 1204|            accountName: c.accountName,
 1205|            lastMessageSeq: c.lastMessageSeq,
 1206|            lastSeenSeq: c.lastSeenSeq,
 1207|            clientSeenSeq: c.clientSeenSeq,
 1208|            lastMessagePreview: c.lastMessagePreview,
 1209|            lastMessageOn: c.lastMessageOn,
 1210|            totalMessageCount: c.totalMessageCount,
 1211|            unreadMessageCount: unread,
 1212|            unreadMentionCount: unread == 0 ? 0 : c.unreadMentionCount,
 1213|            topicKey: c.topicKey,
 1214|            assignedAdminAccountId: c.assignedAdminAccountId,
 1215|            assignedAdminUserId: c.assignedAdminUserId,
 1216|            closedOn: c.closedOn,
 1217|            assignedAdminName: c.assignedAdminName,
 1218|            userId: c.userId,
 1219|            adminRole: c.adminRole,
 1220|            adminRoleTitle: c.adminRoleTitle,
 1221|          );
 1222|        }
 1223|        final sel = selectedChat.value;
 1224|        if (sel?.chatId == chatId) {
 1225|          selectedChat.value = ChatModel(
 1226|            rowNum: sel!.rowNum,
 1227|            chatId: sel.chatId,
 1228|            accountId: sel.accountId,
 1229|            topicId: sel.topicId,
 1230|            topicCode: sel.topicCode,
 1231|            topicTitle: sel.topicTitle,
 1232|            status: sel.status,
 1233|            createdOn: sel.createdOn,
 1234|            lastActivity: sel.lastActivity,
 1235|            accountName: sel.accountName,
 1236|            lastMessageSeq: sel.lastMessageSeq,
 1237|            lastSeenSeq: sel.lastSeenSeq,
 1238|            clientSeenSeq: sel.clientSeenSeq,
 1239|            lastMessagePreview: sel.lastMessagePreview,
 1240|            lastMessageOn: sel.lastMessageOn,
 1241|            totalMessageCount: sel.totalMessageCount,
 1242|            unreadMessageCount: unread,
 1243|            unreadMentionCount: unread == 0 ? 0 : sel.unreadMentionCount,
 1244|            topicKey: sel.topicKey,
 1245|            assignedAdminAccountId: sel.assignedAdminAccountId,
 1246|            assignedAdminUserId: sel.assignedAdminUserId,
 1247|            closedOn: sel.closedOn,
 1248|            assignedAdminName: sel.assignedAdminName,
 1249|            userId: sel.userId,
 1250|            adminRole: sel.adminRole,
 1251|            adminRoleTitle: sel.adminRoleTitle,
 1252|          );
 1253|          accountId ??= sel.accountId;
 1254|          if (idx == -1) {
 1255|            previousChatUnread = sel.unreadMessageCount ?? 0;
 1256|          }
 1257|        }
 1258|
 1259|        _syncAccountUnreadAfterChatSeen(
 1260|          accountId: accountId,
 1261|          previousChatUnread: previousChatUnread,
 1262|          newChatUnread: unread,
 1263|          chatWasInLocalList: chatWasInLocalList,
 1264|          totalUnreadMessageCount: d.totalUnreadMessageCount,
 1265|        );
 1266|      }
 1267|
 1268|      if (selectedChat.value?.chatId == chatId) {
 1269|        final myUserId = int.tryParse(currentUserId);
 1270|        final readerIsCustomer =
 1271|            d.byUserId != null && myUserId != null && d.byUserId != myUserId;
 1272|        if (unread != null) {
 1273|          conversationUnreadCount.value = conversationUnreadAfterSeenBroadcast(
 1274|            currentUnread: conversationUnreadCount.value,
 1275|            broadcastUnread: unread,
 1276|            readerIsCustomer: readerIsCustomer,
 1277|          );
 1278|        }
 1279|        if (upToSeq != null) {
 1280|          if (!readerIsCustomer && upToSeq > _adminMarkedSeenSeq) {
 1281|            _adminMarkedSeenSeq = upToSeq;
 1282|            _pruneUnreadMentionsUpTo(upToSeq);
 1283|          }
 1284|          if (readerIsCustomer) {
 1285|            _applyOutgoingSeenByCustomer(upToSeq: upToSeq);
 1286|          }
 1287|        }
 1288|      }
 1289|    } catch (e) {
 1290|      if (kDebugMode) debugPrint('[chat.seen] broadcast parse error: $e');
 1291|    }
 1292|  }
 1293|
 1294|  Future<void> _ensureAnchorMessageLoaded(String chatId, int anchorSeq) async {
 1295|    if (anchorSeq <= 0) return;
 1296|    const maxPages = 24;
 1297|    for (var i = 0; i < maxPages; i++) {
 1298|      if (chatMessages.any((m) => m.seq == anchorSeq)) return;
 1299|      final oldest = chatMessages.isEmpty
 1300|          ? null
 1301|          : chatMessages
 1302|          .map((m) => m.seq)
 1303|          .whereType<int>()
 1304|          .fold<int?>(null, (a, b) => a == null || b < a ? b : a);
 1305|      if (oldest != null && oldest <= anchorSeq) return;
 1306|      if (!hasMoreMessages.value) return;
 1307|      final before = chatMessages.length;
 1308|      await loadChatMessages(chatId);
 1309|      if (chatMessages.length <= before) return;
 1310|    }
 1311|  }
 1312|
 1313|  ChatMessageModel? _messageForSeq(int seq) {
 1314|    final chatId = selectedChat.value?.chatId?.toString().trim();
 1315|    return chatMessages.firstWhereOrNull(
 1316|          (m) => m.seq == seq && m.chatId?.toString().trim() == chatId,
 1317|    );
 1318|  }
 1319|
 1320|  /// Resolves the last-read bubble; falls back to the newest loaded message at or below [anchorSeq].
 1321|  ChatMessageModel? _messageForLastReadAnchor(int anchorSeq) {
 1322|    final exact = _messageForSeq(anchorSeq);
 1323|    if (exact != null) return exact;
 1324|
 1325|    final chatId = selectedChat.value?.chatId?.toString().trim();
 1326|    ChatMessageModel? best;
