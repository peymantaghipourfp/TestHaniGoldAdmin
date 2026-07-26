import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hanigold_admin/src/config/secure_session_storage.dart';
import 'package:hanigold_admin/src/config/session_storage.dart';
import 'package:hanigold_admin/src/config/web_tab_logout_logic.dart';

void main() {
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
    await GetStorage.init();
  });

  setUp(() {
    SecureSessionStorage.resetInstance();
    SecureSessionStorage.instance = SecureSessionStorage(
      backend: MemorySessionSecretBackend(),
      getStorage: GetStorage(),
    );
  });

  tearDown(() {
    SecureSessionStorage.resetInstance();
  });

  group('shouldLogoutOnPageHide', () {
    test('web + non-persisted pagehide triggers logout intent', () {
      expect(
        shouldLogoutOnPageHide(isWeb: true, persisted: false),
        isTrue,
      );
    });

    test('non-web never triggers logout intent', () {
      expect(
        shouldLogoutOnPageHide(isWeb: false, persisted: false),
        isFalse,
      );
      expect(
        shouldLogoutOnPageHide(isWeb: false, persisted: true),
        isFalse,
      );
    });

    test('bfcache persisted pagehide skips logout', () {
      expect(
        shouldLogoutOnPageHide(isWeb: true, persisted: true),
        isFalse,
      );
    });

    test('sibling tabs alive skips shared session logout', () {
      expect(
        shouldLogoutOnPageHide(
          isWeb: true,
          persisted: false,
          isLastTab: false,
        ),
        isFalse,
      );
    });

    test('last tab still logs out on non-persisted pagehide', () {
      expect(
        shouldLogoutOnPageHide(
          isWeb: true,
          persisted: false,
          isLastTab: true,
        ),
        isTrue,
      );
    });
  });

  group('clearStoredSessionSync', () {
    test('removes session keys from in-memory storage immediately', () async {
      final box = GetStorage();
      final session = SecureSessionStorage.instance;
      await session.init();
      await session.write('Authorization', 'token');
      await session.write('id', 1);
      await session.write('x-session-id', 'sess');
      await session.write('mobile', '0912');
      await session.write('token', 'legacy');
      // Legacy plaintext leftovers must also be scrubbed.
      await box.write('Authorization', 'token');

      clearStoredSessionSync();

      expect(box.read('Authorization'), isNull);
      expect(box.read('id'), isNull);
      expect(box.read('x-session-id'), isNull);
      expect(box.read('mobile'), isNull);
      expect(box.read('token'), isNull);
      expect(hasActiveStoredSession(), isFalse);
    });
  });

  group('performTabCloseLogoutSync', () {
    test('completes without throwing when nothing is registered', () {
      expect(performTabCloseLogoutSync, returnsNormally);
    });
  });
}
