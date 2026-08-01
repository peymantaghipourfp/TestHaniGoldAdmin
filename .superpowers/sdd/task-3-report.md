# Task 3 Report: Consume pending route after successful login

**Status:** DONE  
**Branch:** `feat/web-refresh-session-login-restore`  
**Commit:** `b60dda0` — `feat(auth): restore pending web route after successful login`

---

## Summary

After successful login, `AuthController.login` now consumes `pending_post_login_route` from GetStorage, re-validates via `isPendingPostLoginRouteAllowed` + `RoutePage.knownRouteNames`, and navigates to the pending route or falls back to `/home`. Vault writes, FAB counts, socket bootstrap, chat registration, navigation, and remember-me order unchanged.

---

## Verification

### Static analysis (Step 3)

```text
flutter analyze lib/src/domain/auth/controller/auth.controller.dart
→ 2 pre-existing info issues (avoid_print, use_build_context_synchronously); no new issues from this change
```

### Unit tests

```text
flutter test test/pending_post_login_route_test.dart
→ 00:00 +7: All tests passed!
```

No new test file per brief (`consumePendingPostLoginRoute` already covered in Task 1 tests).

---

## Files Changed

| File | Action |
| --- | --- |
| `lib/src/domain/auth/controller/auth.controller.dart` | Imports + pending-route consume/validate before `Get.offNamed` |

---

## Public API / Behavior

- **Login success navigation**
  - `consumePendingPostLoginRoute()` — reads and clears pending key
  - If allowed (`isPendingPostLoginRouteAllowed` + `RoutePage.knownRouteNames`) → navigate to pending
  - Else → `/home`

---

## Self-Review

| Check | Result |
| --- | --- |
| Matches brief verbatim (imports, navigation block) | Yes |
| Order: vault → FAB → socket → chat → navigate → remember-me | Yes |
| Re-validates pending against `knownRouteNames` | Yes |
| Package imports for pending helpers + `RoutePage` | Yes |
| No new analyze errors | Yes (2 pre-existing infos) |
| Commit message per brief | Yes |

**Logic walkthrough:**

1. Web refresh on protected hash → Task 2 saves pending + boots `/login`.
2. User logs in → pending consumed once; invalid/stale/unknown routes fall back to `/home`.
3. Desktop/mobile login without pending → `consume` returns null → `/home` (unchanged behavior).

---

## Concerns

1. **No AuthController widget/integration test:** Brief defers to Task 1 unit tests; end-to-end web refresh → login → deep-link restore not automated here.

2. **`RoutePage.knownRouteNames` recomputes on each login:** Same as Task 2 concern; cheap for current route table size.

3. **Pre-existing analyze infos in `auth.controller.dart`:** `avoid_print` and `use_build_context_synchronously` unrelated to this task.

---

## Next Task Dependencies

Downstream tasks can assume:

- Post-login navigation honors pending web route when valid
- Pending key is cleared on consume (one-shot restore)

---

## Commands Run

```bash
flutter analyze lib/src/domain/auth/controller/auth.controller.dart
flutter test test/pending_post_login_route_test.dart
git add lib/src/domain/auth/controller/auth.controller.dart
git commit -m "feat(auth): restore pending web route after successful login"
graphify update .
```
