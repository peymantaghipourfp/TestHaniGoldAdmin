import 'dart:async';

import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/session_storage.dart';

bool _redirectInFlight = false;

/// Routes to login after session data has been cleared. Safe to call repeatedly.
Future<void> redirectToLoginIfNeeded({String? reason}) async {
  if (_redirectInFlight) return;
  _redirectInFlight = true;
  try {
    if (reason != null && reason.isNotEmpty) {
      AppLogger.w('Session invalidated: $reason');
    }
    if (Get.key.currentState == null) return;
    if (Get.currentRoute == '/login') return;
    await Get.offAllNamed('/login');
  } catch (e, s) {
    AppLogger.e('redirectToLoginIfNeeded failed', e, s);
  } finally {
    _redirectInFlight = false;
  }
}

/// Clears stored session/controllers and navigates to login (no socket teardown).
Future<void> clearSessionAndRedirectToLogin({String? reason}) async {
  try {
    await clearStoredSession();
    clearSessionControllers();
    await redirectToLoginIfNeeded(reason: reason);
  } catch (e, s) {
    AppLogger.e('clearSessionAndRedirectToLogin failed', e, s);
    await redirectToLoginIfNeeded(reason: reason);
  }
}

/// WebSocket close code / reason indicating the server rejected the session.
bool isInvalidSessionSocketClose({
  int? closeCode,
  String? closeReason,
  String? errorMessage,
}) {
  if (closeCode == 1008) return true;
  final combined = '${closeReason ?? ''} ${errorMessage ?? ''}'.toLowerCase();
  return combined.contains('invalid sessionid') ||
      combined.contains('invalid session');
}
