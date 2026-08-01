# Disable pagehide session logout (explicit logout only)

**Date:** 2026-08-01  
**Status:** Approved for implementation planning  
**Supersedes (in part):** Prior product choice that F5/last-tab `pagehide` cleared the vault (design `2026-08-01-web-refresh-session-login-restore`). Unauthenticated boot gate and Dio/`x-session-id` rules from that work remain.

## Problem

F5 triggers browser `pagehide` with `persisted=false`. Current `registerWebTabCloseLogout` treats last-tab `pagehide` as logout and calls `performTabCloseLogoutSync()` → vault cleared (`Authorization`, `x-session-id`, …). After reload the app boots without a session and sends the user to login even when the server session is still valid and the network never dropped.

## Goals

1. **F5 / refresh:** keep stored session; stay on the same deep link with `Authorization` on Dio.
2. **Closing the last tab and reopening later:** also keep stored session (Approach 3 — no pagehide clear).
3. **Explicit logout** (side menu / home) and **server-driven invalidation** still clear the vault and route to login.
4. **Do not change Socket protocol/dispatch.** Prefer zero edits to `SocketService`. If any socket-adjacent path is touched, errors and empty payloads must be caught/logged so they cannot white-screen the web app.

## Non-goals

- Grace-period / F5-vs-close heuristics (Approach 1 rejected).
- Keydown-only reload detection (Approach 2 rejected).
- Changes to Dio interceptor, pending post-login restore, or hash/`defaultRouteName` login sync (keep as-is).
- Changing WebSocket identification, message models, or reconnect policy beyond stopping logout-driven disconnect on `pagehide`.

## Chosen approach

**Remove shared-session clear from `pagehide`.** Session lives until explicit logout or server invalidation.

Rejected: deferred logout with grace; F5 key flag.

## Behavior matrix

| Event | Vault |
| --- | --- |
| F5 / browser refresh | Keep |
| Close last tab, reopen later | Keep |
| Explicit logout UI | Clear → `/login` |
| Socket invalid-session invalidation | Clear → `/login` (existing path) |
| Boot with active stored session | Deep-link / current hash (existing) |
| Boot without stored session | `/login` + pending/hash sync (existing) |

## File-level plan

### `lib/src/config/web_tab_logout_web.dart`

- On `pagehide`: may still update tab presence (`unregisterAndCheckIfLast`).
- **Must not** call `performTabCloseLogoutSync()` / clear vault / force socket logout-disconnect for session wipe.
- Presence-only path must be try/catch + `AppLogger` (already patterned); never rethrow into the browser event loop.

### `lib/src/config/web_tab_logout_logic.dart`

- Update docs/`shouldLogoutOnPageHide` semantics: either always return `false` for “clear session” intent, or stop using it as a clear gate and document that pagehide no longer clears session.
- Prefer keeping helpers for tests but changing callers so **no production path clears on pagehide**.
- `performTabCloseLogoutSync` / `performTabCloseLogout` may remain for explicit callers if any; if unused after this change, leave as dead helpers or only call from non-pagehide code — do not invent new call sites.

### `lib/main.dart`

- Keep `registerWebTabCloseLogout()` if it still registers presence; otherwise a no-op registration is fine.
- Do not alter `bootstrapSocketConnection` error handling.

### Tests (`test/web_tab_logout_test.dart`)

- Expectation flip: last-tab non-persisted `pagehide` must **not** imply session clear in the product sense.
- Update unit tests accordingly (e.g. `shouldLogoutOnPageHide` always false for clear, or new named helper `shouldClearSessionOnPageHide` → always `false`).
- Keep coverage that explicit `clearStoredSession` still works (existing session storage tests).

## Socket safety constraint (binding)

- **Default:** no changes inside `socket.service.dart` or chat socket controllers for this feature.
- Stopping pagehide logout means the dying page no longer runs logout-disconnect; the new load uses existing `bootstrapSocketConnection` when `hasActiveStoredSession()`.
- If implementation is forced to touch socket connect/disconnect:
  - Wrap in try/catch; log with `AppLogger`; never let exceptions escape to Flutter framework uncaught paths that blank the page.
  - Treat null/empty credentials or empty payloads as no-op / defer connect (existing “No credentials yet” style), not as hard crashes.

## Error handling

- Presence unregister / pagehide handler failures: log only.
- Explicit logout and invalidation paths unchanged.
- GetStorage / secure vault failures on explicit clear: existing logging.

## Manual test plan (Web)

1. Login → open a protected route → F5 → remain on that route; Dio has `Authorization`; no forced `/login`.
2. Explicit logout → `/login`; vault empty.
3. Two tabs → close one → other tab keeps session.
4. Close all tabs, reopen app URL later → still logged in until explicit logout or server invalidation (Approach 3).
5. After F5, chat/socket still connects when session present; no white screen on connect failure (existing handling).

## Success criteria

- F5 with valid stored session never clears vault via `pagehide`.
- Explicit logout still clears vault.
- No regression white screen from socket/pagehide handlers.
- Unauthenticated boot gate still works when vault is actually empty.
