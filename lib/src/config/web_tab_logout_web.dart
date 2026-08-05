import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/web_tab_logout_logic.dart';
import 'package:hanigold_admin/src/config/web_tab_presence_web.dart';
import 'package:universal_html/html.dart' as html;

bool _readPageHidePersisted(html.Event event) {
  try {
    return (event as dynamic).persisted == true;
  } catch (_) {
    return false;
  }
}

WebTabPresence? _tabPresence;

/// Registers a [pagehide] handler that logs out when the *last* app tab is closed.
void registerWebTabCloseLogout() {
  try {
    _tabPresence?.dispose();
    _tabPresence = WebTabPresence()..start();

    html.window.onPageHide.listen((event) {
      try {
        final persisted = _readPageHidePersisted(event);
        final isLastTab = _tabPresence?.unregisterAndCheckIfLast() ?? true;
        if (!shouldLogoutOnPageHide(
          isWeb: true,
          persisted: persisted,
          isLastTab: isLastTab,
        )) {
          AppLogger.d(
            'pagehide: skipping shared session clear '
                '(persisted=$persisted, isLastTab=$isLastTab)',
          );
          return;
        }
        performTabCloseLogoutSync();
      } catch (e, s) {
        AppLogger.e('pagehide tab-close logout handler failed', e, s);
      }
    });
  } catch (e, s) {
    AppLogger.e('registerWebTabCloseLogout failed', e, s);
  }
}
