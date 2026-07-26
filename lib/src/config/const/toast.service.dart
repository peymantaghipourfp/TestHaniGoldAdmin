import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';

import '../logger/app_logger.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  /// Dismiss in-flight toasts when the tab loses focus (avoids overlay assert).
  static void dismissActiveToasts() {
    try {
      SmartDialog.dismiss(status: SmartStatus.toast);
    } catch (e, s) {
      AppLogger.w('ToastService.dismissActiveToasts failed: $e\n$s');
    }
  }

  static bool _canPresentOverlay() {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      return false;
    }
    return true;
  }

  void _safeShowToast(void Function() show) {
    if (!_canPresentOverlay()) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_canPresentOverlay()) return;
      try {
        show();
      } catch (e, s) {
        AppLogger.w('Toast skipped (overlay unavailable): $e\n$s');
      }
    });
  }

  void show(String message) {
    _safeShowToast(() {
      SmartDialog.showToast(
        '',
        alignment: Alignment.topCenter,
        maskColor: const Color(0xff387ae7),
        animationType: SmartAnimationType.fade,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xff387ae7),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(65),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: AppColor.textColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    });
  }

  void success(String message) {
_safeShowToast(() {
    SmartDialog.showToast(
      message,
      alignment: Alignment.topCenter,
      maskColor: Colors.green.withAlpha(50),
    );
});
  }

  void error(String message) {
_safeShowToast(() {
    SmartDialog.showToast(
      message,
      alignment: Alignment.topCenter,
      maskColor: Colors.red.withAlpha(50),
    );
});
  }

  void info(String message) {
_safeShowToast(() {
    SmartDialog.showToast(
      message,
      alignment: Alignment.topCenter,
      maskColor: Colors.blue.withAlpha(50),
    );
});
  }
}
