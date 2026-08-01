# Task 1 Report: Pending post-login route helpers

**Status:** DONE_WITH_CONCERNS  
**Branch:** `feat/web-refresh-session-login-restore`  
**Commit:** `7272f14` — `feat(session): add pending post-login route helpers for web refresh`

---

## Summary

Implemented pure GetStorage helpers for persisting and restoring a post-login route during unauthenticated web boot. No wiring to `session_bootstrap` or `AuthController` (per task scope).

---

## TDD Evidence

### RED (Step 2)

```text
flutter test test/pending_post_login_route_test.dart
→ FAIL — lib/src/config/pending_post_login_route.dart not found; symbols undefined
```

Compilation failed as expected before implementation existed.

### GREEN (Step 4)

After implementation (+ minimal test harness for `path_provider`):

```text
flutter test test/pending_post_login_route_test.dart
→ 00:00 +7: All tests passed!
```

| Group | Tests |
| --- | --- |
| `isPendingPostLoginRouteAllowed` | 3 |
| `save + consume` | 2 |
| `resolveUnauthenticatedWebBootRoute` | 2 |

---

## Files Changed

| File | Action |
| --- | --- |
| `lib/src/config/pending_post_login_route.dart` | Created — helpers, constants, AppLogger error handling |
| `test/pending_post_login_route_test.dart` | Created — unit tests per brief (+ path_provider mock in `setUpAll`) |

---

## Public API (as specified)

- `pendingPostLoginRouteKey` — `'pending_post_login_route'`
- `pendingBootstrapOnlyRoutes` — `{'/splash', '/login'}`
- `isPendingPostLoginRouteAllowed(route, knownRouteNames)` — validates route against allowlist
- `savePendingPostLoginRoute(route, {knownRouteNames, box})` — writes allowed route to GetStorage
- `consumePendingPostLoginRoute({box})` — read + remove; returns `null` if empty/missing
- `resolveUnauthenticatedWebBootRoute({hashRoute, knownRouteNames, box})` — may save pending; always returns `'/login'`

---

## Self-Review

| Check | Result |
| --- | --- |
| Matches brief signatures and behavior | Yes |
| Package imports (`package:hanigold_admin/...`) | Yes |
| AppLogger for errors (no `print`) | Yes |
| Optional `GetStorage? box` for testability | Yes |
| Bootstrap routes excluded from pending save | Yes |
| Unknown routes rejected | Yes |
| `consume` clears key after read | Yes |
| No session_bootstrap / AuthController wiring | Yes |
| Linter clean on new files | Yes |

**Logic walkthrough:**

1. `isPendingPostLoginRouteAllowed` — rejects null/empty, `/splash`, `/login`, and routes not in `knownRouteNames`.
2. `savePendingPostLoginRoute` — no-op unless allowed; try/catch with `AppLogger.e`.
3. `consumePendingPostLoginRoute` — removes key before returning trimmed value; empty string → `null`.
4. `resolveUnauthenticatedWebBootRoute` — delegates save then always returns `'/login'`.

---

## Concerns

1. **Test harness deviation:** Brief specified verbatim test file without Flutter binding / `path_provider` mock. On Windows VM tests, `GetStorage.init` fails with `MissingPluginException` without it. Added the same `TestWidgetsFlutterBinding` + `MethodChannel` mock pattern used in `test/web_tab_logout_test.dart`. All test *cases* and assertions match the brief; only `setUpAll` setup differs.

2. **GetStorage test artifacts:** Running tests created untracked `pending_post_login_route_test.bak` and `pending_post_login_route_test.gs` in the worktree root (GetStorage named-bucket side files). Not committed; consider adding to `.gitignore` if they recur.

3. **Default `GetStorage()` in production:** When `box` is omitted, helpers use the default GetStorage instance (same pattern as other config helpers). Callers in later tasks should pass an explicit box if isolation is needed.

4. **No re-validation on consume:** `consumePendingPostLoginRoute` does not re-check `knownRouteNames`. Later tasks should validate before navigation if the route table can change between save and login.

---

## Next Task Dependencies

Task 2+ can import:

```dart
import 'package:hanigold_admin/src/config/pending_post_login_route.dart';
```

Use `resolveUnauthenticatedWebBootRoute` in unauthenticated web boot and `consumePendingPostLoginRoute` after successful login.

---

## Commands Run

```bash
flutter test test/pending_post_login_route_test.dart   # RED then GREEN
git add lib/src/config/pending_post_login_route.dart test/pending_post_login_route_test.dart
git commit -m "feat(session): add pending post-login route helpers for web refresh"
graphify update .
```
