# Final whole-branch review package
**Plan:** ChatAccountItem Cross-Tab Unread Sync
**Base:** pre-plan working tree | **Head:** post Tasks 1-3 + T3 fix wave
**Note:** No git — file inventory + key excerpts + reports

## Progress ledger
# SDD Progress - ChatAccountItem Cross-Tab Unread Sync

Plan: c:\Users\Admin\.cursor\plans\chataccountitem_unread_sync_433ad669.plan.md
Saved: docs/superpowers/plans/2026-07-11-chat-account-item-cross-tab-unread.md
Started: 2026-07-11
Note: No git repository in workspace - commits skipped; review via file diffs.

Task 1: complete (no git commits; review clean - Approved; Minor: no serverCount:0 test; merge mention seq-update untested)
Task 2: complete (no git commits; review clean - Approved; Minor: duplicated merge branch; optional coverage gaps)
Task 3: complete (no git; review Approved after null-safe merge fix; Minor: page-1 scope plan-mandated; human E2E Pending)

Minor carry-forward: T1 serverCount:0 / mention seq-update; T2 duplicated merge branch; T3 page-1 reconcile + debounce hits HTTP; human dual-window checklist Pending


## Minor carry-forward from task reviews
- T1: no serverCount:0 test; merge mention seq-update untested
- T2: duplicated chat-list mutation branch in _handleSeenBroadcast
- T3: page-1 reconcile scope (plan-mandated); debounce test hits real HTTP; human E2E Pending

## Changed production files
- lib/src/domain/chat/utils/chat_conversation_unread.dart
- lib/src/domain/chat/controller/chat.controller.dart

## Changed/new test files
- test/chat_conversation_unread_test.dart
- test/chat_account_seen_sync_test.dart (new)

