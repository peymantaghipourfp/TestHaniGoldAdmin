/// localStorage key for the cross-tab presence registry (JSON map of tabId → lastSeenMs).
const webTabPresenceStorageKey = 'hanigold_web_tab_presence';

/// Tabs with no heartbeat for this long are treated as gone (crash / killed without pagehide).
const webTabPresenceStaleMs = 45000;

/// Upserts [tabId] into the presence map and drops stale peers.
Map<String, int> upsertTabPresence({
  required Map<String, int> tabs,
  required String tabId,
  required int nowMs,
  int staleMs = webTabPresenceStaleMs,
}) {
  final next = <String, int>{};
  for (final entry in tabs.entries) {
    if (nowMs - entry.value <= staleMs) {
      next[entry.key] = entry.value;
    }
  }
  next[tabId] = nowMs;
  return next;
}

/// Removes [tabId], drops stale peers, and reports whether any other live tab remains.
({Map<String, int> tabs, bool isLastTab}) removeTabPresence({
  required Map<String, int> tabs,
  required String tabId,
  required int nowMs,
  int staleMs = webTabPresenceStaleMs,
}) {
  final next = <String, int>{};
  for (final entry in tabs.entries) {
    if (entry.key == tabId) continue;
    if (nowMs - entry.value <= staleMs) {
      next[entry.key] = entry.value;
    }
  }
  return (tabs: next, isLastTab: next.isEmpty);
}
