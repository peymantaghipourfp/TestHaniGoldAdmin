import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hanigold_admin/src/config/pending_post_login_route.dart';

void main() {
  late GetStorage box;
  const known = {
    '/home',
    '/login',
    '/splash',
    '/listUserInfoTransaction',
    '/orderList',
  };

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '.';
      }
      return null;
    });
    await GetStorage.init('pending_post_login_route_test');
  });

  setUp(() async {
    box = GetStorage('pending_post_login_route_test');
    await box.erase();
  });

  group('isPendingPostLoginRouteAllowed', () {
    test('rejects null, empty, splash, login', () {
      expect(isPendingPostLoginRouteAllowed(null, known), isFalse);
      expect(isPendingPostLoginRouteAllowed('', known), isFalse);
      expect(isPendingPostLoginRouteAllowed('/splash', known), isFalse);
      expect(isPendingPostLoginRouteAllowed('/login', known), isFalse);
    });

    test('accepts known protected routes', () {
      expect(
        isPendingPostLoginRouteAllowed('/listUserInfoTransaction', known),
        isTrue,
      );
    });

    test('rejects unknown routes', () {
      expect(isPendingPostLoginRouteAllowed('/notARealRoute', known), isFalse);
    });
  });

  group('save + consume', () {
    test('saves allowed route and consume clears it', () {
      savePendingPostLoginRoute(
        '/listUserInfoTransaction',
        knownRouteNames: known,
        box: box,
      );
      expect(box.read(pendingPostLoginRouteKey), '/listUserInfoTransaction');
      expect(consumePendingPostLoginRoute(box: box), '/listUserInfoTransaction');
      expect(box.read(pendingPostLoginRouteKey), isNull);
      expect(consumePendingPostLoginRoute(box: box), isNull);
    });

    test('does not save bootstrap-only or unknown routes', () {
      savePendingPostLoginRoute('/login', knownRouteNames: known, box: box);
      savePendingPostLoginRoute('/nope', knownRouteNames: known, box: box);
      expect(box.read(pendingPostLoginRouteKey), isNull);
    });
  });

  group('resolveUnauthenticatedWebBootRoute', () {
    test('protected hash → /login and pending set', () {
      final route = resolveUnauthenticatedWebBootRoute(
        hashRoute: '/listUserInfoTransaction',
        knownRouteNames: known,
        box: box,
      );
      expect(route, '/login');
      expect(box.read(pendingPostLoginRouteKey), '/listUserInfoTransaction');
    });

    test('login/splash hash → /login and pending not set', () {
      expect(
        resolveUnauthenticatedWebBootRoute(
          hashRoute: '/login',
          knownRouteNames: known,
          box: box,
        ),
        '/login',
      );
      expect(box.read(pendingPostLoginRouteKey), isNull);

      expect(
        resolveUnauthenticatedWebBootRoute(
          hashRoute: '/splash',
          knownRouteNames: known,
          box: box,
        ),
        '/login',
      );
      expect(box.read(pendingPostLoginRouteKey), isNull);
    });
  });
}
