import 'dart:async';
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hanigold_admin/src/config/const/toast.service.dart';
import 'package:hanigold_admin/src/config/secure_session_storage.dart';
import 'package:hanigold_admin/src/config/repository/account.repository.dart';
import 'package:hanigold_admin/src/config/repository/chat.repository.dart';
import 'package:hanigold_admin/src/config/repository/chat_attachment.repository.dart';
import 'package:hanigold_admin/src/domain/account/model/account.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat_account.model.dart';
import 'package:hanigold_admin/src/config/const/socket.service.dart';
import 'package:flutter/foundation.dart';
import '../../../config/logger/app_logger.dart';
import '../model/chat_unread_mentions.model.dart';
import '../model/socket_chat_admin_send.model.dart' as admin_send;
import '../model/socket_chat_typing.model.dart' as typing;
import '../model/socket_chat_message.model.dart' as socket_msg;
import '../model/socket_chat_seen.model.dart' as seen;
import '../model/socket_chat_seen_broadcast.model.dart' as seen_bc;
import '../model/socket_chat_unread_total.model.dart' as unread_total;
import '../model/socket_chat_unread_mention_total.model.dart' as unread_mention_total;
import 'package:uuid/uuid.dart';

import '../model/chat_message.model.dart';
import '../model/chat_mention_candidates.model.dart';
import '../model/topic.model.dart';
import '../utils/chat_attachment_pick.dart';
import '../utils/chat_clipboard_paste.dart';
import '../utils/chat_sticker_send.dart';
import '../utils/chat_web_clipboard_paste.dart';
import '../utils/chat_voice_recording.dart';
import '../utils/chat_composer_text_editing.dart';
import '../utils/chat_mention.dart';
import '../utils/chat_open_conversation_match.dart';
import '../utils/chat_outbound_optimistic.dart';
import '../utils/chat_typing_match.dart';
import '../utils/chat_attachment_utils.dart';
import '../utils/chat_forward_outbound.dart';
import '../utils/chat_reply_resolver.dart';
import '../utils/chat_conversation_unread.dart';
import '../widget/chat_row.dart';
import '../widget/chat_image_editor_screen.widget.dart';
import 'chat_fab.controller.dart';

// ─── Pending attachment model ────────────────────────────────────────────────

class ChatPendingAttachment {
  ChatPendingAttachment({
    required this.name,
    required this.sizeBytes,
    required this.fileType,
    this.bytes,
    this.path,
  });

  final String name;
  final int sizeBytes;

  /// Server-accepted file-type string: image | video | audio | pdf | document | archive
  final String fileType;

  /// File bytes (always populated on web; also used on desktop when loaded).
  final Uint8List? bytes;

  /// Native file path (desktop/mobile only; null on web).
  final String? path;

  /// Set by [ChatController._uploadAttachment] after a successful upload.
  String? recordId;

  final RxDouble progress = 0.0.obs;
  final RxBool failed = false.obs;
}

@visibleForTesting
bool shouldFetchChatAccounts({
  required int listLength,
  required bool isLoading,
}) =>
    listLength == 0 && !isLoading;

@visibleForTesting
bool shouldFetchAccountList({
  required int listLength,
  required bool isLoading,
}) =>
    listLength == 0 && !isLoading;

/// Merges server-fetched unread badge fields into [current]; null [fresh] values
/// preserve existing row data (never clear badges solely because API omitted them).
@visibleForTesting
ChatAccountModel mergeChatAccountRowUnreadFields(
    ChatAccountModel current,
    ChatAccountModel fresh,
    ) {
  return ChatAccountModel(
    rowNum: current.rowNum,
    accountId: current.accountId,
    accountName: current.accountName,
    lastChatId: current.lastChatId,
    lastMessageOn: current.lastMessageOn,
    lastMessagePreview: current.lastMessagePreview,
    totalMessageCount: current.totalMessageCount,
    unreadMessageCount: fresh.unreadMessageCount ?? current.unreadMessageCount,
    unreadChatCount: fresh.unreadChatCount ?? current.unreadChatCount,
    adminChatRole: current.adminChatRole,
    hasUnreadMention: fresh.hasUnreadMention ?? current.hasUnreadMention,
    chatStatus: current.chatStatus,
  );
}

class ChatController extends GetxController {
  final ChatRepository chatRepository = ChatRepository();
  final AccountRepository accountRepository = AccountRepository();
  final box = GetStorage();
  var uuid = Uuid();
  var reqId="".obs;

  // Observable variables
  RxList<ChatAccountModel> chatAccountList = <ChatAccountModel>[].obs;
  RxList<ChatModel> chatList = <ChatModel>[].obs;
  RxList<ChatMessageModel> chatMessages = <ChatMessageModel>[].obs;
  RxList<AccountModel> accountList = <AccountModel>[].obs;
  RxList<TopicModel> topicList = <TopicModel>[].obs;
  RxList<AccountModel> filteredAccountList = <AccountModel>[].obs;

  // Selected items
  Rxn<ChatAccountModel> selectedChatAccount = Rxn<ChatAccountModel>();
  Rxn<ChatModel> selectedChat = Rxn<ChatModel>();          // ← NEW
  Rxn<AccountModel> selectedAccount = Rxn<AccountModel>();
  Rxn<TopicModel> selectedTopic = Rxn<TopicModel>();
  /// Topic filter for the per-account chat list panel (not the active conversation).
  Rxn<TopicModel> chatListTopicFilter = Rxn<TopicModel>();
  Rxn<ChatMessageModel> replyToMessage = Rxn<ChatMessageModel>();
  /// Message being forwarded into another conversation (composer preview + send).
  Rxn<ChatMessageModel> pendingForwardMessage = Rxn<ChatMessageModel>();

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController chatAccountsSearchController = TextEditingController();
  final TextEditingController messagesSearchController = TextEditingController();
  final ScrollController messagesScrollController = ScrollController();

  final RxBool isMessageSearchExpanded = false.obs;
  final RxString activeMessageSearchQuery = ''.obs;
  Timer? _messageSearchDebounce;
  static const Duration _messageSearchDebounceDelay = Duration(milliseconds: 400);

  final RxString searchText = ''.obs;
  final RxBool isSearchingChatAccounts = false.obs;
  Timer? _chatAccountSearchDebounce;
  int _chatAccountSearchSeq = 0;
  static const Duration _chatAccountSearchDebounceDelay =
  Duration(milliseconds: 450);

  bool get isMessageSearchActive =>
      activeMessageSearchQuery.value.trim().isNotEmpty;

  // Scroll / composer UX state
  final RxBool isNearBottom = true.obs;
  final RxInt pendingNewMessages = 0.obs;
  /// Unread count for [JumpToLatestPill]; seeded from [ChatModel.unreadMessageCount], then
  /// updated locally as the admin scrolls (separate from outgoing double-check / seen ticks).
  final RxInt conversationUnreadCount = 0.obs;

  int _adminMarkedSeenSeq = 0;
  int _conversationUnreadAnchorSeq = 0;
  Timer? _seenScrollDebounce;
  static const Duration _seenScrollDebounceDelay = Duration(milliseconds: 120);

  Timer? _accountUnreadReconcileTimer;

  /// Test hook: incremented on each [scheduleAccountUnreadReconcile] call.
  @visibleForTesting
  int accountUnreadReconcileScheduleCount = 0;

  /// Test hook: incremented each time [refreshChatAccountUnreadByMerge] runs.
  @visibleForTesting
  int accountUnreadMergeRefreshInvokeCount = 0;

  /// Hides the message list while jumping to the last-read anchor (avoids latest flash).
  final RxBool isAnchoringInitialScroll = false.obs;

  /// Scroll to last-read [seq] once the reversed [ListView] has mounted.
  int? _pendingConversationAnchorSeq;
  String? _initialScrollAppliedChatId;
  int _initialScrollRetryCount = 0;
  static const int _maxInitialScrollRetries = 24;
  bool _suppressScrollSeenSync = false;
  final RxBool isComposerEmpty = true.obs;
  final RxBool isCustomerTyping = false.obs;

  // Mention state
  final RxList<ChatMentionCandidatesModel> mentionCandidates =
      <ChatMentionCandidatesModel>[].obs;
  final RxList<ChatMentionCandidatesModel> mentionSuggestions =
      <ChatMentionCandidatesModel>[].obs;
  final RxBool isMentionPopupVisible = false.obs;
  final RxBool isLoadingMentions = false.obs;
  final RxInt mentionHighlightedIndex = 0.obs;
  int? _mentionQueryStart;
  final List<ChatMentionCandidatesModel> selectedMentions =
  <ChatMentionCandidatesModel>[];
  bool _mentionFetchRequested = false;

  final RxList<ChatUnreadMentionsModel> unreadMentions = <ChatUnreadMentionsModel>[].obs;
  bool _isJumpingToMention = false;

  Timer? _customerTypingIdleTimer;
  static const Duration _customerTypingIdle = Duration(seconds: 4);

  // Attachment state
  final RxList<ChatPendingAttachment> pendingAttachments =
      <ChatPendingAttachment>[].obs;
  final RxBool isUploadingAttachments = false.obs;

  final ChatAttachmentRepository _chatAttachmentRepo = ChatAttachmentRepository();
  final ChatStickerSendService _stickerSendService = ChatStickerSendService();

  /// When set, exactly one list row uses [_scrollTargetGlobalKey] for ensureVisible.
  final Rx<String?> scrollTargetBubbleId = Rx<String?>(null);
  final GlobalKey _scrollTargetGlobalKey = GlobalKey();
  /// Identity for scroll keys and reply-parent highlight (guid or chatId+seq).
  final Rx<String?> highlightedBubbleId = Rx<String?>(null);
  Timer? _replyHighlightTimer;
  static const Duration _replyHighlightDuration = Duration(milliseconds: 2000);
  static const int _bringMessageIntoViewAttempts = 40;

  /// Blocks loader-driven [loadMoreMessages] during programmatic scroll jumps.
  bool _suppressMessagePagination = false;

  void _clearMessageBubbleScrollKeys() {
    scrollTargetBubbleId.value = null;
    _clearReplyHighlight();
  }

  void _clearReplyHighlight() {
    _replyHighlightTimer?.cancel();
    _replyHighlightTimer = null;
    highlightedBubbleId.value = null;
  }

  /// Stable id for [bubbleListKey] / [MessageBubble] highlight paint.
  String bubbleIdentity(ChatMessageModel m) => _bubbleScrollKeyId(m);

  void _highlightReplyParent(ChatMessageModel target) {
    highlightedBubbleId.value = _bubbleScrollKeyId(target);
    _replyHighlightTimer?.cancel();
    _replyHighlightTimer = Timer(_replyHighlightDuration, () {
      if (highlightedBubbleId.value == _bubbleScrollKeyId(target)) {
        highlightedBubbleId.value = null;
      }
    });
  }

  /// ListView item key — [ValueKey] for normal rows, shared [GlobalKey] only for scroll target.
  Key bubbleListKey(ChatMessageModel m) {
    final id = _bubbleScrollKeyId(m);
    if (scrollTargetBubbleId.value == id) {
      return _scrollTargetGlobalKey;
    }
    return ValueKey<String>(id);
  }

  String _bubbleScrollKeyId(ChatMessageModel m) {
    final g = normalizeReplyGuid(m.messageGuid);
    if (g != null) return 'g:$g';
    final chatId = m.chatId?.toString().trim() ?? '';
    final seq = m.seq;
    if (seq != null) return 's:$chatId:$seq';
    final rowNum = m.rowNum;
    if (rowNum != null) return 'r:$chatId:$rowNum';
    final micros = m.createdOnUtc?.microsecondsSinceEpoch ?? 0;
    final textHash = m.text?.hashCode ?? 0;
    return 't:$chatId:$micros:$textHash';
  }

  /// Brings a message bubble into view in the reversed list, then centers it.
  ///
  /// Variable-height media bubbles make absolute offset estimates unstable
  /// (`maxScrollExtent` oscillates as lazy rows build/unbuild). Instead we step
  /// the scroll offset forward monotonically (toward older messages = larger
  /// offset) by a viewport fraction each frame so intermediate rows build
  /// progressively and the target element materialises without backward jumps.
  Future<bool> _bringMessageIntoView(
      ChatMessageModel target, {
        Duration ensureVisibleDuration = const Duration(milliseconds: 380),
        double alignment = 0.38,
      }) async {
    final c = messagesScrollController;
    if (!c.hasClients) return false;

    final rowIndex = indexOfBubbleRowForMessage(chatMessages, target);
    if (rowIndex == null) return false;

    final targetId = _bubbleScrollKeyId(target);
    scrollTargetBubbleId.value = targetId;
    var stalledSteps = 0;

    try {
      for (var attempt = 0; attempt < _bringMessageIntoViewAttempts; attempt++) {
        await WidgetsBinding.instance.endOfFrame;

        final ctx = _scrollTargetGlobalKey.currentContext;
        if (ctx != null) {
          await Scrollable.ensureVisible(
            ctx,
            alignment: alignment,
            duration: ensureVisibleDuration,
            curve: Curves.easeInOut,
          );
          return true;
        }

        if (!c.hasClients) return false;

        final pos = c.position;
        final max = pos.maxScrollExtent;
        final current = pos.pixels;
        // Step < viewport + cacheExtent so we never skip the target unbuilt.
        final step = pos.viewportDimension * 0.7;
        final next = (current + step).clamp(0.0, max);

        if (next <= current + 0.5) {
          if (++stalledSteps >= 2) break;
        } else {
          stalledSteps = 0;
        }

        c.jumpTo(next);
      }

      return false;
    } finally {
      scrollTargetBubbleId.value = null;
    }
  }

  /// Session-scoped cache: recordId → attachment (with bytes).
  /// Used by the bubble renderer to display image thumbnails for
  /// just-sent optimistic messages without a server round-trip.
  final Map<String, ChatPendingAttachment> _sentAttachmentsCache = {};

  /// Original upload file names keyed by [recordId] (survives socket/API without fileName).
  final Map<String, String> _attachmentFileNameByRecordId = {};

  /// Downloaded attachment bytes for history / non-image previews (keyed by recordId).
  final Map<String, Uint8List> _chatAttachmentBytesCache = {};

  /// When the server echoes a different [recordId] than the outbound upload id,
  /// maps server id → client upload id so downloads can still resolve bytes.
  final Map<String, String> _attachmentRecordIdAliases = {};

  /// Returns cached attachment data for [recordId], or null if not in cache.
  ChatPendingAttachment? getCachedAttachment(String recordId) {
    final id = recordId.trim();
    final hit = _sentAttachmentsCache[id];
    if (hit != null) return hit;
    final aliased = _attachmentRecordIdAliases[id];
    if (aliased != null) return _sentAttachmentsCache[aliased];
    return null;
  }

  /// Resolved original file name for display and download.
  String? resolvedAttachmentFileName(
      String recordId, {
        String? fromFilesJson,
      }) {
    final id = recordId.trim();
    final cached = getCachedAttachment(id)?.name.trim();
    if (cached != null && cached.isNotEmpty) return cached;
    final stored = _attachmentFileNameByRecordId[id]?.trim() ??
        _attachmentFileNameByRecordId[_attachmentRecordIdAliases[id] ?? '']?.trim();
    if (stored != null && stored.isNotEmpty) return stored;
    final fromJson = fromFilesJson?.trim();
    if (fromJson != null && fromJson.isNotEmpty) return fromJson;
    return null;
  }

