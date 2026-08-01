import 'package:get_storage/get_storage.dart';

import 'package:hanigold_admin/src/config/logger/app_logger.dart';

const String pendingPostLoginRouteKey = 'pending_post_login_route';

const Set<String> pendingBootstrapOnlyRoutes = {'/splash', '/login'};

bool isPendingPostLoginRouteAllowed(
  String? route,
  Set<String> knownRouteNames,
) {
  if (route == null || route.isEmpty) return false;
  if (pendingBootstrapOnlyRoutes.contains(route)) return false;
  return knownRouteNames.contains(route);
}

void savePendingPostLoginRoute(
  String? route, {
  required Set<String> knownRouteNames,
  GetStorage? box,
}) {
  if (!isPendingPostLoginRouteAllowed(route, knownRouteNames)) return;
  try {
    (box ?? GetStorage()).write(pendingPostLoginRouteKey, route);
  } catch (e, s) {
    AppLogger.e('savePendingPostLoginRoute failed', e, s);
  }
}

String? consumePendingPostLoginRoute({GetStorage? box}) {
  final storage = box ?? GetStorage();
  try {
    final raw = storage.read(pendingPostLoginRouteKey);
    storage.remove(pendingPostLoginRouteKey);
    if (raw == null) return null;
    final route = raw.toString().trim();
    return route.isEmpty ? null : route;
  } catch (e, s) {
    AppLogger.e('consumePendingPostLoginRoute failed', e, s);
    return null;
  }
}

/// Unauthenticated web boot: always `/login`; may persist [hashRoute] as pending.
String resolveUnauthenticatedWebBootRoute({
  required String? hashRoute,
  required Set<String> knownRouteNames,
  GetStorage? box,
}) {
  savePendingPostLoginRoute(
    hashRoute,
    knownRouteNames: knownRouteNames,
    box: box,
  );
  return '/login';
}
