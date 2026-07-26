import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/session_bootstrap.dart';

/// Ensures [ChatController] exists when a chat route is opened.
///
/// Primary registration happens in [bootstrapSessionControllers] at app start;
/// this binding is a safe fallback aligned with login / tear-off tab bootstrap.
class ChatBindings implements Bindings {
  @override
  void dependencies() {
    if (hasActiveStoredSession()) {
      registerChatControllerIfNeeded();
    }
  }
}
