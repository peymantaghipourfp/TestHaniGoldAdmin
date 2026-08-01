# Web Refresh Session Login-Restore + Dio Session Header Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On web refresh with cleared session, boot to `/login`, restore the prior hash route after successful login, and stop sending `x-session-id` on Dio HTTP requests while keeping it in the vault for socket/chat.

**Architecture:** Pure helpers manage GetStorage key `pending_post_login_route` and validate against known `RoutePage` names. `resolveWebInitialRoute` gates unauthenticated boots to `/login` and stashes a recoverable hash. `AuthController.login` consumes the pending route after vault + socket bootstrap. `DioInterceptor` keeps `Authorization` only.

**Tech Stack:** Flutter/Dart, GetX, GetStorage, Dio, `SecureSessionStorage`, `flutter_test`

## Global Constraints

- Follow `AGENTS.md`: GetX, package imports `package:hanigold_admin/...`, `AppLogger` (no `print` in new code), do not weaken lints.
- Do not change `pagehide` / last-tab logout, WebSocket protocol, or desktop `--route=` tear-off boot.
- Keep writing `x-session-id` into `SecureSessionStorage` on login; only remove the Dio request header.
- Pending route lives in GetStorage (not secure vault) so it survives `clearStoredSessionSync`.
- After modifying Dart sources in a session, run `graphify update .` once at the end (not per task).

---

## File Structure

| File | Responsibility |
| --- | --- |
| `lib/src/config/pending_post_login_route.dart` | **Create.** Pure pending-route save/consume/validate + unauthenticated initial-route resolution. |
| `lib/src/config/routes/route_page.dart` | **Modify.** Expose `knownRouteNames` set from registered `GetPage.name` values. |
| `lib/src/config/session_bootstrap.dart` | **Modify.** Wire `resolveWebInitialRoute` to session gate + pending helpers. |
| `lib/src/domain/auth/controller/auth.controller.dart` | **Modify.** Navigate to consumed pending route (or `/home`) after login. |
| `lib/src/config/network/dio_Interceptor.dart` | **Modify.** Remove `x-session-id` header injection. |
| `test/pending_post_login_route_test.dart` | **Create.** Unit tests for pending helpers and unauthenticated boot. |
| `test/dio_interceptor_session_header_test.dart` | **Create.** Assert interceptor does not set `x-session-id`. |

---

### Task 1: Pending post-login route helpers (TDD)

**Files:**
- Create: `lib/src/config/pending_post_login_route.dart`
- Test: `test/pending_post_login_route_test.dart`

**Interfaces:**
- Consumes: `GetStorage`, route name `Set<String>`
- Produces:
  - `const String pendingPostLoginRouteKey = 'pending_post_login_route'`
  - `const Set<String> pendingBootstrapOnlyRoutes = {'/splash', '/login'}`
  - `bool isPendingPostLoginRouteAllowed(String? route, Set<String> knownRouteNames)`
  - `void savePendingPostLoginRoute(String? route, {required Set<String> knownRouteNames, GetStorage? box})`
  - `String? consumePendingPostLoginRoute({GetStorage? box})` — read + remove; returns null if empty/missing
  - `String resolveUnauthenticatedWebBootRoute({required String? hashRoute, required Set<String> knownRouteNames, GetStorage? box})` — may save pending; always returns `'/login'`

- [ ] **Step 1: Write the failing test file**

Create `test/pending_post_login_route_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/pending_post_login_route_test.dart
```

Expected: FAIL — target library / symbols not found.

- [ ] **Step 3: Write minimal implementation**

Create `lib/src/config/pending_post_login_route.dart`:

