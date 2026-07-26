# Task 2: Resume reconcile

**Plan:** FAB cross-tab unread sync (`docs/superpowers/plans/2026-07-11-chat-fab-cross-tab-unread.md`)

## Goal

On app resume, schedule the same FAB unread reconcile so missed/out-of-order `chat.seen` broadcasts cannot leave a stale badge.

## Steps (exact)

In `_MyAppState.didChangeAppLifecycleState` in `lib/main.dart`, in the `AppLifecycleState.resumed` branch:

1. Keep existing `socketService.onAppLifecycleChanged('resumed');`
2. **After** that call, if `Get.isRegistered<ChatFabController>()`, call `scheduleFabUnreadReconcile()` inside try/catch (log only — use existing logging style in main.dart / AppLogger / Get.log; do not throw).

Example shape:

```dart
case AppLifecycleState.resumed:
  socketService.onAppLifecycleChanged('resumed');
  try {
    if (Get.isRegistered<ChatFabController>()) {
      Get.find<ChatFabController>().scheduleFabUnreadReconcile();
    }
  } catch (e, s) {
    // log only — AppLogger.e or Get.log
  }
  break;
```

## Manual note (document in report)

Focus other tear-off window after read → badge should catch up even if `chat.seen` was missed. (Full dual-window E2E is Task 3.)

## Files to change

- `lib/main.dart` only (add import for `ChatFabController` if not already present)

## Do NOT

- Change ChatFabController reconcile logic (Task 1 done)
- Run graphify (Task 3)
- Blind-clear FAB on resume
- Commit (no git repository)

## Fail-safe

- try/catch around the ChatFabController call; log only
- Only call if registered
