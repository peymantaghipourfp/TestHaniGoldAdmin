# Task 1 Report: Date format helper + unit tests

## What was implemented

Created a pure utility function `formatRequestDateForApi(DateTime? requestDate)` in `lib/src/domain/withdraw/util/request_date_api.util.dart`.

Behavior:
- Formats a non-null `DateTime` as `YYYY-MM-DD` using local calendar components (year, month, day).
- Zero-pads month and day to two digits.
- When `requestDate` is `null`, falls back to `DateTime.now()` (local) and formats that date the same way.

This matches the brief verbatim and is ready for later tasks to pass `formatRequestDateForApi(withdraw.requestDate)` into today-report API calls.

## What was tested and test results

Three unit tests in `test/request_date_api_util_test.dart`:

| Test | Assertion |
| --- | --- |
| `formats requestDate as YYYY-MM-DD` | `DateTime(2026, 7, 12, 15, 30)` → `'2026-07-12'` (time ignored) |
| `pads single-digit month and day` | `DateTime(2026, 1, 5)` → `'2026-01-05'` |
| `null requestDate falls back to today local date` | `null` → today's local `YYYY-MM-DD` |

**Result:** All 3 tests passed.

## TDD Evidence

### RED

**Command:**
```
flutter test test/request_date_api_util_test.dart
```

**Relevant failing output:**
```
test/request_date_api_util_test.dart:2:8: Error: Error when reading 'lib/src/domain/withdraw/util/request_date_api.util.dart': The system cannot find the file specified
import 'package:hanigold_admin/src/domain/withdraw/util/request_date_api.util.dart';
       ^
test/request_date_api_util_test.dart:7:7: Error: Method not found: 'formatRequestDateForApi'.
...
00:00 +0 -1: Some tests failed.
```

**Why expected:** Test file was written before the implementation file existed, per TDD step 1–2 in the brief. Compilation failed because the import target and function were missing.

### GREEN

**Command:**
```
flutter test test/request_date_api_util_test.dart
```

**Relevant passing output:**
```
00:00 +0: formats requestDate as YYYY-MM-DD
00:00 +1: pads single-digit month and day
00:00 +2: null requestDate falls back to today local date
00:00 +3: All tests passed!
```

**Why expected:** Minimal implementation from the brief satisfies all three test cases.

## Files changed

| File | Action |
| --- | --- |
| `lib/src/domain/withdraw/util/request_date_api.util.dart` | Created |
| `test/request_date_api_util_test.dart` | Created |

No repository, controller, or UI files were touched.

## Self-review findings

- Implementation matches the brief exactly — no extra logic, dependencies, or exports.
- File placement follows existing withdraw util convention (`today_payment_report_section.util.dart` in the same directory).
- Top-level function style is consistent with sibling utils.
- Linter: no issues on changed files.
- `graphify update .` ran successfully after code changes.

## Issues or concerns

- **Null fallback uses local `DateTime.now()`:** Correct per brief; callers in later tasks should be aware that `null` means "today" in the device's local timezone, not UTC or Jalali calendar. This is intentional for the API `date` query param when `withdraw.requestDate` is absent.
- **No timezone normalization:** The helper uses `DateTime` year/month/day as-is. If `requestDate` is ever stored as UTC midnight, edge cases near timezone boundaries are possible — out of scope for this task; `WithdrawModel.requestDate` usage in later tasks should be checked.

## Commits

**Commits skipped (no git):** Workspace has no `.git` directory. Step 5 commit from the brief was not run.