```dart
import 'package:get_storage/get_storage.dart';

import 'package:hanigold_admin/src/config/logger/app_logger.dart';

const String pendingPostLoginRouteKey = 'pending_post_login_route';

const Set<String> pendingBootstrapOnlyRoutes = {'/splash', '/login'};

bool isPendingPostLoginRouteAllowed(
  String? route,
  Set<String> knownRouteNames,
) {
  if (route == null || route.isEmpty) return false;
  if (pendingBootstrapOnlyRoutes.contains(route)) return false;
  return knownRouteNames.contains(route);
}

void savePendingPostLoginRoute(
  String? route, {
  required Set<String> knownRouteNames,
  GetStorage? box,
}) {
  if (!isPendingPostLoginRouteAllowed(route, knownRouteNames)) return;
  try {
    (box ?? GetStorage()).write(pendingPostLoginRouteKey, route);
  } catch (e, s) {
    AppLogger.e('savePendingPostLoginRoute failed', e, s);
  }
}

String? consumePendingPostLoginRoute({GetStorage? box}) {
  final storage = box ?? GetStorage();
  try {
    final raw = storage.read(pendingPostLoginRouteKey);
    storage.remove(pendingPostLoginRouteKey);
    if (raw == null) return null;
    final route = raw.toString().trim();
    return route.isEmpty ? null : route;
  } catch (e, s) {
    AppLogger.e('consumePendingPostLoginRoute failed', e, s);
    return null;
  }
}

/// Unauthenticated web boot: always `/login`; may persist [hashRoute] as pending.
String resolveUnauthenticatedWebBootRoute({
  required String? hashRoute,
  required Set<String> knownRouteNames,
  GetStorage? box,
}) {
  savePendingPostLoginRoute(
    hashRoute,
    knownRouteNames: knownRouteNames,
    box: box,
  );
  return '/login';
}
```

- [ ] **Step 4: Run tests and verify they pass**

Run:

```bash
flutter test test/pending_post_login_route_test.dart
```

Expected: All PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/config/pending_post_login_route.dart test/pending_post_login_route_test.dart
git commit -m "feat(session): add pending post-login route helpers for web refresh"
```

---

### Task 2: Expose known route names + gate `resolveWebInitialRoute`

**Files:**
- Modify: `lib/src/config/routes/route_page.dart` (add getter near `routePage`)
- Modify: `lib/src/config/session_bootstrap.dart`
- Test: extend `test/pending_post_login_route_test.dart` **or** add cases in `test/session_invalidation_test.dart` only if pure logic stays in Task 1 (prefer no extra test file). Optional smoke: document behavior in existing group by importing `resolveUnauthenticatedWebBootRoute` — already covered in Task 1. This task wires production callers.

**Interfaces:**
- Consumes: `hasActiveStoredSession`, `parseHashRoute`, `resolveUnauthenticatedWebBootRoute`, `RoutePage.knownRouteNames`
- Produces:
  - `RoutePage.knownRouteNames` → `Set<String>`
  - Updated `String resolveWebInitialRoute(String fallback)` behavior

- [ ] **Step 1: Add `knownRouteNames` on `RoutePage`**

In `lib/src/config/routes/route_page.dart`, inside class `RoutePage`, add:

```dart
/// Exact `GetPage.name` values registered in [routePage].
static Set<String> get knownRouteNames =>
    routePage.map((page) => page.name).whereType<String>().toSet();
```

Place it immediately above or below the `routePage` list declaration.

- [ ] **Step 2: Update `resolveWebInitialRoute`**

In `lib/src/config/session_bootstrap.dart`:

1. Add imports:

```dart
import 'package:hanigold_admin/src/config/pending_post_login_route.dart';
import 'package:hanigold_admin/src/config/routes/route_page.dart';
```

2. Replace `resolveWebInitialRoute` with:

```dart
/// On Web, reads the hash route from the current URL; otherwise returns [fallback].
///
/// When there is no active stored session, always returns `/login` and may
/// persist a recoverable hash under [pendingPostLoginRouteKey].
String resolveWebInitialRoute(String fallback) {
  if (!kIsWeb) return fallback;
  final hashRoute = parseHashRoute(html.window.location.hash);
  if (hasActiveStoredSession()) {
    return hashRoute ?? fallback;
  }
  return resolveUnauthenticatedWebBootRoute(
    hashRoute: hashRoute,
    knownRouteNames: RoutePage.knownRouteNames,
  );
}
```

Do **not** change `resolvePostSplashRoute` behavior in this task.

- [ ] **Step 3: Static analysis on touched files**

Run:

```bash
flutter analyze lib/src/config/session_bootstrap.dart lib/src/config/routes/route_page.dart lib/src/config/pending_post_login_route.dart
```

Expected: No issues (or only pre-existing unrelated warnings).

- [ ] **Step 4: Re-run pending unit tests**

Run:

```bash
flutter test test/pending_post_login_route_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/config/routes/route_page.dart lib/src/config/session_bootstrap.dart
git commit -m "fix(web): gate unauthenticated hash boot to login with pending route"
```

---

### Task 3: Consume pending route after successful login

**Files:**
- Modify: `lib/src/domain/auth/controller/auth.controller.dart` (login success navigation ~line 128)
- Test: `test/pending_post_login_route_test.dart` (already covers `consumePendingPostLoginRoute`; no AuthController widget test required)

**Interfaces:**
- Consumes: `consumePendingPostLoginRoute()`, `RoutePage.knownRouteNames` (re-validate before navigate)
- Produces: post-login navigation to pending or `/home`

- [ ] **Step 1: Add imports to `auth.controller.dart`**

```dart
import 'package:hanigold_admin/src/config/pending_post_login_route.dart';
import 'package:hanigold_admin/src/config/routes/route_page.dart';
```

(Skip either import if already present.)

- [ ] **Step 2: Replace hard-coded home navigation**

Replace:

```dart
        registerChatControllerIfNeeded();
        Get.offNamed('/home');
