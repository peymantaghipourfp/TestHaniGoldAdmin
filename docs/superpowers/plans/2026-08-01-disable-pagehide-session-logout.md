# Disable Pagehide Session Logout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop clearing the secure session vault on browser `pagehide` (F5 or tab close); keep session until explicit logout or server-driven invalidation.

**Architecture:** Change the pagehide gate so session clear is never triggered from web unload. Keep tab-presence unregister for multi-tab bookkeeping only. Leave `SocketService`, Dio, and unauthenticated-boot helpers untouched.

**Tech Stack:** Flutter/Dart, GetX, GetStorage, `universal_html` pagehide, `flutter_test`

## Global Constraints

- Follow `AGENTS.md`: package imports `package:hanigold_admin/...`, `AppLogger` (no `print`), do not weaken lints.
- **Do not edit** `lib/src/config/const/socket.service.dart` or chat socket controllers for this feature.
- Prefer zero socket disconnect calls from the pagehide path (removing `performTabCloseLogoutSync` from that path achieves this).
- If any socket-adjacent code is touched anyway: try/catch + `AppLogger`; empty/null credentials = no-op; never rethrow into the browser event loop (no white screen).
- Explicit logout (`clearStoredSession` in side menu / home) and `invalidateStoredSessionAndGoToLogin` must keep working.
- Unauthenticated boot gate + hash login sync remain as-is.
- After Dart edits in a session, run `graphify update .` once at the end (AST-only).

---

## File Structure

| File | Responsibility |
| --- | --- |
| `lib/src/config/web_tab_logout_logic.dart` | **Modify.** `shouldClearSessionOnPageHide` always `false`; keep clear helpers for non-pagehide use / tests. |
| `lib/src/config/web_tab_logout_web.dart` | **Modify.** pagehide = presence unregister only; never clear vault. |
| `lib/src/config/web_tab_logout_stub.dart` | **Unchanged** (already no-op register). |
| `lib/main.dart` | **Unchanged** (still calls `registerWebTabCloseLogout()` for presence). |
| `test/web_tab_logout_test.dart` | **Modify.** Expectations: pagehide never clears session intent. |

---

### Task 1: Flip pagehide clear gate (TDD) + presence-only web handler

**Files:**
- Modify: `lib/src/config/web_tab_logout_logic.dart`
- Modify: `lib/src/config/web_tab_logout_web.dart`
- Test: `test/web_tab_logout_test.dart`

**Interfaces:**
- Consumes: `WebTabPresence.unregisterAndCheckIfLast`, `AppLogger`
- Produces:
  - `bool shouldClearSessionOnPageHide({required bool isWeb, required bool persisted, bool isLastTab = true})` → always `false`
  - Deprecated alias: `shouldLogoutOnPageHide(...)` → calls `shouldClearSessionOnPageHide` (same signature, always `false`) for any leftover imports
  - `registerWebTabCloseLogout()` still starts presence and listens to pagehide, but never calls `performTabCloseLogoutSync`

- [ ] **Step 1: Update failing/characterizing tests first**

Replace the `shouldLogoutOnPageHide` group in `test/web_tab_logout_test.dart` with:

```dart
  group('shouldClearSessionOnPageHide', () {
    test('never clears session on pagehide (explicit logout only)', () {
      expect(
        shouldClearSessionOnPageHide(isWeb: true, persisted: false),
        isFalse,
      );
      expect(
        shouldClearSessionOnPageHide(
          isWeb: true,
          persisted: false,
          isLastTab: true,
        ),
        isFalse,
      );
      expect(
        shouldClearSessionOnPageHide(
          isWeb: true,
          persisted: false,
          isLastTab: false,
        ),
        isFalse,
      );
      expect(
        shouldClearSessionOnPageHide(isWeb: true, persisted: true),
        isFalse,
      );
      expect(
        shouldClearSessionOnPageHide(isWeb: false, persisted: false),
        isFalse,
      );
    });

    test('legacy shouldLogoutOnPageHide matches clear gate (always false)', () {
      expect(
        shouldLogoutOnPageHide(isWeb: true, persisted: false, isLastTab: true),
        isFalse,
      );
    });
  });
```

