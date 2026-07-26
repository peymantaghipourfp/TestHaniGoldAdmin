### Task 4: Per-asset cell widgets (installment-safe)

**Files:** `user_balance_rial_cell.widget.dart`, `user_balance_gold_cell.widget.dart`, `user_balance_coin_cell.widget.dart`, `user_balance_currency_cell.widget.dart`, `user_balance_total_cell.widget.dart`, `user_balance_grouped_header.widget.dart`

**Critical — installment preservation:**
- Rial cell: keep main `cashBalanceBes`/`cashBalanceBed` rows; when `afterCashBalance != 0`, show `Divider` + per-item rows from `balances.where(unitName=="ریال")` (positive and negative polarity coloring) — copy from L1144–1410
- Gold cell: same pattern with `afterGoldBalance` + `unitName=="گرم"` — copy from L1493–1820
- Coin cell: `coinBalanceBes/Bed`, `halfCoin*`, `quarterCoin*` — copy from L1821–2098
- Currency cell: iterate `balances` for each currency (`دلار`, `یورو`, any future unit) — copy from L2099–2185
- Total cell: `currencyValueBes/Bed` + scales SVG — copy from L2186–2490
- Each cell exposes **two sub-widgets** (`creditSection`, `debitSection`) composed vertically in the grouped `DataCell`

- [ ] **Step 1:** Extract rial + gold cells first (installment paths); verify dialog taps preserved
- [ ] **Step 2:** Extract coin, currency, total cells
- [ ] **Step 3:** `UserBalanceGroupedHeader` — asset label + two polarity chips wired to `onSort`
- [ ] **Step 4:** Commit `feat(users): extract grouped balance cells with installment breakdown`

**Global Constraints:**
- Copy cell logic verbatim from monolith — do not change behavior
- Preserve detail dialogs (list.svg tap), polarity colors AppColor.primaryColor/accentColor
- UserBalanceGroupedHeader uses UserBalancePolarityChip + controller.onSort(index, ascending) — sort indices 2-11 unchanged
- Do NOT wire into data table yet (Task 5)
