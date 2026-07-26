# Task 2 Report: Fail-safe `_handleSeenBroadcast` + absent-thread account sync

**Status:** DONE  
**Date:** 2026-07-11

## What was implemented

Wired Task 1 helpers into `ChatController` so Tab B `ChatAccountItem` badges clear on self `chat.seen`, including when the thread was never in local `chatList`.

### `_handleSeenBroadcast`
- Removed blind `unreadMessageCount ?? 0`; keeps nullable `unread`.
- Gates account-badge mutations with `seenBroadcastAffectsLocalUnread` (self admin only).
- Skips thread-unread application and account sync when `unread` is absent.
- Preserves `readerIsCustomer` handling for open-conversation pill/tick.

### `_syncAccountUnreadAfterChatSeen`
- Uses `threadJustReadFromSeenBroadcast` (fixes absent-`chatList` stale badge).
- Accepts `chatWasInLocalList`; `newChatUnread` is `int?`.
- Clears `hasUnreadMention` when `unreadChatCount` reaches 0.

### `_mergeSeenIntoChatLists`
- `unreadMessageCount` now nullable; preserves local unread when server omits it.
- `syncAccountBadge` flag; account sync only when self-seen and unread present.

## TDD

**RED:** `flutter test test/chat_account_seen_sync_test.dart` — 2/5 failed (absent-chatList cases stayed at 3).

**GREEN:** 5/5 new + 28/28 existing helper tests pass (33 total).

## Tests added

`test/chat_account_seen_sync_test.dart`:
- Absent-`chatList` self-seen → account `unreadChatCount` 3→2, mention cleared
- Same with `upToSeq`
- Empty/null/`{}` data → no throw, badges unchanged
- Other admin → badges unchanged
- Self-seen missing `unreadMessageCount` → no blind clear

## Files changed

- `lib/src/domain/chat/controller/chat.controller.dart`
- `test/chat_account_seen_sync_test.dart` (new)

## Commits

None (no git repository).

## Concerns

None. Task 3 can add debounced merge-refresh reconcile.
