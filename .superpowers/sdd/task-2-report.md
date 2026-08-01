# Task 2 Report: Expose known route names + gate `resolveWebInitialRoute`

**Status:** DONE  
**Branch:** `feat/web-refresh-session-login-restore`  
**Commit:** `d269d37` — `fix(web): gate unauthenticated hash boot to login with pending route`

---

## Summary

Wired production web boot routing: `RoutePage.knownRouteNames` exposes registered `GetPage.name` values; `resolveWebInitialRoute` now gates unauthenticated boots to `/login` via Task 1's `resolveUnauthenticatedWebBootRoute` (may stash a recoverable hash). Authenticated boots unchanged (`hashRoute ?? fallback`). `resolvePostSplashRoute` untouched.

---

## Verification

### Static analysis (Step 3)

```text
flutter analyze lib/src/config/session_bootstrap.dart lib/src/config/routes/route_page.dart lib/src/config/pending_post_login_route.dart
→ No issues found!
```

### Unit tests (Step 4)

```text
flutter test test/pending_post_login_route_test.dart
→ 00:00 +7: All tests passed!
```

No new test file per brief (Task 1 helpers already cover pending logic; this task wires callers only).

---

## Files Changed

| File | Action |
| --- | --- |
| `lib/src/config/routes/route_page.dart` | Added `knownRouteNames` getter above `routePage` |
| `lib/src/config/session_bootstrap.dart` | Gated `resolveWebInitialRoute`; imports for pending helpers + `RoutePage` |

---

## Public API / Behavior

- **`RoutePage.knownRouteNames`** — `Set<String>` from `routePage.map((page) => page.name).whereType<String>()`
- **`resolveWebInitialRoute(fallback)`**
  - Non-web → `fallback`
  - Web + active session → `hashRoute ?? fallback`
  - Web + no session → `resolveUnauthenticatedWebBootRoute(...)` → always `'/login'`, may persist pending

---

## Self-Review

| Check | Result |
| --- | --- |
| Matches brief verbatim (getter, function body, imports) | Yes |
| Does not change `resolvePostSplashRoute` | Yes |
| Does not touch `AuthController` / `DioInterceptor` | Yes |
| Uses Task 1 `resolveUnauthenticatedWebBootRoute` | Yes |
| Package imports | Yes |
| `flutter analyze` clean on touched files | Yes |
| Commit message per brief | Yes |

**Logic walkthrough:**

1. `knownRouteNames` is derived at access time from the live `routePage` list — stays in sync when routes are added/removed.
2. Unauthenticated web refresh on `#/listUserInfoTransaction` → pending saved (if known) + initial route `/login` instead of deep-linking protected screen.
3. Authenticated web boot still honors hash or falls back to `/splash` (via `main.dart` caller).

---

## Concerns

1. **No integration test for `resolveWebInitialRoute`:** Brief defers wiring tests to Task 1 unit coverage; production gate is not directly unit-tested (would need `kIsWeb` / `html.window` mocking). Task 3+ may add session-bootstrap tests if desired.

2. **`knownRouteNames` recomputes on every unauthenticated boot:** Cheap for ~60 routes; acceptable unless hot-path profiling says otherwise.

3. **Circular import risk:** `session_bootstrap` → `route_page` → many bindings/views; pre-existing pattern for route table access. No new cycle introduced beyond brief's required import.

---

## Next Task Dependencies

Task 3 can rely on:

- Unauthenticated web boots landing on `/login` with optional `pending_post_login_route` in GetStorage
- `RoutePage.knownRouteNames` for re-validation after login (`consumePendingPostLoginRoute` + `isPendingPostLoginRouteAllowed`)

---

## Commands Run

```bash
flutter analyze lib/src/config/session_bootstrap.dart lib/src/config/routes/route_page.dart lib/src/config/pending_post_login_route.dart
flutter test test/pending_post_login_route_test.dart
git add lib/src/config/routes/route_page.dart lib/src/config/session_bootstrap.dart
git commit -m "fix(web): gate unauthenticated hash boot to login with pending route"
graphify update .
```
