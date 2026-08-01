# Task 4 Report: Remove `x-session-id` from DioInterceptor (TDD)

**Status:** DONE  
**Branch:** `feat/web-refresh-session-login-restore`  
**Commit:** `12c1152` — `fix(network): stop attaching x-session-id on Dio requests`

---

## Summary

`DioInterceptor.onRequest` no longer reads or attaches `x-session-id` on outgoing Dio HTTP requests. `Authorization` header injection is unchanged. Vault writes in `AuthController` / `AuthRepository` were not touched; socket/chat consumers still read `x-session-id` from `SecureSessionStorage`.

---

## TDD Evidence

### RED — Step 2 (before interceptor change)

```text
flutter test test/dio_interceptor_session_header_test.dart
→ onRequest sets Authorization but not x-session-id [E]
  Expected: false
    Actual: <true>

🐛 Headers: {Authorization: Bearer test-token, x-session-id: session-abc}
```

Test harness note: initial run failed on `MissingPluginException` for `path_provider`; fixed by adding `TestWidgetsFlutterBinding.ensureInitialized()` + `MethodChannel` mock (same pattern as `pending_post_login_route_test.dart`). Used Dio-chain capture approach per brief (not `RequestInterceptorHandler` subclass).

### GREEN — Step 4 (after interceptor change)

```text
flutter test test/dio_interceptor_session_header_test.dart test/pending_post_login_route_test.dart
→ 00:00 +8: All tests passed!

🐛 Headers: {Authorization: Bearer test-token}
```

| Suite | Tests | Result |
| --- | --- | --- |
| `dio_interceptor_session_header_test.dart` | 1 | PASS |
| `pending_post_login_route_test.dart` | 7 | PASS |
| **Total** | **8** | **All PASS** |

---

## Files Changed

| File | Action |
| --- | --- |
| `lib/src/config/network/dio_Interceptor.dart` | Removed `x-session-id` read + header injection |
| `test/dio_interceptor_session_header_test.dart` | **Created** — asserts Authorization set, `x-session-id` absent |

---

## Public API / Behavior

- **Dio HTTP requests:** `Authorization: Bearer <token>` when vault has token; no `x-session-id` header.
- **Unchanged:** `SecureSessionStorage` still stores `x-session-id` on login (`AuthController`, `AuthRepository`); `SocketService`, `ChatController`, `BaseController` still read vault `x-session-id` for socket/chat.

---

## Self-Review

| Check | Result |
| --- | --- |
| TDD: failing test before fix | Yes (RED on `containsKey('x-session-id')`) |
| Authorization header preserved | Yes |
| Vault writes not removed | Yes |
| Commit message per brief | Yes |
| Pending-route tests still green | Yes (7/7) |

---

## Concerns

1. **No end-to-end HTTP test:** Unit test covers interceptor only; no live API call verification that backends accept requests without `x-session-id` (product assumption per design spec).

2. **Test harness boilerplate:** `path_provider` mock required for `GetStorage.init` in unit tests; not in brief template but consistent with sibling tests.

3. **graphify-out churn:** `graphify update .` modified `graphify-out/` (unstaged, not committed).

---

## Commands Run

```bash
flutter test test/dio_interceptor_session_header_test.dart          # RED
flutter test test/dio_interceptor_session_header_test.dart \
             test/pending_post_login_route_test.dart                 # GREEN
git add lib/src/config/network/dio_Interceptor.dart \
        test/dio_interceptor_session_header_test.dart
git commit -m "fix(network): stop attaching x-session-id on Dio requests"
graphify update .
```