Keep the existing `clearStoredSessionSync` and `performTabCloseLogoutSync` groups unchanged (explicit clear still works; helper still must not throw).

- [ ] **Step 2: Run tests — expect RED**

Run:

```bash
flutter test test/web_tab_logout_test.dart
```

Expected: FAIL — `shouldClearSessionOnPageHide` not defined and/or old expectations still expecting `true`.

- [ ] **Step 3: Implement logic**

Replace contents of `lib/src/config/web_tab_logout_logic.dart` with:

```dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/socket.service.dart';
import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/session_storage.dart';

/// Whether a browser `pagehide` may clear the shared session vault.
///
/// Product rule (explicit logout only): always `false`. F5 and last-tab close
/// must not wipe `Authorization` / `x-session-id`. Session ends via UI logout
/// or server-driven invalidation only.
bool shouldClearSessionOnPageHide({
  required bool isWeb,
  required bool persisted,
  bool isLastTab = true,
}) {
  return false;
}

/// Legacy name for [shouldClearSessionOnPageHide] (always `false`).
bool shouldLogoutOnPageHide({
  required bool isWeb,
  required bool persisted,
  bool isLastTab = true,
}) {
  return shouldClearSessionOnPageHide(
    isWeb: isWeb,
    persisted: persisted,
    isLastTab: isLastTab,
  );
}

/// Clears vault + session controllers and best-effort socket disconnect.
///
/// Not used from `pagehide` anymore. Kept for tests / any future non-unload
/// caller. Must never be wired back into `registerWebTabCloseLogout`.
void performTabCloseLogoutSync() {
  try {
    clearStoredSessionSync();
    clearSessionControllers();
  } catch (e, s) {
    AppLogger.e('Session clear during tab close logout', e, s);
  }

  try {
    if (Get.isRegistered<SocketService>()) {
      unawaited(SocketService.to.disconnect());
    }
  } catch (e, s) {
    AppLogger.e('Socket disconnect during tab close logout', e, s);
  }
}

/// Async variant of [performTabCloseLogoutSync] (not used from pagehide).
Future<void> performTabCloseLogout() async {
  try {
    await clearStoredSession();
    clearSessionControllers();
  } catch (e, s) {
    AppLogger.e('Session clear during tab close logout', e, s);
  }

  try {
    if (Get.isRegistered<SocketService>()) {
      await SocketService.to.disconnect();
    }
  } catch (e, s) {
    AppLogger.e('Socket disconnect during tab close logout', e, s);
  }
}
```

- [ ] **Step 4: Implement presence-only web pagehide handler**

Replace `lib/src/config/web_tab_logout_web.dart` with:

```dart
import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/web_tab_logout_logic.dart';
import 'package:hanigold_admin/src/config/web_tab_presence_web.dart';
import 'package:universal_html/html.dart' as html;

bool _readPageHidePersisted(html.Event event) {
  try {
    return (event as dynamic).persisted == true;
  } catch (_) {
    return false;
  }
}

WebTabPresence? _tabPresence;

/// Registers tab presence + a [pagehide] handler that never clears the session.
///
/// Last-tab close and F5 both fire `pagehide`; vault wipe is disabled by
/// [shouldClearSessionOnPageHide]. Presence unregister still runs for
/// multi-tab bookkeeping.
void registerWebTabCloseLogout() {
  try {
    _tabPresence?.dispose();
    _tabPresence = WebTabPresence()..start();

    html.window.onPageHide.listen((event) {
      try {
        final persisted = _readPageHidePersisted(event);
        final isLastTab = _tabPresence?.unregisterAndCheckIfLast() ?? true;
        if (!shouldClearSessionOnPageHide(
          isWeb: true,
          persisted: persisted,
          isLastTab: isLastTab,
        )) {
          AppLogger.d(
            'pagehide: presence updated, session vault kept '
            '(persisted=$persisted, isLastTab=$isLastTab)',
          );
          return;
        }
        // Unreachable while shouldClearSessionOnPageHide is always false.
        // Intentionally no performTabCloseLogoutSync() — do not reintroduce.
        AppLogger.w(
          'pagehide: clear gate returned true unexpectedly; refusing vault wipe',
        );
      } catch (e, s) {
        AppLogger.e('pagehide tab presence handler failed', e, s);
      }
    });
  } catch (e, s) {
    AppLogger.e('registerWebTabCloseLogout failed', e, s);
  }
}
```

