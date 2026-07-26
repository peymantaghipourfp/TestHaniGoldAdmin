### Task 2: Repository `date` query parameter

**Files:**
- Modify: `lib/src/config/repository/withdraw.repository.dart` (methods ~574–638)

**Interfaces:**
- Consumes: none from Task 1 (repo accepts already-formatted `String date`)
- Produces:
  - `Future<TodayPaymentReportModel> getTodayPaymentReport({required int accountId, required String date})`
  - `Future<List<TodayWithdrawRequestReportModel>> getTodayWithdrawRequest({required int accountId, required String date})`
  - `Future<List<TodayDepositRequestReportModel>> getTodayDepositRequest({required int accountId, required String date})`

- [ ] **Step 1: Update all three methods**

Change each `option` map from `{'accountId': accountId}` to:

```dart
final Map<String, dynamic> option = {
  'accountId': accountId,
  'date': date,
};
```

and add `required String date` to each method signature.

- [ ] **Step 2: Validate**

Run: `dart analyze lib/src/config/repository/withdraw.repository.dart`
Expected: clean for this file; call sites will error until Task 3–4 (acceptable mid-plan).

- [ ] **Step 3: Commit**

```bash
git add lib/src/config/repository/withdraw.repository.dart
git commit -m "feat(withdraw): pass date query param on today report endpoints"
```

---

