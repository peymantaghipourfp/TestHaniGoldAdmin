import 'package:flutter_test/flutter_test.dart';
import 'package:hanigold_admin/src/config/const/socket.service.dart';

void main() {
  group('shouldAttemptReconnect', () {
    test('allows reconnect when leader with URL and not manual disconnect', () {
      expect(
        shouldAttemptReconnect(
          isManualDisconnect: false,
          isLeader: true,
          lastUrl: 'wss://example.com/ws',
        ),
        isTrue,
      );
    });

    test('blocks reconnect on manual disconnect', () {
      expect(
        shouldAttemptReconnect(
          isManualDisconnect: true,
          isLeader: true,
          lastUrl: 'wss://example.com/ws',
        ),
        isFalse,
      );
    });

    test('blocks reconnect for follower tabs', () {
      expect(
        shouldAttemptReconnect(
          isManualDisconnect: false,
          isLeader: false,
          lastUrl: 'wss://example.com/ws',
        ),
        isFalse,
      );
    });

    test('blocks reconnect when URL is missing', () {
      expect(
        shouldAttemptReconnect(
          isManualDisconnect: false,
          isLeader: true,
          lastUrl: null,
        ),
        isFalse,
      );
    });

    test('blocks reconnect when stored session is gone', () {
      expect(
        shouldAttemptReconnect(
          isManualDisconnect: false,
          isLeader: true,
          lastUrl: 'wss://example.com/ws',
          hasStoredSession: false,
        ),
        isFalse,
      );
    });

    test('allows reconnect after many transport failures (no attempt cap)', () {
      for (var attempt = 1; attempt <= 100; attempt++) {
        expect(
          shouldAttemptReconnect(
            isManualDisconnect: false,
            isLeader: true,
            lastUrl: 'wss://example.com/ws',
          ),
          isTrue,
          reason: 'attempt $attempt must not be blocked by count',
        );
      }
    });
  });
}
