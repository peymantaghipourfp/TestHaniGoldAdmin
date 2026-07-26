# Task 3: Debounced merge-refresh reconcile + validation

**Plan:** ChatAccountItem cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-account-item-cross-tab-unread.md`)

## Goal

Add a ChatController-owned **debounced soft refresh** that re-fetches account page data and **merges by `accountId`** into `chatAccountList` (update matching rows’ `unreadChatCount` / `hasUnreadMention` / related badge fields) — **do not** `clear()` the visible list mid-session.

Schedule it on self `chat.seen` after successful apply **or** when self-seen but `unreadMessageCount` missing. Cancel timer in `onClose`.

Then validate: focused unit tests, manual dual-window checklist, `graphify update .`.

## Implementation details

### Scheduler (ChatController)

Mirror FAB pattern (`ChatFabController.scheduleFabUnreadReconcile` ~300ms debounce):

- `Timer? _accountUnreadReconcileTimer`
- `void scheduleAccountUnreadReconcile()` — cancel prior; schedule ~300ms; then call merge-refresh
- `@visibleForTesting int accountUnreadReconcileScheduleCount` — increment on each schedule call (test hook)
- Cancel timer in `onClose`

### Merge-by-id refresh (do NOT clear list)

`loadChatAccountList(refresh: true)` currently does `chatAccountList.clear()` then reload — unsuitable for silent reconcile (UI flash).

Add something like:

```dart
Future<void> refreshChatAccountUnreadByMerge() async {
  // Fetch page 1 (or same query as current list) via chatRepository.getChatAccountList
  // For each fetched account with matching accountId in chatAccountList:
  //   update unreadChatCount, hasUnreadMention (and any related badge fields already on the model)
  // Do NOT clear() or assignAll() the whole list
  // try/catch — log, never throw
}
```

Prefer a dedicated method over changing `loadChatAccountList` behavior for normal refresh/search.

### Wire into `_handleSeenBroadcast`

On **self** admin seen (`seenBroadcastAffectsLocalUnread` true):

1. After successful apply with present `unreadMessageCount` → `scheduleAccountUnreadReconcile()`
2. When self-seen but `unreadMessageCount` missing → still `scheduleAccountUnreadReconcile()` (defense-in-depth; do not clear badges from missing count)
3. Empty/`null`/`{}` / other user → do **not** schedule

Do **not** expand `main.dart` unless a tiny shared call is natural; prefer ChatController-owned debounce. Hooking app-resume FAB reconcile is optional only if trivial — YAGNI otherwise.

### Tests

Extend `test/chat_account_seen_sync_test.dart` (or focused new cases):

1. Self seen with unread → schedule count increments
2. Self seen without unreadMessageCount → schedule count increments; badges not blindly cleared
3. Empty / other user → schedule count does not increment
4. Optional: debounce cancels prior timer (`fake_async`) if practical

Existing Task 2 tests must stay green.

### Manual checklist

Write `.superpowers/sdd/chat-account-unread/task-3-manual-checklist.md`:

1. Dual tear-off/web: message arrives → both windows’ `ChatAccountItem` badges show unread
2. Mark read in window A → window B’s `ChatAccountItem` clears **without** opening that chat
3. Self-seen with incomplete payload eventually heals via reconcile (if observable)
4. Empty/malformed seen → no white screen, badges unchanged

Mark steps **Pending (human)** if you cannot run dual windows — do **not** invent Pass.

### graphify

After code edits: run `graphify update .` from project root. Record result in report.

### Validation commands

```
flutter test test/chat_account_seen_sync_test.dart
flutter test test/chat_conversation_unread_test.dart
graphify update .
```

## Files

- `lib/src/domain/chat/controller/chat.controller.dart`
- `test/chat_account_seen_sync_test.dart` (extend)
- `.superpowers/sdd/chat-account-unread/task-3-manual-checklist.md`
- Report: `.superpowers/sdd/chat-account-unread/task-3-report.md`

## Out of scope

- Changing ChatAccountItem widget layout
- Second global socket subscription
- Clearing FAB from conversation-level fields
- Commits (no git)

## Fail-safe rules (non-negotiable)

- Never clear account badges solely because data empty / unreadMessageCount absent
- Merge refresh must not `clear()` the visible account list
- try/catch on refresh; no throw to UI
- All socket handlers stay in try/catch

## Workspace note

No git — do not attempt commits.
