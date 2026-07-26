# Final whole-branch review package
Plan: Fix Socket Disconnect After Exit + Re-login
Base: pre-plan working tree
Head: post Tasks 1–3
Commits: none (no git repository)

## Minor carry-forward from per-task reviews
- Task 2 Minor: restored handleIncomingForTest outside brief deliverable (justified unblock)
- Task 3 Minor: pre-existing analyze infos; graph.html viz skipped

## Stat summary
- lib/src/domain/auth/controller/auth.controller.dart — login socket bootstrap order
- lib/src/config/const/socket.service.dart — restored @visibleForTesting handleIncomingForTest
- test/socket_service_sync_test.dart — new manual-disconnect gate test

## Full combined diff

### auth.controller.dart login success (after ChatFab updates)

BEFORE:
```
        registerChatControllerIfNeeded();
        Get.offNamed('/home');
        ...
        await _persistRememberedCredentials();

        final socketService = SocketService.to;
        socketService.resetManualDisconnect();
```

AFTER (lines ~122-129):
```
        SocketService.to.resetManualDisconnect();
        await bootstrapSocketConnection();
        registerChatControllerIfNeeded();
        Get.offNamed('/home');
        ...
        await _persistRememberedCredentials();
```

### socket.service.dart — restored test hook
```
@visibleForTesting
void handleIncomingForTest(dynamic data) {
  _dispatchIncomingMessage(data);
}
```
(+ foundation.dart import). disconnect/ensureConnected/resetManualDisconnect semantics unchanged.

### socket_service_sync_test.dart — new test
```
  test('manual disconnect gate blocks ensureConnected until reset', () async {
    ...
    await service.disconnect();
    expect(service.connectionInfo['isManualDisconnect'], isTrue);
    await service.ensureConnected(...);
    expect(service.connectionInfo['status'], 'disconnected');
    expect(service.connectionInfo['isManualDisconnect'], isTrue);
    service.resetManualDisconnect();
    expect(service.connectionInfo['isManualDisconnect'], isFalse);
    ...
  });
```

## Verification evidence
- flutter test test/socket_service_sync_test.dart → 3/3 pass
- flutter analyze on touched files → 5 infos, 0 errors/warnings
- graphify update . → rebuilt graph

## Plan out of scope (must remain untouched)
- Real WebSocket integration tests
- Refactoring duplicate exit dialogs
- Changing SocketService.disconnect() semantics
- Coordinator/web multi-tab behavior
