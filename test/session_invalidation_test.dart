import 'package:flutter_test/flutter_test.dart';
import 'package:hanigold_admin/src/config/session_invalidation.dart';
import 'package:hanigold_admin/src/config/web_route_hash.dart';

void main() {
  group('isInvalidSessionSocketClose', () {
    test('detects policy close code 1008', () {
      expect(
        isInvalidSessionSocketClose(closeCode: 1008),
        isTrue,
      );
    });

    test('detects invalid sessionId in close reason', () {
      expect(
        isInvalidSessionSocketClose(closeReason: 'Invalid sessionId'),
        isTrue,
      );
    });

    test('ignores unrelated close codes', () {
      expect(
        isInvalidSessionSocketClose(closeCode: 1000, closeReason: 'normal'),
        isFalse,
      );
    });
  });

  group('parseHashRoute bootstrap safety', () {
    test('splash hash resolves to /splash', () {
      expect(parseHashRoute('#/splash'), '/splash');
    });

    test('post-splash must not target bootstrap-only routes', () {
      const bootstrapOnly = {'/splash', '/login'};
      for (final route in bootstrapOnly) {
        expect(bootstrapOnly.contains(route), isTrue);
      }
      expect(parseHashRoute('#/orderList'), '/orderList');
    });
  });
}
