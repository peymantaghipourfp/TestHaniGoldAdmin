import 'package:hanigold_admin/src/config/secure_session_storage.dart';

/// Validates that an incoming WebSocket envelope belongs to the current
/// authenticated login session. The login session id is persisted by
/// AuthController.login under secure session key `x-session-id`.
class SocketSessionGuard {
  static const String _storageKey = 'x-session-id';

  /// Current authenticated session id (from AuthController login), or null
  /// when no session is stored yet (e.g. pre-login).
  static String? get currentSessionId {
    final value = SecureSessionStorage.instance.read(_storageKey);
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Returns true if [envelope] may be processed.
  /// Lenient policy:
  ///   - no/empty top-level `sessionId` -> allow (server always sends it,
  ///     but we only block on an explicit mismatch);
  ///   - no authenticated session stored yet -> allow;
  ///   - explicit mismatch -> reject.
  static bool accepts(Map<String, dynamic> envelope) {
    final incoming = sessionIdFromEnvelope(envelope);
    if (incoming == null || incoming.isEmpty) return true;
    final current = currentSessionId;
    if (current == null || current.isEmpty) return true;
    return incoming == current;
  }

  /// Reads top-level session id from a raw or parsed envelope map.
  static String? sessionIdFromEnvelope(Map<String, dynamic> envelope) {
    final raw = envelope['sessionId'] ?? envelope['SessionId'];
    if (raw == null) return null;
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Returns true when a parsed model [sessionId] may be processed.
  static bool acceptsSessionId(String? sessionId) =>
      accepts({'sessionId': sessionId});
}
