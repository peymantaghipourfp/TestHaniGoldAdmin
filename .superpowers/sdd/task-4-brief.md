### Task 4: Remove `x-session-id` from DioInterceptor (TDD)

**Files:**
- Modify: `lib/src/config/network/dio_Interceptor.dart`
- Create: `test/dio_interceptor_session_header_test.dart`

**Interfaces:**
- Consumes: `SecureSessionStorage` (`Authorization` only for headers)
- Produces: request headers without `x-session-id`

- [ ] **Step 1: Write failing / characterizing test**

Create `test/dio_interceptor_session_header_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hanigold_admin/src/config/network/dio_Interceptor.dart';
import 'package:hanigold_admin/src/config/secure_session_storage.dart';

void main() {
  setUpAll(() async {
    await GetStorage.init('dio_interceptor_session_header_test');
  });

  setUp(() async {
    SecureSessionStorage.resetInstance();
    SecureSessionStorage.instance = SecureSessionStorage(
      backend: MemorySessionSecretBackend(),
      getStorage: GetStorage('dio_interceptor_session_header_test'),
    );
    await SecureSessionStorage.instance.init();
    await SecureSessionStorage.instance.write('Authorization', 'test-token');
    await SecureSessionStorage.instance.write('x-session-id', 'session-abc');
    await SecureSessionStorage.instance.write('id', '1');
  });

  tearDown(() {
    SecureSessionStorage.resetInstance();
  });

  test('onRequest sets Authorization but not x-session-id', () async {
    final interceptor = DioInterceptor();
    final options = RequestOptions(path: '/api/test', baseUrl: 'http://example.com');
    final completer = CompleterOrNext();

    interceptor.onRequest(options, completer);

    expect(options.headers['Authorization'], 'Bearer test-token');
    expect(options.headers.containsKey('x-session-id'), isFalse);
  });
}

/// Minimal RequestInterceptorHandler stand-in for unit tests.
class CompleterOrNext extends RequestInterceptorHandler {
  @override
  void next(RequestOptions options) {}
}
```

If `RequestInterceptorHandler` cannot be subclassed easily in the Dio version used by this project, use this alternative instead (same file, replace the test body approach):

```dart
  test('onRequest sets Authorization but not x-session-id', () async {
    final dio = Dio();
    dio.interceptors.add(DioInterceptor());
    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ),
    );

    await dio.get('/api/test');

    expect(captured.headers['Authorization'], 'Bearer test-token');
    expect(captured.headers.containsKey('x-session-id'), isFalse);
  });
```

Prefer the Dio-chain alternative if the handler subclass fails to compile.

- [ ] **Step 2: Run test (may FAIL while header still present)**

Run:

```bash
flutter test test/dio_interceptor_session_header_test.dart
```

Expected before Step 3: FAIL on `containsKey('x-session-id')` isFalse (header still set).  
If the test fails to compile first, fix the test harness, then re-run until you see the assertion failure about `x-session-id`.

- [ ] **Step 3: Remove session header from interceptor**

Replace `lib/src/config/network/dio_Interceptor.dart` `onRequest` body with:

```dart
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final session = SecureSessionStorage.instance;
      final token = session.read('Authorization');

      // Authorization Header
      if (token != null && token.toString().isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      AppLogger.d(
          '➡️ REQUEST[${options.method}] => ${options.baseUrl}${options.path}');
      AppLogger.d('Headers: ${options.headers}');
      AppLogger.d('Query: ${options.queryParameters}');
      AppLogger.d('Body: ${options.data}');
    } catch (e, s) {
      AppLogger.e('onRequest error', e, s);
    }

    handler.next(options);
  }
```

Do **not** remove `x-session-id` writes from `AuthController` / `AuthRepository`.

- [ ] **Step 4: Run interceptor test + pending tests**

Run:

```bash
flutter test test/dio_interceptor_session_header_test.dart test/pending_post_login_route_test.dart
```

Expected: All PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/config/network/dio_Interceptor.dart test/dio_interceptor_session_header_test.dart
git commit -m "fix(network): stop attaching x-session-id on Dio requests"
```

---
