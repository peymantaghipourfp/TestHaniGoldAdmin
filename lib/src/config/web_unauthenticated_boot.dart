import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/pending_post_login_route.dart';
import 'package:hanigold_admin/src/config/routes/route_page.dart';
import 'package:hanigold_admin/src/config/session_storage.dart';
import 'package:hanigold_admin/src/config/web_route_hash.dart';
import 'package:universal_html/html.dart' as html;

/// Whether an unauthenticated web boot must leave [currentRoute] for `/login`.
///
/// Flutter Web prefers [PlatformDispatcher.defaultRouteName] (from the URL hash)
/// over [GetMaterialApp.initialRoute], so a protected deep link still opens even
/// when bootstrap returns `/login`.
bool shouldForceLoginInsteadOfDeepLink(String? currentRoute) {
  if (currentRoute == null || currentRoute.isEmpty) return false;
  return !pendingBootstrapOnlyRoutes.contains(currentRoute);
}

/// Replaces the browser hash with `#/login` without adding history entries.
///
/// Call after session vault init and pending-route save, before [runApp], so the
/// platform default route name can align with `/login` when it re-reads the URL.
void replaceBrowserHashWithLogin() {
  if (!kIsWeb) return;
  try {
    final href = html.window.location.href;
    final base = href.contains('#') ? href.split('#').first : href;
    html.window.history.replaceState(null, '', '$base#/login');
  } catch (e, s) {
    AppLogger.e('replaceBrowserHashWithLogin failed', e, s);
  }
}

/// Post-frame safety net: leave a protected deep link when the vault is empty.
void enforceUnauthenticatedWebLoginRedirect() {
  if (!kIsWeb) return;
  if (hasActiveStoredSession()) return;

  final current = Get.currentRoute;
  if (!shouldForceLoginInsteadOfDeepLink(current)) return;

  AppLogger.w(
    'Unauthenticated web deep link blocked: $current → /login '
        '(platform defaultRouteName overrides initialRoute)',
  );

  savePendingPostLoginRoute(
    current,
    knownRouteNames: RoutePage.knownRouteNames,
  );
  replaceBrowserHashWithLogin();

  try {
    Get.offAllNamed('/login');
  } catch (e, s) {
    AppLogger.e('enforceUnauthenticatedWebLoginRedirect navigation failed', e, s);
  }
}

/// Builds the hash string that [replaceBrowserHashWithLogin] would apply.
///
/// Pure helper for tests — does not touch the browser.
String buildLoginHashUrl(String href) {
  final base = href.contains('#') ? href.split('#').first : href;
  return '$base#/login';
}

/// Parses a platform [defaultRouteName] the same way we treat a hash path.
String? normalizePlatformDefaultRoute(String? defaultRouteName) {
  if (defaultRouteName == null || defaultRouteName.isEmpty) return null;
  if (defaultRouteName == '/') return null;
  return parseHashRoute(
    defaultRouteName.startsWith('#') ? defaultRouteName : '#$defaultRouteName',
  );
}
