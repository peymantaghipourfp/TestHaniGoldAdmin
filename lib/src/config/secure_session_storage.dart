import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

import 'package:hanigold_admin/src/config/logger/app_logger.dart';

/// Sensitive session keys that must never live in plaintext GetStorage / Local Storage.
const secureSessionKeys = <String>[
  'Authorization',
  'token',
  'x-session-id',
  'id',
  'mobile',
  'userName',
  'password',
];

/// Persistence backend for encrypted session secrets.
abstract class SessionSecretBackend {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSessionSecretBackend implements SessionSecretBackend {
  FlutterSessionSecretBackend([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// In-memory backend for unit tests.
class MemorySessionSecretBackend implements SessionSecretBackend {
  final Map<String, String> data = {};

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async {
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    data.remove(key);
  }
}

/// In-memory + encrypted backend session vault.
///
/// Sync [read] for Dio / GetX call sites; async [write]/[remove]/[init].
/// On web, [FlutterSessionSecretBackend] encrypts values (not plaintext GetStorage JSON).
class SecureSessionStorage {
  SecureSessionStorage({
    SessionSecretBackend? backend,
    GetStorage? getStorage,
  })  : _backend = backend ?? FlutterSessionSecretBackend(),
        _box = getStorage ?? GetStorage();

  static SecureSessionStorage? _instance;

  static SecureSessionStorage get instance =>
      _instance ??= SecureSessionStorage();

  /// Test / DI override.
  static set instance(SecureSessionStorage value) => _instance = value;

  static void resetInstance() => _instance = null;

  final SessionSecretBackend _backend;
  final GetStorage _box;
  final Map<String, String> _cache = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;

  String _secureKey(String key) => 'session_$key';

  /// Load secure store into memory and scrub plaintext GetStorage leftovers.
  Future<void> init() async {
    if (_initialized) return;
    try {
      await _migrateFromGetStorage();
      for (final key in secureSessionKeys) {
        if (key == 'password') {
          // Never keep a session password copy; remember-me uses CredentialsStorage.
          _cache.remove(key);
          await _backend.delete(_secureKey(key));
          continue;
        }
        final value = await _backend.read(_secureKey(key));
        if (value != null && value.isNotEmpty) {
          _cache[key] = value;
        }
      }
    } catch (e, s) {
      AppLogger.e('SecureSessionStorage.init failed', e, s);
    } finally {
      _initialized = true;
      await _scrubGetStorageSecrets();
    }
  }

  Future<void> _migrateFromGetStorage() async {
    for (final key in secureSessionKeys) {
      final raw = _box.read(key);
      if (raw == null) continue;
      final value = raw.toString();
      if (value.isEmpty) continue;
      if (key == 'password') {
        // Drop plaintext password from GetStorage; do not migrate into session vault.
        continue;
      }
      final existing = await _backend.read(_secureKey(key));
      if (existing == null || existing.isEmpty) {
        await _backend.write(_secureKey(key), value);
      }
    }
  }

  Future<void> _scrubGetStorageSecrets() async {
    for (final key in secureSessionKeys) {
      try {
        await _box.remove(key);
      } catch (_) {}
    }
  }

  /// Sync read from memory cache (populated by [init] / [write]).
  dynamic read(String key) => _cache[key];

  Future<void> write(String key, dynamic value) async {
    if (key == 'password') {
      // Do not persist session password anywhere.
      _cache.remove(key);
      try {
        await _backend.delete(_secureKey(key));
        await _box.remove(key);
      } catch (_) {}
      return;
    }
    if (value == null) {
      await remove(key);
      return;
    }
    final asString = value.toString();
    _cache[key] = asString;
    try {
      await _backend.write(_secureKey(key), asString);
      await _box.remove(key);
    } catch (e, s) {
      AppLogger.e('SecureSessionStorage.write($key) failed', e, s);
    }
  }

  Future<void> remove(String key) async {
    _cache.remove(key);
    try {
      await _backend.delete(_secureKey(key));
      await _box.remove(key);
    } catch (e, s) {
      AppLogger.e('SecureSessionStorage.remove($key) failed', e, s);
    }
  }

  /// Clears all session secrets from memory and secure storage; scrubs GetStorage.
  Future<void> clearAll() async {
    _cache.clear();
    for (final key in secureSessionKeys) {
      try {
        await _backend.delete(_secureKey(key));
      } catch (_) {}
    }
    await _scrubGetStorageSecrets();
  }

  /// Sync memory + GetStorage scrub for unload handlers; secure deletes are fire-and-forget.
  void clearAllSync() {
    _cache.clear();
    for (final key in secureSessionKeys) {
      try {
        _box.remove(key);
      } catch (_) {}
      try {
        // ignore: discarded_futures
        _backend.delete(_secureKey(key)).catchError((_) => null);
      } catch (_) {}
    }
  }

  bool hasActiveSession() {
    final token = _cache['Authorization'];
    final userId = _cache['id'];
    final sessionId = _cache['x-session-id'];
    return token != null &&
        token.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty &&
        sessionId != null &&
        sessionId.isNotEmpty;
  }

  /// Re-writes in-memory session secrets to the encrypted backend.
  ///
  /// Used before opening a new browser tab so the new isolate can hydrate
  /// Authorization even if a prior tab-close cleared shared storage while
  /// this tab kept working from memory.
  Future<void> persistCacheToBackend() async {
    for (final key in secureSessionKeys) {
      if (key == 'password') continue;
      final value = _cache[key];
      if (value == null || value.isEmpty) continue;
      try {
        await _backend.write(_secureKey(key), value);
      } catch (e, s) {
        AppLogger.e('SecureSessionStorage.persistCacheToBackend($key) failed', e, s);
      }
    }
  }
}
