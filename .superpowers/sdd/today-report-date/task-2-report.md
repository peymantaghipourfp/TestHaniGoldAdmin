# Task 2 Report: Repository `date` query parameter

## Status: DONE

## Summary

Added `required String date` to all three today-report GET methods in `withdraw.repository.dart` and included `'date': date` in each method's `queryParameters` option map alongside `'accountId'`.

## Changes

**File modified:** `lib/src/config/repository/withdraw.repository.dart`

### Methods updated

1. `getTodayPaymentReport({required int accountId, required String date})`
2. `getTodayWithdrawRequest({required int accountId, required String date})`
3. `getTodayDepositRequest({required int accountId, required String date})`

Each method now builds:

```dart
final Map<String, dynamic> option = {
  'accountId': accountId,
  'date': date,
};
```

Pattern matches `transfer_wallet.repository.dart` usage of `'date'` in `queryParameters`.

## Validation

**Command:** `dart analyze lib/src/config/repository/withdraw.repository.dart`

**Result:** 1 pre-existing warning at line 137 (`unnecessary_null_comparison`) — unrelated to this task. No errors in the modified file. Call-site errors in controllers/views are expected until Tasks 3–4.

## Commits

Skipped — no git repository in workspace.

## Self-review

- [x] All three methods have `required String date` in signature
- [x] Query key is exactly `'date'`
- [x] Option map includes both `accountId` and `date`
- [x] No changes outside the three target methods
- [x] No dependency on Task 1 util in repository (accepts pre-formatted string)
- [x] Analyzer clean for this file (only pre-existing warning)

## Concerns

None. Mid-plan call-site analyzer errors at controllers are expected and acceptable per plan.
