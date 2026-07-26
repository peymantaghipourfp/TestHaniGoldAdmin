# Task 1: Pure helpers + account reconcile semantics

**Plan:** ChatAccountItem cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-account-item-cross-tab-unread.md`)

## Goal

Make `test/chat_conversation_unread_test.dart` compile and pass by implementing missing pure helpers. Add/adjust tests so self-seen with chat **absent** from loaded chats still yields an account unread decrement when authoritative unread is 0.

## Missing helpers (restore in `chat_conversation_unread.dart`)

Tests already specify behavior — implement to match:

1. `seenBroadcastAffectsLocalUnread({required int? broadcastByUserId, required int? localUserId})`
   - `true` when both non-null and equal
   - `false` when mismatch or either null

2. `resolveThreadUnreadFromSocket({required int localCount, required int? serverCount, required bool incrementFallback})`
   - Prefer authoritative `serverCount` when present (clamp negatives to 0)
   - When `serverCount` absent: increment local by 1 if `incrementFallback`, else keep local

3. `mergeSocketMentionIntoUnreadList(List<ChatUnreadMentionsModel> current, {required String messageGuid, required int? seq})`
   - Add mention sorted by seq; dedupe by messageGuid
   - Required so the suite compiles; YAGNI for wiring into message path this task (helpers only)

## Account reconcile semantics (absent thread)

Add/adjust tests for: self-seen with chat **absent** from loaded chats still yields a decrement when authoritative unread is 0.

Either:
- Extend `reconcileAccountUnreadChatCount` usage/docs, **or**
- Add a small pure helper used by the controller later (e.g. computing `threadJustRead` when chat not in list but broadcast says unread==0)

Recommended pure helper (controller will wire in Task 2):

```dart
/// True when a self-seen broadcast should treat the thread as just-read for
/// account badge sync, even if the chat row was never in local [chatList].
bool threadJustReadFromSeenBroadcast({
  required int previousChatUnread,
  required int? newChatUnread,
  required bool chatWasInLocalList,
})
```

Semantics matching the plan root cause fix:
- If `newChatUnread == 0` and (`previousChatUnread > 0` OR chat was **not** in local list with authoritative zero) → treat as just-read
- Exact API may vary; tests must lock: **absent from loaded chats + authoritative unread 0 → reconcile drops account count by ≥1 when threadJustRead**

Existing `reconcileAccountUnreadChatCount` already drops by at least one when `threadJustRead: true`. The gap is computing `threadJustRead` when `previousChatUnread` is 0 because the chat was never loaded.

## TDD steps

1. Run `flutter test test/chat_conversation_unread_test.dart` — expect compile failures for missing symbols (RED).
2. Implement missing helpers + absent-thread `threadJustRead` helper/tests.
3. Run again — all green (GREEN).

## Files to change

- `lib/src/domain/chat/utils/chat_conversation_unread.dart`
- `test/chat_conversation_unread_test.dart`

## Out of scope (do NOT do)

- Do **not** modify `chat.controller.dart` (Task 2)
- Do **not** add debounced refresh (Task 3)
- Do **not** change `ChatAccountItem` widget
- Do **not** run graphify
- No second socket subscription

## Fail-safe rules (non-negotiable)

- Never invent cleared unread solely because data is empty / `unreadMessageCount` absent (helpers must not force `?? 0` as a clear signal — `resolveThreadUnreadFromSocket` only applies server count when present)
- Pure helpers only this task

## Workspace note

No git repository — **do not attempt commits**. Implement, test, write report only.
