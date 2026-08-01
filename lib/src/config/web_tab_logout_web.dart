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

/// Registers tab presence + a [pagehide] handler that never clears the session.
///
/// Last-tab close and F5 both fire `pagehide`; vault wipe is disabled by
/// [shouldClearSessionOnPageHide]. Presence unregister still runs for
/// multi-tab bookkeeping.
void registerWebTabCloseLogout() {
  try {
    _tabPresence?.dispose();
    _tabPresence = WebTabPresence()..start();

    html.window.onPageHide.listen((event) {
      try {
        final persisted = _readPageHidePersisted(event);
        final isLastTab = _tabPresence?.unregisterAndCheckIfLast() ?? true;
        if (!shouldClearSessionOnPageHide(
          isWeb: true,
          persisted: persisted,
          isLastTab: isLastTab,
        )) {
          AppLogger.d(
            'pagehide: presence updated, session vault kept '
            '(persisted=$persisted, isLastTab=$isLastTab)',
          );
          return;
        }
        // Unreachable while shouldClearSessionOnPageHide is always false.
        // Intentionally no performTabCloseLogoutSync() — do not reintroduce.
        AppLogger.w(
          'pagehide: clear gate returned true unexpectedly; refusing vault wipe',
        );
      } catch (e, s) {
        AppLogger.e('pagehide tab presence handler failed', e, s);
      }
    });
  } catch (e, s) {
    AppLogger.e('registerWebTabCloseLogout failed', e, s);
  }
}
