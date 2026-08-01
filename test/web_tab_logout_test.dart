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

  group('shouldClearSessionOnPageHide', () {
    test('never clears session on pagehide (explicit logout only)', () {
      expect(
        shouldClearSessionOnPageHide(isWeb: true, persisted: false),
        isFalse,
      );
      expect(
        shouldClearSessionOnPageHide(
          isWeb: true,
          persisted: false,
          isLastTab: true,
        ),
        isFalse,
      );
      expect(
        shouldClearSessionOnPageHide(
          isWeb: true,
          persisted: false,
          isLastTab: false,
        ),
        isFalse,
      );
      expect(
        shouldClearSessionOnPageHide(isWeb: true, persisted: true),
        isFalse,
      );
      expect(
        shouldClearSessionOnPageHide(isWeb: false, persisted: false),
        isFalse,
      );
    });

    test('legacy shouldLogoutOnPageHide matches clear gate (always false)', () {
      expect(
        shouldLogoutOnPageHide(isWeb: true, persisted: false, isLastTab: true),
        isFalse,
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
