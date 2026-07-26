# Review package — Task 1 (Chat FAB Cross-Tab Sync)

**Base:** (no git — workspace snapshot before Task 1)
**Head:** (no git — same; no production changes)

## Commits
none (no git repository)

## Stat summary
No files changed (confirm-RED only).

## Diff
```
(empty — Task 1 ran tests only; no production or test file edits)
```

## Implementer claims (for reviewer cross-check)
- Command: flutter test test/chat_fab_controller_test.dart
- Result: 3 passed / 2 failed
- FAIL: local admin read applies totalUnreadMessageCount to FAB; self seen with totalUnread 0 also clears mention badge
- PASS: another admin read; empty/non-map data; missing totalUnread
- Production code unchanged
