# Task 3 Report — Debounced merge-refresh reconcile + validation

## Status: DONE

## Summary

Added ChatController-owned debounced account unread reconcile (300ms, mirroring FAB pattern):

- `scheduleAccountUnreadReconcile()` — cancels prior timer, increments `accountUnreadReconcileScheduleCount`, fires `refreshChatAccountUnreadByMerge()`
- `refreshChatAccountUnreadByMerge()` — fetches page 1 via `getChatAccountList`, merges `unreadChatCount` / `hasUnreadMention` / `unreadMessageCount` by `accountId` in-place via `_publishChatAccountRowUpdate`; never clears `chatAccountList`; try/catch + `AppLogger`
- Wired into `_handleSeenBroadcast`: schedules when `selfAffectsUnread` (self admin seen with valid `chatId`); no schedule on empty/malformed/other-user
- Timer cancelled in `onClose`

## Tests

```
flutter test test/chat_account_seen_sync_test.dart test/chat_conversation_unread_test.dart
→ 37/37 passed
```

New cases: self-seen schedules (with/without `unreadMessageCount`), non-self/empty does not schedule, `fake_async` debounce (single merge invoke, list length preserved). Task 2 tests remain green.

## graphify

```
graphify update .
→ OK — 8487 nodes, 15743 edges, 495 communities (graphify-out updated)
```

## Manual checklist

`.superpowers/sdd/chat-account-unread/task-3-manual-checklist.md` — all steps **Pending (human)** (dual-window validation not run in CI).

## Commits

None (per task brief).

## Concerns

- Merge refresh only reconciles accounts returned on page 1 (first 20 rows); accounts loaded via pagination beyond page 1 are not updated until a full refresh. Acceptable for defense-in-depth per brief; note if cross-tab heal misses deep-scroll rows.
- Debounce test triggers a real (unauthenticated) API call that 400s; caught safely but logs noise in test output.

## Files changed

- `lib/src/domain/chat/controller/chat.controller.dart`
- `test/chat_account_seen_sync_test.dart`
- `.superpowers/sdd/chat-account-unread/task-3-manual-checklist.md`
- `.superpowers/sdd/chat-account-unread/task-3-report.md`

---

## Fix wave — null-safe merge badge fields

### What changed

- Added `mergeChatAccountRowUnreadFields` (`@visibleForTesting`): merges `unreadMessageCount`, `unreadChatCount`, and `hasUnreadMention` using `fresh ?? current` so null API values never clear existing badges (same fail-safe as socket path).
- `refreshChatAccountUnreadByMerge` now uses that helper instead of blindly copying fresh fields.
- Moved `accountUnreadMergeRefreshInvokeCount++` after the empty-list early return so empty reconcile does not count as an invoke.

### Tests

```
flutter test test/chat_account_seen_sync_test.dart
→ 11/11 passed
```

New cases: `mergeChatAccountRowUnreadFields` preserves counts when fresh badge fields are null; applies non-null fresh values (including zero/false).

### Files changed (fix wave)

- `lib/src/domain/chat/controller/chat.controller.dart`
- `test/chat_account_seen_sync_test.dart`
- `.superpowers/sdd/chat-account-unread/task-3-report.md`
