import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/socket.service.dart';
import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/secure_session_storage.dart';
import 'package:hanigold_admin/src/config/session_invalidation.dart';
import 'package:hanigold_admin/src/config/session_storage.dart';
import 'package:hanigold_admin/src/config/web_route_hash.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
import 'package:universal_html/html.dart' as html;

export 'session_storage.dart'
    show hasActiveStoredSession, clearStoredSession, clearSessionControllers;

const _bootstrapOnlyRoutes = {'/splash', '/login'};

/// Registers [ChatController] once per app instance (light init only).
void registerChatControllerIfNeeded() {
  if (!Get.isRegistered<ChatController>()) {
    Get.put(ChatController(), permanent: true);
  }
}

/// Registers session-scoped controllers when the app boots with stored credentials.
void bootstrapSessionControllers() {
  if (!hasActiveStoredSession()) return;
  registerChatControllerIfNeeded();
}

/// On Web, reads the hash route from the current URL; otherwise returns [fallback].
String resolveWebInitialRoute(String fallback) {
  if (!kIsWeb) return fallback;
  return parseHashRoute(html.window.location.hash) ?? fallback;
}

/// Post-splash destination: never re-navigate to splash/login from stored session.
String resolvePostSplashRoute([String fallback = '/home']) {
  if (!kIsWeb) return fallback;
  final route = parseHashRoute(html.window.location.hash);
  if (route == null || _bootstrapOnlyRoutes.contains(route)) {
    return fallback;
  }
  return route;
}

/// Disconnects socket, clears session, and routes to login.
Future<void> invalidateStoredSessionAndGoToLogin({String? reason}) async {
  try {
    if (Get.isRegistered<SocketService>()) {
      await SocketService.to.disconnect();
    }
  } catch (e, s) {
    AppLogger.e('Socket disconnect during session invalidation', e, s);
  }
  await clearSessionAndRedirectToLogin(reason: reason);
}

/// Ensures the WebSocket is connected when the app boots with stored credentials.
Future<void> bootstrapSocketConnection() async {
  if (!hasActiveStoredSession()) return;
  if (!Get.isRegistered<SocketService>()) return;
  try {
    final session = SecureSessionStorage.instance;
    await SocketService.to.ensureConnected(
      clientId: session.read('id')?.toString(),
      sessionId: session.read('x-session-id')?.toString(),
    );
  } catch (e, s) {
    AppLogger.e('bootstrapSocketConnection failed', e, s);
  }
}
