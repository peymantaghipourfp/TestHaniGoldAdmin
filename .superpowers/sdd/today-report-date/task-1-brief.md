### Task 1: Date format helper + unit tests

**Files:**
- Create: `lib/src/domain/withdraw/util/request_date_api.util.dart`
- Test: `test/request_date_api_util_test.dart`

**Interfaces:**
- Produces: `String formatRequestDateForApi(DateTime? requestDate)`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hanigold_admin/src/domain/withdraw/util/request_date_api.util.dart';

void main() {
  test('formats requestDate as YYYY-MM-DD', () {
    expect(
      formatRequestDateForApi(DateTime(2026, 7, 12, 15, 30)),
      '2026-07-12',
    );
  });

  test('pads single-digit month and day', () {
    expect(formatRequestDateForApi(DateTime(2026, 1, 5)), '2026-01-05');
  });

  test('null requestDate falls back to today local date', () {
    final now = DateTime.now();
    final expected =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    expect(formatRequestDateForApi(null), expected);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/request_date_api_util_test.dart`
Expected: FAIL (library/helper not found)

- [ ] **Step 3: Write minimal implementation**

```dart
String formatRequestDateForApi(DateTime? requestDate) {
  final d = requestDate ?? DateTime.now();
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/request_date_api_util_test.dart`
Expected: PASS (all 3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/src/domain/withdraw/util/request_date_api.util.dart test/request_date_api_util_test.dart
git commit -m "feat(withdraw): add YYYY-MM-DD requestDate API formatter"
```

---

