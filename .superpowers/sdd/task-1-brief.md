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
