import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/secure_session_storage.dart';
import 'package:hanigold_admin/src/config/web_route_hash.dart';
import 'package:universal_html/html.dart' as html;

bool get supportsOpenInNewTab => true;

Future<void> openRouteInNewTab(
    String route, {
      String? title,
      int? iconCodePoint,
    }) async {
  try {
    // Ensure the new tab can hydrate Authorization from shared secure storage.
    await SecureSessionStorage.instance.persistCacheToBackend();
    final currentUrl = html.window.location.href;
    final baseUrl = currentUrl.split('/#/')[0];
    final newUrl = buildNewTabUrl(baseUrl, route);
    html.window.open(newUrl, '_blank');
  } catch (e, s) {
    AppLogger.e('openRouteInNewTab failed', e, s);
    rethrow;
  }
}
