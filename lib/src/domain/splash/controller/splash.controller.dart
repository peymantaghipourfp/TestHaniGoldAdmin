import 'dart:async';

import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/session_bootstrap.dart';

class SplashController extends GetxController {
  static const Duration _navigationDelay = Duration(seconds: 2);
  static const Duration _watchdogDelay = Duration(seconds: 6);

  @override
  void onInit() {
    super.onInit();
    unawaited(_navigateFromSplash());
    unawaited(_startSplashWatchdog());
  }

  Future<void> _navigateFromSplash() async {
    await Future.delayed(_navigationDelay);
    if (isClosed) return;

    try {
      if (hasActiveStoredSession()) {
        final destination = resolvePostSplashRoute('/home');
        await Get.offNamed(destination);
      } else {
        await Get.offNamed('/login');
      }
    } catch (e, s) {
      AppLogger.e('Splash navigation failed', e, s);
      await invalidateStoredSessionAndGoToLogin(
        reason: 'Splash navigation error',
      );
    }
  }

  /// Fail-safe: never leave the user stuck on splash.
  Future<void> _startSplashWatchdog() async {
    await Future.delayed(_watchdogDelay);
    if (isClosed) return;
    if (Get.currentRoute == '/splash') {
      AppLogger.w('Splash watchdog: still on splash, redirecting to login');
      await invalidateStoredSessionAndGoToLogin(
        reason: 'Splash watchdog timeout',
      );
    }
  }
}
