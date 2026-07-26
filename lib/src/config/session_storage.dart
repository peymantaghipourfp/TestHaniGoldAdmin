import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/secure_session_storage.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';

/// Whether stored credentials indicate a logged-in session.
bool hasActiveStoredSession() {
  return SecureSessionStorage.instance.hasActiveSession();
}

/// Kicks off session key removal synchronously (in-memory + GetStorage scrub).
///
/// Use on pagehide/unload where awaiting [clearStoredSession] may not finish
/// before the browser tears down the tab.
void clearStoredSessionSync() {
  SecureSessionStorage.instance.clearAllSync();
}

/// Removes persisted auth/session keys (logout / invalid session).
Future<void> clearStoredSession() async {
  await SecureSessionStorage.instance.clearAll();
}

/// Tears down session-scoped controllers on logout or invalid session.
void clearSessionControllers() {
  if (Get.isRegistered<ChatController>()) {
    Get.delete<ChatController>(force: true);
  }
}
