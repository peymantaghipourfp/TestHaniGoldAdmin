# Review package - Task 2 (no git)
Base: pre-task (methods had accountId only)
Head: working tree after Task 2
Commits: none (no git)

## Stat
 modify lib/src/config/repository/withdraw.repository.dart (3 methods)

## Diff (post-change methods 574–650)

```dart
  Future<TodayPaymentReportModel> getTodayPaymentReport({
    required int accountId,
    required String date,
  }) async {
    try {
      final Map<String, dynamic> option = {
        'accountId': accountId,
        'date': date,
      };
      final response = await withdrawDio.get(
        'WithdrawRequest/getTodayPaymentReport',
        queryParameters: option,
      );
      return TodayPaymentReportModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } catch (e, s) {
      AppLogger.e('getTodayPaymentReport failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  Future<List<TodayWithdrawRequestReportModel>> getTodayWithdrawRequest({
    required int accountId,
    required String date,
  }) async {
    try {
      final Map<String, dynamic> option = {
        'accountId': accountId,
        'date': date,
      };
      final response = await withdrawDio.get(
        'WithdrawRequest/getTodayWithdrawRequest',
        queryParameters: option,
      );
      final data = response.data;
      if (data is! List) return [];
      return data
          .map(
            (e) => TodayWithdrawRequestReportModel.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList();
    } catch (e, s) {
      AppLogger.e('getTodayWithdrawRequest failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  Future<List<TodayDepositRequestReportModel>> getTodayDepositRequest({
    required int accountId,
    required String date,
  }) async {
    try {
      final Map<String, dynamic> option = {
        'accountId': accountId,
        'date': date,
      };
      final response = await withdrawDio.get(
        'WithdrawRequest/getTodayDepositRequest',
        queryParameters: option,
      );
      final data = response.data;
      if (data is! List) return [];
      return data
          .map(
            (e) => TodayDepositRequestReportModel.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList();
    } catch (e, s) {
      AppLogger.e('getTodayDepositRequest failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }
```
