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
