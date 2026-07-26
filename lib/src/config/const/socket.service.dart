import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../logger/app_logger.dart';
import '../repository/url/web_socket_url.dart';
import '../secure_session_storage.dart';
import '../session_invalidation.dart';
import '../session_storage.dart';
import 'socket_coordinator/socket_coordinator.dart';
import 'socket_session_guard.dart';

/// Whether a transport reconnect should be scheduled (leader tab, not manual disconnect).
bool shouldAttemptReconnect({
  required bool isManualDisconnect,
  required bool isLeader,
  required String? lastUrl,
  bool hasStoredSession = true,
}) {
  if (isManualDisconnect) return false;
  if (!isLeader) return false;
  if (lastUrl == null) return false;
  if (!hasStoredSession) return false;
  return true;
}

// Mixin for views that need socket connection
mixin SocketConnectionMixin {
  Future<void> ensureSocketConnection() async {
    try {
      final socketService = Get.find<SocketService>();
      await socketService.ensureConnected();
    } catch (e, s) {
      AppLogger.e('Error ensuring socket connection', e, s);
    }
  }
}

class SocketService extends GetxService {
  static SocketService get to => Get.find();

  final SocketCoordinator _coordinator = createSocketCoordinator();

  WebSocketChannel? _channel;
  final RxString _connectionStatus = 'disconnected'.obs;
  final RxString _lastError = ''.obs;
  final _messageStream = StreamController<dynamic>.broadcast();
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _connectionTimeoutTimer;
  Timer? _healthCheckTimer;

  // Configuration
  static const int _reconnectDelay = 3; // seconds
  static const int _heartbeatInterval = 30; // seconds
  static const int _connectionTimeout = 10; // seconds
  static const int _healthCheckInterval = 60; // seconds

  int _reconnectAttempts = 0;
  String? _lastUrl;
  String? _clientId;
  String? _sessionId;
  bool _isManualDisconnect = false;
  DateTime? _lastHeartbeatResponse;
  Completer<void>? _connectCompleter;
  Completer<void>? _followerSyncCompleter;
  bool _coordinatorReady = false;
  bool _hasBroadcastConnected = false;
  bool _sessionInvalidationInProgress = false;

  Stream<dynamic> get messageStream => _messageStream.stream;
  String get connectionStatus => _connectionStatus.value;
  String get lastError => _lastError.value;
  bool get isConnected => _connectionStatus.value == 'connected';
  bool get isLeader => _coordinator.isLeader;
  bool get supportsCrossTab => _coordinator.supportsCrossTab;

  // Method to get detailed connection info for debugging
  Map<String, dynamic> get connectionInfo => {
    'status': _connectionStatus.value,
    'lastError': _lastError.value,
    'isConnected': isConnected,
    'isLeader': isLeader,
    'supportsCrossTab': supportsCrossTab,
    'lastUrl': _lastUrl,
    'clientId': _clientId,
    'sessionId': _sessionId,
    'reconnectAttempts': _reconnectAttempts,
    'isManualDisconnect': _isManualDisconnect,
  };

  @override
  void onInit() {
    super.onInit();
    unawaited(_initCoordinator());
  }

  Future<void> _initCoordinator() async {
    if (_coordinatorReady) return;
    await _coordinator.initialize(
      onLeaderAcquired: _onLeaderAcquired,
      onFollowerMessage: _onFollowerMessage,
      onLeaderSendRequest: _onLeaderSendRequest,
      onLeaderReleased: _onLeaderReleased,
      onFollowerConnected: _onFollowerConnected,
      onFollowerDisconnected: _onFollowerDisconnected,
      onLeaderHello: _onLeaderHello,
    );
    _coordinatorReady = true;
  }

  void _onLeaderAcquired() {
    if (_isManualDisconnect) return;
    unawaited(_connectAsLeaderIfNeeded());
  }

  void _onLeaderReleased() {
    _resetFollowerSyncCompleter();
    _closeTransportChannel();
    if (!_isManualDisconnect) {
      _connectionStatus.value = 'disconnected';
    }
  }

  void _onFollowerConnected() {
    if (_isManualDisconnect) return;
    _connectionStatus.value = 'connected';
    _lastError.value = '';
    AppLogger.i('WebSocket: follower tab synced to leader connection');
    _completeFollowerSync();
  }

