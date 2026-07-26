import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:hanigold_admin/src/config/logger/app_logger.dart';
import 'package:hanigold_admin/src/config/web_tab_presence_logic.dart';
import 'package:universal_html/html.dart' as html;

/// Tracks live admin-panel tabs so shared session logout only runs on the last tab.
class WebTabPresence {
  WebTabPresence({
    String? tabId,
    int Function()? nowMs,
  })  : tabId = tabId ?? _newTabId(),
        _nowMs = nowMs ?? _defaultNowMs;

  final String tabId;
  final int Function() _nowMs;
  Timer? _heartbeat;

  static int _defaultNowMs() => DateTime.now().millisecondsSinceEpoch;

  static String _newTabId() {
    final random = Random();
    final suffix = List.generate(8, (_) => random.nextInt(16).toRadixString(16))
        .join();
    return 'tab_${_defaultNowMs()}_$suffix';
  }

  Map<String, int> _readTabs() {
    try {
      final raw = html.window.localStorage[webTabPresenceStorageKey];
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final tabs = <String, int>{};
      decoded.forEach((key, value) {
        final id = key?.toString();
        if (id == null || id.isEmpty) return;
        final seen = value is int
            ? value
            : int.tryParse(value?.toString() ?? '');
        if (seen != null) tabs[id] = seen;
      });
      return tabs;
    } catch (e, s) {
      AppLogger.e('WebTabPresence read failed', e, s);
      return {};
    }
  }

  void _writeTabs(Map<String, int> tabs) {
    try {
      html.window.localStorage[webTabPresenceStorageKey] = jsonEncode(tabs);
    } catch (e, s) {
      AppLogger.e('WebTabPresence write failed', e, s);
    }
  }

  /// Registers this tab and starts a heartbeat so peers can detect liveliness.
  void start() {
    final now = _nowMs();
    _writeTabs(
      upsertTabPresence(tabs: _readTabs(), tabId: tabId, nowMs: now),
    );
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 10), (_) {
      final tick = _nowMs();
      _writeTabs(
        upsertTabPresence(tabs: _readTabs(), tabId: tabId, nowMs: tick),
      );
    });
  }

  /// Removes this tab from the registry. Returns true when no other live tabs remain.
  bool unregisterAndCheckIfLast() {
    _heartbeat?.cancel();
    _heartbeat = null;
    final result = removeTabPresence(
      tabs: _readTabs(),
      tabId: tabId,
      nowMs: _nowMs(),
    );
    _writeTabs(result.tabs);
    return result.isLastTab;
  }

  void dispose() {
    _heartbeat?.cancel();
    _heartbeat = null;
  }
}
