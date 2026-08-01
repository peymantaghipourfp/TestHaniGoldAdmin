import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hanigold_admin/src/config/network/dio_Interceptor.dart';
import 'package:hanigold_admin/src/config/secure_session_storage.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '.';
      }
      return null;
    });
    await GetStorage.init('dio_interceptor_session_header_test');
  });

  setUp(() async {
    SecureSessionStorage.resetInstance();
    SecureSessionStorage.instance = SecureSessionStorage(
      backend: MemorySessionSecretBackend(),
      getStorage: GetStorage('dio_interceptor_session_header_test'),
    );
    await SecureSessionStorage.instance.init();
    await SecureSessionStorage.instance.write('Authorization', 'test-token');
    await SecureSessionStorage.instance.write('x-session-id', 'session-abc');
    await SecureSessionStorage.instance.write('id', '1');
  });

  tearDown(() {
    SecureSessionStorage.resetInstance();
  });

  test('onRequest sets Authorization but not x-session-id', () async {
    final dio = Dio();
    dio.interceptors.add(DioInterceptor());
    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ),
    );

    await dio.get('/api/test');

    expect(captured.headers['Authorization'], 'Bearer test-token');
    expect(captured.headers.containsKey('x-session-id'), isFalse);
  });
}
