import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hanigold_admin/src/config/secure_session_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';

  @override
  Future<String?> getTemporaryPath() async => '.';

  @override
  Future<String?> getApplicationSupportPath() async => '.';

  @override
  Future<String?> getLibraryPath() async => '.';

  @override
  Future<String?> getDownloadsPath() async => '.';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = _FakePathProvider();
    await GetStorage.init();
  });

  setUp(() async {
    SecureSessionStorage.resetInstance();
    final box = GetStorage();
    for (final key in secureSessionKeys) {
      await box.remove(key);
    }
  });

  tearDown(() {
    SecureSessionStorage.resetInstance();
  });

  test('sensitive keys are scrubbed from GetStorage after init migrate', () async {
    final box = GetStorage();
    await box.write('Authorization', 'legacy-token');
    await box.write('password', 'legacy-password');
    await box.write('x-session-id', 'legacy-session');
    await box.write('id', '1');
    await box.write('mobile', '09120000000');
    await box.write('userName', 'admin');
    await box.write('token', 'legacy-token');
    await box.write('rememberMe', true);

    final session = SecureSessionStorage(
      backend: MemorySessionSecretBackend(),
      getStorage: box,
    );
    SecureSessionStorage.instance = session;
    await session.init();

    for (final key in secureSessionKeys) {
      expect(box.read(key), isNull, reason: '$key must not remain in GetStorage');
    }
    expect(box.read('rememberMe'), isTrue,
        reason: 'non-secret prefs may stay in GetStorage');

    expect(session.read('Authorization'), 'legacy-token');
    expect(session.read('x-session-id'), 'legacy-session');
    expect(session.read('id'), '1');
    expect(session.read('password'), isNull,
        reason: 'password must never be kept in session vault');
  });

  test('write keeps secrets out of GetStorage', () async {
    final box = GetStorage();
    final session = SecureSessionStorage(
      backend: MemorySessionSecretBackend(),
      getStorage: box,
    );
    SecureSessionStorage.instance = session;
    await session.init();

    await session.write('Authorization', 'tok');
    await session.write('password', 'secret');

    expect(box.read('Authorization'), isNull);
    expect(box.read('password'), isNull);
    expect(session.read('Authorization'), 'tok');
    expect(session.read('password'), isNull);
  });

  test('persistCacheToBackend restores secrets for a fresh tab vault', () async {
    final backend = MemorySessionSecretBackend();
    final box = GetStorage();

    final tabA = SecureSessionStorage(backend: backend, getStorage: box);
    SecureSessionStorage.instance = tabA;
    await tabA.init();
    await tabA.write('Authorization', 'shared-token');
    await tabA.write('id', '1');
    await tabA.write('x-session-id', 'sess');

    // Simulate a sibling tab wiping shared storage while Tab A keeps memory.
    backend.data.clear();
    expect(tabA.read('Authorization'), 'shared-token');

    await tabA.persistCacheToBackend();

    final tabB = SecureSessionStorage(backend: backend, getStorage: GetStorage());
    await tabB.init();
    expect(tabB.read('Authorization'), 'shared-token');
    expect(tabB.read('id'), '1');
    expect(tabB.read('x-session-id'), 'sess');
  });
}
