import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hanigold_admin/src/config/const/socket.service.dart';
import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/secure_session_storage.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
import 'package:hanigold_admin/src/domain/chat/model/socket_chat_message.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/socket_chat_unread_total.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/socket_chat_unread_mention_total.model.dart';
import 'package:hanigold_admin/src/domain/chat/utils/chat_conversation_unread.dart';
import 'package:uuid/uuid.dart';

import '../../../config/session_bootstrap.dart';


/// Global chat FAB badge state and chat socket fan-out for the chat floating button.
///
/// Listens to [SocketService.messageStream] independently of [HomeController].
class ChatFabController extends GetxController {
  static const _uuid = Uuid();

  /// [GetStorage] key for login / socket-synchronized FAB unread total.
  static const String chatFabUnreadStorageKey = 'totalUnreadMessageCount';

  /// [GetStorage] key for login / socket-synchronized FAB unread-mention total.
  static const String chatFabUnreadMentionStorageKey = 'unreadMentionCount';

  final box = GetStorage();
  StreamSubscription<dynamic>? _socketSubscription;

  /// Global unread count for the chat FAB (`chat.message` or `ack` for unread total).
  final chatFabUnreadCount = 0.obs;

  /// Global unread-mention count for the chat FAB (`chat.message` or `ack` for unreadMention total).
  final chatFabUnreadMentionCount = 0.obs;

  /// Pending `reqId` values for in-flight `chat.admin.unread.total` requests.
  final _pendingUnreadTotalReqIds = <String>{};

  /// Pending `reqId` values for in-flight `chat.unread.mentions.total` requests.
  final _pendingUnreadMentionTotalReqIds = <String>{};

  Timer? _fabUnreadReconcileTimer;

  /// Test hook: incremented on each [scheduleFabUnreadReconcile] call.
  @visibleForTesting
  int fabUnreadReconcileScheduleCount = 0;

  /// Drives FAB attention animation when [chatFabUnreadCount] > 0.
  final chatFabHighlight = false.obs;

  @override
  void onInit() {
    hydrateChatFabFromStorage();
    _subscribeToSocket();
    super.onInit();
  }

  void _subscribeToSocket() {
    if (!Get.isRegistered<SocketService>()) return;
    _socketSubscription?.cancel();
    _socketSubscription = SocketService.to.messageStream.listen(
          (message) {
        if (message is! String) return;
        try {
          final decoded = json.decode(message);
          if (decoded is Map) {
            handleSocketEnvelope(Map<String, dynamic>.from(decoded));
          }
        } catch (e) {
          Get.log('Error processing socket message in ChatFabController: $e');
        }
      },
      onError: (error) {
        Get.log('Socket stream error in ChatFabController: $error');
      },
    );
  }

  /// Routes chat-related socket envelopes (used by the stream listener and tests).
  void handleSocketEnvelope(Map<String, dynamic> envelope) {
    try {
      final channel = envelope['channel'];
      if (channel == 'chat.message') {
        updateChatFabFromChatMessage(envelope);
        _forwardChatSocketEnvelope(envelope);
      } else if (channel == 'ack') {
        updateChatFabFromSocketAck(envelope);
        _deferChatControllerCall(
              (controller) => controller.handleSocketAckEnvelope(envelope),
        );
      } else if (channel == 'chat.seen') {
        updateChatFabFromSeenBroadcast(envelope);
        _forwardChatSocketEnvelope(envelope);
      } else if (channel is String && channel.startsWith('chat.')) {
        _forwardChatSocketEnvelope(envelope);
      } else if (channel == 'error') {
        _deferChatControllerCall(
              (controller) => controller.handleSocketErrorEnvelope(envelope),
        );
      }
    } catch (e, s) {
      AppLogger.e('handleSocketEnvelope failed', e, s);
    }
  }

