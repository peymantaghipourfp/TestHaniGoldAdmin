# Task 3 Report: Controller loaders + composite cache keys

## Status: DONE

## Scope

Modified only: `lib/src/domain/withdraw/controller/withdraw.controller.dart`

No git repository in workspace — commit skipped per instructions.

## Changes Implemented

### 1. Composite cache key helper

```dart
String _todayReportCacheKey(int accountId, String date) => '$accountId|$date';
```

### 2. Cache / in-flight maps

Changed all six today-report maps from `Map<int, …>` to `Map<String, …>` keyed by `_todayReportCacheKey(accountId, date)`.

### 3. Loader signatures (required `date`)

- `loadTodayPaymentReport(int accountId, {required String date, bool forceRefresh = false})`
- `loadTodayWithdrawRequestReport(int accountId, {required String date, bool forceRefresh = false})`
- `loadTodayDepositRequestReport(int accountId, {required String date, bool forceRefresh = false})`

### 4. State / data / error accessors (required `date`)

- `todayPaymentReportStateFor` / `todayPaymentReportFor` / `todayPaymentReportErrorFor`
- `todayWithdrawRequestReportStateFor` / `todayWithdrawRequestReportFor` / `todayWithdrawRequestReportErrorFor`
- `todayDepositRequestReportStateFor` / `todayDepositRequestReportFor` / `todayDepositRequestReportErrorFor`

### 5. Clear-cache overloads (optional `date`)

- `clearTodayPaymentReportCache([int? accountId, String? date])`
- `clearTodayWithdrawRequestReportCache([int? accountId, String? date])`
- `clearTodayDepositRequestReportCache([int? accountId, String? date])`

Behavior:
- `accountId == null` → clear entire map
- `accountId` + `date` → remove single composite key
- `accountId` only → remove all keys with prefix `'$accountId|'` (preserves prior “clear for account” semantics across dates)

`clearTodayReportCaches()` unchanged — still clears all six maps.

### 6. Fetch methods thread `date` to repository

- `_fetchTodayPaymentReport(accountId, date)` → `getTodayPaymentReport(accountId:, date:)`
- `_fetchTodayWithdrawRequestReport(accountId, date)` → `getTodayWithdrawRequest(accountId:, date:)`
- `_fetchTodayDepositRequestReport(accountId, date)` → `getTodayDepositRequest(accountId:, date:)`

Controller does **not** format dates; callers pass pre-formatted `String date`.

## Validation

### `dart analyze lib/src/domain/withdraw/controller/withdraw.controller.dart`

```
10 issues found (exit code 2)
```

All issues are **pre-existing** warnings/info in unrelated code (unnecessary null comparisons, unnecessary import, avoid_print, strict_top_level_inference). **No errors** in the controller file from this task.

### Downstream call sites (expected — Task 4)

Analyzing widgets/tests surfaces **18 `missing_required_argument` errors** for `date:` and **1 `invalid_override`** in the test stub:

| File | Errors |
|------|--------|
| `hover_tooltip_today_payment_report.widget.dart` | 3 |
| `hover_tooltip_withdraw_request_report.widget.dart` | 3 |
| `hover_tooltip_deposit_request_report.widget.dart` | 3 |
| `today_payment_report_tooltip_content.widget.dart` | 8 |
| `test/today_payment_report_tooltip_test.dart` | 1 (invalid_override) |

This matches the plan expectation: widget/test fixes deferred to Task 4.

## Self-Review

| Check | Result |
|-------|--------|
| Composite keys used consistently in cache + in-flight | ✓ |
| `date` threaded through load → fetch → repository | ✓ |
| No date formatting inside controller | ✓ |
| `forceRefresh` clears correct composite key | ✓ |
| Only controller file modified | ✓ |
| Graphify updated | ✓ |

### Design note (account-only clear)

When `clearToday*Cache(accountId)` is called without `date`, entries are removed by `accountId|` prefix. This keeps `getWithdrawListPager()` → `clearTodayReportCaches()` behavior intact while allowing precise per-date eviction when both args are supplied.

## Commits

None (no git repo).

## Concerns

None blocking. Widget/test compile errors are intentional until Task 4.
