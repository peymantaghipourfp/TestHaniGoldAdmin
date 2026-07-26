# Task 3 Report: Manual verification checklist (human)

## What I Did

1. Read the task brief at `.superpowers/sdd/chat-fab-sync/task-3-brief.md`.
2. Created durable checklist at `.superpowers/sdd/chat-fab-sync/task-3-manual-checklist.md` with steps 1–6, Status column, and coverage map.
3. Mapped each step to unit-test coverage vs human E2E requirements.
4. Re-ran unit tests to confirm Task 2 remains GREEN before documenting.
5. Self-reviewed checklist and report (no production code touched).

## Unit Test Verification

```bash
flutter test test/chat_fab_controller_test.dart
```

```
00:00 +5: All tests passed!
```

**Summary:** 5 passed, 0 failed (exit code 0).

## Checklist vs Brief Compliance

| Brief step | Checklist # | Status set by agent | Rationale |
| --- | --- | --- | --- |
| 1. Two tabs/windows, same admin | 1 | Pending | Cannot run dual-tab E2E in agent environment |
| 2. New message → both FABs unread/mention | 2 | Pending | Requires live socket + dual UI |
| 3. Tab A: open chat, mark read, local FAB clears | 3 | Pending | UI/mark-seen flow not automatable here |
| 4. Tab B FAB clears without opening chat | 4 | Pending | Core E2E pass criterion; handler unit-proven only |
| 5. Other-admin read does not clear FAB | 5 | N/A (unit) / Pending optional human | Covered by `another admin read does not change FAB` |
| 6. No crash on `data: null` or `{}` | 6 | N/A (unit) | Covered by `empty or non-map data does not throw or change FAB` |

## Coverage Summary

| Area | Unit tests | Human E2E required |
| --- | --- | --- |
| Self `chat.seen` → FAB unread update | Yes (3 tests) | Yes — tab B must receive same broadcast |
| Mention + highlight clear at total 0 | Yes | Yes — cross-tab |
| Ignore other admin reads | Yes | Optional dual-admin confirm |
| Malformed / empty `chat.seen` data | Yes | Optional live inject |
| Dual-tab setup, new message, mark-read UI | No | Yes (steps 1–3) |

## Files Changed

| File | Change |
| --- | --- |
| `.superpowers/sdd/chat-fab-sync/task-3-manual-checklist.md` | Created — human checklist with coverage map |
| `.superpowers/sdd/chat-fab-sync/task-3-report.md` | Created — this report |

**Not modified:** production code, tests, or graphify (docs-only task).

## Self-Review

- **Brief compliance:** Checklist includes steps 1–6 with Pending / N/A per instructions; no false E2E Pass claims.
- **Coverage map:** Each checklist row links to specific unit test names where applicable; dual-tab steps explicitly marked insufficient alone.
- **Consistency:** Aligns with Task 2 implementation (`updateChatFabFromSeenBroadcast`) and existing test group names.
- **Actionable:** "How to fill after a human run" section defines when feature is E2E-verified (steps 1–4 Pass).
- **No scope creep:** No production or test file changes.

## Concerns

1. **E2E still open:** Cross-tab sync (steps 1–4) remains **Pending** until a human runs web or Windows tear-off verification.
2. **Step 2 gap:** New-message dual-FAB behavior relies on `updateChatFabFromChatMessage`, not covered in the `chat.seen` test group — E2E is the right place to validate.
3. **Step 5 optional:** Unit test suffices for the ignore-other-user rule; dual-admin live check is nice-to-have only.

## Commits

None (no git repository in workspace).
