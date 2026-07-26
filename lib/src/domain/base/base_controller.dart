import 'dart:async';
import 'package:get/get.dart';
import '../../config/const/socket.service.dart';
import '../../config/logger/app_logger.dart';
import '../../config/secure_session_storage.dart';

// Base controller that ensures socket connection for all controllers
class BaseController extends GetxController {
  final SocketService socketService = Get.find<SocketService>();
  final SecureSessionStorage session = SecureSessionStorage.instance;

  // Reactive variable to track socket connection status
  final RxBool isSocketConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToSocketStatus();
  }

  void _listenToSocketStatus() {
    // Check socket status periodically since _connectionStatus is private
    Timer.periodic(Duration(seconds: 2), (timer) {
      final wasConnected = isSocketConnected.value;
      final isNowConnected = socketService.isConnected;

      if (wasConnected != isNowConnected) {
        isSocketConnected.value = isNowConnected;
        AppLogger.i(
          'BaseController: Socket status changed → ${isNowConnected ? 'connected' : 'disconnected'}',
        );
      }

      // Stop timer if controller is disposed
      if (!Get.isRegistered<BaseController>()) {
        timer.cancel();
      }
    });
  }

  // Method to get current user ID
  int? get currentUserId {
    final raw = session.read('id');
    if (raw == null) return null;
    return int.tryParse(raw.toString());
  }

  String? get sessionId => session.read('x-session-id')?.toString();

  // Method to check if user is logged in
  bool get isLoggedIn {
    final token = session.read('Authorization');
    return token != null && token.toString().isNotEmpty;
  }
}
