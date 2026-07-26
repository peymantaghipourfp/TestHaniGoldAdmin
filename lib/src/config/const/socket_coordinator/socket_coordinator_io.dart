import 'socket_coordinator_interface.dart';

/// Single-process pass-through: always leader, no cross-tab relay.
class SocketCoordinatorImpl implements SocketCoordinator {
  bool _initialized = false;

  @override
  bool get isLeader => true;

  @override
  bool get supportsCrossTab => false;

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
    onLeaderAcquired();
  }

  @override
  void broadcastToFollowers(dynamic data) {}

  @override
  void sendToLeader(dynamic data) {}

  @override
  void broadcastConnected() {}

  @override
  void broadcastDisconnected() {}

  @override
  void requestLeaderSync() {}

  @override
  void dispose() {}
}

SocketCoordinator createSocketCoordinator() => SocketCoordinatorImpl();