  void _deferChatControllerCall(void Function(ChatController controller) action) {
    if (!hasActiveStoredSession()) return;
    registerChatControllerIfNeeded();
    if (!Get.isRegistered<ChatController>()) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<ChatController>()) return;
      try {
        action(Get.find<ChatController>());
      } catch (e, s) {
        AppLogger.e('ChatFabController deferred chat handler failed', e, s);
      }
    });
  }

  /// Tracks [reqId] until the matching `ack` for `chat.admin.unread.total` arrives.
  void registerUnreadTotalRequest(String reqId) {
    final id = reqId.trim();
    if (id.isEmpty) return;
    _pendingUnreadTotalReqIds.add(id);
  }

  /// Tracks [reqId] until the matching `ack` for `chat.unread.mentions.total` arrives.
  void registerUnreadMentionTotalRequest(String reqId) {
    final id = reqId.trim();
    if (id.isEmpty) return;
    _pendingUnreadMentionTotalReqIds.add(id);
  }

  /// Applies FAB badge/highlight and persists [count] for the next session.
  void applyChatFabUnreadCount(int? count) {
    final safeCount = (count ?? 0).clamp(0, 999999);
    chatFabUnreadCount.value = safeCount;
    chatFabHighlight.value = safeCount > 0;
    box.write(chatFabUnreadStorageKey, safeCount);
  }

  /// Applies FAB unreadMention badge and persists [count] for the next session.
  void applyChatFabUnreadMentionCount(int? count) {
    final safeCount = (count ?? 0).clamp(0, 999999);
    chatFabUnreadMentionCount.value = safeCount;
    box.write(chatFabUnreadMentionStorageKey, safeCount);
  }

  /// Restores FAB state after login or app start (before socket `chat.message`).
  void hydrateChatFabFromStorage() {
    final storedUnread = box.read(chatFabUnreadStorageKey);
    if (storedUnread is int) {
      applyChatFabUnreadCount(storedUnread);
    } else if (storedUnread is num) {
      applyChatFabUnreadCount(storedUnread.toInt());
    }

    final storedUnreadMention = box.read(chatFabUnreadMentionStorageKey);
    if (storedUnreadMention is int) {
      applyChatFabUnreadMentionCount(storedUnreadMention);
    } else if (storedUnreadMention is num) {
      applyChatFabUnreadMentionCount(storedUnreadMention.toInt());
    }
  }

  void _forwardChatSocketEnvelope(Map<String, dynamic> envelope) {
    if (!hasActiveStoredSession()) return;
    registerChatControllerIfNeeded();
    if (!Get.isRegistered<ChatController>()) {
      if (kDebugMode) {
        AppLogger.d(
          '[chat.socket] ChatController not registered; '
              'channel=${envelope['channel']}',
        );
      }
      return;
    }
    final payload = Map<String, dynamic>.from(envelope);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<ChatController>()) return;
      try {
        Get.find<ChatController>().handleSocketChatEnvelope(payload);
      } catch (e, s) {
        AppLogger.e('ChatFabController forward chat envelope failed', e, s);
      }
    });
  }

  /// Updates FAB badge/highlight from `chat.message` → [SocketChatMessagePayload.totalUnreadMessageCount].
  void updateChatFabFromChatMessage(Map<String, dynamic> envelope) {
    try {
      final payload = SocketChatMessageModel.fromJson(envelope);
      if (kDebugMode) {
        AppLogger.d(
          '[chat.message] SocketChatMessageModel (sessionId=${payload.sessionId}):\n'
              '${const JsonEncoder.withIndent('  ').convert(payload.toJson())}',
        );
      }
      final totalUnread = payload.data?.message?.totalUnreadMessageCount;
      if (totalUnread != null) {
        applyChatFabUnreadCount(totalUnread);
      }
      final unreadMention = payload.data?.message?.unreadMentionCount;
      if (unreadMention != null) {
        applyChatFabUnreadMentionCount(unreadMention);
      } else if (messageMentionsAccount(
        payload.data?.message?.mentions,
        _currentUserIdFromStorage(),
      )) {
        unawaited(requestChatUnreadMentionTotal());
      }
    } catch (e) {
      Get.log('updateChatFabFromChatMessage: $e');
    }
  }

  /// Updates FAB from self `chat.seen` when [SocketChatSeenBroadcastModel.data.totalUnreadMessageCount] is present.
  void updateChatFabFromSeenBroadcast(Map<String, dynamic> envelope) {
    try {
      final rawData = envelope['data'];
      if (rawData is! Map) return;
      final data = Map<String, dynamic>.from(rawData);
      if (data.isEmpty) return;

      final byUserIdRaw = data['byUserId'];
      final byUserId = byUserIdRaw is int
          ? byUserIdRaw
          : byUserIdRaw is num
          ? byUserIdRaw.toInt()
          : int.tryParse('$byUserIdRaw');
      final myUserId = _currentUserIdFromStorage();
      if (byUserId == null || myUserId == null || byUserId != myUserId) {
        return;
      }

      final totalRaw = data['totalUnreadMessageCount'];
      if (totalRaw != null) {
        final totalUnread = totalRaw is int
            ? totalRaw
            : totalRaw is num
            ? totalRaw.toInt()
            : int.tryParse('$totalRaw');
        if (totalUnread != null) {
          applyChatFabUnreadCount(totalUnread);
          if (totalUnread == 0) {
            applyChatFabUnreadMentionCount(0);
          }
        }
      }

      scheduleFabUnreadReconcile();
    } catch (e, s) {
      AppLogger.e('updateChatFabFromSeenBroadcast failed', e, s);
    }
  }

  int? _currentUserIdFromStorage() {
    final stored = SecureSessionStorage.instance.read('id');
    if (stored is int) return stored;
    if (stored is num) return stored.toInt();
    return int.tryParse('$stored');
  }

  /// Debounced server reconcile for cross-window FAB unread convergence.
  void scheduleFabUnreadReconcile() {
    _fabUnreadReconcileTimer?.cancel();
    fabUnreadReconcileScheduleCount++;
    _fabUnreadReconcileTimer = Timer(const Duration(milliseconds: 300), () {
      unawaited(requestChatUnreadTotal());
      unawaited(requestChatUnreadMentionTotal());
    });
  }

  /// Requests global unread total; server replies on `ack` with matching [reqId].
  Future<void> requestChatUnreadTotal() async {
    if (!Get.isRegistered<SocketService>()) return;
    try {
      final userId = SecureSessionStorage.instance.read('id')?.toString();
      await SocketService.to.ensureConnected(clientId: userId);
      final reqId = _uuid.v4();
      registerUnreadTotalRequest(reqId);
      SocketService.to.send(
        SocketChatUnreadTotalRequest(reqId: reqId).toJson(),
      );
    } catch (e) {
      Get.log('requestChatUnreadTotal (fab): $e');
    }
  }

  /// Requests global unread-mention total; server replies on `ack` with matching [reqId].
  Future<void> requestChatUnreadMentionTotal() async {
    if (!Get.isRegistered<SocketService>()) return;
    try {
      final userId = SecureSessionStorage.instance.read('id')?.toString();
      await SocketService.to.ensureConnected(clientId: userId);
      final reqId = _uuid.v4();
      registerUnreadMentionTotalRequest(reqId);
      SocketService.to.send(
        SocketChatUnreadMentionTotalRequest(reqId: reqId).toJson(),
      );
    } catch (e) {
      Get.log('requestChatUnreadMentionTotal (fab): $e');
    }
  }

  /// Dispatches `ack` envelopes to unread / unreadMention total handlers by [reqId].
  void updateChatFabFromSocketAck(Map<String, dynamic> envelope) {
    updateChatFabFromUnreadTotalAck(envelope);
    updateChatFabFromUnreadMentionTotalAck(envelope);
  }

  /// Updates FAB from `ack` response to `chat.admin.unread.total` → [SocketChatUnreadTotalModel].
  void updateChatFabFromUnreadTotalAck(Map<String, dynamic> envelope) {
    try {
      final reqId = envelope['reqId']?.toString();
      if (reqId == null || !_pendingUnreadTotalReqIds.remove(reqId)) {
        return;
      }
      final payload = SocketChatUnreadTotalModel.fromJson(envelope);
      final totalUnread = payload.data?.totalUnreadMessageCount;
      if (totalUnread == null) return;
      applyChatFabUnreadCount(totalUnread);
    } catch (e) {
      Get.log('updateChatFabFromUnreadTotalAck: $e');
    }
  }

  /// Updates FAB from `ack` response to `chat.unread.mentions.total` → [SocketChatUnreadMentionTotalModel].
  void updateChatFabFromUnreadMentionTotalAck(Map<String, dynamic> envelope) {
    try {
      final reqId = envelope['reqId']?.toString();
      if (reqId == null || !_pendingUnreadMentionTotalReqIds.remove(reqId)) {
        return;
      }
      final payload = SocketChatUnreadMentionTotalModel.fromJson(envelope);
      final unreadMention = payload.data?.totalUnreadMentionCount;
      if (unreadMention == null) return;
      applyChatFabUnreadMentionCount(unreadMention);
    } catch (e) {
      Get.log('updateChatFabFromUnreadMentionTotalAck: $e');
    }
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    _fabUnreadReconcileTimer?.cancel();
    super.onClose();
  }
}
