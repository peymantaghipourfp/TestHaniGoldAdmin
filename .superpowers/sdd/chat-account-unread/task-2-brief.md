# Task 2: Fail-safe `_handleSeenBroadcast` + absent-thread account sync

**Plan:** ChatAccountItem cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-account-item-cross-tab-unread.md`)

## Goal

Wire Task 1 helpers into `ChatController` so other windows’ `ChatAccountItem` badges clear on self `chat.seen`, including when the thread was never in local `chatList`. Harden fail-safes: no blind `?? 0` clear; empty data → no-op.

## Interfaces from Task 1 (use these)

- `seenBroadcastAffectsLocalUnread(broadcastByUserId:, localUserId:)` — gate for **account badge** mutations
- `threadJustReadFromSeenBroadcast(previousChatUnread:, newChatUnread:, chatWasInLocalList:)` — replace `previousChatUnread > 0 && newChatUnread == 0`
- `resolveThreadUnreadFromSocket` — use if needed when applying thread unread from socket (no inventing 0 from absent)
- `reconcileAccountUnreadChatCount` / `reconcileAccountHasUnreadMention` — already exist

## Requirements

1. **Self-user gate for account badges:** Account-row unread/mention mutations only when `seenBroadcastAffectsLocalUnread` is true. Keep existing `readerIsCustomer` handling for open-conversation tick/pill — do **not** clear account badges on other-admin or customer reads.

2. **Stop blind `unreadMessageCount ?? 0`:** If `unreadMessageCount` is **absent** → do **not** invent `0`; skip applying thread unread / skip forcing account decrement from a fabricated zero. If present and parsable → apply via `_mergeSeenIntoChatLists` / sync.

3. **Absent-thread sync:** `_syncAccountUnreadAfterChatSeen` (or call sites) must use `threadJustReadFromSeenBroadcast` so when self-seen, `accountId` known, and authoritative `unreadMessageCount == 0`, account `unreadChatCount` decrements even if chat was never in `chatList`.

4. **Mentions:** After computing new `unreadChatCount`, set `hasUnreadMention = false` when count hits 0; otherwise prefer loaded-chat reconcile over blindly clearing when other threads may still have mentions.

5. **Empty/`{}`/`null` data:** no throw, badges unchanged.

6. **Tests:** New `test/chat_account_seen_sync_test.dart` **or** extend existing controller tests covering:
   - Absent-`chatList` self-seen → account badge drops
   - Empty data → no throw, badges unchanged
   - Other user → account badges unchanged

## TDD

Write failing controller/helper-path tests first where practical, then implement. Prefer testing pure sync logic if full ChatController is hard to instantiate — but the plan asks for controller-level coverage of the three scenarios above. Follow patterns in `test/chat_fab_controller_test.dart` if useful.

Run focused tests green.

## Files to change

- `lib/src/domain/chat/controller/chat.controller.dart`
- `test/chat_account_seen_sync_test.dart` (new) and/or existing tests
- May import helpers already in `chat_conversation_unread.dart` (do not re-implement)

## Out of scope

- Debounced merge-refresh (Task 3)
- ChatAccountItem widget layout changes
- Second global `messageStream` subscription
- Clearing global FAB from conversation-level fields
- graphify

## Fail-safe rules (non-negotiable)

- Never set account unread/mention to cleared solely because `data` is empty or `unreadMessageCount` is absent.
- All socket handlers stay in try/catch; no new uncaught white-screen paths.
- No second global socket subscription (keep ChatFabController fan-out).

## Workspace note

No git repository — **do not attempt commits**. Implement, test, write report only.