Critical: **do not** call `performTabCloseLogoutSync()` anywhere in this file.

- [ ] **Step 5: Run tests — expect GREEN**

Run:

```bash
flutter test test/web_tab_logout_test.dart
```

Expected: All PASS.

- [ ] **Step 6: Analyze touched files**

Run:

```bash
flutter analyze lib/src/config/web_tab_logout_logic.dart lib/src/config/web_tab_logout_web.dart
```

Expected: No issues in these files.

- [ ] **Step 7: Commit**

```bash
git add lib/src/config/web_tab_logout_logic.dart lib/src/config/web_tab_logout_web.dart test/web_tab_logout_test.dart
git commit -m "fix(web): keep session on pagehide; clear only via explicit logout"
```

---

### Task 2: Verification + graphify

**Files:** none required beyond graphify outputs if regenerated

- [ ] **Step 1: Run related session tests**

Run:

```bash
flutter test test/web_tab_logout_test.dart test/pending_post_login_route_test.dart test/web_unauthenticated_boot_test.dart test/secure_session_storage_test.dart test/dio_interceptor_session_header_test.dart
```

Expected: All PASS.  
Note: If `test/web_unauthenticated_boot_test.dart` or `test/pending_post_login_route_test.dart` is missing on this branch, skip only the missing file and report it; do not recreate unrelated features.

- [ ] **Step 2: Confirm no socket file edits**

Run:

```bash
git diff --name-only HEAD~1..HEAD
```

(or the range covering Task 1 commits)

Expected: no `socket.service.dart` / chat controller paths.

- [ ] **Step 3: Manual web checklist (engineer)**

1. Login → protected route → F5 → stay logged in; Dio shows `Authorization`.
2. Explicit logout → `/login`.
3. Two tabs → close one → other keeps session.
4. Close all tabs, reopen later → still logged in (Approach 3).
5. No white screen after F5 if socket reconnect is slow/fails.

- [ ] **Step 4: Update knowledge graph**

```bash
graphify update .
```

- [ ] **Step 5: Commit graphify if tracked outputs changed**

```bash
git add graphify-out/GRAPH_REPORT.md graphify-out/graph.json graphify-out/manifest.json
git status
```

If changed:

```bash
git commit -m "chore: refresh graphify after disabling pagehide session logout"
```

If unchanged, skip commit.

---

## Spec coverage self-check

| Spec requirement | Task |
| --- | --- |
| F5 keeps vault | Task 1 (no clear on pagehide) |
| Last-tab close keeps vault | Task 1 |
| Explicit logout still clears | Task 1 (unchanged `clearStoredSessionSync` test + UI paths untouched) |
| No SocketService edits | Global Constraints + Task 2 check |
| pagehide errors logged, not rethrown | Task 1 web handler try/catch |
| Tests updated | Task 1 |
| Manual verification | Task 2 |

## Placeholder / consistency self-check

- No TBD/TODO placeholders.
- Names consistent: `shouldClearSessionOnPageHide`, `shouldLogoutOnPageHide` alias, `registerWebTabCloseLogout`, no `performTabCloseLogoutSync` in web handler.
- Socket safety: disconnect removed from pagehide path only; helpers retain try/catch if ever called.
