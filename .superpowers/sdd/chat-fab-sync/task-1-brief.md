# Task 1: Confirm RED baseline

**Files:**
- Test: [`test/chat_fab_controller_test.dart`](test/chat_fab_controller_test.dart)

- [ ] **Step 1: Run existing `chat.seen` tests**

```bash
flutter test test/chat_fab_controller_test.dart
```

Expected: FAIL on at least:
- `local admin read applies totalUnreadMessageCount to FAB`
- `self seen with totalUnread 0 also clears mention badge`

PASS (already no-op):
- `another admin read does not change FAB`
- `empty or non-map data does not throw or change FAB`
- `self seen with missing totalUnread does not clear unread blindly`

**Do not implement the production fix in this task.** Confirm RED only; write results to the report file.