  /// Fetches bytes for [recordId] via [Attachment/downloadChatAttachment],
  /// with in-memory de-duplication so scrolling does not re-hit the network.
  Future<Uint8List?> fetchChatAttachmentBytes(String recordId) async {
    final normalizedId = recordId.trim();
    if (normalizedId.isEmpty) return null;

    final hit = _chatAttachmentBytesCache[normalizedId];
    if (hit != null) return hit;
    final pending = _sentAttachmentsCache[normalizedId]?.bytes;
    if (pending != null) {
      _chatAttachmentBytesCache[normalizedId] = pending;
      return pending;
    }

    final aliased = _attachmentRecordIdAliases[normalizedId];
    if (aliased != null) {
      final aliasedBytes = _chatAttachmentBytesCache[aliased] ??
          _sentAttachmentsCache[aliased]?.bytes;
      if (aliasedBytes != null) {
        _chatAttachmentBytesCache[normalizedId] = aliasedBytes;
        return aliasedBytes;
      }
    }
    try {
      final bytes = await _chatAttachmentRepo.downloadChatAttachment(
        recordId: normalizedId,
      );
      _chatAttachmentBytesCache[normalizedId] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  void _registerAttachmentRecordIdAlias(String serverId, String uploadId) {
    final s = serverId.trim();
    final u = uploadId.trim();
    if (s.isEmpty || u.isEmpty || s == u) return;
    _attachmentRecordIdAliases[s] = u;
  }

  void _remapAttachmentCachesForRecordIdAlias(String serverId, String uploadId) {
    _registerAttachmentRecordIdAlias(serverId, uploadId);
    final pending = _sentAttachmentsCache.remove(uploadId);
    if (pending != null) {
      _sentAttachmentsCache[serverId] = pending;
      if (pending.bytes != null) {
        _chatAttachmentBytesCache[serverId] = pending.bytes!;
      }
    }
    final name = _attachmentFileNameByRecordId.remove(uploadId);
    if (name != null) {
      _attachmentFileNameByRecordId[serverId] = name;
    }
    final bytes = _chatAttachmentBytesCache.remove(uploadId);
    if (bytes != null) {
      _chatAttachmentBytesCache[serverId] = bytes;
    }
  }

  void _syncAttachmentRecordIdAliasesFromFilesJson(
      String? incoming,
      String? optimistic,
      ) {
    if (incoming == null || optimistic == null) return;
    try {
      final inItems = json.decode(incoming) as List<dynamic>;
      final outItems = json.decode(optimistic) as List<dynamic>;
      final limit = inItems.length < outItems.length
          ? inItems.length
          : outItems.length;
      for (var i = 0; i < limit; i++) {
        final inEntry = inItems[i];
        final outEntry = outItems[i];
        if (inEntry is! Map || outEntry is! Map) continue;
        final inMap = Map<String, dynamic>.from(inEntry);
        final outMap = Map<String, dynamic>.from(outEntry);
        final inId =
        (inMap['recordId'] ?? inMap['RecordId'])?.toString().trim();
        final outId =
        (outMap['recordId'] ?? outMap['RecordId'])?.toString().trim();
        if (inId == null ||
            outId == null ||
            inId.isEmpty ||
            outId.isEmpty ||
            inId == outId) {
          continue;
        }
        _remapAttachmentCachesForRecordIdAlias(inId, outId);
      }
    } catch (_) {}
  }

  // State variables
  RxBool isLoadingChatAccounts = false.obs;
  RxBool isLoadingChats = false.obs;
  RxBool isLoadingMessages = false.obs;
  RxBool isLoadingAccounts = false.obs;
  RxBool isLoadingTopics = false.obs;
  RxBool isSendingMessage = false.obs;
  RxBool isSendingSticker = false.obs;

  // Pagination variables
  RxBool isLoadingMoreChatAccounts = false.obs;
  RxBool isLoadingMoreChats = false.obs;
  RxBool isLoadingMoreMessages = false.obs;
  RxBool hasMoreChatAccounts = true.obs;
  RxBool hasMoreChats = true.obs;
  RxBool hasMoreMessages = true.obs;
  int chatAccountPage = 1;
  int chatPage = 1;
  int messagePage = 1;
  final int pageSize = 20;

  // Current user ID
  String get currentUserId =>
      SecureSessionStorage.instance.read('id')?.toString() ?? '';
  String get currentUserName =>
      SecureSessionStorage.instance.read('userName')?.toString() ?? 'کاربر';

  late final FocusNode messageFocusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        if (isMentionPopupVisible.value) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            mentionMoveHighlight(1);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            mentionMoveHighlight(-1);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.tab) {
            confirmHighlightedMention();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            closeMentionPopup();
            return KeyEventResult.handled;
          }
        }
        if (!kIsWeb &&
            event.logicalKey == LogicalKeyboardKey.keyV &&
            (HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed)) {
          unawaited(pasteFromClipboard());
          return KeyEventResult.handled;
        }
      }
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter &&
          !HardwareKeyboard.instance.isShiftPressed) {
        if (!isSendingMessage.value && !isMentionPopupVisible.value) {
          Future.microtask(() {
            final value = messageController.value;
            var text = value.text;
            if (text.endsWith('\n')) {
              text = text.substring(0, text.length - 1);
            }
            messageController.value = value.copyWith(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
              composing: TextRange.empty,
            );
            sendMessage();
          });
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
  );

  /// Returns keyboard focus to the message field so [messageFocusNode.onKeyEvent]
  /// (Enter to send) keeps working after emoji/attachment UI interactions.
  void refocusMessageComposer() {
    if (!messageFocusNode.canRequestFocus) return;
    messageFocusNode.requestFocus();
  }

  void scheduleRefocusMessageComposer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refocusMessageComposer();
    });
  }

  void _onMessageComposerTextChanged() {
    isComposerEmpty.value = messageController.text.trim().isEmpty;
    _syncMentionPopupFromComposer();
    final value = messageController.value;
    if (value.composing.isValid) return;
    final normalized = normalizeComposerTextEditingValue(value);
    if (normalized == value) return;
    messageController.value = normalized;
  }

  void _clearMentionState() {
    mentionCandidates.clear();
    mentionSuggestions.clear();
    isMentionPopupVisible.value = false;
    isLoadingMentions.value = false;
    mentionHighlightedIndex.value = 0;
    _mentionQueryStart = null;
    _mentionFetchRequested = false;
    selectedMentions.clear();
    unreadMentions.clear();
    _isJumpingToMention = false;
  }

  Future<void> fetchMentionCandidates({bool force = false}) async {
    final chatId = selectedChat.value?.chatId?.trim();
    if (chatId == null || chatId.isEmpty) return;
    if (isLoadingMentions.value) return;
    if (!force && mentionCandidates.isNotEmpty) {
      _applyMentionFilterFromComposer();
      return;
    }

    try {
      isLoadingMentions.value = true;
      final list = await chatRepository.chatMentionCandidates(chatId);
      mentionCandidates.assignAll(list);
      _applyMentionFilterFromComposer();
    } catch (e, s) {
      AppLogger.e('fetchMentionCandidates failed', e, s);
      mentionSuggestions.clear();
      isMentionPopupVisible.value = false;
    } finally {
      isLoadingMentions.value = false;
    }
  }

  Future<void> loadUnreadMentions() async {
    final chatId = selectedChat.value?.chatId?.trim();
    if (chatId == null || chatId.isEmpty) return;

    try {
      final list = await chatRepository.getUnreadMention(chatId);
      list.sort((a, b) => (a.seq ?? 0).compareTo(b.seq ?? 0));
      unreadMentions.assignAll(list);
    } catch (e, s) {
      AppLogger.e('loadUnreadMentions failed', e, s);
    }
  }

  void _applyMentionFilterFromComposer() {
    final value = messageController.value;
    final query = detectComposerMentionQuery(
      value.text,
      value.selection.baseOffset,
    );
    if (query == null) {
      closeMentionPopup(clearSuggestions: true);
      return;
    }

    _mentionQueryStart = query.start;
    final filtered = filterMentionCandidates(mentionCandidates, query.query);
    mentionSuggestions.assignAll(filtered);
    mentionHighlightedIndex.value = 0;
    isMentionPopupVisible.value =
        isLoadingMentions.value || mentionSuggestions.isNotEmpty;
  }

  void _syncMentionPopupFromComposer() {
    final value = messageController.value;
    final query = detectComposerMentionQuery(
      value.text,
      value.selection.baseOffset,
    );

    if (query == null) {
      if (_mentionQueryStart != null) {
        closeMentionPopup(clearSuggestions: true);
      }
      return;
    }

    final isNewMentionSession = _mentionQueryStart != query.start;
    _mentionQueryStart = query.start;

    if (isNewMentionSession || !_mentionFetchRequested) {
      _mentionFetchRequested = true;
      unawaited(fetchMentionCandidates());
    } else {
      _applyMentionFilterFromComposer();
    }
  }

  void selectMention(ChatMentionCandidatesModel candidate) {
    final name = candidate.name?.trim();
    if (name == null || name.isEmpty) return;

    final start = _mentionQueryStart;
    if (start == null) return;

    final value = messageController.value;
    final caret = value.selection.baseOffset.clamp(0, value.text.length);
    final replacement = '@$name ';
    final newText = value.text.replaceRange(start, caret, replacement);
    final newOffset = start + replacement.length;

    applyComposerTextEditingValue(
      messageController,
      TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
        composing: TextRange.empty,
      ),
    );

    if (!selectedMentions.any(
          (m) => m.name?.trim().toLowerCase() == name.toLowerCase(),
    )) {
      selectedMentions.add(candidate);
    }

    closeMentionPopup(clearSuggestions: true);
    scheduleRefocusMessageComposer();
  }

  void mentionMoveHighlight(int delta) {
    if (mentionSuggestions.isEmpty) return;
    final next = mentionHighlightedIndex.value + delta;
    if (next < 0) {
      mentionHighlightedIndex.value = mentionSuggestions.length - 1;
    } else if (next >= mentionSuggestions.length) {
      mentionHighlightedIndex.value = 0;
    } else {
      mentionHighlightedIndex.value = next;
    }
  }

  void confirmHighlightedMention() {
    if (mentionSuggestions.isEmpty) {
      closeMentionPopup();
      return;
    }
    final index = mentionHighlightedIndex.value.clamp(
      0,
      mentionSuggestions.length - 1,
    );
    selectMention(mentionSuggestions[index]);
  }

  void closeMentionPopup({bool clearSuggestions = false}) {
    isMentionPopupVisible.value = false;
    mentionHighlightedIndex.value = 0;
    _mentionQueryStart = null;
    _mentionFetchRequested = false;
    if (clearSuggestions) {
      mentionSuggestions.clear();
    }
  }

  @override
  void onInit() {
    _initializeSocketListener();
    messageController.addListener(_onMessageComposerTextChanged);
    messagesScrollController.addListener(_onMessagesScrollChanged);
    super.onInit();
  }

  Future<void> ensureChatAccountsLoaded() async {
    if (!shouldFetchChatAccounts(
      listLength: chatAccountList.length,
      isLoading: isLoadingChatAccounts.value,
    )) {
      return;
    }
    await loadChatAccountList(refresh: true);
  }

  Future<void> ensureAccountListLoaded() async {
    if (!shouldFetchAccountList(
      listLength: accountList.length,
      isLoading: isLoadingAccounts.value,
    )) {
      return;
    }
    await loadAccountList();
  }

  @override
  void onClose() {
    _clearCustomerTyping();
    _clearReplyHighlight();
    messageController.removeListener(_onMessageComposerTextChanged);
    messagesScrollController.dispose();
    searchController.dispose();
    chatAccountsSearchController.dispose();
    _messageSearchDebounce?.cancel();
    _chatAccountSearchDebounce?.cancel();
    _seenScrollDebounce?.cancel();
    _accountUnreadReconcileTimer?.cancel();
    messagesSearchController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }

  void _onMessagesScrollChanged() {
    if (!messagesScrollController.hasClients) return;
    isNearBottom.value = messagesScrollController.position.pixels < 80;
    if (_suppressScrollSeenSync) return;
    _seenScrollDebounce?.cancel();
    _seenScrollDebounce = Timer(_seenScrollDebounceDelay, () {
      unawaited(_syncSeenFromScrollPosition());
    });
  }

  /// Advances admin read cursor from scroll position (debounced). Unread pill decreases
  /// as newer messages enter the viewport; does not run on panel open.
  Future<void> _syncSeenFromScrollPosition() async {
    final chatId = selectedChat.value?.chatId?.trim();
    if (chatId == null || chatId.isEmpty) return;
    if (isLoadingMessages.value || chatMessages.isEmpty) return;

    final upToSeq = isNearBottom.value
        ? _maxLoadedMessageSeq()
        : _maxVisibleMessageSeqInViewport();
    if (upToSeq == null || upToSeq <= _adminMarkedSeenSeq) return;

    await markMessagesSeenUpTo(upToSeq);
  }

  int? _maxVisibleMessageSeqInViewport() {
    if (!messagesScrollController.hasClients) return null;

    final pos = messagesScrollController.position;
    return maxVisibleSeqInReversedRows(
      rows: buildChatRows(chatMessages),
      scrollPixels: pos.pixels,
      viewportDimension: pos.viewportDimension,
    );
  }

  /// Smoothly scrolls the (reversed) message list to the newest message.
  void scrollToLatest({bool animate = true}) {
    if (!messagesScrollController.hasClients) return;
    if (animate) {
      messagesScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      messagesScrollController.jumpTo(0.0);
    }
  }

  /// Jumps to latest and marks every loaded message as read (jump pill).
  Future<void> jumpToLatestAndMarkAllRead() async {
    scrollToLatest();
    pendingNewMessages.value = 0;
    final maxSeq = _maxLoadedMessageSeq();
    if (maxSeq != null) {
      await markMessagesSeenUpTo(maxSeq, force: true);
    }
    // Force local message-unread state to zero after the admin has explicitly
    // scrolled to the latest message. This wins over any failure-revert inside
    // markMessagesSeenUpTo and ensures the pill dismisses deterministically.
    conversationUnreadCount.value = 0;
    pendingNewMessages.value = 0;
    unreadMentions.clear();
  }

  int? _maxLoadedMessageSeq() {
    int? max;
    for (final m in chatMessages) {
      final s = m.seq;
      if (s != null && (max == null || s > max)) max = s;
    }
    return max;
  }

  void _syncConversationUnreadFromChat(ChatModel chat) {
    final unread = chat.unreadMessageCount ?? 0;
    conversationUnreadCount.value = unread;
  }

  void _updateConversationUnreadAfterSeen(int upToSeq) {
    final chat = selectedChat.value;
    final serverUnread =
        chat?.unreadMessageCount ?? conversationUnreadCount.value;
    conversationUnreadCount.value = conversationUnreadAfterSeen(
      serverUnread: serverUnread,
      anchorSeenSeq: _conversationUnreadAnchorSeq,
      newSeenSeq: upToSeq,
      loadedMessages: chatMessages,
      lastMessageSeq: chat?.lastMessageSeq ?? 0,
      maxLoadedSeq: _maxLoadedMessageSeq() ?? 0,
    );
  }

  /// Drops mentions whose seq is at or below [upToSeq] from the local list.
  void _pruneUnreadMentionsUpTo(int upToSeq) {
    if (unreadMentions.isEmpty) return;
    final pruned = unreadMentionsAfterSeen(unreadMentions, upToSeq);
    if (pruned.length != unreadMentions.length) {
      unreadMentions.assignAll(pruned);
    }
  }

  Future<void> markMessagesSeenUpTo(int upToSeq, {bool force = false}) async {
    if (upToSeq <= 0) return;
    if (!force && upToSeq <= _adminMarkedSeenSeq) return;

    final chatId = selectedChat.value?.chatId?.trim();
    if (chatId == null || chatId.isEmpty) return;

    final prevMarked = _adminMarkedSeenSeq;
    _adminMarkedSeenSeq = upToSeq;
    _updateConversationUnreadAfterSeen(upToSeq);
    _pruneUnreadMentionsUpTo(upToSeq);

    final sent = await sendSeenChatRequest(chatId, upToSeq);
    if (!sent) {
      _adminMarkedSeenSeq = prevMarked;
      _syncConversationUnreadFromChat(selectedChat.value!);
      return;
    }

    _mergeSeenIntoChatLists(
      chatId: chatId,
      upToSeq: upToSeq,
      unreadMessageCount: conversationUnreadCount.value,
    );
    unawaited(requestChatUnreadTotal());
    unawaited(requestChatUnreadMentionTotal());
  }

  /// Sends `chat.admin.seen` ([SocketChatSeenModel]); [upToSeq] maps to `UpToSeq` in JSON.
  Future<bool> sendSeenChatRequest(String chatId, int upToSeq) async {
    if (chatId.isEmpty || upToSeq <= 0) return false;
    try {
      await SocketService.to.ensureConnected(clientId: currentUserId);
      final payload = seen.SocketChatSeenModel(
        channel: 'chat.admin.seen',
        reqId: uuid.v4(),
        sessionId: SecureSessionStorage.instance.read('x-session-id')?.toString(),
        data: seen.Data(
          chatId: chatId,
          upToSeq: upToSeq,
        ),
      );
      SocketService.to.send(payload.toJson());
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[chat.admin.seen] send failed: $e');
      return false;
    }
  }

  /// Requests global unread total; server replies on `ack` with matching [reqId].
  Future<void> requestChatUnreadTotal() async {
    try {
      await SocketService.to.ensureConnected(clientId: currentUserId);
      final reqId = uuid.v4();
      if (Get.isRegistered<ChatFabController>()) {
        Get.find<ChatFabController>().registerUnreadTotalRequest(reqId);
      }
      final payload = unread_total.SocketChatUnreadTotalRequest(reqId: reqId);
      SocketService.to.send(payload.toJson());
    } catch (e) {
      if (kDebugMode) debugPrint('[chat.admin.unread.total] send failed: $e');
    }
  }

  /// Requests global unreadMention total; server replies on `ack` with matching [reqId].
  Future<void> requestChatUnreadMentionTotal() async {
    try {
      await SocketService.to.ensureConnected(clientId: currentUserId);
      final reqId = uuid.v4();
      if (Get.isRegistered<ChatFabController>()) {
        Get.find<ChatFabController>().registerUnreadMentionTotalRequest(reqId);
      }
      final payload = unread_mention_total.SocketChatUnreadMentionTotalRequest(reqId: reqId);
      SocketService.to.send(payload.toJson());
    } catch (e) {
      if (kDebugMode) debugPrint('[chat.unread.mentions.total] send failed: $e');
    }
  }

  /// Updates double-check state on admin outgoing rows when the customer has read up to [upToSeq].
  void _applyOutgoingSeenByCustomer({required int upToSeq}) {
    var changed = false;
    final now = DateTime.now();
    for (var i = 0; i < chatMessages.length; i++) {
      final m = chatMessages[i];
      if (m.senderType != 1) continue;
      final seq = m.seq;
      if (seq == null || seq > upToSeq) continue;
      if (m.seen == true || m.seenOnUtc != null) continue;
      chatMessages[i] = ChatMessageModel(
        rowNum: m.rowNum,
        chatId: m.chatId,
        messageGuid: m.messageGuid,
        replyToMessageGuid: m.replyToMessageGuid,
        replyMessage: m.replyMessage,
        seq: m.seq,
        senderType: m.senderType,
        senderAccountId: m.senderAccountId,
        senderUserId: m.senderUserId,
        messageType: m.messageType,
        text: m.text,
        createdOnUtc: m.createdOnUtc,
        isDeleted: m.isDeleted,
        deliveredOnUtc: m.deliveredOnUtc ?? now,
        seenOnUtc: now,
        seen: true,
        senderAccountName: m.senderAccountName,
        replyToSeq: m.replyToSeq,
        forwardFromSeq: m.forwardFromSeq,
        forwardFromMessageGuid: m.forwardFromMessageGuid,
        forwardFromSenderName: m.forwardFromSenderName,
        forwardMessage: m.forwardMessage,
        filesJson: m.filesJson,
        mentions: m.mentions,
      );
      changed = true;
    }
    if (changed) chatMessages.refresh();
  }

  void _mergeSeenIntoChatLists({
    required String chatId,
    required int upToSeq,
    int? unreadMessageCount,
    int? customerAccountId,
    int? totalUnreadMessageCount,
    bool syncAccountBadge = true,
  }) {
    int? accountId = customerAccountId;
    var previousChatUnread = 0;
    final idx = chatList.indexWhere((c) => c.chatId == chatId);
    final chatWasInLocalList = idx != -1 || selectedChat.value?.chatId == chatId;
    if (idx != -1) {
      final c = chatList[idx];
      accountId ??= c.accountId;
      previousChatUnread = c.unreadMessageCount ?? 0;
      final appliedUnread = unreadMessageCount ?? c.unreadMessageCount;
      chatList[idx] = ChatModel(
        rowNum: c.rowNum,
        chatId: c.chatId,
        accountId: c.accountId,
        topicId: c.topicId,
        topicCode: c.topicCode,
        topicTitle: c.topicTitle,
        status: c.status,
        createdOn: c.createdOn,
        lastActivity: c.lastActivity,
        accountName: c.accountName,
        lastMessageSeq: c.lastMessageSeq,
        lastSeenSeq: c.lastSeenSeq,
        clientSeenSeq: upToSeq,
        lastMessagePreview: c.lastMessagePreview,
        lastMessageOn: c.lastMessageOn,
        totalMessageCount: c.totalMessageCount,
        unreadMessageCount: appliedUnread,
        unreadMentionCount:
        appliedUnread == 0 ? 0 : c.unreadMentionCount,
        topicKey: c.topicKey,
        assignedAdminAccountId: c.assignedAdminAccountId,
        assignedAdminUserId: c.assignedAdminUserId,
        closedOn: c.closedOn,
        assignedAdminName: c.assignedAdminName,
        userId: c.userId,
        adminRole: c.adminRole,
        adminRoleTitle: c.adminRoleTitle,
      );
    }

    final sel = selectedChat.value;
    if (sel?.chatId == chatId) {
      final appliedUnread = unreadMessageCount ?? sel!.unreadMessageCount;
      selectedChat.value = ChatModel(
        rowNum: sel!.rowNum,
        chatId: sel.chatId,
        accountId: sel.accountId,
        topicId: sel.topicId,
        topicCode: sel.topicCode,
        topicTitle: sel.topicTitle,
        status: sel.status,
        createdOn: sel.createdOn,
        lastActivity: sel.lastActivity,
        accountName: sel.accountName,
        lastMessageSeq: sel.lastMessageSeq,
        lastSeenSeq: sel.lastSeenSeq,
        clientSeenSeq: upToSeq,
        lastMessagePreview: sel.lastMessagePreview,
        lastMessageOn: sel.lastMessageOn,
        totalMessageCount: sel.totalMessageCount,
        unreadMessageCount: appliedUnread,
        unreadMentionCount:
        appliedUnread == 0 ? 0 : sel.unreadMentionCount,
        topicKey: sel.topicKey,
        assignedAdminAccountId: sel.assignedAdminAccountId,
        assignedAdminUserId: sel.assignedAdminUserId,
        closedOn: sel.closedOn,
        assignedAdminName: sel.assignedAdminName,
        userId: sel.userId,
        adminRole: sel.adminRole,
        adminRoleTitle: sel.adminRoleTitle,
      );
      accountId ??= sel.accountId;
      if (idx == -1) {
        previousChatUnread = sel.unreadMessageCount ?? 0;
      }
    }

    if (syncAccountBadge && unreadMessageCount != null) {
      _syncAccountUnreadAfterChatSeen(
        accountId: accountId,
        previousChatUnread: previousChatUnread,
        newChatUnread: unreadMessageCount,
        chatWasInLocalList: chatWasInLocalList,
        totalUnreadMessageCount: totalUnreadMessageCount,
      );
    }
  }

  /// Publishes an in-place account-row change so [Obx] listeners rebuild.
  void _publishChatAccountRowUpdate(
      int accountIndex,
      ChatAccountModel updatedAccount,
      ) {
    chatAccountList[accountIndex] = updatedAccount;
    chatAccountList.refresh();
    if (selectedChatAccount.value?.accountId == updatedAccount.accountId) {
      selectedChatAccount.value = updatedAccount;
    }
  }

  /// Keeps [chatAccountList] / [selectedChatAccount] [unreadChatCount] in sync when a thread is read.
  void _syncAccountUnreadAfterChatSeen({
    required int? accountId,
    required int previousChatUnread,
    required int? newChatUnread,
    required bool chatWasInLocalList,
    int? totalUnreadMessageCount,
  }) {
    if (accountId == null) return;

    final accountIndex =
    chatAccountList.indexWhere((a) => a.accountId == accountId);
    if (accountIndex == -1) return;

    final current = chatAccountList[accountIndex];
    final threadJustRead = threadJustReadFromSeenBroadcast(
      previousChatUnread: previousChatUnread,
      newChatUnread: newChatUnread,
      chatWasInLocalList: chatWasInLocalList,
    );
    final unreadChatCount = reconcileAccountUnreadChatCount(
      currentCount: current.unreadChatCount ?? 0,
      reconciled: accountUnreadChatCountFromLoadedChats(chatList, accountId),
      threadJustRead: threadJustRead,
    );
    var hasUnreadMention = reconcileAccountHasUnreadMention(
      current: current.hasUnreadMention ?? false,
      reconciled: accountHasUnreadMentionFromLoadedChats(chatList, accountId),
      threadJustRead: threadJustRead,
    );
    if (unreadChatCount == 0) {
      hasUnreadMention = false;
    }

    final updatedAccount = ChatAccountModel(
      rowNum: current.rowNum,
      accountId: current.accountId,
      accountName: current.accountName,
      lastChatId: current.lastChatId,
      lastMessageOn: current.lastMessageOn,
      lastMessagePreview: current.lastMessagePreview,
      totalMessageCount: current.totalMessageCount,
      unreadMessageCount:
      totalUnreadMessageCount ?? current.unreadMessageCount,
      unreadChatCount: unreadChatCount,
      adminChatRole: current.adminChatRole,
      hasUnreadMention: hasUnreadMention,
      chatStatus: current.chatStatus,
    );
    _publishChatAccountRowUpdate(accountIndex, updatedAccount);
  }

  /// Live unread-thread count for an account row; use inside [Obx].
  int liveUnreadChatCountForAccount(int? accountId) {
    if (accountId == null) return 0;
    final accounts = chatAccountList.toList();
    chatAccountList.length;
    final row = accounts.firstWhereOrNull((a) => a.accountId == accountId);
    return row?.unreadChatCount ?? 0;
  }

  /// Live unread-mention-thread count for an account row; use inside [Obx].
  bool liveUnreadMentionCountForAccount(int? accountId) {
    if (accountId == null) return false;
    final accounts = chatAccountList.toList();
    chatAccountList.length;
    final row = accounts.firstWhereOrNull((a) => a.accountId == accountId);
    return row?.hasUnreadMention ?? false;
  }

  void _handleSeenBroadcast(Map<String, dynamic> data) {
    try {
      final payload = seen_bc.SocketChatSeenBroadcastModel(
        channel: 'chat.seen',
        sessionId: null,
        data: seen_bc.Data.fromJson(data),
      );
      final d = payload.data;
      if (d == null) return;

      final chatId = d.chatId?.trim();
      if (chatId == null || chatId.isEmpty) return;

      final upToSeq = d.upToSeq;
      final unread = d.unreadMessageCount;
      final selfAffectsUnread = seenBroadcastAffectsLocalUnread(
        broadcastByUserId: d.byUserId,
        localUserId: int.tryParse(currentUserId),
      );

      if (upToSeq != null) {
        _mergeSeenIntoChatLists(
          chatId: chatId,
          upToSeq: upToSeq,
          unreadMessageCount: unread,
          customerAccountId: d.customerAccountId,
          totalUnreadMessageCount: d.totalUnreadMessageCount,
          syncAccountBadge: selfAffectsUnread,
        );
      } else if (unread != null && selfAffectsUnread) {
        int? accountId = d.customerAccountId;
        var previousChatUnread = 0;
        final idx = chatList.indexWhere((c) => c.chatId == chatId);
        final chatWasInLocalList =
            idx != -1 || selectedChat.value?.chatId == chatId;
        if (idx != -1) {
          final c = chatList[idx];
          accountId ??= c.accountId;
          previousChatUnread = c.unreadMessageCount ?? 0;
          chatList[idx] = ChatModel(
            rowNum: c.rowNum,
            chatId: c.chatId,
            accountId: c.accountId,
            topicId: c.topicId,
            topicCode: c.topicCode,
            topicTitle: c.topicTitle,
            status: c.status,
            createdOn: c.createdOn,
            lastActivity: c.lastActivity,
            accountName: c.accountName,
            lastMessageSeq: c.lastMessageSeq,
            lastSeenSeq: c.lastSeenSeq,
            clientSeenSeq: c.clientSeenSeq,
            lastMessagePreview: c.lastMessagePreview,
            lastMessageOn: c.lastMessageOn,
            totalMessageCount: c.totalMessageCount,
            unreadMessageCount: unread,
            unreadMentionCount: unread == 0 ? 0 : c.unreadMentionCount,
            topicKey: c.topicKey,
            assignedAdminAccountId: c.assignedAdminAccountId,
            assignedAdminUserId: c.assignedAdminUserId,
            closedOn: c.closedOn,
            assignedAdminName: c.assignedAdminName,
            userId: c.userId,
            adminRole: c.adminRole,
            adminRoleTitle: c.adminRoleTitle,
          );
        }
        final sel = selectedChat.value;
        if (sel?.chatId == chatId) {
          selectedChat.value = ChatModel(
            rowNum: sel!.rowNum,
            chatId: sel.chatId,
            accountId: sel.accountId,
            topicId: sel.topicId,
            topicCode: sel.topicCode,
            topicTitle: sel.topicTitle,
            status: sel.status,
            createdOn: sel.createdOn,
            lastActivity: sel.lastActivity,
            accountName: sel.accountName,
            lastMessageSeq: sel.lastMessageSeq,
            lastSeenSeq: sel.lastSeenSeq,
            clientSeenSeq: sel.clientSeenSeq,
            lastMessagePreview: sel.lastMessagePreview,
            lastMessageOn: sel.lastMessageOn,
            totalMessageCount: sel.totalMessageCount,
            unreadMessageCount: unread,
            unreadMentionCount: unread == 0 ? 0 : sel.unreadMentionCount,
            topicKey: sel.topicKey,
            assignedAdminAccountId: sel.assignedAdminAccountId,
            assignedAdminUserId: sel.assignedAdminUserId,
            closedOn: sel.closedOn,
            assignedAdminName: sel.assignedAdminName,
            userId: sel.userId,
            adminRole: sel.adminRole,
            adminRoleTitle: sel.adminRoleTitle,
          );
          accountId ??= sel.accountId;
          if (idx == -1) {
            previousChatUnread = sel.unreadMessageCount ?? 0;
          }
        }

        _syncAccountUnreadAfterChatSeen(
          accountId: accountId,
          previousChatUnread: previousChatUnread,
          newChatUnread: unread,
          chatWasInLocalList: chatWasInLocalList,
          totalUnreadMessageCount: d.totalUnreadMessageCount,
        );
      }

      if (selectedChat.value?.chatId == chatId) {
        final myUserId = int.tryParse(currentUserId);
        final readerIsCustomer =
            d.byUserId != null && myUserId != null && d.byUserId != myUserId;
        if (unread != null) {
          conversationUnreadCount.value = conversationUnreadAfterSeenBroadcast(
            currentUnread: conversationUnreadCount.value,
            broadcastUnread: unread,
            readerIsCustomer: readerIsCustomer,
          );
        }
        if (upToSeq != null) {
          if (!readerIsCustomer && upToSeq > _adminMarkedSeenSeq) {
            _adminMarkedSeenSeq = upToSeq;
            _pruneUnreadMentionsUpTo(upToSeq);
          }
          if (readerIsCustomer) {
            _applyOutgoingSeenByCustomer(upToSeq: upToSeq);
          }
        }
      }

      if (selfAffectsUnread) {
        scheduleAccountUnreadReconcile();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[chat.seen] broadcast parse error: $e');
    }
  }

  /// Debounced server reconcile for cross-window account unread badge convergence.
  void scheduleAccountUnreadReconcile() {
    _accountUnreadReconcileTimer?.cancel();
    accountUnreadReconcileScheduleCount++;
    _accountUnreadReconcileTimer = Timer(const Duration(milliseconds: 300), () {
      unawaited(refreshChatAccountUnreadByMerge());
    });
  }

  /// Re-fetches page-1 account rows and merges unread badge fields by [accountId].
  ///
  /// Does not [RxList.clear] [chatAccountList] — safe for silent cross-tab reconcile.
  Future<void> refreshChatAccountUnreadByMerge() async {
    try {
      if (chatAccountList.isEmpty) return;

      accountUnreadMergeRefreshInvokeCount++;
      final query = searchText.value.trim();
      final fetched = await chatRepository.getChatAccountList(
        startIndex: 1,
        toIndex: pageSize,
        searchText: query.isNotEmpty ? query : null,
      );

      for (final fresh in fetched) {
        final accountId = fresh.accountId;
        if (accountId == null) continue;

        final accountIndex =
        chatAccountList.indexWhere((a) => a.accountId == accountId);
        if (accountIndex == -1) continue;

        final current = chatAccountList[accountIndex];
        _publishChatAccountRowUpdate(
          accountIndex,
          mergeChatAccountRowUnreadFields(current, fresh),
        );
      }
    } catch (e, s) {
      AppLogger.e('refreshChatAccountUnreadByMerge failed', e, s);
    }
  }

  Future<void> _ensureAnchorMessageLoaded(String chatId, int anchorSeq) async {
    if (anchorSeq <= 0) return;
    const maxPages = 24;
    for (var i = 0; i < maxPages; i++) {
      if (chatMessages.any((m) => m.seq == anchorSeq)) return;
      final oldest = chatMessages.isEmpty
          ? null
          : chatMessages
          .map((m) => m.seq)
          .whereType<int>()
          .fold<int?>(null, (a, b) => a == null || b < a ? b : a);
      if (oldest != null && oldest <= anchorSeq) return;
      if (!hasMoreMessages.value) return;
      final before = chatMessages.length;
      await loadChatMessages(chatId);
      if (chatMessages.length <= before) return;
    }
  }

  ChatMessageModel? _messageForSeq(int seq) {
    final chatId = selectedChat.value?.chatId?.toString().trim();
    return chatMessages.firstWhereOrNull(
          (m) => m.seq == seq && m.chatId?.toString().trim() == chatId,
    );
  }

  /// Resolves the last-read bubble; falls back to the newest loaded message at or below [anchorSeq].
  ChatMessageModel? _messageForLastReadAnchor(int anchorSeq) {
    final exact = _messageForSeq(anchorSeq);
    if (exact != null) return exact;

    final chatId = selectedChat.value?.chatId?.toString().trim();
    ChatMessageModel? best;
    for (final m in chatMessages) {
      final seq = m.seq;
      if (seq == null || seq > anchorSeq) continue;
      if (chatId != null && m.chatId?.toString().trim() != chatId) continue;
      if (best == null || (best.seq ?? 0) < seq) best = m;
    }
    return best;
  }

  void _scheduleInitialConversationScroll(ChatModel chat) {
    _initialScrollRetryCount = 0;
    _initialScrollAppliedChatId = null;
    if (shouldAnchorConversationToLastRead(chat)) {
      _pendingConversationAnchorSeq = lastReadAnchorSeq(chat);
      isNearBottom.value = false;
      isAnchoringInitialScroll.value = true;
    } else {
      _pendingConversationAnchorSeq = null;
      isNearBottom.value = true;
      isAnchoringInitialScroll.value = false;
    }
  }

  void _completeInitialScrollSession(String chatId) {
    _initialScrollAppliedChatId = chatId;
    _pendingConversationAnchorSeq = null;
    _initialScrollRetryCount = 0;
    isAnchoringInitialScroll.value = false;
    if (messagesScrollController.hasClients) {
      isNearBottom.value = messagesScrollController.position.pixels < 80;
    }
  }

  Future<void> _preJumpTowardBubbleRow(int rowIndex, int rowCount) async {
    final c = messagesScrollController;
    if (!c.hasClients || rowCount <= 1 || rowIndex <= 0) return;

    await WidgetsBinding.instance.endOfFrame;
    if (!c.hasClients) return;

    final fraction = estimateReversedListPreJumpFraction(rowIndex, rowCount);
    final max = c.position.maxScrollExtent;
    if (max <= 0) return;

    c.jumpTo(max * fraction);
    await WidgetsBinding.instance.endOfFrame;
  }

  /// Lands on the last-read bubble with unread messages below the fold.
  Future<bool> _anchorToLastReadMessage(ChatMessageModel target) async {
    final rowIndex = indexOfBubbleRowForMessage(chatMessages, target);
    final rowCount = buildChatRows(chatMessages).length;
    if (rowIndex != null && rowCount > 0) {
      await _preJumpTowardBubbleRow(rowIndex, rowCount);
    }

    _suppressMessagePagination = true;
    try {
      return await _bringMessageIntoView(
        target,
        ensureVisibleDuration: Duration.zero,
        alignment: kLastReadAnchorAlignment,
      );
    } finally {
      _suppressMessagePagination = false;
    }
  }

  /// Called from [ConversationPanel] after the reversed [ListView] is built.
  Future<void> applyInitialConversationScrollIfNeeded() async {
    final chatId = selectedChat.value?.chatId?.trim();
    if (chatId == null || chatId.isEmpty) return;
    if (_initialScrollAppliedChatId == chatId) return;
    if (isLoadingMessages.value || chatMessages.isEmpty) return;

    final anchorSeq = _pendingConversationAnchorSeq;
    if (anchorSeq == null || anchorSeq <= 0) {
      if (messagesScrollController.hasClients) {
        scrollToLatest(animate: false);
      }
      _completeInitialScrollSession(chatId);
      await _syncSeenFromScrollPosition();
      return;
    }

    if (!messagesScrollController.hasClients) {
      if (_initialScrollRetryCount++ < _maxInitialScrollRetries) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(applyInitialConversationScrollIfNeeded());
        });
      }
      return;
    }

    await _ensureAnchorMessageLoaded(chatId, anchorSeq);
    final target = _messageForLastReadAnchor(anchorSeq);
    if (target == null) {
      _completeInitialScrollSession(chatId);
      return;
    }

    _suppressScrollSeenSync = true;
    try {
      await _anchorToLastReadMessage(target);
    } finally {
      _suppressScrollSeenSync = false;
    }

    _completeInitialScrollSession(chatId);
    await _syncSeenFromScrollPosition();
  }

  void _prepareConversationState(ChatModel chat) {
    _clearCustomerTyping();
    _clearMessageSearchState();
    _clearMentionState();
    chatMessages.clear();
    _clearMessageBubbleScrollKeys();
    replyToMessage.value = null;
    messageController.clear();
    pendingNewMessages.value = 0;
    _seenScrollDebounce?.cancel();

    final lastSeen = lastReadAnchorSeq(chat);
    _adminMarkedSeenSeq = lastSeen;
    _conversationUnreadAnchorSeq = lastSeen;
    _syncConversationUnreadFromChat(chat);
    _scheduleInitialConversationScroll(chat);

    if (chat.topicTitle != null) {
      final matchingTopic = topicList.firstWhereOrNull(
            (t) => t.title == chat.topicTitle,
      );
      if (matchingTopic != null) {
        selectedTopic.value = matchingTopic;
      }
    }
  }

  Future<void> _initializeSocketListener() async {
    try {
      await SocketService.to.ensureConnected(clientId: currentUserId);
      // `chat.*` events are handled via [ChatFabController] socket fan-out
      // only — avoids double-processing the broadcast [SocketService.messageStream].
    } catch (_) {
      // Keep controller resilient; UI remains functional with repository fallback loads.
    }
  }

  // TEMP(debug): remove after realtime `chat.message` investigation.
  void _debugChatMessage(String message) {
    if (kDebugMode) debugPrint(message);
  }

  /// Entry for [ChatFabController] socket fan-out and the local subscription.
  void handleSocketChatEnvelope(Map<String, dynamic> envelope) {
    _handleSocketMessage(envelope);
  }

  final Set<String> _pendingAdminSendReqIds = <String>{};
  final Map<String, ChatMessageModel> _outboundForwardSourceByReqId = {};

  /// Handles `ack` for in-flight `chat.admin.send` requests ([reqId]).
  void handleSocketAckEnvelope(Map<String, dynamic> envelope) {
    final id = envelope['reqId']?.toString().trim();
    if (id == null || id.isEmpty || !_pendingAdminSendReqIds.remove(id)) {
      return;
    }
    final data = envelope['data'];
    if (data is! Map) return;
    final m = Map<String, dynamic>.from(data);
    final success = m['success'] ?? m['Success'] ?? m['ok'] ?? m['Ok'];
    if (success == false) {
      final message = (m['message'] ?? m['Message'] ?? m['error'] ?? m['Error'])
          ?.toString()
          .trim();
      _rollbackFailedOutboundSend(id);
      ToastService().error(
        message == null || message.isEmpty
            ? 'ارسال پیام توسط سرور رد شد'
            : message,
      );
    } else {
      _outboundForwardSourceByReqId.remove(id);
    }
  }

  /// Handles server `error` envelopes tied to a failed `chat.admin.send`.
  void handleSocketErrorEnvelope(Map<String, dynamic> envelope) {
    final id = envelope['reqId']?.toString().trim();
    if (id == null || id.isEmpty) return;
    if (!_pendingAdminSendReqIds.remove(id)) return;

    final data = envelope['data'];
    String? message;
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      message = (m['message'] ?? m['Message'] ?? m['error'] ?? m['Error'])
          ?.toString()
          .trim();
    }
    message ??= envelope['message']?.toString().trim();

    _rollbackFailedOutboundSend(id);
    ToastService().error(
      message == null || message.isEmpty ? 'ارسال پیام ناموفق بود' : message,
    );
  }

  void _rollbackFailedOutboundSend(String reqId) {
    chatMessages.removeWhere((m) => m.messageGuid == reqId);
    chatMessages.refresh();
    final forwardSource = _outboundForwardSourceByReqId.remove(reqId);
    if (forwardSource != null) {
      pendingForwardMessage.value = forwardSource;
    }
  }

  void _handleSocketMessage(dynamic rawData) {
    try {
      final dynamic decoded = rawData is String ? json.decode(rawData) : rawData;
      if (decoded is! Map) return;
      final envelope = Map<String, dynamic>.from(decoded);

      final channel = envelope['channel']?.toString();
      final rawPayload = envelope['data'];
      if (channel == null || rawPayload is! Map) {
        if (channel == 'chat.message') {
          _debugChatMessage(
            '[chat.message] dropped: data is not a Map (${rawPayload.runtimeType})',
          );
        }
        return;
      }
      final data = Map<String, dynamic>.from(rawPayload);

      switch (channel) {
        case 'chat.message':
          _handleIncomingChatMessage(data);
          break;
        case 'chat.typing':
          _handleTypingEvent(data);
          break;
        case 'chat.seen':
          _handleSeenBroadcast(data);
          break;
      }
    } catch (e, s) {
      _debugChatMessage('[chat.message] _handleSocketMessage error: $e\n$s');
    }
  }

  int? get _openCustomerAccountId =>
      selectedAccount.value?.id ??
          selectedChatAccount.value?.accountId ??
          selectedChat.value?.accountId;

  String? get _openTopicCode =>
      selectedTopic.value?.code ?? selectedChat.value?.topicCode;

  String? get _openTopicKey => selectedChat.value?.topicKey;

  bool get _hasOpenComposerConversation {
    final code = _openTopicCode?.trim();
    return _openCustomerAccountId != null && code != null && code.isNotEmpty;
  }

  void _clearCustomerTyping() {
    _customerTypingIdleTimer?.cancel();
    _customerTypingIdleTimer = null;
    isCustomerTyping.value = false;
  }

  void _markCustomerTypingActive() {
    isCustomerTyping.value = true;
    _customerTypingIdleTimer?.cancel();
    _customerTypingIdleTimer = Timer(_customerTypingIdle, _clearCustomerTyping);
  }

  void _handleTypingEvent(Map<String, dynamic> data) {
    if (!_hasOpenComposerConversation) return;

    final payload = typing.Data.fromJson(data);
    if (!chatTypingMatchesOpenConversation(
      eventCustomerAccountId: payload.customerAccountId,
      eventTopicCode: payload.topicCode,
      eventTopicKey: payload.topicKey,
      openCustomerAccountId: _openCustomerAccountId,
      openTopicCode: _openTopicCode,
      openTopicKey: _openTopicKey,
    )) {
      return;
    }

    //use by chat_typing_handler.dart
    /* void _handleTypingEvent(Map<String, dynamic> data) {
      final flag = customerTypingFlagFromSocketData(
        data: data,
        openCustomerAccountId: _openCustomerAccountId,
        openTopicCode: _openTopicCode,
        openTopicKey: _openTopicKey,
      );
      if (flag == true) {
        _markCustomerTypingActive();
      } else if (flag == false) {
        _clearCustomerTyping();
      }
    }*/

    if (payload.isTyping == true) {
      _markCustomerTypingActive();
    } else if (payload.isTyping == false) {
      _clearCustomerTyping();
    }
  }

  /// Parses `chat.message` [data] (nested `message` / optional `chat`) or legacy flat maps.
  socket_msg.SocketChatMessageData? _parseChatMessageSocketData(
      Map<String, dynamic> data) {
    final normalized = socket_msg.normalizeSocketChatMessageDataJson(data);
    final rawMessage = normalized['message'];
    if (rawMessage is Map) {
      return socket_msg.SocketChatMessageData.fromJson(normalized);
    }
    // Legacy: message fields at the root of `data`.
    final flat = socket_msg.normalizeSocketChatMessagePayloadJson(normalized);
    if (flat['chatId'] != null) {
      return socket_msg.SocketChatMessageData(
        isNewChat: false,
        chat: null,
        message: socket_msg.SocketChatMessagePayload.fromJson(flat),
      );
    }
    return null;
  }

  /// Inserts or refreshes a thread row when the server signals [isNewChat].
  void _upsertChatFromSocket(socket_msg.SocketChatMessageChat chat) {
    final chatId = chat.chatId?.trim();
    if (chatId == null || chatId.isEmpty) return;

    final customerId = chat.customerAccountId ?? chat.accountId;
    final selectedAccountId = selectedChatAccount.value?.accountId;
    if (selectedAccountId != null &&
        customerId != null &&
        selectedAccountId != customerId) {
      return;
    }

    final incoming = chat.toChatModel();
    final idx = chatList.indexWhere((c) => c.chatId == chatId);
    if (idx == -1) {
      chatList.insert(0, incoming);
      return;
    }

    final current = chatList[idx];
    chatList[idx] = ChatModel(
      rowNum: current.rowNum,
      chatId: current.chatId,
      accountId: incoming.accountId ?? current.accountId,
      topicId: incoming.topicId ?? current.topicId,
      topicCode: incoming.topicCode ?? current.topicCode,
      topicTitle: incoming.topicTitle ?? current.topicTitle,
      status: incoming.status,
      createdOn: incoming.createdOn ?? current.createdOn,
      lastActivity: incoming.lastActivity ?? current.lastActivity,
      accountName: incoming.accountName ?? current.accountName,
      lastMessageSeq: incoming.lastMessageSeq ?? current.lastMessageSeq,
      lastSeenSeq: incoming.lastSeenSeq ?? current.lastSeenSeq,
      clientSeenSeq: incoming.clientSeenSeq ?? current.clientSeenSeq,
      lastMessagePreview:
      incoming.lastMessagePreview ?? current.lastMessagePreview,
      lastMessageOn: incoming.lastMessageOn ?? current.lastMessageOn,
      totalMessageCount: incoming.totalMessageCount ?? current.totalMessageCount,
      unreadMessageCount:
      incoming.unreadMessageCount ?? current.unreadMessageCount,
      unreadMentionCount:
      incoming.unreadMentionCount ?? current.unreadMentionCount,
      topicKey: incoming.topicKey ?? current.topicKey,
      assignedAdminAccountId:
      incoming.assignedAdminAccountId ?? current.assignedAdminAccountId,
      assignedAdminUserId:
      incoming.assignedAdminUserId ?? current.assignedAdminUserId,
      closedOn: current.closedOn,
      assignedAdminName:
      incoming.assignedAdminName ?? current.assignedAdminName,
      userId: current.userId,
      adminRole: incoming.adminRole ?? current.adminRole,
      adminRoleTitle: incoming.adminRoleTitle ?? current.adminRoleTitle,
    );
  }

  void _handleIncomingChatMessage(Map<String, dynamic> data) {
    _debugChatMessage('[chat.message] handler entered');

    final socketPayload = _parseChatMessageSocketData(data);
    if (socketPayload == null) {
      _debugChatMessage('[chat.message] parse returned null');
      return;
    }

    if (socketPayload.isNewChat == true && socketPayload.chat != null) {
      _upsertChatFromSocket(socketPayload.chat!);
    }

    final messagePayload = socketPayload.message;
    if (messagePayload == null) {
      _debugChatMessage('[chat.message] no nested message in payload');
      return;
    }

    final chatId = messagePayload.chatId?.trim() ??
        socketPayload.chat?.chatId?.trim();
    if (chatId == null || chatId.isEmpty) {
      _debugChatMessage(
        '[chat.message] missing chatId (message=${messagePayload.chatId} '
            'chat=${socketPayload.chat?.chatId})',
      );
      return;
    }

    var incomingMessage =
    messagePayload.toChatMessageModel(chatIdOverride: chatId);
    var filesJson = incomingMessage.filesJson;

    final guid = incomingMessage.messageGuid?.trim();
    final optimisticIdxPreview = indexOfOutgoingOptimisticMatch(
      messages: chatMessages,
      chatId: chatId,
      incomingMessageGuid: guid,
      pendingReqId: reqId.value,
    );
    final hasOptimisticDraft = optimisticIdxPreview != -1;

    final isCurrentChatOpen = incomingChatMessageMatchesOpenConversation(
      incomingChatId: chatId,
      selectedChatId: selectedChat.value?.chatId,
      loadedMessageChatIds: chatMessages.map((m) => m.chatId),
      hasOpenComposerConversation: _hasOpenComposerConversation,
      messageCustomerAccountId: messagePayload.customerAccountId,
      messageTopicCode: messagePayload.topicCode,
      messageTopicKey: messagePayload.topicKey,
      openCustomerAccountId: _openCustomerAccountId,
      openTopicCode: _openTopicCode,
      openTopicKey: _openTopicKey,
      hasOptimisticDraftForMessageGuid: hasOptimisticDraft,
    );

    // TEMP(debug): remove after realtime `chat.message` investigation.
    final selectedChatId = selectedChat.value?.chatId;
    _debugChatMessage(
      '[chat.message] isCurrentChatOpen=$isCurrentChatOpen '
          'selectedChatId=$selectedChatId incomingChatId=$chatId '
          'isMessageSearchActive=$isMessageSearchActive',
    );

    var debugMessageListAction = 'no-append';
    if (isCurrentChatOpen && !isMessageSearchActive) {
      final senderType = incomingMessage.senderType;
      if (senderType != null && senderType != 1 && senderType != 2) {
        _clearCustomerTyping();
      }
      final optimisticIdx = indexOfOutgoingOptimisticMatch(
        messages: chatMessages,
        chatId: chatId,
        incomingMessageGuid: guid,
        pendingReqId: reqId.value,
      );
      if (optimisticIdx != -1) {
        final optimistic = chatMessages[optimisticIdx];
        _syncAttachmentRecordIdAliasesFromFilesJson(
          filesJson,
          optimistic.filesJson,
        );
        _syncAttachmentRecordIdAliasesFromFilesJson(
          incomingMessage.forwardMessage?.filesJson,
          optimistic.forwardMessage?.filesJson,
        );
        filesJson = mergeChatFilesJsonFromOutbound(
          filesJson,
          optimistic.filesJson,
        );
        final mergedReply = mergeIncomingReplyFields(
          incoming: incomingMessage,
          threadMessages: chatMessages,
          fallback: optimistic,
        );
        chatMessages[optimisticIdx] = ChatMessageModel(
          rowNum: incomingMessage.rowNum,
          chatId: incomingMessage.chatId,
          messageGuid: incomingMessage.messageGuid,
          replyToMessageGuid: mergedReply.replyToMessageGuid,
          replyMessage: mergedReply.replyMessage,
          forwardFromMessageGuid: mergedReply.forwardFromMessageGuid,
          forwardFromSenderName: mergedReply.forwardFromSenderName,
          forwardMessage: mergedReply.forwardMessage,
          seq: incomingMessage.seq,
          senderType: incomingMessage.senderType,
          senderAccountId: incomingMessage.senderAccountId,
          senderUserId: incomingMessage.senderUserId,
          messageType: incomingMessage.messageType,
          text: incomingMessage.text,
          createdOnUtc: incomingMessage.createdOnUtc,
          isDeleted: incomingMessage.isDeleted,
          deliveredOnUtc: incomingMessage.deliveredOnUtc,
          seenOnUtc: incomingMessage.seenOnUtc,
          seen: incomingMessage.seen ?? incomingMessage.seenOnUtc != null,
          senderAccountName: incomingMessage.senderAccountName,
          replyToSeq: mergedReply.replyToSeq,
          forwardFromSeq: mergedReply.forwardFromSeq,
          filesJson: filesJson ?? optimistic.filesJson,
          mentions: incomingMessage.mentions ?? optimistic.mentions,
        );
        chatMessages.refresh();
        debugMessageListAction = 'replaced-optimistic';
        _outboundForwardSourceByReqId.remove(reqId.value);
        _maybeAdoptRealChatAfterFirstIncomingMessage(chatId, incomingMessage);
        if (isNearBottom.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) => scrollToLatest());
          final seq = incomingMessage.seq;
          if (seq != null) {
            unawaited(markMessagesSeenUpTo(seq));
          }
        } else {
          pendingNewMessages.value++;
          _updateConversationUnreadAfterSeen(_adminMarkedSeenSeq);
        }
      } else {
        final exists = chatMessages.any((m) =>
        (incomingMessage.messageGuid != null &&
            incomingMessage.messageGuid!.isNotEmpty &&
            m.messageGuid == incomingMessage.messageGuid) ||
            (incomingMessage.seq != null &&
                incomingMessage.seq! > 0 &&
                m.seq == incomingMessage.seq &&
                chatIdsEqual(m.chatId, chatId)));
        if (!exists) {
          chatMessages.insert(
            0,
            mergeIncomingReplyFields(
              incoming: incomingMessage,
              threadMessages: chatMessages,
            ),
          );
          chatMessages.refresh();
          debugMessageListAction = 'inserted';
          if (selectedChat.value == null) {
            _maybeAdoptRealChatAfterFirstIncomingMessage(
              chatId,
              incomingMessage,
            );
          }
          if (isNearBottom.value) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => scrollToLatest());
            final seq = incomingMessage.seq;
            if (seq != null) {
              unawaited(markMessagesSeenUpTo(seq));
            }
          } else {
            pendingNewMessages.value++;
            _updateConversationUnreadAfterSeen(_adminMarkedSeenSeq);
          }
        } else {
          debugMessageListAction = 'duplicate-skipped';
        }
      }
    } else if (!isCurrentChatOpen) {
      debugMessageListAction = 'not-open-conversation';
    } else if (isMessageSearchActive) {
      debugMessageListAction = 'search-active-skipped';
    }

    // TEMP(debug): remove after realtime `chat.message` investigation.
    _debugChatMessage(
      '[chat.message] chatMessages.length=${chatMessages.length} '
          'action=$debugMessageListAction',
    );

    _applyRealtimeListUpdates(
      chatId: chatId,
      messageText: incomingMessage.text,
      messageTime: incomingMessage.createdOnUtc ?? DateTime.now(),
      incrementUnread: !isCurrentChatOpen,
      incrementUnreadMention: !isCurrentChatOpen,
      customerAccountId: messagePayload.customerAccountId ??
          socketPayload.chat?.customerAccountId ??
          socketPayload.chat?.accountId,
    );
  }

  /// Binds [selectedChat] (and [chatList] if missing) after the first real `chat.message`
  /// for a thread that was opened as topic-only (no [ChatModel] yet).
  void _maybeAdoptRealChatAfterFirstIncomingMessage(
      String chatId,
      ChatMessageModel firstMessage,
      ) {
    if (selectedChat.value != null) return;
    final topic = selectedTopic.value;
    if (topic == null) return;

    final fromList = chatList.firstWhereOrNull((c) => c.chatId == chatId);
    if (fromList != null) {
      selectedChat.value = fromList;
      hasMoreMessages.value = chatMessages.length >= pageSize;
      unawaited(loadChatAccountList(refresh: true));
      return;
    }

    final accountId =
        selectedAccount.value?.id ?? selectedChatAccount.value?.accountId;
    final name = selectedChatAccount.value?.accountName ??
        selectedAccount.value?.name;
    final when = firstMessage.createdOnUtc ?? DateTime.now();

    final stub = ChatModel(
      rowNum: null,
      chatId: chatId,
      accountId: accountId,
      topicId: null,
      topicCode: topic.code,
      topicTitle: topic.title,
      status: 0,
      createdOn: when,
      lastActivity: when,
      accountName: name,
      lastMessageSeq: firstMessage.seq,
      lastSeenSeq: fromList?.lastSeenSeq,
      clientSeenSeq: fromList?.clientSeenSeq,
      lastMessagePreview: firstMessage.text,
      lastMessageOn: when,
      totalMessageCount: 1,
      unreadMessageCount: 0,
      unreadMentionCount: 0,
      topicKey: null,
      assignedAdminAccountId: null,
      assignedAdminUserId: null,
      closedOn: null,
      assignedAdminName: null,
      userId: null,
      adminRole: null,
      adminRoleTitle: null,
    );
    selectedChat.value = stub;

    final listIdx = chatList.indexWhere((c) => c.chatId == chatId);
    if (listIdx == -1) {
      chatList.insert(0, stub);
    }
    // Avoid pagination footer + spinner until a thread id exists; then infer from
    // how many rows we already have vs [pageSize] (no history fetch yet).
    hasMoreMessages.value = chatMessages.length >= pageSize;
    unawaited(loadChatAccountList(refresh: true));
  }

  void _applyRealtimeListUpdates({
    required String chatId,
    required String? messageText,
    required DateTime messageTime,
    required bool incrementUnread,
    required bool incrementUnreadMention,
    int? customerAccountId,
  }) {
    int? messageAccountId = customerAccountId;
    final chatIndex = chatList.indexWhere((c) => c.chatId == chatId);
    final int? threadUnreadBefore = chatIndex != -1
        ? (chatList[chatIndex].unreadMessageCount ?? 0)
        : null;
    if (chatIndex != -1) {
      final current = chatList[chatIndex];
      messageAccountId ??= current.accountId;
      final updatedChat = ChatModel(
        rowNum: current.rowNum,
        chatId: current.chatId,
        accountId: current.accountId,
        topicId: current.topicId,
        topicCode: current.topicCode,
        topicTitle: current.topicTitle,
        status: current.status,
        createdOn: current.createdOn,
        lastActivity: messageTime,
        accountName: current.accountName,
        lastMessageSeq: current.lastMessageSeq,
        lastSeenSeq: current.lastSeenSeq,
        clientSeenSeq: current.clientSeenSeq,
        lastMessagePreview: messageText ?? current.lastMessagePreview,
        lastMessageOn: messageTime,
        totalMessageCount: current.totalMessageCount,
        unreadMessageCount: incrementUnread
            ? ((current.unreadMessageCount ?? 0) + 1)
            : current.unreadMessageCount,
        unreadMentionCount: incrementUnreadMention
            ? ((current.unreadMentionCount ?? 0) + 1)
            : current.unreadMentionCount,
        topicKey: current.topicKey,
        assignedAdminAccountId: current.assignedAdminAccountId,
        assignedAdminUserId: current.assignedAdminUserId,
        closedOn: current.closedOn,
        assignedAdminName: current.assignedAdminName,
        userId: current.userId,
        adminRole: current.adminRole,
        adminRoleTitle: current.adminRoleTitle,
      );
      chatList.removeAt(chatIndex);
      chatList.insert(0, updatedChat);
    }

    if (messageAccountId != null) {
      final accountIndex =
      chatAccountList.indexWhere((a) => a.accountId == messageAccountId);
      if (accountIndex != -1) {
        final current = chatAccountList[accountIndex];
        final bumpUnreadChatCount = shouldIncrementAccountUnreadChatCount(
          incrementUnread: incrementUnread,
          threadUnreadBefore: threadUnreadBefore ?? 0,
          threadRowInList: chatIndex != -1,
          accountLastChatId: current.lastChatId,
          chatId: chatId,
          accountUnreadChatCount: current.unreadChatCount ?? 0,
        );
        final updatedAccount = ChatAccountModel(
          rowNum: current.rowNum,
          accountId: current.accountId,
          accountName: current.accountName,
          lastChatId: chatId,
          lastMessageOn: messageTime,
          lastMessagePreview: messageText ?? current.lastMessagePreview,
          totalMessageCount: current.totalMessageCount,
          unreadMessageCount: incrementUnread
              ? ((current.unreadMessageCount ?? 0) + 1)
              : current.unreadMessageCount,
          unreadChatCount: bumpUnreadChatCount
              ? ((current.unreadChatCount ?? 0) + 1)
              : current.unreadChatCount,
          adminChatRole: current.adminChatRole,
          hasUnreadMention: incrementUnreadMention ? true : current.hasUnreadMention,
          chatStatus: current.chatStatus,
        );
        chatAccountList.removeAt(accountIndex);
        chatAccountList.insert(0, updatedAccount);
        chatAccountList.refresh();
        if (selectedChatAccount.value?.accountId == messageAccountId) {
          selectedChatAccount.value = updatedAccount;
        }
      }
    }
  }

  void onChatAccountSearchChanged(String value) {
    _chatAccountSearchDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed == searchText.value) return;
    if (trimmed.isEmpty) {
      searchChatAccounts('');
      return;
    }
    _chatAccountSearchDebounce = Timer(_chatAccountSearchDebounceDelay, () {
      searchChatAccounts(chatAccountsSearchController.text);
    });
  }

  Future<void> searchChatAccounts(String value) async {
    _chatAccountSearchDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed == searchText.value && chatAccountList.isNotEmpty) return;
    searchText.value = trimmed;
    await loadChatAccountList(refresh: true, fromSearch: true);
    if (selectedChatAccount.value != null) {
      await loadChatList(
        selectedChatAccount.value!.accountId.toString(),
        refresh: true,
      );
    }
    if (selectedChat.value != null) {
      final chatId = selectedChat.value!.chatId?.toString();
      if (chatId != null && chatId.isNotEmpty) {
        activeMessageSearchQuery.value = trimmed;
        if (trimmed.isEmpty) {
          messagesSearchController.clear();
        } else {
          messagesSearchController.text = trimmed;
          messagesSearchController.selection =
              TextSelection.collapsed(offset: trimmed.length);
          isMessageSearchExpanded.value = true;
        }
        await loadChatMessages(chatId, refresh: true);
      }
    }
  }

  // ─── Load chat account list ───
  Future<void> loadChatAccountList({
    bool refresh = false,
    bool fromSearch = false,
  }) async {
    final query = searchText.value.trim();
    final isSearchRequest = refresh && (fromSearch || query.isNotEmpty);
    final seq =
    isSearchRequest ? ++_chatAccountSearchSeq : _chatAccountSearchSeq;
    try {
      if (refresh) {
        chatAccountPage = 1;
        hasMoreChatAccounts.value = false;
        chatAccountList.clear();
      }
      if (!refresh &&
          (!hasMoreChatAccounts.value || isLoadingMoreChatAccounts.value)) {
        return;
      }
      if (refresh) {
        if (fromSearch) {
          isSearchingChatAccounts.value = true;
        } else {
          isLoadingChatAccounts.value = true;
        }
      } else {
        isLoadingMoreChatAccounts.value = true;
      }

      final startIndex = (chatAccountPage - 1) * pageSize + 1;
      final toIndex = chatAccountPage * pageSize;

      final chats = await chatRepository.getChatAccountList(
        startIndex: startIndex,
        toIndex: toIndex,
        searchText: query.isNotEmpty ? query : null,
      );

      if (isSearchRequest && seq != _chatAccountSearchSeq) return;

      if (refresh) {
        chatAccountList.assignAll(chats);
      } else {
        chatAccountList.addAll(chats);
      }

      hasMoreChatAccounts.value = chats.length == pageSize;
      if (hasMoreChatAccounts.value) chatAccountPage++;
    } catch (e) {
      if (isSearchRequest && seq != _chatAccountSearchSeq) return;
      Get.snackbar('خطا', 'خطا در بارگذاری لیست چت ‌اکانت ها: $e');
    } finally {
      if (!isSearchRequest || seq == _chatAccountSearchSeq) {
        isLoadingChatAccounts.value = false;
        isLoadingMoreChatAccounts.value = false;
        isSearchingChatAccounts.value = false;
      }
    }
  }

  // ─── Load chat list ───
  Future<void> loadChatList(String accountId, {bool refresh = false}) async {
    try {
      if (refresh) {
        chatPage = 1;
        hasMoreChats.value = true;
        chatList.clear();
      }
      if (!hasMoreChats.value || isLoadingMoreChats.value) return;
      if (refresh) {
        isLoadingChats.value = true;
      } else {
        isLoadingMoreChats.value = true;
      }

      final startIndex = (chatPage - 1) * pageSize + 1;
      final toIndex = chatPage * pageSize;

      final topicCode = chatListTopicFilter.value?.code?.trim();
      final search = searchText.value.trim();
      final chats = await chatRepository.getChatList(
        accountId,
        startIndex: startIndex,
        toIndex: toIndex,
        chatStatus: null,
        topicCode: topicCode != null && topicCode.isNotEmpty ? topicCode : null,
        searchText: search.isNotEmpty ? search : null,
      );

      if (refresh) {
        chatList.assignAll(chats);
      } else {
        chatList.addAll(chats);
      }

      hasMoreChats.value = chats.length == pageSize;
      if (hasMoreChats.value) chatPage++;
    } catch (e) {
      Get.snackbar('خطا', 'خطا در بارگذاری لیست چت ها: $e');
    } finally {
      isLoadingChats.value = false;
      isLoadingMoreChats.value = false;
    }
  }

  // ─── Load account list ───
  Future<void> loadAccountList() async {
    try {
      isLoadingAccounts.value = true;
      final accounts = await accountRepository.getAccountList('');
      accountList.assignAll(accounts);
      filteredAccountList.assignAll(accounts);
    } catch (e) {
      Get.snackbar('خطا', 'خطا در بارگذاری لیست کاربران: $e');
    } finally {
      isLoadingAccounts.value = false;
    }
  }

  // ─── Chat list topic filter ───
  Future<void> setChatListTopicFilter(TopicModel? topic) async {
    chatListTopicFilter.value = topic;
    final accountId = selectedChatAccount.value?.accountId?.toString();
    if (accountId == null || accountId.isEmpty || selectedChat.value != null) {
      return;
    }
    await loadChatList(accountId, refresh: true);
  }

  List<TopicModel> get sortedTopicList {
    final copy = List<TopicModel>.from(topicList);
    copy.sort((a, b) {
      final ao = a.sortOrder ?? 0;
      final bo = b.sortOrder ?? 0;
      if (ao != bo) return ao.compareTo(bo);
      return (a.title ?? '').compareTo(b.title ?? '');
    });
    return copy;
  }

  // ─── Load topics ───
  Future<void> loadTopics() async {
    try {
      isLoadingTopics.value = true;
      final topics = await chatRepository.getTopics();
      topicList.assignAll(topics);
    } catch (e) {
      Get.snackbar('خطا', 'خطا در بارگذاری موضوعات: $e');
    } finally {
      isLoadingTopics.value = false;
    }
  }

  void toggleMessageSearch() {
    if (isMessageSearchExpanded.value) {
      collapseMessageSearch();
      return;
    }
    isMessageSearchExpanded.value = true;
  }

  void collapseMessageSearch({bool clearQuery = false}) {
    isMessageSearchExpanded.value = false;
    if (clearQuery) {
      _resetMessageSearchQuery(reload: true);
    }
  }

  void _resetMessageSearchQuery({bool reload = false}) {
    _messageSearchDebounce?.cancel();
    messagesSearchController.clear();
    final hadQuery = activeMessageSearchQuery.value.trim().isNotEmpty;
    activeMessageSearchQuery.value = '';
    if (reload && hadQuery) {
      final chatId = selectedChat.value?.chatId?.toString();
      if (chatId != null && chatId.isNotEmpty) {
        loadChatMessages(chatId, refresh: true);
      }
    }
  }

  void clearMessageSearchAndReload() {
    _resetMessageSearchQuery(reload: true);
  }

  void _clearMessageSearchState({bool collapse = true}) {
    _messageSearchDebounce?.cancel();
    messagesSearchController.clear();
    activeMessageSearchQuery.value = '';
    if (collapse) {
      isMessageSearchExpanded.value = false;
    }
  }

  void _seedConversationSearchFromGlobal() {
    final global = searchText.value.trim();
    if (global.isEmpty) return;
    activeMessageSearchQuery.value = global;
    messagesSearchController.text = global;
    messagesSearchController.selection =
        TextSelection.collapsed(offset: global.length);
    isMessageSearchExpanded.value = true;
  }

  void onMessagesSearchChanged(String value) {
    _messageSearchDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      if (activeMessageSearchQuery.value.isNotEmpty) {
        _resetMessageSearchQuery(reload: true);
      }
      return;
    }
    _messageSearchDebounce = Timer(_messageSearchDebounceDelay, () {
      submitMessageSearch(messagesSearchController.text);
    });
  }

  void submitMessageSearch(String value) {
    _messageSearchDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _resetMessageSearchQuery(reload: true);
      return;
    }
    if (trimmed == activeMessageSearchQuery.value.trim()) return;
    activeMessageSearchQuery.value = trimmed;
    final chatId = selectedChat.value?.chatId?.toString();
    if (chatId == null || chatId.isEmpty) return;
    loadChatMessages(chatId, refresh: true);
  }

  // ─── Load chat messages ───
  Future<void> loadChatMessages(
      String chatId, {
        bool refresh = false,
        bool searchFallbackRetry = false,
      }) async {
    final searchText = activeMessageSearchQuery.value.trim();
    try {
      if (refresh) {
        messagePage = 1;
        hasMoreMessages.value = true;
        _clearMessageBubbleScrollKeys();
        chatMessages.clear();
      }
      if (!hasMoreMessages.value || isLoadingMoreMessages.value) return;
      if (refresh) {
        isLoadingMessages.value = true;
      } else {
        isLoadingMoreMessages.value = true;
      }

      final startIndex = (messagePage - 1) * pageSize + 1;
      final toIndex = messagePage * pageSize;

      final messages = await chatRepository.getChatMessages(
        chatId,
        startIndex: startIndex,
        toIndex: toIndex,
        textSearch: searchText.isNotEmpty ? searchText : null,
      );

      final enrichedMessages = messages
          .map(
            (m) => enrichForwardSourceForOutbound(m, messages),
      )
          .toList();
      if (refresh) {
        chatMessages.assignAll(enrichedMessages);
      } else {
        chatMessages.addAll(enrichedMessages);
      }

      hasMoreMessages.value = messages.length == pageSize;
      if (hasMoreMessages.value) messagePage++;
    } catch (e) {
      if (searchText.isNotEmpty && !searchFallbackRetry) {
        _messageSearchDebounce?.cancel();
        messagesSearchController.clear();
        activeMessageSearchQuery.value = '';
        ToastService().info('جستجو در دسترس نیست؛ نمایش همه پیام‌ها');
        await loadChatMessages(
          chatId,
          refresh: refresh,
          searchFallbackRetry: true,
        );
        return;
      }
      if (!searchFallbackRetry) {
        Get.snackbar('خطا', 'خطا در بارگذاری پیام‌ها: $e');
      }
    } finally {
      isLoadingMessages.value = false;
      isLoadingMoreMessages.value = false;
      if (refresh && selectedChat.value?.chatId?.toString() == chatId) {
        _scheduleInitialConversationScroll(selectedChat.value!);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(applyInitialConversationScrollIfNeeded());
        });
      }
    }
  }

  // ─── Attachment helpers ─────────────────────────────────────────────────────

  /// Sends a single voice clip immediately (hold-to-record flow).
  Future<void> sendVoiceMessage(Uint8List bytes, String fileName) async {
    if (bytes.isEmpty) return;
    if (isSendingMessage.value || isUploadingAttachments.value) return;

    final ext = chatAttachmentExtensionFromName(fileName);
    if (ext == null || !isChatAttachmentExtensionAllowed(ext)) {
      ToastService().error('فرمت فایل صوتی پشتیبانی نمی‌شود');
      return;
    }

    pendingAttachments.clear();
    pendingAttachments.add(
      ChatPendingAttachment(
        name: fileName,
        sizeBytes: bytes.length,
        //fileType: classifyChatAttachmentFileType(ext),
        fileType: 'audio',
        bytes: bytes,
      ),
    );
    //await sendMessage();
  }

  Future<void> pickImageAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      _addPickedFiles(result.files);
    } catch (e) {
      ToastService().error('خطا در انتخاب تصویر: $e');
    } finally {
      scheduleRefocusMessageComposer();
    }
  }

  Future<void> pickVideoAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      _addPickedFiles(result.files);
    } catch (e) {
      ToastService().error('خطا در انتخاب ویدئو: $e');
    } finally {
      scheduleRefocusMessageComposer();
    }
  }

  Future<void> pickAudioAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      _addPickedFiles(result.files);
    } catch (e) {
      ToastService().error('خطا در انتخاب صدا: $e');
    } finally {
      scheduleRefocusMessageComposer();
    }
  }

  Future<void> pickDocumentAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv',
        ],
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      _addPickedFiles(result.files);
    } catch (e) {
      ToastService().error('خطا در انتخاب سند: $e');
    } finally {
      scheduleRefocusMessageComposer();
    }
  }

  Future<void> pickArchiveAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'rar', '7z', 'tar', 'gz'],
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      _addPickedFiles(result.files);
    } catch (e) {
      ToastService().error('خطا در انتخاب آرشیو: $e');
    } finally {
      scheduleRefocusMessageComposer();
    }
  }

  void _addPickedFiles(List<PlatformFile> files) {
    for (final f in files) {
      final sizeBytes = f.size > 0 ? f.size : (f.bytes?.length ?? 0);
      if (_isDuplicatePendingAttachment(f.name, sizeBytes)) {
        continue;
      }
      final ext = (f.extension ??
          resolveChatAttachmentExtension(fileName: f.name) ??
          chatAttachmentExtensionFromName(f.name) ??
          '')
          .toLowerCase();
      if (!isChatAttachmentExtensionAllowed(ext)) {
        ToastService().error('نوع فایل «${f.name}» پشتیبانی نمی‌شود');
        continue;
      }
      final fileType = classifyChatAttachmentFileType(ext);
      final bytes = f.bytes;
      if (bytes == null || bytes.isEmpty) {
        ToastService().error('خواندن فایل «${f.name}» ناموفق بود');
        continue;
      }
      pendingAttachments.add(ChatPendingAttachment(
        name: f.name,
        sizeBytes: sizeBytes,
        fileType: fileType,
        bytes: bytes,
        path: f.path,
      ));
    }
  }

  bool _isDuplicatePendingAttachment(String name, int sizeBytes) {
    return pendingAttachments.any(
          (attachment) =>
      attachment.name == name && attachment.sizeBytes == sizeBytes,
    );
  }

  /// Handles Ctrl+V in the composer: file/image paste or text fallback.
  Future<void> pasteFromClipboard() async {
    if (isSendingMessage.value || isUploadingAttachments.value) return;

    try {
      final clipboard = await readClipboardForComposer();

      if (clipboard.filePaths.isNotEmpty) {
        final xFiles = clipboard.filePaths.map(XFile.new).toList();
        await addAttachmentsFromDrop(xFiles);
        return;
      }

      final imageBytes = clipboard.imageBytes;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final fileName = clipboardImageFileName(imageBytes);
        _addPickedFiles([
          PlatformFile(
            name: fileName,
            size: imageBytes.length,
            bytes: imageBytes,
          ),
        ]);
        return;
      }

      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      if (text == null || text.isEmpty) return;

      final value = messageController.value;
      final selection = value.selection;
      final start = selection.start >= 0 ? selection.start : value.text.length;
      final end = selection.end >= 0 ? selection.end : value.text.length;
      final nextText = value.text.replaceRange(start, end, text);
      final offset = start + text.length;
      messageController.value = value.copyWith(
        text: nextText,
        selection: TextSelection.collapsed(offset: offset),
        composing: TextRange.empty,
      );
    } catch (e) {
      ToastService().error('خطا در چسباندن از کلیپ‌بورد: $e');
    } finally {
      scheduleRefocusMessageComposer();
    }
  }

  /// Web-only: files extracted from a browser paste event (ClipboardEvent).
  void addWebClipboardPastedFiles(List<ChatWebPastedFile> files) {
    if (files.isEmpty) return;
    if (isSendingMessage.value || isUploadingAttachments.value) return;

    _addPickedFiles(
      files
          .map(
            (file) => PlatformFile(
          name: file.name,
          size: file.bytes.length,
          bytes: file.bytes,
        ),
      )
          .toList(),
    );
    scheduleRefocusMessageComposer();
  }

  Future<void> editPendingImageAttachment(ChatPendingAttachment target) async {
    final index =
    pendingAttachments.indexWhere((attachment) => identical(attachment, target));
    if (index < 0) return;
    await editImageAttachment(index);
  }

  Future<void> editImageAttachment(int index) async {
    if (index < 0 || index >= pendingAttachments.length) return;
    if (isSendingMessage.value || isUploadingAttachments.value) return;

    final attachment = pendingAttachments[index];
    final bytes = attachment.bytes;
    if (attachment.fileType != 'image' || bytes == null || bytes.isEmpty) {
      return;
    }

    try {
      await _openImageEditor(
        imageBytes: bytes,
        onDone: (edited) async => _applyEditedImage(index, edited),
      );
    } catch (_) {
      return;
    }
  }

  Future<void> _openImageEditor({
    required Uint8List imageBytes,
    required Future<void> Function(Uint8List edited) onDone,
  }) async {
    messageFocusNode.unfocus();

    try {
      final overlayContext = Get.overlayContext;
      if (overlayContext != null) {
        await Navigator.of(overlayContext, rootNavigator: true).push<void>(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => ChatImageEditorScreen(
              imageBytes: imageBytes,
              onDone: onDone,
            ),
          ),
        );
      } else {
        await Get.to(
              () => ChatImageEditorScreen(
            imageBytes: imageBytes,
            onDone: onDone,
          ),
          fullscreenDialog: true,
          preventDuplicates: false,
        );
      }
    } catch (e, s) {
      AppLogger.e('_openImageEditor failed', e, s);
      ToastService().error('باز کردن ویرایشگر تصویر ناموفق بود');
      rethrow;
    }
    scheduleRefocusMessageComposer();
  }

  void _applyEditedImage(int index, Uint8List edited) {
    if (index < 0 || index >= pendingAttachments.length) return;
    if (edited.isEmpty) return;

    final old = pendingAttachments[index];
    pendingAttachments[index] = ChatPendingAttachment(
      name: _editedImageFileName(old.name),
      sizeBytes: edited.length,
      fileType: 'image',
      bytes: edited,
      path: null,
    );
    pendingAttachments.refresh();
  }

  String _editedImageFileName(String originalName) {
    final trimmed = originalName.trim();
    final dot = trimmed.lastIndexOf('.');
    final base = dot > 0 ? trimmed.substring(0, dot) : trimmed;
    return '${base.isEmpty ? 'image' : base}.jpg';
  }

  /// Adds files dropped onto the composer (desktop / web). Same pipeline as menu pickers.
  Future<void> addAttachmentsFromDrop(List<XFile> droppedFiles) async {
    if (droppedFiles.isEmpty) return;
    try {
      final platformFiles = <PlatformFile>[];
      for (final file in droppedFiles) {
        final name = resolveDroppedAttachmentFileName(file);
        if (!isDroppedChatAttachmentAllowed(file)) {
          ToastService().error('نوع فایل «$name» پشتیبانی نمی‌شود');
          continue;
        }
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          ToastService().error('فایل «$name» خالی است');
          continue;
        }
        platformFiles.add(
          PlatformFile(
            name: name,
            size: bytes.length,
            bytes: bytes,
            path: file.path,
          ),
        );
      }
      if (platformFiles.isNotEmpty) {
        _addPickedFiles(platformFiles);
      }
    } catch (e) {
      ToastService().error('خطا در افزودن فایل: $e');
    } finally {
      scheduleRefocusMessageComposer();
    }
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < pendingAttachments.length) {
      pendingAttachments.removeAt(index);
    }
  }

  void clearAttachments() {
    pendingAttachments.clear();
    isUploadingAttachments.value = false;
  }

  /// Uploads a single attachment via the dedicated chat endpoint and sets
  /// its [ChatPendingAttachment.recordId].  Returns true on success.
  Future<bool> _uploadAttachment(ChatPendingAttachment attachment) async {
    try {
      attachment.recordId = uuid.v4();
      attachment.failed.value = false;
      attachment.progress.value = 0.1;

      final bytes = attachment.bytes;
      if (bytes == null) {
        throw Exception('داده‌های فایل در دسترس نیست');
      }

      attachment.progress.value = 0.4;

      final ext = chatAttachmentExtensionFromName(attachment.name);
      await _chatAttachmentRepo.uploadChatAttachment(
        bytes: bytes,
        fileName: attachment.name,
        recordId: attachment.recordId!,
        mimeType: ext != null
            ? chatVoiceRecordingUploadMimeType(ext)
            : null,
      );

      _chatAttachmentBytesCache[attachment.recordId!] = bytes;
      attachment.progress.value = 1.0;
      return true;
    } catch (e) {
      attachment.failed.value = true;
      attachment.progress.value = 0;
      return false;
    }
  }

  // ─── Send message ─── (MODIFIED)
  Future<void> sendMessage() async {
    final hasAttachments = pendingAttachments.isNotEmpty;
    final hasText = messageController.text.trim().isNotEmpty;

    final forwardSource = pendingForwardMessage.value != null
        ? enrichForwardSourceForOutbound(
      pendingForwardMessage.value!,
      chatMessages.toList(),
    )
        : null;
    final hasForward = forwardSource != null;
    if (!hasText && !hasAttachments && replyToMessage.value == null && !hasForward) {
      return;
    }

    if (selectedAccount.value == null && selectedChatAccount.value == null) {
      Get.snackbar('خطا', 'کاربر انتخاب نشده است');
      return;
    }

    if (selectedTopic.value == null) {
      Get.snackbar('خطا', 'لطفا ابتدا موضوع گفتگو را انتخاب کنید');
      return;
    }

    try {
      isSendingMessage.value = true;
      final customerAccountId =
          selectedAccount.value?.id ?? selectedChatAccount.value?.accountId;
      if (customerAccountId == null) {
        Get.snackbar('خطا', 'شناسه کاربر نامعتبر است');
        return;
      }

      // ─── Upload pending attachments first ───
      String? filesJsonStr;
      if (pendingAttachments.isNotEmpty) {
        isUploadingAttachments.value = true;
        bool anyFailed = false;
        for (final attachment in pendingAttachments) {
          final ok = await _uploadAttachment(attachment);
          if (!ok) anyFailed = true;
        }
        if (anyFailed) {
          ToastService().error('آپلود برخی فایل‌ها ناموفق بود. فایل‌های قرمز را حذف کرده و دوباره تلاش کنید.');
          isUploadingAttachments.value = false;
          isSendingMessage.value = false;
          return;
        }
        isUploadingAttachments.value = false;

        // Cache each attachment by its recordId for in-bubble rendering.
        for (final a in pendingAttachments) {
          if (a.recordId != null) {
            _sentAttachmentsCache[a.recordId!] = a;
            _attachmentFileNameByRecordId[a.recordId!] = a.name;
          }
        }

        // Build the JSON-encoded string that the server expects.
        final fileEntries = <Map<String, dynamic>>[];
        for (final a in pendingAttachments) {
          final entry = <String, dynamic>{
            'recordId': a.recordId,
            'fileType': a.fileType,
            'fileName': a.name,
          };
          if (a.fileType == 'image') {
            final bytes = a.bytes;
            if (bytes != null && bytes.isNotEmpty) {
              final dims = await decodeChatImagePixelSizeFromBytes(bytes);
              if (dims != null) {
                entry['size'] = formatChatImageSizeField(
                  dims.width,
                  dims.height,
                );
              }
            }
          }
          fileEntries.add(entry);
        }
        filesJsonStr = jsonEncode(fileEntries);
      }

      // Conservative assumptions:
      // - `TopicKey` may be null for "new chat" flows; we send null if unknown.
      // - `TopicCode` comes from the selected topic; fallback to selected chat.
      final topicCode = selectedTopic.value?.code ?? selectedChat.value?.topicCode;
      final topicKey = selectedChat.value?.topicKey;
      reqId.value = uuid.v4();
      _pendingAdminSendReqIds.add(reqId.value);

      await SocketService.to.ensureConnected(clientId: currentUserId);

      final messageText = messageController.text.trim();
      final outboundBody = resolveForwardAdminSendPayload(
        userCaption: messageText,
        userFilesJson: filesJsonStr,
        forwardSource: forwardSource,
      );
      final mentionPool = <ChatMentionCandidatesModel>[
        ...selectedMentions,
        ...mentionCandidates,
      ];
      final outboundMentions = messageText.isEmpty
          ? <MessageMention>[]
          : buildOutboundMentions(messageText, mentionPool);
      if (hasForward &&
          outboundBody.text == null &&
          !forwardSnapshotHasBody(outboundBody.forwardSnapshot)) {
        ToastService().error('محتوای پیام بازنشرشده یافت نشد');
        isSendingMessage.value = false;
        return;
      }
      if (forwardSource != null) {
        _outboundForwardSourceByReqId[reqId.value] = forwardSource;
      }

      final forwardRef = forwardSource != null
          ? resolveForwardOutboundReference(forwardSource)
          : null;

      final payload = admin_send.SocketChatAdminSendModel(
        channel: 'chat.admin.send',
        reqId: reqId.value,
        sessionId: SecureSessionStorage.instance.read('x-session-id')?.toString(),
        data: admin_send.Data(
          customerAccountId: customerAccountId,
          topicCode: topicCode,
          topicKey: topicKey,
          text: outboundBody.text,
          dataJson: null,
          filesJson: outboundBody.forwardSnapshot != null
              ? null
              : outboundBody.filesJson,
          replyToMessageGuid: replyToMessage.value?.messageGuid,
          forwardFromMessageGuid: forwardRef?.messageGuid,
          forwardFromSenderName: _forwardSenderName(forwardSource),
          forwardMessage: outboundBody.forwardSnapshot,
          referenceType: null,
          referenceId: null,
          mentions: outboundMentions.isEmpty ? null : outboundMentions,
        ),
      );

      final localNow = DateTime.now();
      final persistedChatId = selectedChat.value?.chatId?.toString();
      final bool draftNewThread =
          persistedChatId == null && selectedTopic.value != null;
      final optimisticChatId = draftNewThread
          ? kOptimisticNewChatPlaceholderChatId
          : persistedChatId;

      if (optimisticChatId != null) {
        final localMessage = ChatMessageModel(
          rowNum: null,
          chatId: optimisticChatId,
          messageGuid: reqId.value,
          replyToMessageGuid: replyToMessage.value?.messageGuid,
          replyMessage: replyToMessage.value?.toReplyMessageSnapshot(),
          forwardFromMessageGuid: forwardRef?.messageGuid,
          forwardFromSenderName: _forwardSenderName(forwardSource),
          forwardMessage: outboundBody.forwardSnapshot ??
              forwardRef?.body,
          seq: null,
          senderType: 1,
          senderAccountId: int.tryParse(currentUserId),
          senderUserId: int.tryParse(currentUserId),
          messageType: 0,
          text: messageText.isEmpty ? null : messageText,
          createdOnUtc: localNow,
          isDeleted: false,
          deliveredOnUtc: null,
          seenOnUtc: null,
          seen: false,
          senderAccountName: currentUserName,
          replyToSeq: replyToMessage.value?.seq,
          forwardFromSeq: forwardRef?.seq,
          filesJson: hasForward ? null : filesJsonStr,
          mentions: outboundMentions.isEmpty ? null : outboundMentions,
        );
        chatMessages.insert(0, localMessage);
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToLatest());
        if (persistedChatId != null) {
          _applyRealtimeListUpdates(
            chatId: persistedChatId,
            messageText: localMessage.text,
            messageTime: localNow,
            incrementUnread: false,
            incrementUnreadMention: false,
            customerAccountId: customerAccountId,
          );
        }
      }

      SocketService.to.send(payload.toJson());

      messageController.clear();
      replyToMessage.value = null;
      pendingForwardMessage.value = null;
      pendingAttachments.clear();
      closeMentionPopup(clearSuggestions: true);
      selectedMentions.clear();
      if (selectedAccount.value != null && selectedChatAccount.value == null) {
        await addNewChatAccount(selectedAccount.value!);
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطا در ارسال پیام: $e');
    } finally {
      isSendingMessage.value = false;
      isUploadingAttachments.value = false;
    }
  }

  /// Sends a bundled sticker image immediately without touching composer state
  /// (draft text, reply, forward, or pending attachments).
  ///
  /// Returns `true` when the sticker was uploaded and dispatched successfully.
  Future<bool> sendSticker(String assetPath) async {
    if (isSendingSticker.value) return false;

    if (selectedAccount.value == null && selectedChatAccount.value == null) {
      Get.snackbar('خطا', 'کاربر انتخاب نشده است');
      return false;
    }

    if (selectedTopic.value == null) {
      Get.snackbar('خطا', 'لطفا ابتدا موضوع گفتگو را انتخاب کنید');
      return false;
    }

    try {
      isSendingSticker.value = true;
      final customerAccountId =
          selectedAccount.value?.id ?? selectedChatAccount.value?.accountId;
      if (customerAccountId == null) {
        Get.snackbar('خطا', 'شناسه کاربر نامعتبر است');
        return false;
      }

      final prepared = await _stickerSendService.prepareAndUpload(assetPath);

      _chatAttachmentBytesCache[prepared.recordId] = prepared.bytes;
      _attachmentFileNameByRecordId[prepared.recordId] = prepared.fileName;
      final cachedAttachment = ChatPendingAttachment(
        name: prepared.fileName,
        sizeBytes: prepared.bytes.length,
        fileType: 'image',
        bytes: prepared.bytes,
      );
      cachedAttachment.recordId = prepared.recordId;
      _sentAttachmentsCache[prepared.recordId] = cachedAttachment;

      await SocketService.to.ensureConnected(clientId: currentUserId);

      final topicCode =
          selectedTopic.value?.code ?? selectedChat.value?.topicCode;
      final topicKey = selectedChat.value?.topicKey;
      // Match [sendMessage]: correlate optimistic row with socket `chat.message`.
      reqId.value = prepared.reqId;
      _pendingAdminSendReqIds.add(reqId.value);

      final payload = admin_send.SocketChatAdminSendModel(
        channel: 'chat.admin.send',
        reqId: reqId.value,
        sessionId: SecureSessionStorage.instance.read('x-session-id')?.toString(),
        data: admin_send.Data(
          customerAccountId: customerAccountId,
          topicCode: topicCode,
          topicKey: topicKey,
          text: null,
          dataJson: null,
          filesJson: prepared.filesJson,
          replyToMessageGuid: null,
          forwardFromMessageGuid: null,
          forwardFromSenderName: null,
          forwardMessage: null,
          referenceType: null,
          referenceId: null,
          mentions: null,
        ),
      );

      final localNow = DateTime.now();
      final persistedChatId = selectedChat.value?.chatId?.toString();
      final draftNewThread =
          persistedChatId == null && selectedTopic.value != null;
      final optimisticChatId = draftNewThread
          ? kOptimisticNewChatPlaceholderChatId
          : persistedChatId;

      if (optimisticChatId != null) {
        final localMessage = ChatMessageModel(
          rowNum: null,
          chatId: optimisticChatId,
          messageGuid: reqId.value,
          replyToMessageGuid: null,
          replyMessage: null,
          forwardFromMessageGuid: null,
          forwardFromSenderName: null,
          forwardMessage: null,
          seq: null,
          senderType: 1,
          senderAccountId: int.tryParse(currentUserId),
          senderUserId: int.tryParse(currentUserId),
          messageType: 0,
          text: null,
          createdOnUtc: localNow,
          isDeleted: false,
          deliveredOnUtc: null,
          seenOnUtc: null,
          seen: false,
          senderAccountName: currentUserName,
          replyToSeq: null,
          forwardFromSeq: null,
          filesJson: prepared.filesJson,
          mentions: null,
        );
        chatMessages.insert(0, localMessage);
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToLatest());
        if (persistedChatId != null) {
          _applyRealtimeListUpdates(
            chatId: persistedChatId,
            messageText: localMessage.text,
            messageTime: localNow,
            incrementUnread: false,
            incrementUnreadMention: false,
            customerAccountId: customerAccountId,
          );
        }
      }

      SocketService.to.send(payload.toJson());

      if (selectedAccount.value != null && selectedChatAccount.value == null) {
        await addNewChatAccount(selectedAccount.value!);
      }
      return true;
    } catch (e, s) {
      AppLogger.e('sendSticker failed', e, s);
      ToastService().error('خطا در ارسال استیکر');
      return false;
    } finally {
      isSendingSticker.value = false;
    }
  }

  // ─── Select chat account → loads CHAT LIST ─── (MODIFIED)
  void selectChatUserForExistingChat(ChatAccountModel chatAccount) {
    _clearCustomerTyping();
    // پاک‌سازی وضعیت قبلی
    chatMessages.clear();
    _clearMessageBubbleScrollKeys();
    chatList.clear();
    selectedChat.value = null;
    selectedTopic.value = null;
    chatListTopicFilter.value = null;
    replyToMessage.value = null;
    messageController.clear();

    selectedChatAccount.value = chatAccount;

    final account = findAccountById(chatAccount.accountId ?? 0);
    if (account != null) {
      selectedAccount.value = account;
    }

    // ← MODIFIED: بارگذاری لیست چت به جای پیام‌ها
    loadChatList(chatAccount.accountId.toString(), refresh: true);
    loadTopics();
    cancelForward();
  }

  // ─── Select a specific chat → loads MESSAGES ─── (NEW)
  void selectChat(ChatModel chat) {
    unawaited(openChatConversation(chat));
  }

  /// Loads messages, opens [ConversationPanel], and anchors to last-read when unread.
  Future<void> openChatConversation(ChatModel chat) async {
    final chatId = chat.chatId?.toString().trim();
    if (chatId == null || chatId.isEmpty) return;

    _prepareConversationState(chat);
    selectedChat.value = chat;
    _seedConversationSearchFromGlobal();
    await loadChatMessages(chatId, refresh: true);
    unawaited(fetchMentionCandidates(force: true));
    unawaited(loadUnreadMentions());
  }

  // ─── بازگشت از پیام‌ها به لیست چت‌ها ─── (NEW)
  void goBackToChatList() {
    _clearCustomerTyping();
    _clearMessageSearchState();
    _clearMentionState();
    selectedChat.value = null;
    selectedTopic.value = null;
    replyToMessage.value = null;
    pendingForwardMessage.value = null;
    chatMessages.clear();
    _clearMessageBubbleScrollKeys();
    messageController.clear();
    pendingNewMessages.value = 0;
    conversationUnreadCount.value = 0;
    isNearBottom.value = true;
    isAnchoringInitialScroll.value = false;
    _adminMarkedSeenSeq = 0;
    _conversationUnreadAnchorSeq = 0;
    _seenScrollDebounce?.cancel();
    _pendingConversationAnchorSeq = null;
    _initialScrollAppliedChatId = null;
    _initialScrollRetryCount = 0;
    _suppressScrollSeenSync = false;
    messagePage = 1;
    hasMoreMessages.value = true;
    final accountId = selectedChatAccount.value?.accountId?.toString();
    if (accountId != null &&
        accountId.isNotEmpty &&
        chatList.isEmpty) {
      Future.microtask(() => _reconcileEmptyChatListAfterBack(accountId));
    }
  }

  /// After pick, [chatList] can be empty on the Unpicked tab while [selectedChatAccount]
  /// stays set — back would show a misleading empty state. Reload; if still empty, exit drill-down.
  Future<void> _reconcileEmptyChatListAfterBack(String accountId) async {
    try {
      await loadChatList(accountId, refresh: true);
    } catch (_) {}
    if (chatList.isNotEmpty) return;

    selectedChatAccount.value = null;
    selectedAccount.value = null;
    chatList.clear();
    try {
      await loadChatAccountList(refresh: true);
    } catch (_) {}
  }

  // ─── Select account for new chat ───
  void selectAccount(AccountModel account) {
    _clearCustomerTyping();
    chatMessages.clear();
    _clearMessageBubbleScrollKeys();
    chatList.clear();
    selectedChatAccount.value = null;
    selectedChat.value = null;    // ← NEW
    selectedAccount.value = account;
    loadTopics();
  }

  // ─── Select topic ─── (MODIFIED)
  void selectTopic(TopicModel topic) {
    _clearCustomerTyping();
    if (selectedChatAccount.value != null && selectedChat.value == null) {
      final existing = _findOpenChatMatchingTopicInList(topic);
      if (existing != null) {
        selectChat(existing);
        selectedTopic.value = topic;
        return;
      }
    }
    selectedTopic.value = topic;
    // فقط اگر چت انتخاب شده باشد پیام‌ها را بارگذاری کن
    if (selectedChat.value != null) {
      loadChatMessages(selectedChat.value!.chatId.toString(), refresh: true);
    }
  }

  /// Active thread: not closed (1), not unpicked (3), not viewer-only (adminRole 2).
  ChatModel? _findOpenChatMatchingTopicInList(TopicModel topic) {
    final code = topic.code?.trim();
    final title = topic.title?.trim();
    return chatList.firstWhereOrNull((c) {
      if (c.status == 1 || c.status == 3 || c.adminRole == 2) {
        return false;
      }
      if (code != null && code.isNotEmpty) {
        return c.topicCode?.trim() == code;
      }
      if (title != null && title.isNotEmpty) {
        return c.topicTitle?.trim() == title;
      }
      return false;
    });
  }

  // ─── Filter accounts ───
  void filterAccounts(String query) {
    if (query.isEmpty) {
      filteredAccountList.assignAll(accountList);
    } else {
      final filtered = accountList
          .where((account) =>
      account.name?.toLowerCase().contains(query.toLowerCase()) ??
          false)
          .toList();
      filteredAccountList.assignAll(filtered);
    }
  }

  // ─── Clear selections ─── (MODIFIED)
  void clearSelections({bool clearPendingForward = true}) {
    _clearCustomerTyping();
    _clearMessageSearchState();
    _clearMentionState();
    selectedChatAccount.value = null;
    selectedAccount.value = null;
    selectedChat.value = null;     // ← NEW
    selectedTopic.value = null;
    chatListTopicFilter.value = null;
    replyToMessage.value = null;
    if (clearPendingForward) {
      pendingForwardMessage.value = null;
    }
    chatMessages.clear();
    _clearMessageBubbleScrollKeys();
    chatList.clear();              // ← NEW
    messageController.clear();
    clearAttachments();
    _chatAttachmentBytesCache.clear();
    _attachmentRecordIdAliases.clear();
    _pendingAdminSendReqIds.clear();
    _outboundForwardSourceByReqId.clear();
    pendingNewMessages.value = 0;
    conversationUnreadCount.value = 0;
    isAnchoringInitialScroll.value = false;
    _adminMarkedSeenSeq = 0;
    _conversationUnreadAnchorSeq = 0;
    _seenScrollDebounce?.cancel();
    _pendingConversationAnchorSeq = null;
    _initialScrollAppliedChatId = null;
    _initialScrollRetryCount = 0;
    _suppressScrollSeenSync = false;
  }

  bool isAccountInChatList(int accountId) {
    return chatAccountList.any((ca) => ca.accountId == accountId);
  }

  AccountModel? findAccountById(int accountId) {
    try {
      return accountList.firstWhere((account) => account.id == accountId);
    } catch (e) {
      return null;
    }
  }

  Future<void> addNewChatAccount(AccountModel account) async {
    try {
      if (!isAccountInChatList(account.id ?? 0)) {
        final newChatAccount = ChatAccountModel(
          accountId: account.id,
          accountName: account.name,
          adminChatRole: 1,
          lastChatId: null,
          lastMessageOn: null,
          lastMessagePreview: null,
          rowNum: null,
          totalMessageCount: null,
          unreadMessageCount: null,
          chatStatus: null,
          unreadChatCount: null,
          hasUnreadMention: null,
        );
        chatAccountList.insert(0, newChatAccount);
        selectedChatAccount.value = newChatAccount;
      }
    } catch (e , s) {
      AppLogger.e('Error adding new chat user: ', e, s);
    }
  }

  // ─── Reset ─── (MODIFIED)
  void resetChatState() {
    clearSelections(); // also calls clearAttachments()
    isLoadingChatAccounts.value = false;
    isLoadingChats.value = false;   // ← NEW
    isLoadingMessages.value = false;
    isLoadingAccounts.value = false;
    isLoadingTopics.value = false;
    isSendingMessage.value = false;
    isSendingSticker.value = false;
  }
  /// Parent row in [chatMessages] for tap-to-scroll, resolved from [ChatMessageModel.replyMessage].
  ChatMessageModel? findReplyTargetMessage(ChatMessageModel reply) =>
      findReplyParentInList(chatMessages, reply);

  /// Jumps to the oldest unread mention, highlights it, then consumes it from the list.
  Future<void> jumpToNextMention() async {
    if (unreadMentions.isEmpty || _isJumpingToMention) return;

    final chatId = selectedChat.value?.chatId?.toString().trim();
    if (chatId == null || chatId.isEmpty) return;

    final targetMention = unreadMentions.first;
    final seq = targetMention.seq;
    if (seq == null || seq <= 0) {
      unreadMentions.removeAt(0);
      return;
    }

    _isJumpingToMention = true;
    try {
      await _ensureAnchorMessageLoaded(chatId, seq);
      final msg = _messageForSeq(seq);
      if (msg == null) {
        ToastService().info('پیام منشن یافت نشد');
        return;
      }

      if (!messagesScrollController.hasClients) return;

      _suppressMessagePagination = true;
      try {
        await _bringMessageIntoView(msg);
        _highlightReplyParent(msg);
      } finally {
        _suppressMessagePagination = false;
      }

      unreadMentions.removeWhere((m) => m.seq == seq);
    } finally {
      _isJumpingToMention = false;
    }
  }

  /// Scrolls the reversed message list to the parent of [reply] and highlights it.
  Future<void> scrollToReplyParent(ChatMessageModel reply) async {

    final embedded = reply.replyMessage;
    if (embedded == null) return;

    final chatId = selectedChat.value?.chatId?.toString().trim();
    if (chatId == null || chatId.isEmpty) return;

    final parentSeq = embedded.seq;
    if (parentSeq != null) {
      await _ensureAnchorMessageLoaded(chatId, parentSeq);
    } else {
      for (var i = 0; i < 8 && hasMoreMessages.value; i++) {
        if (findReplyTargetMessage(reply) != null) break;
        final before = chatMessages.length;
        await loadChatMessages(chatId);
        if (chatMessages.length <= before) break;
      }
    }
    final target = findReplyTargetMessage(reply);
    if (target == null) {
      ToastService().info('پیام اصلی یافت نشد');
      return;
    }

    if (!messagesScrollController.hasClients) return;

    _suppressMessagePagination = true;
    try {
      await _bringMessageIntoView(target);
      _highlightReplyParent(target);
    } finally {
      _suppressMessagePagination = false;
    }
  }

  void setReplyMessage(ChatMessageModel message) {
    pendingForwardMessage.value = null;
    replyToMessage.value = message;
  }

  void cancelReply() {
    replyToMessage.value = null;
  }

  void beginForwardMessage(ChatMessageModel message) {
    if (message.isDeleted == true) return;
    replyToMessage.value = null;
    pendingForwardMessage.value = enrichForwardSourceForOutbound(
      message,
      chatMessages.toList(),
    );
  }

  void cancelForward() {
    pendingForwardMessage.value = null;
  }

  String? _forwardSenderName(ChatMessageModel? message) {
    if (message == null) return null;
    return forwardOutboundSenderName(
      message,
      currentUserNameFallback: currentUserName,
    );
  }

  String getCurrentConversationId() {
    final currentUser = currentUserId;
    final otherUser = selectedAccount.value?.id?.toString() ??
        selectedChatAccount.value?.accountId?.toString() ??
        'unknown';
    return "$currentUser-$otherUser";
  }

  // ─── Pagination: chat accounts ─── (RENAMED)
  Future<void> loadMoreChatAccounts() async {
    if (isSearchingChatAccounts.value || isLoadingChatAccounts.value) return;
    if (hasMoreChatAccounts.value && !isLoadingMoreChatAccounts.value) {
      await loadChatAccountList();
    }
  }

  // ─── Pagination: chat items ─── (NEW)
  Future<void> loadMoreChatItems() async {
    if (hasMoreChats.value &&
        !isLoadingMoreChats.value &&
        selectedChatAccount.value != null) {
      await loadChatList(selectedChatAccount.value!.accountId.toString());
    }
  }

  // ─── Pagination: messages ─── (MODIFIED - بدون پارامتر)
  Future<void> loadMoreMessages() async {
    if (_suppressMessagePagination) return;
    if (hasMoreMessages.value &&
        !isLoadingMoreMessages.value &&
        selectedChat.value != null) {
      await loadChatMessages(selectedChat.value!.chatId.toString());
    }
  }

  Future<bool> ensureTopicSelected() async {
    if (selectedTopic.value != null) return true;

    if (selectedAccount.value != null) {
      await loadTopics();
      if (topicList.isNotEmpty && selectedTopic.value == null) {
        Get.snackbar(
          'انتخاب موضوع',
          'لطفا موضوع گفتگو را انتخاب کنید.',
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange.withAlpha(200),
        );
        return false;
      }
    }
    return selectedTopic.value != null;
  }
}
