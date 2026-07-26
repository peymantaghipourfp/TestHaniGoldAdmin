### Task 1: Chrome, polarity chip, KPI helper + tests

**Files:**
- Create: `user_balance_page_chrome.dart`, `user_balance_polarity_chip.widget.dart`, `user_balance_stats_helper.dart`
- Test: `test/domain/users/user_balance_stats_helper_test.dart`

**Interfaces:**
- Produces: `UserBalancePageChrome.panelDecoration`, `toolbarDecoration`, `radiusLg=16`, `radiusMd=12`, `slateBorder=Color(0xFF64748B)`
- Produces: `UserBalancePolarityChip({required String label, required bool isCredit, bool isActive, VoidCallback? onTap})`
- Produces:

```dart
class UserBalanceKpiSnapshot {
  const UserBalanceKpiSnapshot({
    required this.totalUsers,
    required this.netRial,
    required this.netGoldGrams,
    required this.netCoinCount,
  });
  final int? totalUsers;
  final double netRial;
  final double netGoldGrams;
  final double netCoinCount;
}

UserBalanceKpiSnapshot buildUserBalanceKpis({
  required int? totalCount,
  required List<TransactionInfoFooterModel> footer,
});
```

- [ ] **Step 1:** Write failing tests — empty footer; rial/gold/coin net sums; null `totalCount`
- [ ] **Step 2:** Run `flutter test test/domain/users/user_balance_stats_helper_test.dart` — expect FAIL
- [ ] **Step 3:** Implement chrome, chip (`AppColor.primaryColor`/`accentColor`), helper (`sum(totalPositiveBalance + totalNegativeBalance)` per `unitName`)
- [ ] **Step 4:** Run tests — expect PASS
- [ ] **Step 5:** Commit `feat(users): add user-balance chrome, polarity chip, KPI helper`

**Global Constraints (binding):**
- Do not change API contracts, repository methods, or `*.g.dart` files
- Use `AppColor` and `AppTextStyle` — no hard-coded colors except `slateBorder=Color(0xFF64748B)` as specified
- Polarity colors: `AppColor.primaryColor` (بستانکار/credit) / `AppColor.accentColor` (بدهکار/debit)
- Widget files go under `lib/src/domain/users/widgets/list_user_info_transaction/`
- `TransactionInfoFooterModel` is at `lib/src/domain/users/model/transaction_info_footer.model.dart`
- Helper aggregation: `sum(totalPositiveBalance + totalNegativeBalance)` per `unitName` for rial (ریال), gold (گرم), coin (سکه or itemGroupName patterns as in existing view)
- Touch targets on sort chips: min 44×44 via padding