## Key helpers (utils) — symbols
int lastReadAnchorSeq(ChatModel chat) {
bool shouldAnchorConversationToLastRead(ChatModel chat) {
int countMessagesWithSeqAbove(
int conversationUnreadAfterSeen({
bool messageMentionsAccount(
bool shouldIncrementAccountUnreadChatCount({
/// When [threadJustRead] is true, the count drops by at least one even if
int reconcileAccountUnreadChatCount({
required bool threadJustRead,
if (threadJustRead) {
/// Trusts [reconciled] when present; otherwise clears on [threadJustRead].
bool reconcileAccountHasUnreadMention({
required bool threadJustRead,
if (threadJustRead) return false;
bool seenBroadcastAffectsLocalUnread({
int resolveThreadUnreadFromSocket({
List<ChatUnreadMentionsModel> mergeSocketMentionIntoUnreadList(
bool threadJustReadFromSeenBroadcast({
int conversationUnreadAfterSeenBroadcast({

## Controller key symbols
98:ChatAccountModel mergeChatAccountRowUnreadFields(
178:Timer? _accountUnreadReconcileTimer;
180:/// Test hook: incremented on each [scheduleAccountUnreadReconcile] call.
182:int accountUnreadReconcileScheduleCount = 0;
184:/// Test hook: incremented each time [refreshChatAccountUnreadByMerge] runs.
780:_accountUnreadReconcileTimer?.cancel();
1016:bool syncAccountBadge = true,
1096:if (syncAccountBadge && unreadMessageCount != null) {
1134:final threadJustRead = threadJustReadFromSeenBroadcast(
1204:final selfAffectsUnread = seenBroadcastAffectsLocalUnread(
1216:syncAccountBadge: selfAffectsUnread,
1325:scheduleAccountUnreadReconcile();
1333:void scheduleAccountUnreadReconcile() {
1334:_accountUnreadReconcileTimer?.cancel();
1335:accountUnreadReconcileScheduleCount++;
1336:_accountUnreadReconcileTimer = Timer(const Duration(milliseconds: 300), () {
1337:unawaited(refreshChatAccountUnreadByMerge());
1344:Future<void> refreshChatAccountUnreadByMerge() async {
1367:mergeChatAccountRowUnreadFields(current, fresh),
1371:AppLogger.e('refreshChatAccountUnreadByMerge failed', e, s);

## Task reports (concat)
===== d:\curserAi project\.superpowers\sdd\chat-account-unread\task-1-report.md =====
# Task 1 Report: Pure helpers + account reconcile semantics

**Status:** DONE  
**Date:** 2026-07-11  
**Plan:** ChatAccountItem cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-account-item-cross-tab-unread.md`)

---

## What was implemented

Restored four pure helpers in `chat_conversation_unread.dart` and added tests locking absent-thread `threadJustRead` semantics for Task 2 controller wiring.

### Restored helpers

1. **`seenBroadcastAffectsLocalUnread`** â€” returns `true` only when both `broadcastByUserId` and `localUserId` are non-null and equal; `false` on mismatch or either null.

2. **`resolveThreadUnreadFromSocket`** â€” prefers authoritative `serverCount` when present (clamps negatives to 0); when `serverCount` is absent, increments local by 1 if `incrementFallback`, else keeps local. Does not invent zero from absent server data.

3. **`mergeSocketMentionIntoUnreadList`** â€” inserts a mention sorted by `seq`, deduped by `messageGuid`. Helper-only this task (not wired into message path).

4. **`threadJustReadFromSeenBroadcast`** â€” new helper for Task 2:
   - `true` when `newChatUnread == 0` and (`previousChatUnread > 0` OR chat was **not** in local list)
   - `false` when `newChatUnread` is null, positive, or chat was already read in list (`previousChatUnread == 0` and `chatWasInLocalList`)

### Absent-thread reconcile tests

Added integration test proving: chat absent from loaded list + authoritative unread `0` â†’ `threadJustReadFromSeenBroadcast` is `true` â†’ `reconcileAccountUnreadChatCount` drops account count by at least one (`3 â†’ 2` with `reconciled: null`).

---

## TDD Evidence RED

### Step 1 â€” Existing tests fail to compile (missing symbols)

**Command:**

```powershell
cd "d:\curserAi project"; flutter test test/chat_conversation_unread_test.dart
```

**Result:** EXIT 1 (compilation failure)

```
Error: Method not found: 'seenBroadcastAffectsLocalUnread'.
Error: Method not found: 'resolveThreadUnreadFromSocket'.
Error: Method not found: 'mergeSocketMentionIntoUnreadList'.
```

**Why expected:** Helpers were referenced by existing tests but not yet implemented in `chat_conversation_unread.dart`.

---

## TDD Evidence GREEN

### Step 2 â€” Implement helpers + absent-thread tests

Updated `lib/src/domain/chat/utils/chat_conversation_unread.dart` with all four helpers.  
Extended `test/chat_conversation_unread_test.dart` with `threadJustReadFromSeenBroadcast` group (5 cases) and `absent-thread account reconcile` integration test.

**Command:**

```powershell
cd "d:\curserAi project"; flutter test test/chat_conversation_unread_test.dart
```

**Result:** EXIT 0 â€” **28/28 passed**

```
conversationUnreadAfterSeen (3)
seenBroadcastAffectsLocalUnread (3)
conversationUnreadAfterSeenBroadcast (3)
messageMentionsAccount (3)
unreadMentionsAfterSeen (1)
shouldIncrementAccountUnreadChatCount (2)
reconcileAccountUnreadChatCount (2)
resolveThreadUnreadFromSocket (4)
threadJustReadFromSeenBroadcast (5)
absent-thread account reconcile (1)
mergeSocketMentionIntoUnreadList (1)
All tests passed!
```

---

## Test coverage matrix

| Helper / scenario | Key assertion |
| --- | --- |
| `seenBroadcastAffectsLocalUnread` | equal non-null IDs â†’ true; mismatch/null â†’ false |
| `resolveThreadUnreadFromSocket` | server wins; null server + fallback â†’ +1; null server no fallback â†’ unchanged; negative server â†’ 0 |
| `threadJustReadFromSeenBroadcast` | prior unread + zero broadcast â†’ true |
| `threadJustReadFromSeenBroadcast` | absent from list + authoritative 0 â†’ true (root-cause fix) |
| `threadJustReadFromSeenBroadcast` | in-list already read â†’ false |
| `threadJustReadFromSeenBroadcast` | null `newChatUnread` â†’ false (no blind clear) |
| absent-thread reconcile | `threadJustRead` from absent case + `reconciled: null` â†’ count drops 3â†’2 |
| `mergeSocketMentionIntoUnreadList` | sorted by seq; dedupe by messageGuid |

---

## Files changed

| File | Change |
| --- | --- |
| `lib/src/domain/chat/utils/chat_conversation_unread.dart` | Added `seenBroadcastAffectsLocalUnread`, `resolveThreadUnreadFromSocket`, `mergeSocketMentionIntoUnreadList`, `threadJustReadFromSeenBroadcast` |
| `test/chat_conversation_unread_test.dart` | Added `threadJustReadFromSeenBroadcast` and `absent-thread account reconcile` groups |
| `.superpowers/sdd/chat-account-unread/task-1-report.md` | This report |

**Not changed:** `chat.controller.dart`, `ChatAccountItem`, graphify, debounced refresh (Task 3).

**Commits:** none (no git repository in workspace).

---

## Self-review

- [x] TDD order: RED compile failure confirmed, then implementation, then GREEN 28/28
- [x] `resolveThreadUnreadFromSocket` does not treat absent `serverCount` as zero
- [x] `threadJustReadFromSeenBroadcast` requires explicit `newChatUnread == 0` (null â†’ false)
- [x] Absent-thread case: `previousChatUnread == 0` + `!chatWasInLocalList` + authoritative zero â†’ just-read
- [x] Existing `reconcileAccountUnreadChatCount` unchanged; integration test proves drop-by-one path
- [x] Pure helpers only; no controller/widget changes
- [x] No linter errors on changed files
- [x] No commit attempted

---

## Concerns

None. Task 2 can wire `threadJustReadFromSeenBroadcast` into `_syncAccountUnreadAfterChatSeen` / `_handleSeenBroadcast` replacing `previousChatUnread > 0 && newChatUnread == 0`.
===== d:\curserAi project\.superpowers\sdd\chat-account-unread\task-2-report.md =====
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
===== d:\curserAi project\.superpowers\sdd\chat-account-unread\task-3-report.md =====
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
===== d:\curserAi project\.superpowers\sdd\chat-account-unread\task-3-manual-checklist.md =====
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

## Controller: mergeChatAccountRowUnreadFields + schedule + refresh (excerpts)
--- 98-152 ---
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
  138|  /// Topic filter for the per-account chat list panel (not the active conversation).
  139|  Rxn<TopicModel> chatListTopicFilter = Rxn<TopicModel>();
  140|  Rxn<ChatMessageModel> replyToMessage = Rxn<ChatMessageModel>();
  141|  /// Message being forwarded into another conversation (composer preview + send).
  142|  Rxn<ChatMessageModel> pendingForwardMessage = Rxn<ChatMessageModel>();
  143|
  144|  // Controllers
  145|  final TextEditingController messageController = TextEditingController();
  146|  final TextEditingController searchController = TextEditingController();
  147|  final TextEditingController chatAccountsSearchController = TextEditingController();
  148|  final TextEditingController messagesSearchController = TextEditingController();
  149|  final ScrollController messagesScrollController = ScrollController();
  150|
  151|  final RxBool isMessageSearchExpanded = false.obs;
  152|  final RxString activeMessageSearchQuery = ''.obs;
--- 1333-1387 ---
 1333|  void scheduleAccountUnreadReconcile() {
 1334|    _accountUnreadReconcileTimer?.cancel();
 1335|    accountUnreadReconcileScheduleCount++;
 1336|    _accountUnreadReconcileTimer = Timer(const Duration(milliseconds: 300), () {
 1337|      unawaited(refreshChatAccountUnreadByMerge());
 1338|    });
 1339|  }
 1340|
 1341|  /// Re-fetches page-1 account rows and merges unread badge fields by [accountId].
 1342|  ///
 1343|  /// Does not [RxList.clear] [chatAccountList] â€” safe for silent cross-tab reconcile.
 1344|  Future<void> refreshChatAccountUnreadByMerge() async {
 1345|    try {
 1346|      if (chatAccountList.isEmpty) return;
 1347|
 1348|      accountUnreadMergeRefreshInvokeCount++;
 1349|      final query = searchText.value.trim();
 1350|      final fetched = await chatRepository.getChatAccountList(
 1351|        startIndex: 1,
 1352|        toIndex: pageSize,
 1353|        searchText: query.isNotEmpty ? query : null,
 1354|      );
 1355|
 1356|      for (final fresh in fetched) {
 1357|        final accountId = fresh.accountId;
 1358|        if (accountId == null) continue;
 1359|
 1360|        final accountIndex =
 1361|            chatAccountList.indexWhere((a) => a.accountId == accountId);
 1362|        if (accountIndex == -1) continue;
 1363|
 1364|        final current = chatAccountList[accountIndex];
 1365|        _publishChatAccountRowUpdate(
 1366|          accountIndex,
 1367|          mergeChatAccountRowUnreadFields(current, fresh),
 1368|        );
 1369|      }
 1370|    } catch (e, s) {
 1371|      AppLogger.e('refreshChatAccountUnreadByMerge failed', e, s);
 1372|    }
 1373|  }
 1374|
 1375|  Future<void> _ensureAnchorMessageLoaded(String chatId, int anchorSeq) async {
 1376|    if (anchorSeq <= 0) return;
 1377|    const maxPages = 24;
 1378|    for (var i = 0; i < maxPages; i++) {
 1379|      if (chatMessages.any((m) => m.seq == anchorSeq)) return;
 1380|      final oldest = chatMessages.isEmpty
 1381|          ? null
 1382|          : chatMessages
 1383|          .map((m) => m.seq)
 1384|          .whereType<int>()
 1385|          .fold<int?>(null, (a, b) => a == null || b < a ? b : a);
 1386|      if (oldest != null && oldest <= anchorSeq) return;
 1387|      if (!hasMoreMessages.value) return;
--- 1344-1398 ---
 1344|  Future<void> refreshChatAccountUnreadByMerge() async {
 1345|    try {
 1346|      if (chatAccountList.isEmpty) return;
 1347|
 1348|      accountUnreadMergeRefreshInvokeCount++;
 1349|      final query = searchText.value.trim();
 1350|      final fetched = await chatRepository.getChatAccountList(
 1351|        startIndex: 1,
 1352|        toIndex: pageSize,
 1353|        searchText: query.isNotEmpty ? query : null,
 1354|      );
 1355|
 1356|      for (final fresh in fetched) {
 1357|        final accountId = fresh.accountId;
 1358|        if (accountId == null) continue;
 1359|
 1360|        final accountIndex =
 1361|            chatAccountList.indexWhere((a) => a.accountId == accountId);
 1362|        if (accountIndex == -1) continue;
 1363|
 1364|        final current = chatAccountList[accountIndex];
 1365|        _publishChatAccountRowUpdate(
 1366|          accountIndex,
 1367|          mergeChatAccountRowUnreadFields(current, fresh),
 1368|        );
 1369|      }
 1370|    } catch (e, s) {
 1371|      AppLogger.e('refreshChatAccountUnreadByMerge failed', e, s);
 1372|    }
 1373|  }
 1374|
 1375|  Future<void> _ensureAnchorMessageLoaded(String chatId, int anchorSeq) async {
 1376|    if (anchorSeq <= 0) return;
 1377|    const maxPages = 24;
 1378|    for (var i = 0; i < maxPages; i++) {
 1379|      if (chatMessages.any((m) => m.seq == anchorSeq)) return;
 1380|      final oldest = chatMessages.isEmpty
 1381|          ? null
 1382|          : chatMessages
 1383|          .map((m) => m.seq)
 1384|          .whereType<int>()
 1385|          .fold<int?>(null, (a, b) => a == null || b < a ? b : a);
 1386|      if (oldest != null && oldest <= anchorSeq) return;
 1387|      if (!hasMoreMessages.value) return;
 1388|      final before = chatMessages.length;
 1389|      await loadChatMessages(chatId);
 1390|      if (chatMessages.length <= before) return;
 1391|    }
 1392|  }
 1393|
 1394|  ChatMessageModel? _messageForSeq(int seq) {
 1395|    final chatId = selectedChat.value?.chatId?.toString().trim();
 1396|    return chatMessages.firstWhereOrNull(
 1397|          (m) => m.seq == seq && m.chatId?.toString().trim() == chatId,
 1398|    );
