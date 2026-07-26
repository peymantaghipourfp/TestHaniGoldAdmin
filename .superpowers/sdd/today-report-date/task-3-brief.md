### Task 3: Controller loaders + composite cache keys

**Files:**
- Modify: `lib/src/domain/withdraw/controller/withdraw.controller.dart`

**Interfaces:**
- Consumes: `formatRequestDateForApi` (callers may format; controller accepts `String date`)
- Produces updated signatures:
  - `loadTodayPaymentReport(int accountId, {required String date, bool forceRefresh = false})`
  - `loadTodayWithdrawRequestReport(int accountId, {required String date, bool forceRefresh = false})`
  - `loadTodayDepositRequestReport(int accountId, {required String date, bool forceRefresh = false})`
  - state/data/error/clear helpers take the same `date` (or a shared private `_todayReportCacheKey(accountId, date)` → `'$accountId|$date'`)
  - `_fetch*` methods pass `date:` into repository

- [ ] **Step 1: Add private cache key helper**

```dart
String _todayReportCacheKey(int accountId, String date) => '$accountId|$date';
```

Replace all `_today*Cache[accountId]` / `_today*InFlight[accountId]` usages in the today-report block with `_todayReportCacheKey(accountId, date)`. Update `clearToday*Cache` overloads to accept optional `date` and remove by composite key when both provided.

- [ ] **Step 2: Thread `date` into load + fetch + repository calls**

Example fetch call:

```dart
final report = await withdrawRepository.getTodayPaymentReport(
  accountId: accountId,
  date: date,
);
```

Same for withdraw-request and deposit-request fetchers.

- [ ] **Step 3: Validate**

Run: `dart analyze lib/src/domain/withdraw/controller/withdraw.controller.dart`
Expected: analyzer reports missing `date:` only at widget/test call sites (Task 4).

- [ ] **Step 4: Commit**

```bash
git add lib/src/domain/withdraw/controller/withdraw.controller.dart
git commit -m "feat(withdraw): thread report date through today-report loaders"
```

---

