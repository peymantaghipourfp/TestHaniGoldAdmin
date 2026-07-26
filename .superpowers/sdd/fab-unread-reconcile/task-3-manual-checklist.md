# Task 3: Manual verification checklist (FAB unread reconcile)

**Feature:** FAB unread/mention sync via `chat.seen` + debounced server reconcile (`requestChatUnreadTotal` / `requestChatUnreadMentionTotal`)  
**Plan:** FAB cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-fab-cross-tab-unread.md`)  
**Environment:** Web (two tabs) or Windows desktop (tear-off windows) — human run only  
**Unit tests:** `test/chat_fab_controller_test.dart` (groups `ChatFabController chat.seen`, `ChatFabController scheduleFabUnreadReconcile`)  
**Task 1–2 status:** Reconcile API + self-seen scheduling + `main.dart` resume → `scheduleFabUnreadReconcile`; **9/9 unit tests GREEN**

| # | Step | Status | Coverage |
| --- | --- | --- | --- |
| 1 | Open two web tabs (or two Windows tear-off windows) logged in as the same admin. | **Pending (human)** | **Human E2E** — multi-tab/window session and socket fan-in not unit-tested |
| 2 | Receive a new chat message → both FABs show unread (and mention if applicable). | **Pending (human)** | **Human E2E** — dual-window `chat.message` delivery not unit-tested |
| 3 | In tab/window A only: open chat FAB → open conversation → scroll/mark read until local FAB clears. | **Pending (human)** | **Human E2E** — UI mark-seen flow and local FAB clear not unit-tested |
| 4 | **Pass:** tab/window B FAB unread/mention clears (or updates to server `totalUnreadMessageCount`) without opening chat. | **Pending (human)** | **Partial unit + human E2E** — handler + reconcile scheduling unit-proven; cross-tab delivery requires human run |
| 5 | **Resume reconcile:** In window A, mark chat read. Switch focus to window B (or background B briefly). Bring B to foreground (resume). FAB badge should catch up via debounced reconcile even if `chat.seen` was missed or out-of-order. | **Pending (human)** | **Partial unit + human E2E** — `scheduleFabUnreadReconcile` debounce unit-tested; `main.dart` resume wiring not E2E-tested |
| 6 | Confirm other-admin read of a chat does not clear this user's FAB (if two admins available). | **Pending (human, optional)** / **N/A (unit)** | **Unit tests** prove ignore-other-user rule |
| 7 | Confirm no white screen / crash when socket sends `chat.seen` with `data: null` or `{}`. | **N/A (unit)** | **Unit tests** — malformed-payload safety |

**Status values:** Pending (human) / Pass / Fail / N/A

---

## Coverage map

| Checklist # | Expectation | Unit test name(s) | Sufficient alone? |
| --- | --- | --- | --- |
| 1 | Same admin, two tabs/windows share socket session | — | No — human required |
| 2 | New message increments FAB unread/mention in both views | — | No — dual delivery untested |
| 3 | Mark-read in tab A clears local FAB | — | No — UI path not unit-tested |
| 4 | Self `chat.seen` applies `totalUnreadMessageCount` to FAB | `local admin read applies totalUnreadMessageCount to FAB` | No — proves handler only, not tab B |
| 4 | Self seen with total `0` clears mention badge | `self seen with totalUnread 0 also clears mention badge` | No — cross-tab limitation |
| 4 | Self seen without total schedules reconcile (no blind-clear) | `self seen with missing totalUnread does not clear unread blindly`, `self seen without total schedules reconcile without changing FAB` | Supports fail-safe; still need E2E for tab B |
| 5 | Resume triggers debounced reconcile | `debounces rapid schedules so reconcile fires once` | No — proves debounce only, not lifecycle resume |
| 6 | Other admin `byUserId` ≠ local admin → FAB unchanged | `another admin read does not change FAB` | **Yes** for ignore-other-user rule |
| 7 | `data: null`, `data: {}` → no throw, FAB unchanged | `empty or non-map data does not throw or change FAB` | **Yes** for malformed-payload safety |

---

## How to fill after a human run

1. Mark steps **1–5** Pass or Fail (add notes on Fail: platform, tab vs tear-off, observed vs expected counts, resume timing).
2. Step **6:** leave **N/A (unit)** if dual-admin not available; otherwise Pass/Fail.
3. Step **7:** leave **N/A (unit)** unless you injected a live malformed `chat.seen`.
4. Feature is **E2E-verified** only when steps **1–5** are Pass. Unit coverage alone does not close cross-tab or resume verification.

---

## Quick run commands (reference)

```bash
flutter run -d chrome          # web dual-tab
flutter run -d windows         # desktop tear-off via side menu
flutter test test/chat_fab_controller_test.dart
```
