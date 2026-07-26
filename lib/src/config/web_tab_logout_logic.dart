import 'dart:async';

import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/socket.service.dart';
import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/session_storage.dart';

/// Whether a pagehide event should trigger tab-close logout.
///
/// Skips when not web, when the page enters the back-forward cache
/// ([persisted] true), or when other app tabs are still alive
/// ([isLastTab] false). Shared session storage must survive while any
/// tab remains — otherwise a new tab boots without Authorization (401).
bool shouldLogoutOnPageHide({
  required bool isWeb,
  required bool persisted,
  bool isLastTab = true,
}) {
  if (!isWeb) return false;
  if (persisted) return false;
  if (!isLastTab) return false;
  return true;
}

/// Synchronous tab-close teardown for pagehide/unload handlers.
///
/// Clears stored session first (sync kickoff), then controllers, then
/// attempts socket disconnect without blocking on async work.
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

/// Logout-equivalent teardown for tab close (async callers may await socket).
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
