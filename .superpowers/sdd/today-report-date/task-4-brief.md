### Task 4: Widgets and list call sites

**Files:**
- Modify: `lib/src/domain/withdraw/widget/hover_tooltip_today_payment_report.widget.dart`
- Modify: `lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart`
- Modify: `lib/src/domain/withdraw/widget/hover_tooltip_withdraw_request_report.widget.dart` (if still used with loaders)
- Modify: `lib/src/domain/withdraw/widget/hover_tooltip_deposit_request_report.widget.dart` (same)
- Modify: `lib/src/domain/withdraw/view/withdraws_list.view.dart` (~6152, ~7323)
- Modify: `test/today_payment_report_tooltip_test.dart`

**Interfaces:**
- Consumes: `formatRequestDateForApi(withdraw.requestDate)` and controller `date:` named arg
- Produces: tooltips expose `final String date` (already formatted) and pass it on every `loadToday*` / `clearToday*` call

- [ ] **Step 1: Add `date` to tooltip widgets**

On `HoverTooltipTodayPaymentReportWidget` and nested content:

```dart
final String date; // YYYY-MM-DD from requestDate
```

Pass into:

```dart
widget.withdrawController.loadTodayPaymentReport(
  widget.accountId,
  date: widget.date,
  forceRefresh: forceRefresh,
);
```

Update nested expand/reload/clear in `TodayPaymentReportTooltipContent` the same way for withdraw/deposit loaders.

- [ ] **Step 2: Wire list rows**

At both `HoverTooltipTodayPaymentReportWidget(` sites in `withdraws_list.view.dart`, pass:

```dart
date: formatRequestDateForApi(withdraw.requestDate),
```

(For the deposit-request nested row ~7323, use the parent `withdraw.requestDate` already in scope.)

- [ ] **Step 3: Fix tests**

Update `_ExpandingWithdrawController.loadTodayWithdrawRequestReport` and any widget constructions in `test/today_payment_report_tooltip_test.dart` to include `required String date` / pass a literal like `'2026-07-08'`.

- [ ] **Step 4: Validate**

```bash
flutter test test/request_date_api_util_test.dart test/today_payment_report_tooltip_test.dart
dart analyze lib/src/config/repository/withdraw.repository.dart lib/src/domain/withdraw/controller/withdraw.controller.dart lib/src/domain/withdraw/widget lib/src/domain/withdraw/view/withdraws_list.view.dart
```

Expected: tests PASS; analyze clean for touched paths.

- [ ] **Step 5: Graphify + commit**

```bash
graphify update .
git add lib/src/domain/withdraw/util/request_date_api.util.dart lib/src/config/repository/withdraw.repository.dart lib/src/domain/withdraw/controller/withdraw.controller.dart lib/src/domain/withdraw/widget lib/src/domain/withdraw/view/withdraws_list.view.dart test/
git commit -m "feat(withdraw): send requestDate as date on today report API calls"
```

---

## Self-review

- Spec coverage: `String date` on three repo methods; value from `requestDate`; format `YYYY-MM-DD`; callers updated so project compiles; tests for format + tooltip signatures.
- No placeholders / TBDs.
- Query key locked to `date` (assumption stated above). If backend expects `requestDate` instead, only the repository `option` map key changes.
