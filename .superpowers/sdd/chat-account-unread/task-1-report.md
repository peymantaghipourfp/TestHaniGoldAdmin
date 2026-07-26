# Task 1 Report: Pure helpers + account reconcile semantics

**Status:** DONE  
**Date:** 2026-07-11  
**Plan:** ChatAccountItem cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-account-item-cross-tab-unread.md`)

---

## What was implemented

Restored four pure helpers in `chat_conversation_unread.dart` and added tests locking absent-thread `threadJustRead` semantics for Task 2 controller wiring.

### Restored helpers

1. **`seenBroadcastAffectsLocalUnread`** — returns `true` only when both `broadcastByUserId` and `localUserId` are non-null and equal; `false` on mismatch or either null.

2. **`resolveThreadUnreadFromSocket`** — prefers authoritative `serverCount` when present (clamps negatives to 0); when `serverCount` is absent, increments local by 1 if `incrementFallback`, else keeps local. Does not invent zero from absent server data.

3. **`mergeSocketMentionIntoUnreadList`** — inserts a mention sorted by `seq`, deduped by `messageGuid`. Helper-only this task (not wired into message path).

4. **`threadJustReadFromSeenBroadcast`** — new helper for Task 2:
   - `true` when `newChatUnread == 0` and (`previousChatUnread > 0` OR chat was **not** in local list)
   - `false` when `newChatUnread` is null, positive, or chat was already read in list (`previousChatUnread == 0` and `chatWasInLocalList`)

### Absent-thread reconcile tests

Added integration test proving: chat absent from loaded list + authoritative unread `0` → `threadJustReadFromSeenBroadcast` is `true` → `reconcileAccountUnreadChatCount` drops account count by at least one (`3 → 2` with `reconciled: null`).

---

## TDD Evidence RED

### Step 1 — Existing tests fail to compile (missing symbols)

**Command:**

```powershell
cd "d:\curserAi project"; flutter test test/chat_conversation_unread_test.dart
```

**Result:** EXIT 1 (compilation failure)

```
Error: Method not found: 'seenBroadcastAffectsLocalUnread'.
Error: Method not found: 'resolveThreadUnreadFromSocket'.
Error: Method not found: 'mergeSocketMentionIntoUnreadList'.
```

**Why expected:** Helpers were referenced by existing tests but not yet implemented in `chat_conversation_unread.dart`.

---

## TDD Evidence GREEN

### Step 2 — Implement helpers + absent-thread tests

Updated `lib/src/domain/chat/utils/chat_conversation_unread.dart` with all four helpers.  
Extended `test/chat_conversation_unread_test.dart` with `threadJustReadFromSeenBroadcast` group (5 cases) and `absent-thread account reconcile` integration test.

**Command:**

```powershell
cd "d:\curserAi project"; flutter test test/chat_conversation_unread_test.dart
```

**Result:** EXIT 0 — **28/28 passed**

```
conversationUnreadAfterSeen (3)
seenBroadcastAffectsLocalUnread (3)
conversationUnreadAfterSeenBroadcast (3)
messageMentionsAccount (3)
unreadMentionsAfterSeen (1)
shouldIncrementAccountUnreadChatCount (2)
reconcileAccountUnreadChatCount (2)
resolveThreadUnreadFromSocket (4)
threadJustReadFromSeenBroadcast (5)
absent-thread account reconcile (1)
mergeSocketMentionIntoUnreadList (1)
All tests passed!
```

---

## Test coverage matrix

| Helper / scenario | Key assertion |
| --- | --- |
| `seenBroadcastAffectsLocalUnread` | equal non-null IDs → true; mismatch/null → false |
| `resolveThreadUnreadFromSocket` | server wins; null server + fallback → +1; null server no fallback → unchanged; negative server → 0 |
| `threadJustReadFromSeenBroadcast` | prior unread + zero broadcast → true |
| `threadJustReadFromSeenBroadcast` | absent from list + authoritative 0 → true (root-cause fix) |
| `threadJustReadFromSeenBroadcast` | in-list already read → false |
| `threadJustReadFromSeenBroadcast` | null `newChatUnread` → false (no blind clear) |
| absent-thread reconcile | `threadJustRead` from absent case + `reconciled: null` → count drops 3→2 |
| `mergeSocketMentionIntoUnreadList` | sorted by seq; dedupe by messageGuid |

---

## Files changed

| File | Change |
| --- | --- |
| `lib/src/domain/chat/utils/chat_conversation_unread.dart` | Added `seenBroadcastAffectsLocalUnread`, `resolveThreadUnreadFromSocket`, `mergeSocketMentionIntoUnreadList`, `threadJustReadFromSeenBroadcast` |
| `test/chat_conversation_unread_test.dart` | Added `threadJustReadFromSeenBroadcast` and `absent-thread account reconcile` groups |
| `.superpowers/sdd/chat-account-unread/task-1-report.md` | This report |

**Not changed:** `chat.controller.dart`, `ChatAccountItem`, graphify, debounced refresh (Task 3).

**Commits:** none (no git repository in workspace).

---

## Self-review

- [x] TDD order: RED compile failure confirmed, then implementation, then GREEN 28/28
- [x] `resolveThreadUnreadFromSocket` does not treat absent `serverCount` as zero
- [x] `threadJustReadFromSeenBroadcast` requires explicit `newChatUnread == 0` (null → false)
- [x] Absent-thread case: `previousChatUnread == 0` + `!chatWasInLocalList` + authoritative zero → just-read
- [x] Existing `reconcileAccountUnreadChatCount` unchanged; integration test proves drop-by-one path
- [x] Pure helpers only; no controller/widget changes
- [x] No linter errors on changed files
- [x] No commit attempted

---

## Concerns

None. Task 2 can wire `threadJustReadFromSeenBroadcast` into `_syncAccountUnreadAfterChatSeen` / `_handleSeenBroadcast` replacing `previousChatUnread > 0 && newChatUnread == 0`.
