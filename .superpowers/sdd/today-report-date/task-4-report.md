# Task 4 Report: Widgets and list call sites

## Status

**DONE**

## Summary

Wired `date` (YYYY-MM-DD, pre-formatted) through all today-report tooltip widgets and list call sites so every `loadToday*`, `clearToday*`, and accessor call uses the withdraw row's `requestDate`.

## Changes

### 1. `hover_tooltip_today_payment_report.widget.dart`

- Added `final String date` (required constructor param).
- Passed `date: widget.date` to:
  - `loadTodayPaymentReport`
  - `todayPaymentReportStateFor`
  - `todayPaymentReportErrorFor`
- Forwarded `date` to `TodayPaymentReportTooltipContent`.

### 2. `today_payment_report_tooltip_content.widget.dart`

- Added `final String date` (required constructor param).
- Passed `date: widget.date` to:
  - `loadTodayWithdrawRequestReport` (initial load + reload)
  - `loadTodayDepositRequestReport` (initial load + reload)
  - `clearTodayWithdrawRequestReportCache` (dispose + collapse)
  - `clearTodayDepositRequestReportCache` (dispose + collapse)
  - `todayWithdrawRequestReportStateFor` / `todayWithdrawRequestReportErrorFor`
  - `todayDepositRequestReportStateFor` / `todayDepositRequestReportErrorFor`

### 3. `hover_tooltip_withdraw_request_report.widget.dart`

- Added `final String date`.
- Updated all loader, cache-clear, state, and error accessor calls to pass `date: widget.date`.
- Not currently referenced from list views; updated for API consistency if re-used.

### 4. `hover_tooltip_deposit_request_report.widget.dart`

- Same pattern as withdraw-request hover tooltip.

### 5. `withdraws_list.view.dart`

- Imported `request_date_api.util.dart`.
- Both `HoverTooltipTodayPaymentReportWidget` sites (~6152 paid amount, ~7323 deposit-request account name) now pass:
  ```dart
  date: formatRequestDateForApi(withdraw.requestDate),
  ```
- Deposit-request nested row uses parent `withdraw.requestDate` as specified.

### 6. `test/today_payment_report_tooltip_test.dart`

- `_ExpandingWithdrawController.loadTodayWithdrawRequestReport` now includes `required String date`.
- All six `TodayPaymentReportTooltipContent` constructions pass `date: '2026-07-08'`.

## Validation

### Tests

```
flutter test test/request_date_api_util_test.dart test/today_payment_report_tooltip_test.dart
```

**Result:** 9/9 passed.

### Analyze

```
dart analyze lib/src/config/repository/withdraw.repository.dart lib/src/domain/withdraw/controller/withdraw.controller.dart lib/src/domain/withdraw/widget lib/src/domain/withdraw/view/withdraws_list.view.dart
```

**Result:** No errors. 58 pre-existing warnings/info (unused imports, deprecated `withOpacity`, etc.) — none introduced by this task.

### Graphify

```
graphify update .
```

**Result:** Success (8496 nodes, 15751 edges).

## Commits

**Skipped** — workspace has no git repository (per constraint).

## Self-review

| Check | Result |
| --- | --- |
| `String date` on tooltip widgets | Yes — all three hover tooltip widgets + nested content |
| Value from `requestDate` via `formatRequestDateForApi` | Yes — both list call sites |
| Format YYYY-MM-DD | Yes — util produces that format; widgets receive pre-formatted string |
| All `loadToday*` / `clearToday*` / accessor calls pass `date` | Yes — verified in modified widget files |
| Tests updated | Yes — mock signature + widget constructions |
| Project compiles | Yes — tests pass, analyze clean for new code |
| Placeholders / TBDs | None |

## Concerns

None. Withdraw/deposit standalone hover tooltip widgets are updated but have no current call sites; they will require `date` when wired in future.
