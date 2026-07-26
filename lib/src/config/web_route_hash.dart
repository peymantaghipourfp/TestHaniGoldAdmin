/// Parses `window.location.hash` into a GetX route path.
///
/// Examples: `#/orderList` → `/orderList`; empty, `#`, or `#/` → `null`.
String? parseHashRoute(String hash) {
  if (hash.isEmpty || hash == '#') return null;

  var route = hash.startsWith('#') ? hash.substring(1) : hash;
  if (route.isEmpty || route == '/') return null;
  if (!route.startsWith('/')) route = '/$route';
  return route;
}

/// Builds a hash-based URL for opening a route in a new browser tab.
String buildNewTabUrl(String baseUrl, String route) {
  final normalizedRoute = route.startsWith('/') ? route : '/$route';
  final base = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  return '$base/#$normalizedRoute';
}
