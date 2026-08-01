# Web refresh session → login restore + Dio session header

**Date:** 2026-08-01  
**Status:** Approved for implementation planning  
**Scope:** Flutter web session boot after refresh; Dio `x-session-id` header removal

## Problem

On web refresh, `pagehide` intentionally clears the last-tab session (`performTabCloseLogoutSync` → `clearStoredSessionSync`). After restart, `resolveWebInitialRoute` still uses the URL hash as `initialRoute` (e.g. `/listUserInfoTransaction`) even though `SecureSessionStorage` is empty.

Observed failure mode:

1. Dio requests leave with only `{content-type: application/json}` (no `Authorization`) → HTTP 401.
2. Socket logs `No credentials yet` / `No stored session, skipping reconnection`.
3. Chat cannot identify because `clientId` / `sessionId` are missing from the vault.

Separately: authoritative HTTP APIs no longer require `x-session-id` on requests. Attaching it from `DioInterceptor` is unnecessary for HTTP. Chat/socket still require `sessionId` from `SecureSessionStorage` (not from Dio).

## Goals

1. Unauthenticated web boot always lands on `/login` (never a protected deep-link).
2. Preserve the previous hash route and restore it after successful login.
3. Remove `x-session-id` from Dio request headers only; keep writing/reading it in `SecureSessionStorage` for socket/chat.
4. Keep injecting `Authorization` on Dio from the vault.

## Non-goals

- Changing `pagehide` / last-tab logout behavior (refresh logout remains intentional).
- Changing WebSocket protocol, identification payload shape, or `SocketSessionGuard`.
- Desktop tear-off `--route=` boot path.
- Network-drop-without-refresh session handling (vault stays intact today).

## Chosen approach

**Boot gate + pending route in GetStorage** (not secure vault):

- If `hasActiveStoredSession()` → keep current hash deep-link behavior.
- If no session → stash recoverable hash in GetStorage key `pending_post_login_route`, return `/login`.
- After successful login → navigate to pending if valid, else `/home`, then clear pending.
- Strip `x-session-id` from `DioInterceptor`; leave Authorization as-is.

Rejected alternatives:

- Always boot via splash (extra delay; user wants direct `/login`).
- Full GetX auth middleware on every route (broader than needed for this bug).

## Architecture

```
pagehide (last tab) → clear session (intentional)
        ↓
boot: hash=/X, session empty
        ↓
pending_post_login_route=/X → initialRoute=/login
        ↓
login success → write Authorization + x-session-id to vault
        ↓
bootstrap socket/chat → Get.offNamed(pending ?? /home) → clear pending
```

HTTP and WebSocket remain separate consumers of `SecureSessionStorage`:

| Consumer | Uses `Authorization` | Uses `x-session-id` |
| --- | --- | --- |
| `DioInterceptor` | Yes (header) | **No** (removed) |
| `SocketService` / chat controllers / `SocketSessionGuard` | N/A | Yes (vault / payload) |

## File-level changes

### `lib/src/config/network/dio_Interceptor.dart`

- Remove reading and attaching `x-session-id` request header.
- Keep `Authorization: Bearer …` when present.

### `lib/src/config/session_bootstrap.dart` (+ helpers as needed)

- Extend web initial-route resolution:
  - Session present → existing `parseHashRoute` / fallback behavior.
  - Session absent → persist pending route when allowed; always return `/login`.
- Pending storage: GetStorage key `pending_post_login_route` (plaintext path only; not a secret).

### Pending route rules

- **Do not store:** `null`/empty, `/splash`, `/login`.
- **Store only if** the path matches a `GetPage.name` in `RoutePage.routePage` (exact string match, e.g. `/listUserInfoTransaction`).
- **Not in `RoutePage`:** do not store; post-login falls back to `/home`.
- Pending must survive `clearStoredSessionSync` (hence GetStorage, not secure session keys).
- Helper API (pure, testable): `savePendingPostLoginRoute` / `consumePendingPostLoginRoute` living next to session bootstrap or `web_route_hash`.

### `lib/src/domain/auth/controller/auth.controller.dart`

- After successful credential write, socket bootstrap, and chat registration (existing order):
  - Read pending → `Get.offNamed(validPending ?? '/home')`.
  - Remove pending key.
- Failed login leaves pending intact for the next attempt.

### Tests

- Unit: empty session + protected hash → `/login` and pending set.
- Unit: empty session + `#/login` or `#/splash` → `/login`, pending not set.
- Unit: consume pending after “login success” navigation helper → correct destination and key cleared.
- Existing Dio/socket session tests remain green; add assertion that interceptor does not set `x-session-id` if covered by tests.

## Edge cases

| Scenario | Behavior |
| --- | --- |
| Refresh with empty session + protected hash | `/login` + pending saved |
| Refresh on `#/login` or `#/splash` | `/login`, no pending |
| Refresh while another tab kept shared session alive | Deep-link as today |
| Failed login | Pending unchanged |
| Success + missing/invalid pending | `/home` |
| Close last tab, reopen | Login (no auto deep-link without pending from that close) |
| Offline without refresh | Out of scope; vault unchanged |
| Desktop `--route=` | Out of scope |

## Error handling

- GetStorage pending read/write failure → log via `AppLogger`; boot still `/login`; post-login still `/home`.
- Socket bootstrap failure after login → still navigate (preserve current behavior).
- If any HTTP API still requires `x-session-id` header → that endpoint alone will fail; product assumption is authoritative HTTP no longer needs it. Chat must not regress.

## Manual test plan (Web)

1. Login → open `/listUserInfoTransaction` → F5 → login screen → login again → land on same list; Dio has `Authorization`, no `x-session-id` header; socket identifies with vault `sessionId`.
2. Two tabs open → close one → remaining tab keeps session.
3. Close last tab → reopen app → login required.
4. After login, chat unread/FAB and WS identification work with `sessionId` from vault.

## Success criteria

- Refresh on a protected hash never issues authenticated API calls before login.
- Post-login restores the intended route when pending was set.
- Chat/socket still receive `sessionId` from storage after login.
- Dio request headers never include `x-session-id`.
