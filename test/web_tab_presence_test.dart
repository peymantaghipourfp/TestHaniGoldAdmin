import 'package:flutter_test/flutter_test.dart';
import 'package:hanigold_admin/src/config/web_tab_presence_logic.dart';

void main() {
  group('upsertTabPresence', () {
    test('registers tab and prunes stale peers', () {
      final now = 100000;
      final tabs = upsertTabPresence(
        tabs: {
          'alive': now - 1000,
          'stale': now - webTabPresenceStaleMs - 1,
        },
        tabId: 'self',
        nowMs: now,
      );

      expect(tabs.keys, unorderedEquals(['alive', 'self']));
      expect(tabs['self'], now);
    });
  });

  group('removeTabPresence', () {
    test('reports last tab when no live peers remain', () {
      final now = 100000;
      final result = removeTabPresence(
        tabs: {
          'self': now,
          'stale': now - webTabPresenceStaleMs - 1,
        },
        tabId: 'self',
        nowMs: now,
      );

      expect(result.isLastTab, isTrue);
      expect(result.tabs, isEmpty);
    });

    test('keeps shared session when another live tab remains', () {
      final now = 100000;
      final result = removeTabPresence(
        tabs: {
          'self': now,
          'peer': now - 5000,
        },
        tabId: 'self',
        nowMs: now,
      );

      expect(result.isLastTab, isFalse);
      expect(result.tabs.keys, unorderedEquals(['peer']));
    });
  });
}