  void _onFollowerDisconnected() {
    _connectionStatus.value = 'disconnected';
    _resetFollowerSyncCompleter();
    AppLogger.w('WebSocket: leader disconnected (follower tab)');
  }

  void _completeFollowerSync() {
    final completer = _followerSyncCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  void _resetFollowerSyncCompleter() {
    final completer = _followerSyncCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _followerSyncCompleter = null;
  }

  void _onLeaderHello() {
    if (_connectionStatus.value == 'connected') {
      _coordinator.broadcastConnected();
    } else {
      _coordinator.broadcastDisconnected();
    }
  }

  void _onFollowerMessage(dynamic data) {
    _dispatchIncomingMessage(data);
  }

  void _onLeaderSendRequest(dynamic data) {
    _sendOnTransport(data);
  }

  Future<void> _connectAsLeaderIfNeeded() async {
    if (!_coordinator.isLeader || _isManualDisconnect) return;
    if (_connectionStatus.value == 'connected' && _channel != null) return;

    final clientId = _clientId ?? _readStoredClientId();
    final sessionId = _sessionId ?? _readStoredSessionId();
    if (clientId == null || sessionId == null) {
      AppLogger.d('WebSocket: No credentials yet, deferring leader connect');
      return;
    }

    final url = _lastUrl ?? WebSocketUrl.webSocketUrl;

    await connect(
      url,
      clientId: clientId,
      sessionId: sessionId,
    );
  }

  String? _readStoredClientId() {
    return SecureSessionStorage.instance.read('id')?.toString();
  }

  String? _readStoredSessionId() {
    return SecureSessionStorage.instance.read('x-session-id')?.toString();
  }

  // Method to test socket connection
  Future<void> testConnection() async {
    try {
      AppLogger.i('WebSocket: Testing connection...');
      AppLogger.d('WebSocket: Connection info: $connectionInfo');

      if (isConnected) {
        final testMessage = {
          'type': 'test',
          'message': 'Socket connection test from new tab',
          'timestamp': DateTime.now().toIso8601String(),
        };
        send(testMessage);
        AppLogger.d('WebSocket: Test message sent successfully');
      } else {
        AppLogger.w('WebSocket: Not connected, attempting to connect...');
        await ensureConnected();
      }
    } catch (e, s) {
      AppLogger.e('WebSocket: Error testing connection', e, s);
    }
  }

  Future<void> connect(
      String url, {
        String? clientId,
        String? sessionId,
      }) async {
    if (!_coordinator.isLeader) {
      AppLogger.d('WebSocket: Follower tab — skipping transport connect');
      return;
    }

    if (_connectionStatus.value == 'connecting' && _connectCompleter != null) {
      AppLogger.d(
          'WebSocket: Already connecting, awaiting in-flight attempt...');
      return _connectCompleter!.future;
    }

    if (_isManualDisconnect) {
      AppLogger.w(
        'WebSocket: Manual disconnect in progress, skipping connection',
      );
      return;
    }

    if (_connectionStatus.value == 'connected' && _channel != null) {
      AppLogger.d('WebSocket: Already connected');
      return;
    }

    _connectCompleter = Completer<void>();
    try {
      _lastUrl = url;
      _clientId = clientId ?? _clientId;
      _sessionId = sessionId ?? _sessionId;
      _cancelTimers();
      _closeTransportChannel();
      _connectionStatus.value = 'connecting';
      _lastError.value = '';

      AppLogger.i('WebSocket: Attempting to connect to $url');

      _channel = WebSocketChannel.connect(
        Uri.parse(url),
      );

      _connectionTimeoutTimer =
          Timer(Duration(seconds: _connectionTimeout), () {
            if (_connectionStatus.value == 'connecting') {
              AppLogger.w('WebSocket: Connection timeout');
              _handleConnectionError('Connection timeout');
            }
          });

      _channel!.stream.listen(
            (data) {
          _connectionTimeoutTimer?.cancel();
          _handleMessage(data);
        },
        onError: (error) {
          _connectionTimeoutTimer?.cancel();
          if (_shouldInvalidateSession(
            closeCode: _channel?.closeCode,
            closeReason: _channel?.closeReason,
            errorMessage: error.toString(),
          )) {
            unawaited(_handleInvalidSession('Stream error: $error'));
            return;
          }
          _handleConnectionError('Stream error: $error');
        },
        onDone: () {
          _connectionTimeoutTimer?.cancel();
          _handleConnectionClosed();
        },
        cancelOnError: false,
      );

      await _channel!.ready.timeout(
        const Duration(seconds: _connectionTimeout),
      );
      _connectionTimeoutTimer?.cancel();

      if (_isManualDisconnect) return;

      _connectionStatus.value = 'connected';
      _reconnectAttempts = 0;
      _hasBroadcastConnected = false;
      AppLogger.i('WebSocket: Connected successfully');

      if (_clientId != null && _clientId!.isNotEmpty) {
        _sendUserIdentification(_clientId, _sessionId);
        _markConnectedAndBroadcast();
      }

      _startHeartbeat();
      _connectCompleter?.complete();
    } catch (e, s) {
      _connectionTimeoutTimer?.cancel();
      if (_shouldInvalidateSession(
        closeCode: _channel?.closeCode,
        closeReason: _channel?.closeReason,
        errorMessage: e.toString(),
      )) {
        unawaited(_handleInvalidSession('Connection rejected: $e'));
        _connectCompleter?.complete();
        return;
      }
      _handleConnectionError('Connection error: $e');
      AppLogger.e('WebSocket connect failed', e, s);
      _connectCompleter?.complete();
    } finally {
      _connectCompleter = null;
    }
  }

  void _handleMessage(dynamic data) {
    if (_coordinator.isLeader && !_hasBroadcastConnected) {
      _markConnectedAndBroadcast();
    }
    _dispatchIncomingMessage(data);
    if (_coordinator.isLeader) {
      _coordinator.broadcastToFollowers(data);
    }
  }

  void _markConnectedAndBroadcast() {
    if (_hasBroadcastConnected) return;
    _hasBroadcastConnected = true;
    _coordinator.broadcastConnected();
  }

  void _dispatchIncomingMessage(dynamic data) {
    try {
      if (data == null) return;
      if (data is String && data.trim().isEmpty) return;

      if (data is String && data == 'ping') {
        AppLogger.d('WebSocket: Heartbeat received');
        _lastHeartbeatResponse = DateTime.now();
        return;
      }

      if (_isSessionRejected(data)) {
        AppLogger.w('WebSocket: Dropped message — sessionId mismatch');
        return;
      }

      _messageStream.add(data);
    } catch (e, s) {
      AppLogger.e('WebSocket: Error handling message', e, s);
    }
  }

  @visibleForTesting
  void handleIncomingForTest(dynamic data) {
    _dispatchIncomingMessage(data);
  }

  bool _isSessionRejected(dynamic data) {
    try {
      final decoded = data is String ? jsonDecode(data) : data;
      if (decoded is! Map) return false;
      return !SocketSessionGuard.accepts(
        Map<String, dynamic>.from(decoded),
      );
    } catch (e, s) {
      AppLogger.e('WebSocket: Dropped message — invalid JSON payload', e, s);
      return true;
    }
  }

  bool _shouldInvalidateSession({
    int? closeCode,
    String? closeReason,
    String? errorMessage,
  }) {
    return isInvalidSessionSocketClose(
      closeCode: closeCode,
      closeReason: closeReason,
      errorMessage: errorMessage,
    );
  }

  Future<void> _handleInvalidSession(String reason) async {
    if (_isManualDisconnect || _sessionInvalidationInProgress) return;
    _sessionInvalidationInProgress = true;
    try {
      AppLogger.w('WebSocket: invalid session — $reason');
      _isManualDisconnect = true;
      _cancelTimers();
      _connectionStatus.value = 'disconnected';
      _lastError.value = reason;
      _coordinator.broadcastDisconnected();
      _closeTransportChannel();
      await clearSessionAndRedirectToLogin(
        reason: 'WebSocket session rejected',
      );
    } catch (e, s) {
      AppLogger.e('WebSocket: session invalidation failed', e, s);
    } finally {
      _sessionInvalidationInProgress = false;
    }
  }

  void _handleConnectionError(String error) {
    if (_isManualDisconnect) return;

    if (_shouldInvalidateSession(errorMessage: error)) {
      unawaited(_handleInvalidSession(error));
      return;
    }

    _lastError.value = error;
    _connectionStatus.value = 'error';
    AppLogger.e('WebSocket: $error');

    _coordinator.broadcastDisconnected();
    _reconnect();
  }

  void _handleConnectionClosed() {
    if (_isManualDisconnect) return;

    final closeCode = _channel?.closeCode;
    final closeReason = _channel?.closeReason;
    if (_shouldInvalidateSession(
      closeCode: closeCode,
      closeReason: closeReason,
    )) {
      unawaited(
        _handleInvalidSession(
          'Connection closed ($closeCode: ${closeReason ?? ''})',
        ),
      );
      return;
    }

    _connectionStatus.value = 'disconnected';
    AppLogger.w('WebSocket: Connection closed');
    _closeTransportChannel();

    _coordinator.broadcastDisconnected();
    _reconnect();
  }

  void _reconnect() {
    final hasStoredSession = hasActiveStoredSession();

    if (!shouldAttemptReconnect(
      isManualDisconnect: _isManualDisconnect,
      isLeader: _coordinator.isLeader,
      lastUrl: _lastUrl,
      hasStoredSession: hasStoredSession,
    )) {
      if (_isManualDisconnect) {
        AppLogger.w(
          'WebSocket: Manual disconnect in progress, skipping reconnection',
        );
      } else if (!_coordinator.isLeader) {
        AppLogger.d('WebSocket: Follower tab — skipping reconnection');
      } else if (_lastUrl == null) {
        AppLogger.e('WebSocket: No URL available for reconnection');
        _connectionStatus.value = 'disconnected';
      } else if (!hasStoredSession) {
        AppLogger.w(
          'WebSocket: No stored session, skipping reconnection',
        );
        _connectionStatus.value = 'disconnected';
      }
      return;
    }

    if (_reconnectTimer?.isActive == true) {
      AppLogger.d('WebSocket: Reconnect timer already active');
      return;
    }

    _reconnectAttempts++;
    _connectionStatus.value = 'reconnecting';
    AppLogger.i(
      'WebSocket: Scheduling reconnect attempt #$_reconnectAttempts',
    );

    _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), () {
      if (!_isManualDisconnect &&
          _coordinator.isLeader &&
          hasActiveStoredSession()) {
        connect(_lastUrl!, clientId: _clientId, sessionId: _sessionId);
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer =
        Timer.periodic(Duration(seconds: _heartbeatInterval), (timer) {
          if (_connectionStatus.value == 'connected' && !_isManualDisconnect) {
            // send('ping');
          } else {
            timer.cancel();
          }
        });

    _startHealthCheck();
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer =
        Timer.periodic(Duration(seconds: _healthCheckInterval), (timer) {
          if (_connectionStatus.value == 'connected' && !_isManualDisconnect) {
            if (_lastHeartbeatResponse != null) {
              final timeSinceLastHeartbeat =
              DateTime.now().difference(_lastHeartbeatResponse!);
              if (timeSinceLastHeartbeat.inSeconds > _heartbeatInterval * 2) {
                AppLogger.w(
                  'WebSocket: No heartbeat response for ${timeSinceLastHeartbeat.inSeconds} seconds, reconnecting...',
                );
                _handleConnectionError('Heartbeat timeout');
              }
            }
          } else {
            timer.cancel();
          }
        });
  }

  void _cancelTimers() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _connectionTimeoutTimer?.cancel();
    _healthCheckTimer?.cancel();
  }

  void _closeTransportChannel() {
    try {
      _channel?.sink.close();
    } catch (e, s) {
      AppLogger.e('WebSocket: Error closing transport channel', e, s);
    }
    _channel = null;
  }

  void _sendUserIdentification(String? clientId, String? sessionId) {
    try {
      final identificationMessage = {
        'type': 'identification',
        'clientId': clientId,
        'sessionId': sessionId,
        'timestamp': DateTime.now().toIso8601String(),
      };
      send(identificationMessage);
      AppLogger.d(
        'WebSocket: Sent client identification for clientId: $clientId , sessionId: $sessionId',
      );
    } catch (e, s) {
      AppLogger.e('WebSocket: Error sending client identification', e, s);
    }
  }

  void send(dynamic message) {
    if (_isManualDisconnect) {
      AppLogger.w(
        'WebSocket: Cannot send message - manual disconnect in progress',
      );
      return;
    }

    if (!_coordinator.isLeader) {
      if (isConnected) {
        _coordinator.sendToLeader(message);
        AppLogger.d('WebSocket: Forwarded message to leader tab');
      } else {
        AppLogger.w(
          'WebSocket: Cannot send message - follower not synced with leader',
        );
      }
      return;
    }

    _sendOnTransport(message);
  }

  void _sendOnTransport(dynamic message) {
    if (_channel == null ||
        _connectionStatus.value != 'connected' ||
        _isManualDisconnect) {
      AppLogger.w(
        'WebSocket: Cannot send message - not connected or manual disconnect in progress',
      );
      return;
    }

    try {
      final messageToSend = message is Map ? json.encode(message) : message;
      _channel!.sink.add(messageToSend);
      AppLogger.d('WebSocket: Sent message: $messageToSend');
    } catch (e, s) {
      _lastError.value = 'Send error: $e';
      AppLogger.e('WebSocket: Send error', e, s);
      if (!_isManualDisconnect) {
        _handleConnectionError('Send error: $e');
      }
    }
  }

  Future<void> disconnect() async {
    AppLogger.i('WebSocket: Manual disconnect initiated...');
    _isManualDisconnect = true;
    _cancelTimers();
    _connectionStatus.value = 'disconnected';
    _reconnectAttempts = 0;
    _lastUrl = null;
    _clientId = null;
    _sessionId = null;

    _coordinator.broadcastDisconnected();
    _closeTransportChannel();
    AppLogger.i('WebSocket: Disconnected');
  }

  void resetManualDisconnect() {
    _isManualDisconnect = false;
    _sessionInvalidationInProgress = false;
    _reconnectAttempts = 0;
  }

  Future<void> ensureConnected({String? clientId, String? sessionId}) async {
    if (!_coordinatorReady) {
      await _initCoordinator();
    }

    if (clientId != null) _clientId = clientId;
    if (sessionId != null) _sessionId = sessionId;
    if (_lastUrl == null) _lastUrl = WebSocketUrl.webSocketUrl;

    if (_isManualDisconnect) {
      AppLogger.w(
          'WebSocket: Manual disconnect active, skipping ensureConnected');
      return;
    }

    if (_connectionStatus.value == 'connected') {
      AppLogger.d('WebSocket: Already connected');
      return;
    }

    if (_connectionStatus.value == 'connecting' && _connectCompleter != null) {
      AppLogger.d(
          'WebSocket: Already connecting, awaiting in-flight attempt...');
      try {
        await _connectCompleter!.future;
      } catch (_) {}
      return;
    }

    if (!_coordinator.isLeader) {
      AppLogger.i(
        'WebSocket: Follower tab — awaiting leader relay (no transport connect)',
      );
      _coordinator.requestLeaderSync();
      final synced = await waitForConnection();
      if (!synced) {
        AppLogger.w('WebSocket: Follower sync timed out waiting for leader');
      }
      return;
    }

    await connect(
      _lastUrl!,
      clientId: _clientId ?? _readStoredClientId(),
      sessionId: _sessionId ?? _readStoredSessionId(),
    );
  }

  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (isConnected) return true;

    _followerSyncCompleter ??= Completer<void>();
    try {
      await _followerSyncCompleter!.future.timeout(timeout);
      return isConnected;
    } on TimeoutException {
      return false;
    }
  }

  /// Backward-compatible alias used by legacy callers.
  Future<void> initializeForNewTab() => ensureConnected(
    clientId: _readStoredClientId(),
    sessionId: _readStoredSessionId(),
  );

  void onAppLifecycleChanged(String state) {
    switch (state) {
      case 'resumed':
        if (_lastUrl != null &&
            _connectionStatus.value == 'disconnected' &&
            !_isManualDisconnect &&
            _coordinator.isLeader) {
          AppLogger.i('WebSocket: App resumed, attempting to reconnect...');
          connect(
            _lastUrl!,
            clientId: _clientId,
            sessionId: _sessionId,
          );
        }
        break;
      case 'paused':
        AppLogger.d('WebSocket: App paused, keeping connection alive');
        break;
      case 'inactive':
        AppLogger.d('WebSocket: App inactive, keeping connection alive');
        break;
      case 'detached':
        AppLogger.d('WebSocket: App detached');
        break;
      case 'hidden':
        AppLogger.d('WebSocket: App hidden, keeping connection alive');
        break;
    }
  }

  @override
  void onClose() {
    _coordinator.dispose();
    disconnect();
    _messageStream.close();
    super.onClose();
  }
}
