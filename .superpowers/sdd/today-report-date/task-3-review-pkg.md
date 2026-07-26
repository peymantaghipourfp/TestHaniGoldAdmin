# Review package - Task 3 (no git)
Base: pre-task (int-keyed caches, no date on loaders)
Head: working tree after Task 3
Commits: none (no git)
File: lib/src/domain/withdraw/controller/withdraw.controller.dart

Full post-change controller snapshot (for line refs):
D:\curserAi project\.superpowers\sdd\today-report-date\_task3-controller-snapshot.dart

## Key hunks (excerpt)

Maps now String-keyed + helper at L155-162:
```
final Map<String, _TodayPaymentReportCacheEntry> _todayPaymentReportCache = {};
...
String _todayReportCacheKey(int accountId, String date) => '$accountId|$date';
```

Accessors, clear overloads, loaders, fetchers: L1283-1688 in snapshot.
See also implementer report for behavior of account-only clear (prefix remove).

## Diff excerpt (L1283-1688)
```dart
  final Map<String, _TodayPaymentReportCacheEntry> _todayPaymentReportCache = {};
  final Map<String, Future<TodayPaymentReportModel?>> _todayPaymentReportInFlight = {};
  final Map<String, _TodayWithdrawRequestReportCacheEntry> _todayWithdrawRequestReportCache = {};
  final Map<String, Future<List<TodayWithdrawRequestReportModel>?>> _todayWithdrawRequestReportInFlight = {};
  final Map<String, _TodayDepositRequestReportCacheEntry> _todayDepositRequestReportCache = {};
  final Map<String, Future<List<TodayDepositRequestReportModel>?>> _todayDepositRequestReportInFlight = {};

  String _todayReportCacheKey(int accountId, String date) => '$accountId|$date';


---

  TodayPaymentReportLoadState todayPaymentReportStateFor(
    int accountId, {
    required String date,
  }) {
    return _todayPaymentReportCache[_todayReportCacheKey(accountId, date)]
            ?.state ??
        TodayPaymentReportLoadState.idle;
  }

  TodayPaymentReportModel? todayPaymentReportFor(
    int accountId, {
    required String date,
  }) {
    return _todayPaymentReportCache[_todayReportCacheKey(accountId, date)]
        ?.data;
  }

  String? todayPaymentReportErrorFor(
    int accountId, {
    required String date,
  }) {
    return _todayPaymentReportCache[_todayReportCacheKey(accountId, date)]
        ?.errorMessage;
  }

  void clearTodayReportCaches() {
    _todayPaymentReportCache.clear();
    _todayPaymentReportInFlight.clear();
    _todayWithdrawRequestReportCache.clear();
    _todayWithdrawRequestReportInFlight.clear();
    _todayDepositRequestReportCache.clear();
    _todayDepositRequestReportInFlight.clear();
  }

  void clearTodayPaymentReportCache([int? accountId, String? date]) {
    if (accountId == null) {
      _todayPaymentReportCache.clear();
      _todayPaymentReportInFlight.clear();
    } else if (date != null) {
      final key = _todayReportCacheKey(accountId, date);
      _todayPaymentReportCache.remove(key);
      _todayPaymentReportInFlight.remove(key);
    } else {
      final prefix = '$accountId|';
      _todayPaymentReportCache.removeWhere((k, _) => k.startsWith(prefix));
      _todayPaymentReportInFlight.removeWhere((k, _) => k.startsWith(prefix));
    }
  }

  void clearTodayWithdrawRequestReportCache([int? accountId, String? date]) {
    if (accountId == null) {
      _todayWithdrawRequestReportCache.clear();
      _todayWithdrawRequestReportInFlight.clear();
    } else if (date != null) {
      final key = _todayReportCacheKey(accountId, date);
      _todayWithdrawRequestReportCache.remove(key);
      _todayWithdrawRequestReportInFlight.remove(key);
    } else {
      final prefix = '$accountId|';
      _todayWithdrawRequestReportCache
          .removeWhere((k, _) => k.startsWith(prefix));
      _todayWithdrawRequestReportInFlight
          .removeWhere((k, _) => k.startsWith(prefix));
    }
  }

  void clearTodayDepositRequestReportCache([int? accountId, String? date]) {
    if (accountId == null) {
      _todayDepositRequestReportCache.clear();
      _todayDepositRequestReportInFlight.clear();
    } else if (date != null) {
      final key = _todayReportCacheKey(accountId, date);
      _todayDepositRequestReportCache.remove(key);
      _todayDepositRequestReportInFlight.remove(key);
    } else {
      final prefix = '$accountId|';
      _todayDepositRequestReportCache
          .removeWhere((k, _) => k.startsWith(prefix));
      _todayDepositRequestReportInFlight
          .removeWhere((k, _) => k.startsWith(prefix));
    }
  }

  bool _isTodayPaymentReportEmpty(TodayPaymentReportModel report) {
    final numericValues = [
      report.withdrawRequestAmount,
      report.withdrawCoverageAmount,
      report.withdrawSettlementAmount,
      report.pledgeAmount,
      report.transferAmount,
      report.outstandingAmount,
      report.overPaymentAmount,
    ];
    final countValues = [
      report.withdrawRequestCount,
      report.withdrawCoverageCount,
      report.withdrawSettlementCount,
      report.pledgeCount,
      report.transferCount,
      report.activePledgeCount,
      report.finishedPledgeCount,
      report.overPaymentCount,
    ];
    final hasAmount = numericValues.any((v) => (v ?? 0) > 0);
    final hasCount = countValues.any((v) => (v ?? 0) > 0);
    return !hasAmount && !hasCount;
  }

  Future<TodayPaymentReportModel?> loadTodayPaymentReport(
    int accountId, {
    required String date,
    bool forceRefresh = false,
  }) async {
    if (accountId <= 0) return null;

    final cacheKey = _todayReportCacheKey(accountId, date);

    if (!forceRefresh) {
      final cached = _todayPaymentReportCache[cacheKey];
      if (cached != null &&
          (cached.state == TodayPaymentReportLoadState.success ||
              cached.state == TodayPaymentReportLoadState.empty)) {
        return cached.data;
      }
      final inFlight = _todayPaymentReportInFlight[cacheKey];
      if (inFlight != null) return inFlight;
    } else {
      _todayPaymentReportCache.remove(cacheKey);
      _todayPaymentReportInFlight.remove(cacheKey);
    }

    final future = _fetchTodayPaymentReport(accountId, date);
    _todayPaymentReportInFlight[cacheKey] = future;
    return future;
  }

  Future<TodayPaymentReportModel?> _fetchTodayPaymentReport(
    int accountId,
    String date,
  ) async {
    final cacheKey = _todayReportCacheKey(accountId, date);
    _todayPaymentReportCache[cacheKey] = _TodayPaymentReportCacheEntry(
      state: TodayPaymentReportLoadState.loading,
    );

    try {
      final report = await withdrawRepository.getTodayPaymentReport(
        accountId: accountId,
        date: date,
      );

      if (_isTodayPaymentReportEmpty(report)) {
        _todayPaymentReportCache[cacheKey] = _TodayPaymentReportCacheEntry(
          state: TodayPaymentReportLoadState.empty,
        );
        return null;
      }

      _todayPaymentReportCache[cacheKey] = _TodayPaymentReportCacheEntry(
        state: TodayPaymentReportLoadState.success,
        data: report,
      );
      return report;
    } on ErrorException catch (e) {
      AppLogger.e('loadTodayPaymentReport failed for account $accountId', e);
      _todayPaymentReportCache[cacheKey] = _TodayPaymentReportCacheEntry(
        state: TodayPaymentReportLoadState.error,
        errorMessage: e.message,
      );
      return null;
    } catch (e, s) {
      AppLogger.e('loadTodayPaymentReport failed for account $accountId', e, s);
      _todayPaymentReportCache[cacheKey] = _TodayPaymentReportCacheEntry(
        state: TodayPaymentReportLoadState.error,
        errorMessage: 'Ø®Ø·Ø§ Ø¯Ø± Ø¯Ø±ÛŒØ§ÙØª Ú¯Ø²Ø§Ø±Ø´ Ù¾Ø±Ø¯Ø§Ø®Øªâ€ŒÙ‡Ø§ÛŒ Ø§Ù…Ø±ÙˆØ²',
      );
      return null;
    } finally {
      _todayPaymentReportInFlight.remove(cacheKey);
    }
  }

  TodayWithdrawRequestReportLoadState todayWithdrawRequestReportStateFor(
    int accountId, {
    required String date,
  }) {
    return _todayWithdrawRequestReportCache[
                _todayReportCacheKey(accountId, date)]
            ?.state ??
        TodayWithdrawRequestReportLoadState.idle;
  }

  List<TodayWithdrawRequestReportModel>? todayWithdrawRequestReportFor(
    int accountId, {
    required String date,
  }) {
    return _todayWithdrawRequestReportCache[
            _todayReportCacheKey(accountId, date)]
        ?.data;
  }

  String? todayWithdrawRequestReportErrorFor(
    int accountId, {
    required String date,
  }) {
    return _todayWithdrawRequestReportCache[
            _todayReportCacheKey(accountId, date)]
        ?.errorMessage;
  }

  Future<List<TodayWithdrawRequestReportModel>?> loadTodayWithdrawRequestReport(
    int accountId, {
    required String date,
    bool forceRefresh = false,
  }) async {
    if (accountId <= 0) return null;

    final cacheKey = _todayReportCacheKey(accountId, date);

    if (!forceRefresh) {
      final cached = _todayWithdrawRequestReportCache[cacheKey];
      if (cached != null &&
          (cached.state == TodayWithdrawRequestReportLoadState.success ||
              cached.state == TodayWithdrawRequestReportLoadState.empty)) {
        return cached.data;
      }
      final inFlight = _todayWithdrawRequestReportInFlight[cacheKey];
      if (inFlight != null) return inFlight;
    } else {
      clearTodayWithdrawRequestReportCache(accountId, date);
    }

    final future = _fetchTodayWithdrawRequestReport(accountId, date);
    _todayWithdrawRequestReportInFlight[cacheKey] = future;
    return future;
  }

  Future<List<TodayWithdrawRequestReportModel>?> _fetchTodayWithdrawRequestReport(
    int accountId,
    String date,
  ) async {
    final cacheKey = _todayReportCacheKey(accountId, date);
    _todayWithdrawRequestReportCache[cacheKey] =
        _TodayWithdrawRequestReportCacheEntry(
      state: TodayWithdrawRequestReportLoadState.loading,
    );

    try {
      final reports = await withdrawRepository.getTodayWithdrawRequest(
        accountId: accountId,
        date: date,
      );

      if (reports.isEmpty) {
        _todayWithdrawRequestReportCache[cacheKey] =
            _TodayWithdrawRequestReportCacheEntry(
          state: TodayWithdrawRequestReportLoadState.empty,
        );
        return null;
      }

      _todayWithdrawRequestReportCache[cacheKey] =
          _TodayWithdrawRequestReportCacheEntry(
        state: TodayWithdrawRequestReportLoadState.success,
        data: reports,
      );
      return reports;
    } on ErrorException catch (e) {
      AppLogger.e(
        'loadTodayWithdrawRequestReport failed for account $accountId',
        e,
      );
      _todayWithdrawRequestReportCache[cacheKey] =
          _TodayWithdrawRequestReportCacheEntry(
        state: TodayWithdrawRequestReportLoadState.error,
        errorMessage: e.message,
      );
      return null;
    } catch (e, s) {
      AppLogger.e(
        'loadTodayWithdrawRequestReport failed for account $accountId',
        e,
        s,
      );
      _todayWithdrawRequestReportCache[cacheKey] =
          _TodayWithdrawRequestReportCacheEntry(
        state: TodayWithdrawRequestReportLoadState.error,
        errorMessage: 'Ø®Ø·Ø§ Ø¯Ø± Ø¯Ø±ÛŒØ§ÙØª Ø¯Ø±Ø®ÙˆØ§Ø³Øªâ€ŒÙ‡Ø§ÛŒ Ø¨Ø±Ø¯Ø§Ø´Øª Ø§Ù…Ø±ÙˆØ²',
      );
      return null;
    } finally {
      _todayWithdrawRequestReportInFlight.remove(cacheKey);
    }
  }

  TodayDepositRequestReportLoadState todayDepositRequestReportStateFor(
    int accountId, {
    required String date,
  }) {
    return _todayDepositRequestReportCache[
                _todayReportCacheKey(accountId, date)]
            ?.state ??
        TodayDepositRequestReportLoadState.idle;
  }

  List<TodayDepositRequestReportModel>? todayDepositRequestReportFor(
    int accountId, {
    required String date,
  }) {
    return _todayDepositRequestReportCache[
            _todayReportCacheKey(accountId, date)]
        ?.data;
  }

  String? todayDepositRequestReportErrorFor(
    int accountId, {
    required String date,
  }) {
    return _todayDepositRequestReportCache[
            _todayReportCacheKey(accountId, date)]
        ?.errorMessage;
  }

  Future<List<TodayDepositRequestReportModel>?> loadTodayDepositRequestReport(
    int accountId, {
    required String date,
    bool forceRefresh = false,
  }) async {
    if (accountId <= 0) return null;

    final cacheKey = _todayReportCacheKey(accountId, date);

    if (!forceRefresh) {
      final cached = _todayDepositRequestReportCache[cacheKey];
      if (cached != null &&
          (cached.state == TodayDepositRequestReportLoadState.success ||
              cached.state == TodayDepositRequestReportLoadState.empty)) {
        return cached.data;
      }
      final inFlight = _todayDepositRequestReportInFlight[cacheKey];
      if (inFlight != null) return inFlight;
    } else {
      clearTodayDepositRequestReportCache(accountId, date);
    }

    final future = _fetchTodayDepositRequestReport(accountId, date);
    _todayDepositRequestReportInFlight[cacheKey] = future;
    return future;
  }

  Future<List<TodayDepositRequestReportModel>?> _fetchTodayDepositRequestReport(
    int accountId,
    String date,
  ) async {
    final cacheKey = _todayReportCacheKey(accountId, date);
    _todayDepositRequestReportCache[cacheKey] =
        _TodayDepositRequestReportCacheEntry(
      state: TodayDepositRequestReportLoadState.loading,
    );

    try {
      final reports = await withdrawRepository.getTodayDepositRequest(
        accountId: accountId,
        date: date,
      );

      if (reports.isEmpty) {
        _todayDepositRequestReportCache[cacheKey] =
            _TodayDepositRequestReportCacheEntry(
          state: TodayDepositRequestReportLoadState.empty,
        );
        return null;
      }

      _todayDepositRequestReportCache[cacheKey] =
          _TodayDepositRequestReportCacheEntry(
        state: TodayDepositRequestReportLoadState.success,
        data: reports,
      );
      return reports;
    } on ErrorException catch (e) {
      AppLogger.e(
        'loadTodayDepositRequestReport failed for account $accountId',
        e,
      );
      _todayDepositRequestReportCache[cacheKey] =
          _TodayDepositRequestReportCacheEntry(
        state: TodayDepositRequestReportLoadState.error,
        errorMessage: e.message,
      );
      return null;
    } catch (e, s) {
      AppLogger.e(
        'loadTodayDepositRequestReport failed for account $accountId',
        e,
        s,
      );
      _todayDepositRequestReportCache[cacheKey] =
          _TodayDepositRequestReportCacheEntry(
        state: TodayDepositRequestReportLoadState.error,
        errorMessage: 'Ø®Ø·Ø§ Ø¯Ø± Ø¯Ø±ÛŒØ§ÙØª ØªØ¹Ù‡Ø¯Ø§Øª Ù¾Ø±Ø¯Ø§Ø®Øª Ø§Ù…Ø±ÙˆØ²',
      );
      return null;
    } finally {
      _todayDepositRequestReportInFlight.remove(cacheKey);
    }
  }
```
