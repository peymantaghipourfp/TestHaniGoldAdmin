/// Cross-tab WebSocket coordination callbacks.
typedef LeaderAcquiredCallback = void Function();
typedef FollowerMessageCallback = void Function(dynamic data);
typedef LeaderSendRequestCallback = void Function(dynamic data);
typedef LeaderReleasedCallback = void Function();
typedef FollowerConnectedCallback = void Function();
typedef FollowerDisconnectedCallback = void Function();
typedef LeaderHelloCallback = void Function();

/// Abstracts leader election and cross-tab message relay.
///
/// On web, exactly one browser tab holds the Web Lock and owns the real socket;
/// follower tabs relay send/receive through [BroadcastChannel].
/// On io (mobile/desktop), every instance is always the leader (no-op relay).
abstract class SocketCoordinator {
  /// Whether this tab/process currently owns the real WebSocket connection.
  bool get isLeader;

  /// True when cross-tab coordination is active (web only).
  bool get supportsCrossTab;

  /// Prepares leader election and cross-tab listeners.
  Future<void> initialize({
    required LeaderAcquiredCallback onLeaderAcquired,
    required FollowerMessageCallback onFollowerMessage,
    required LeaderSendRequestCallback onLeaderSendRequest,
    required LeaderReleasedCallback onLeaderReleased,
    required FollowerConnectedCallback onFollowerConnected,
    required FollowerDisconnectedCallback onFollowerDisconnected,
    required LeaderHelloCallback onLeaderHello,
  });

  /// Leader → followers: relay an incoming socket payload.
  void broadcastToFollowers(dynamic data);

  /// Follower → leader: forward an outgoing payload for the real socket.
  void sendToLeader(dynamic data);

  /// Leader → followers: announce that the socket is connected.
  void broadcastConnected();

  /// Leader → followers: announce that the socket disconnected (logout, etc.).
  void broadcastDisconnected();

  /// Follower → leader: request current connection status sync.
  void requestLeaderSync();

  void dispose();
}
