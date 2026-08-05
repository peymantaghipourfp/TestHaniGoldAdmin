import 'package:flutter_test/flutter_test.dart';
import 'package:hanigold_admin/src/config/web_unauthenticated_boot.dart';

void main() {
  group('shouldForceLoginInsteadOfDeepLink', () {
    test('rejects login/splash/empty', () {
      expect(shouldForceLoginInsteadOfDeepLink(null), isFalse);
      expect(shouldForceLoginInsteadOfDeepLink(''), isFalse);
      expect(shouldForceLoginInsteadOfDeepLink('/login'), isFalse);
      expect(shouldForceLoginInsteadOfDeepLink('/splash'), isFalse);
    });

    test('accepts protected deep links', () {
      expect(
        shouldForceLoginInsteadOfDeepLink('/listUserInfoTransaction'),
        isTrue,
      );
      expect(shouldForceLoginInsteadOfDeepLink('/orderList'), isTrue);
    });
  });

  group('buildLoginHashUrl', () {
    test('replaces existing hash', () {
      expect(
        buildLoginHashUrl('http://localhost/#/listUserInfoTransaction'),
        'http://localhost/#/login',
      );
    });

    test('appends hash when missing', () {
      expect(
        buildLoginHashUrl('http://localhost/'),
        'http://localhost/#/login',
      );
    });
  });

  group('normalizePlatformDefaultRoute', () {
    test('normalizes platform default route names', () {
      expect(normalizePlatformDefaultRoute('/'), isNull);
      expect(normalizePlatformDefaultRoute(''), isNull);
      expect(
        normalizePlatformDefaultRoute('/listUserInfoTransaction'),
        '/listUserInfoTransaction',
      );
    });
  });
}
