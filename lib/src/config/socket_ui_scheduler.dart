import 'package:flutter/widgets.dart';

/// Runs [action] after the current frame when the app tab is visible.
///
/// Keeps socket-driven list updates off the WebSocket call stack and skips
/// background browser tabs (inactive/hidden).
void scheduleSocketUiUpdate(void Function() action) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      return;
    }
    action();
  });
}
