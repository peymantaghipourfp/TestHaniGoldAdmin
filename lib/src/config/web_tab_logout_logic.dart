import 'dart:async';

import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/socket.service.dart';
import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/session_storage.dart';

/// Whether a browser `pagehide` may clear the shared session vault.
///
/// Product rule (explicit logout only): always `false`. F5 and last-tab close
/// must not wipe `Authorization` / `x-session-id`. Session ends via UI logout
/// or server-driven invalidation only.
bool shouldClearSessionOnPageHide({
  required bool isWeb,
  required bool persisted,
  bool isLastTab = true,
}) {
  return false;
}

/// Legacy name for [shouldClearSessionOnPageHide] (always `false`).
bool shouldLogoutOnPageHide({
  required bool isWeb,
  required bool persisted,
  bool isLastTab = true,
}) {
  return shouldClearSessionOnPageHide(
    isWeb: isWeb,
    persisted: persisted,
    isLastTab: isLastTab,
  );
}

/// Clears vault + session controllers and best-effort socket disconnect.
///
/// Not used from `pagehide` anymore. Kept for tests / any future non-unload
/// caller. Must never be wired back into `registerWebTabCloseLogout`.
void performTabCloseLogoutSync() {
  try {
    clearStoredSessionSync();
    clearSessionControllers();
  } catch (e, s) {
    AppLogger.e('Session clear during tab close logout', e, s);
  }

  try {
    if (Get.isRegistered<SocketService>()) {
      unawaited(SocketService.to.disconnect());
    }
  } catch (e, s) {
    AppLogger.e('Socket disconnect during tab close logout', e, s);
  }
}

/// Async variant of [performTabCloseLogoutSync] (not used from pagehide).
Future<void> performTabCloseLogout() async {
  try {
    await clearStoredSession();
    clearSessionControllers();
  } catch (e, s) {
    AppLogger.e('Session clear during tab close logout', e, s);
  }

  try {
    if (Get.isRegistered<SocketService>()) {
      await SocketService.to.disconnect();
    }
  } catch (e, s) {
    AppLogger.e('Socket disconnect during tab close logout', e, s);
  }
}
