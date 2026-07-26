import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../logger/app_logger.dart';
import 'socket_coordinator_interface.dart';

const _channelName = 'hanigold-socket-v1';
const _lockName = 'hanigold-socket';

/// Web implementation: Web Locks leader election + BroadcastChannel relay.
class SocketCoordinatorImpl implements SocketCoordinator {
  web.BroadcastChannel? _channel;
  Completer<void>? _lockHeldCompleter;
  bool _disposed = false;
  bool _initialized = false;
  bool _isLeader = false;
  DateTime? _lastHelloPostedAt;

  LeaderAcquiredCallback? _onLeaderAcquired;
  FollowerMessageCallback? _onFollowerMessage;
  LeaderSendRequestCallback? _onLeaderSendRequest;
  LeaderReleasedCallback? _onLeaderReleased;
  FollowerConnectedCallback? _onFollowerConnected;
  FollowerDisconnectedCallback? _onFollowerDisconnected;
  LeaderHelloCallback? _onLeaderHello;

  @override
  bool get isLeader => _isLeader;

  @override
  bool get supportsCrossTab => true;

  @override
  Future<void> initialize({
    required LeaderAcquiredCallback onLeaderAcquired,
    required FollowerMessageCallback onFollowerMessage,
    required LeaderSendRequestCallback onLeaderSendRequest,
    required LeaderReleasedCallback onLeaderReleased,
    required FollowerConnectedCallback onFollowerConnected,
    required FollowerDisconnectedCallback onFollowerDisconnected,
    required LeaderHelloCallback onLeaderHello,
  }) async {
    if (_initialized) return;
    _initialized = true;

    _onLeaderAcquired = onLeaderAcquired;
    _onFollowerMessage = onFollowerMessage;
    _onLeaderSendRequest = onLeaderSendRequest;
    _onLeaderReleased = onLeaderReleased;
    _onFollowerConnected = onFollowerConnected;
    _onFollowerDisconnected = onFollowerDisconnected;
    _onLeaderHello = onLeaderHello;

    _channel = web.BroadcastChannel(_channelName);
    _channel!.onmessage = ((web.MessageEvent event) {
      _handleChannelMessage(event);
    }).toJS;

    _postHello();
    unawaited(_requestLeaderLock());
  }

  Future<void> _requestLeaderLock() async {
    if (_disposed) return;

    _lockHeldCompleter = Completer<void>();

    try {
      await web.window.navigator.locks
          .request(
        _lockName,
        ((web.Lock lock) {
          if (_disposed) {
            return Future.value().toJS;
          }
          _becomeLeader();
          return _lockHeldCompleter!.future.toJS;
        }).toJS,
      )
          .toDart;
    } catch (e, s) {
      AppLogger.e('WebSocket coordinator: lock request failed', e, s);
      if (_disposed) return;
      await Future<void>.delayed(const Duration(seconds: 2));
      return _requestLeaderLock();
    }

    if (!_disposed) {
      _becomeFollower();
      _onLeaderReleased?.call();
      await _requestLeaderLock();
    }
  }

  void _becomeLeader() {
    if (_disposed) return;
    final wasLeader = _isLeader;
    _isLeader = true;
    if (!wasLeader) {
      AppLogger.i('WebSocket coordinator: this tab became leader');
      _onLeaderAcquired?.call();
    }
  }

  void _becomeFollower() {
    if (_disposed) return;
    final wasLeader = _isLeader;
    _isLeader = false;
    if (wasLeader) {
      AppLogger.i('WebSocket coordinator: this tab became follower');
    }
  }

  void _handleChannelMessage(web.MessageEvent event) {
    if (_disposed) return;

    final raw = event.data;
    Map<String, dynamic>? envelope;
    try {
      if (raw.isA<JSString>()) {
        final decoded = jsonDecode((raw as JSString).toDart);
        if (decoded is Map) {
          envelope = Map<String, dynamic>.from(decoded);
        }
      }
    } catch (e) {
      AppLogger.w('WebSocket coordinator: invalid channel message: $e');
      return;
    }

    if (envelope == null) return;
    final kind = envelope['kind']?.toString();
    switch (kind) {
      case 'hello':
        if (_isLeader) {
          _onLeaderHello?.call();
        }
        break;
      case 'msg':
        if (!_isLeader) {
          _onFollowerMessage?.call(envelope['data']);
        }
        break;
      case 'send':
        if (_isLeader) {
          _onLeaderSendRequest?.call(envelope['data']);
        }
        break;
      case 'connected':
        if (!_isLeader) {
          _onFollowerConnected?.call();
        }
        break;
      case 'disconnected':
        if (!_isLeader) {
          _onFollowerDisconnected?.call();
        }
        break;
    }
  }

  void _postHello() {
    if (_disposed) return;
    final now = DateTime.now();
    if (_lastHelloPostedAt != null &&
        now.difference(_lastHelloPostedAt!) <
            const Duration(milliseconds: 500)) {
      return;
    }
    _lastHelloPostedAt = now;
    _post({'kind': 'hello'});
  }

  void _post(Map<String, dynamic> envelope) {
    if (_disposed || _channel == null) return;
    try {
      _channel!.postMessage(jsonEncode(envelope).toJS);
    } catch (e, s) {
      AppLogger.e('WebSocket coordinator: postMessage failed', e, s);
    }
  }

  @override
  void broadcastToFollowers(dynamic data) {
    if (!_isLeader || _disposed) return;
    _post({'kind': 'msg', 'data': data});
  }

  @override
  void sendToLeader(dynamic data) {
    if (_isLeader || _disposed) return;
    _post({'kind': 'send', 'data': data});
  }

  @override
  void broadcastConnected() {
    if (!_isLeader || _disposed) return;
    _post({'kind': 'connected'});
  }

  @override
  void broadcastDisconnected() {
    if (!_isLeader || _disposed) return;
    _post({'kind': 'disconnected'});
  }

  @override
  void requestLeaderSync() {
    if (_isLeader || _disposed) return;
    _postHello();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _lockHeldCompleter?.complete();
    _lockHeldCompleter = null;
    _channel?.close();
    _channel = null;
  }
}

SocketCoordinator createSocketCoordinator() => SocketCoordinatorImpl();