```

with:

```dart
        registerChatControllerIfNeeded();
        final pending = consumePendingPostLoginRoute();
        final destination =
            isPendingPostLoginRouteAllowed(pending, RoutePage.knownRouteNames)
                ? pending!
                : '/home';
        Get.offNamed(destination);
```

Keep the surrounding order unchanged: write vault → FAB counts → `resetManualDisconnect` → `bootstrapSocketConnection` → `registerChatControllerIfNeeded` → navigate → remember-me persist.

- [ ] **Step 3: Analyze auth controller**

Run:

```bash
flutter analyze lib/src/domain/auth/controller/auth.controller.dart
```

Expected: No new issues.

- [ ] **Step 4: Commit**

```bash
git add lib/src/domain/auth/controller/auth.controller.dart
git commit -m "feat(auth): restore pending web route after successful login"
```

---

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

### Task 5: Verification + graphify

**Files:** none new (verification only)

- [ ] **Step 1: Run focused + related session tests**

Run:

```bash
flutter test test/pending_post_login_route_test.dart test/dio_interceptor_session_header_test.dart test/session_invalidation_test.dart test/secure_session_storage_test.dart
```

Expected: All PASS.

- [ ] **Step 2: Analyze changed production files**

Run:

```bash
flutter analyze lib/src/config/pending_post_login_route.dart lib/src/config/session_bootstrap.dart lib/src/config/routes/route_page.dart lib/src/domain/auth/controller/auth.controller.dart lib/src/config/network/dio_Interceptor.dart
```

Expected: No issues in these files.

- [ ] **Step 3: Manual web checklist (engineer)**

1. Login → open `#/listUserInfoTransaction` → F5 → login screen (no 401 spam from that page before login).
2. Login again → lands on list; Dio has `Authorization`, no `x-session-id` header; socket identifies with vault `sessionId`.
3. Two tabs → close one → other keeps session.
4. Close last tab → reopen → login required.

- [ ] **Step 4: Update knowledge graph**

Run from repo root:

```bash
graphify update .
```

- [ ] **Step 5: Commit graphify outputs only if they changed and are normally tracked**

```bash
git add graphify-out/GRAPH_REPORT.md graphify-out/graph.json graphify-out/manifest.json
git status
```

If those files changed:

```bash
git commit -m "chore: refresh graphify after session boot and Dio header changes"
```

If unchanged, skip commit.

---

## Spec coverage self-check

| Spec requirement | Task |
| --- | --- |
| Unauthenticated boot → `/login` | Task 2 |
| Save recoverable hash pending | Task 1–2 |
| Restore pending after login | Task 3 |
| Remove Dio `x-session-id` header | Task 4 |
| Keep vault `x-session-id` for socket/chat | Task 3–4 (no removal of writes) |
| Keep Dio `Authorization` | Task 4 |
| Unit tests for pending / bootstrap-only / consume | Task 1 |
| Manual web scenarios | Task 5 |
| No pagehide / WS protocol / tear-off changes | Global Constraints |

## Placeholder / consistency self-check

- No TBD/TODO placeholders in steps.
- Symbols consistent: `pendingPostLoginRouteKey`, `savePendingPostLoginRoute`, `consumePendingPostLoginRoute`, `resolveUnauthenticatedWebBootRoute`, `isPendingPostLoginRouteAllowed`, `RoutePage.knownRouteNames`.
- Auth re-validates pending with `isPendingPostLoginRouteAllowed` before `Get.offNamed` so a stale unknown value cannot navigate.
