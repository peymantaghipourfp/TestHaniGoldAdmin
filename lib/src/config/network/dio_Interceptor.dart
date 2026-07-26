
import 'package:dio/dio.dart';

import '../logger/app_logger.dart';
import '../secure_session_storage.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final session = SecureSessionStorage.instance;
      final token = session.read('Authorization');
      final sessionId = session.read('x-session-id');

      // Authorization Header
      if (token != null && token.toString().isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      // Session Header
      if (sessionId != null && sessionId.toString().isNotEmpty) {
        options.headers['x-session-id'] = sessionId.toString();
      }

      AppLogger.d(
          '➡️ REQUEST[${options.method}] => ${options.baseUrl}${options.path}');
      AppLogger.d('Headers: ${options.headers}');
      AppLogger.d('Query: ${options.queryParameters}');
      AppLogger.d('Body: ${options.data}');
    } catch (e, s) {
      AppLogger.e('onRequest error', e, s);
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.i(
        '✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.path}');
    AppLogger.d('Response Data: ${response.data}');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e(
      '❌ ERROR[${err.response?.statusCode}] => ${err.requestOptions.path}',
      err.message,
      err.stackTrace,
    );

    /// 🔐 در آینده برای refresh token:
    if (err.response?.statusCode == 401) {
      AppLogger.w('Unauthorized - token may be expired');
      // اینجا می‌توانی refresh token بزنی
    }

    handler.next(err);
  }
}
