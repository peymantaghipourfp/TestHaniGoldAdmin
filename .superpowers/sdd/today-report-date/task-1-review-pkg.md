# Review package - Task 1 (no git)
Base: pre-task (files did not exist)
Head: working tree after Task 1
Commits: none (no git)

## Stat
 create mode lib/src/domain/withdraw/util/request_date_api.util.dart
 create mode test/request_date_api_util_test.dart

## Files

### lib/src/domain/withdraw/util/request_date_api.util.dart
```dart
String formatRequestDateForApi(DateTime? requestDate) {
  final d = requestDate ?? DateTime.now();
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
``` 

### test/request_date_api_util_test.dart
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
