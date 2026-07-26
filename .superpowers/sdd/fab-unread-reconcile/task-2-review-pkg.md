# Review package — Task 2 (no git; file snapshot)

Base: post-Task-1  
Head: post-Task-2

## Files changed
- lib/main.dart

## Diff (logical)

### lib/main.dart — AppLifecycleState.resumed

```dart
      case AppLifecycleState.resumed:
        socketService.onAppLifecycleChanged('resumed');
        try {
          if (Get.isRegistered<ChatFabController>()) {
            Get.find<ChatFabController>().scheduleFabUnreadReconcile();
          }
        } catch (e, s) {
          AppLogger.e('ChatFabController scheduleFabUnreadReconcile failed', e, s);
        }
        break;
```

`ChatFabController` import already existed (`package:hanigold_admin/src/domain/chat/controller/chat_fab.controller.dart`).

No other files changed for this task.
