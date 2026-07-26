# Task 3: Manual verification checklist (Chat FAB cross-tab sync)

**Feature:** FAB unread/mention sync via `chat.seen` across tabs/windows  
**Environment:** Web (two tabs) or Windows desktop (tear-off windows) — human run only  
**Unit tests:** `test/chat_fab_controller_test.dart` (group `ChatFabController chat.seen`)  
**Task 2 status:** `updateChatFabFromSeenBroadcast` implemented; all 5 unit tests GREEN

| # | Step | Status | Coverage |
| --- | --- | --- | --- |
| 1 | Open two web tabs (or two Windows tear-off windows) logged in as the same admin. | Pending | **Human E2E** — multi-tab/window session and socket fan-in not unit-tested |
| 2 | Receive a new chat message → both FABs show unread (and mention if applicable). | Pending | **Human E2E** — dual-window `chat.message` delivery not unit-tested (handler exists in `updateChatFabFromChatMessage`, no dual-tab test) |
| 3 | In tab/window A only: open chat FAB → open conversation → scroll/mark read until local FAB clears. | Pending | **Human E2E** — UI mark-seen flow and local FAB clear not unit-tested |
| 4 | **Pass:** tab/window B FAB unread/mention clears (or updates to server `totalUnreadMessageCount`) without opening chat. | Pending | **Partial unit + human E2E** — handler logic unit-proven; cross-tab delivery requires human run. See [coverage map](#coverage-map). |
| 5 | Confirm other-admin read of a chat does not clear this user's FAB (if two admins available). | Pending (optional human) / **N/A (unit)** | **Unit tests** prove ignore-other-user rule; optional dual-admin desktop confirms live behavior |
| 6 | Confirm no white screen / crash when socket sends `chat.seen` with `data: null` or `{}` (server or proxy glitch). | **N/A (unit)** | **Unit tests** — no desktop inject required unless you have a debug socket path |

**Status values:** Pending / Pass / Fail / N/A

---

## Coverage map

| Checklist # | Expectation | Unit test name(s) | Sufficient alone? |
| --- | --- | --- | --- |
| 1 | Same admin, two tabs/windows share socket session | — | No — setup only; human required |
| 2 | New message increments FAB unread/mention in both views | — | No — `chat.message` FAB update not in `chat.seen` group; dual delivery untested |
| 3 | Mark-read in tab A clears local FAB | — | No — UI + mark-seen path not unit-tested |
| 4 | Self `chat.seen` applies `totalUnreadMessageCount` to FAB | `local admin read applies totalUnreadMessageCount to FAB` | No — proves handler only, not tab B receiving broadcast |
| 4 | Self seen with total `0` clears mention badge and highlight | `self seen with totalUnread 0 also clears mention badge` | No — same cross-tab limitation |
| 4 | Self seen without `totalUnreadMessageCount` does not blind-clear | `self seen with missing totalUnread does not clear unread blindly` | Supports fail-safe; still need E2E for tab B |
| 5 | Other admin `byUserId` ≠ local admin → FAB unchanged | `another admin read does not change FAB` | **Yes** for ignore-other-user rule (optional human for dual-admin observability) |
| 6 | `data: null`, `data: {}`, or missing `data` → no throw, FAB unchanged | `empty or non-map data does not throw or change FAB` | **Yes** for malformed-payload safety |

---

## How to fill after a human run

1. Mark steps **1–4** Pass or Fail (add notes on Fail: platform, tab vs tear-off, observed vs expected counts).
2. Step **5:** leave **N/A (unit)** if dual-admin not available; otherwise Pass/Fail from live observation.
3. Step **6:** leave **N/A (unit)** unless you injected a live malformed `chat.seen` — then Pass/Fail.
4. Feature is **E2E-verified** only when steps **1–4** are Pass. Unit coverage alone does not close cross-tab verification.

---

## Quick run commands (reference)

```bash
flutter run -d chrome          # web dual-tab
flutter run -d windows         # desktop tear-off via side menu
flutter test test/chat_fab_controller_test.dart
```
