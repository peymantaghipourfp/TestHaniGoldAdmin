# Task 2 Report — Fit-width DataTable with meta merge + بدهکار/بستانکار grouping

**Status:** DONE_WITH_CONCERNS  
**Branch:** `feat/gold-tx-fit-table`  
**Commit:** `5a23e90` — `feat(users): grouped debit/credit gold ledger table without horizontal scroll`

## What was implemented

### Created (under `lib/src/domain/users/widgets/user_info_gold_transaction/`)

| File | Responsibility |
| --- | --- |
| `gold_transaction_grouped_header.widget.dart` | Asset label + display-only `UserBalancePolarityChip` (بستانکار / بدهکار); chips stacked vertically for narrow columns; `onTap: null` |
| `gold_transaction_data_table.widget.dart` | 14-col `Obx` → `LayoutBuilder` → `DataTable`; `_assetCell` credit-above-debit; width budgets; sort on تاریخ/ساعت (visual index 2) |
| `gold_transaction_datetime_cell.widget.dart` | Merged date above + time below |
| `gold_transaction_invoice_cell.widget.dart` | Compact icon buttons + tooltips (با مانده / بدون مانده) |
| `gold_transaction_description_cell.widget.dart` | Ported type-branched شرح; `maxLines: 1` on `SelectableText` (SDK has no `softWrap`); width-constrained + `ClipRect` |
| `gold_transaction_qty_cell.widget.dart` | وزن یا تعداد amount formatting |
| `gold_transaction_gold_cell.widget.dart` | credit / debit / balance (`itemUnit.id == 2`, `goldTotalRunning`) |
| `gold_transaction_coin_cell.widget.dart` | تمام‌سکه (`item.id == 2`, `coinTotalRunning`) |
| `gold_transaction_half_quarter_cell.widget.dart` | نیم/ربع vertical stacks (`item.id` 3/4); separate balance section |
| `gold_transaction_rial_cell.widget.dart` | ریال (`item.id == 6`, sell/buy `totalPrice`, `cashTotalRunning`) |

### Modified

| File | Change |
| --- | --- |
| `gold_transaction_desktop_body.widget.dart` | Replaced table placeholder with `GoldTransactionDataTable` |
| `user_info_gold_transaction.view.dart` | Desktop uses `GoldTransactionDesktopBody`; removed dead `buildDataColumns` / `buildDataRows` (~1462 lines) |
| `test/gold_transaction_data_table_layout_test.dart` | Asserts 14 cols, 4 grouped + 4 مانده headers, no «طلا بدهکار»/«طلا بستانکار», no H-scroll, description no `softWrap: true` |

### Column model (14) — visual order

`ردیف | فاکتور | تاریخ/ساعت | عملیات | شرح | وزن یا تعداد | طلا | مانده طلایی | تمام‌سکه | مانده تمام‌سکه | نیم‌ربع | مانده نیم‌ربع | ریال | مانده ریالی`

## TDD evidence

### RED (expanded assertions before full green)

After scaffolding table but before Obx/`LayoutBuilder` fix and header width fix, tests failed with:

1. GetX improper use of Obx (observables only read inside deferred `LayoutBuilder`)
2. `RenderFlex` overflow (~92px) on grouped header chip `Row` at ~80px column width

### GREEN

```
flutter test test/gold_transaction_data_table_layout_test.dart
→ 00:00 +3: All tests passed!
```

Assertions covered: no horizontal `SingleChildScrollView`; 14 columns; 4 `GoldTransactionGroupedHeader`; 4 مانده labels; no separate طلا بدهکار/بستانکار titles; merged تاریخ/ساعت; description source has no `softWrap: true` and uses `maxLines: 1`; شرح header `softWrap: false`.

## Verification

| Command | Result |
| --- | --- |
| `flutter test test/gold_transaction_data_table_layout_test.dart` | **PASS** (+3) |
| `flutter analyze` on `user_info_gold_transaction/` widgets + layout test | **7 info** only (`unnecessary_string_interpolations` ported from description); **no errors/warnings** |
| `flutter analyze` on view | Pre-existing infos + 1 unused import warning (unchanged legacy); **no errors** from this task |

Graphify **not** run (Task 4 owns it).

## Self-review

| Check | Result |
| --- | --- |
| No desktop `Axis.horizontal` around table | Pass |
| 14 columns; مانده not merged into debit/credit | Pass |
| Sort only on تاریخ/ساعت (index 2) | Pass |
| Polarity chips display-only | Pass (`onTap: null`) |
| Business rules ported (amount sign, unit/id, نیم/ربع 3/4, running totals, sell/buy rial) | Pass |
| `AppColor` / `AppTextStyle` / package imports | Pass |
| Mobile list not extracted (Task 3) | Pass |
| `headingRowHeight` 72 | Pass (within 64–72) |

## Concerns / carry-forward

1. **SelectableText softWrap:** Flutter 3.44 `SelectableText` has no `softWrap` parameter. Cells use `maxLines: 1` instead; `Text` headers use `softWrap: false`. Meets “no wrap” intent.
2. **Grouped header chips vertical:** Side-by-side chips overflowed at fit-width budgets; stacked vertically under the label (still بستانکار above بدهکار, matching `_assetCell`). Slight UX variance vs list-balance horizontal chip row.
3. **Description cell size:** Large port (~780 lines) retains original type branches and a large commented block; `unnecessary_string_interpolations` infos left as port fidelity.
4. **Width budgets:** Tuned for ≥1280; very narrow desktops (~1100) may still clip dense description Rows despite `ClipRect`/`maxLines` — worth a visual pass.
5. **Controller `scrollController`:** Desktop H-scroll removed; desktop `scrollController` on controller is now unused (mobile still uses `scrollControllerMobile`). Cleanup optional.
6. **Date sort behavior:** Unchanged from monolith — `onSortColum` only sorts when `columnIndex == 0`; UI sort indicator still wires through `setSort` on تاریخ/ساعت.

## Files changed (this commit scope)

**Created:** 10 cell/table/header widgets listed above  
**Modified:** desktop body, gold transaction view, layout test, this report  
**Not committed:** graphify-out cache, unrelated `.superpowers/sdd` brief/progress churn

---

# Task 2 Fix Report — Review findings (overflow / width budgets / date sort)

**Status:** DONE_WITH_CONCERNS  
**Branch:** `feat/gold-tx-fit-table`

## Findings addressed

1. **شرح overflow handling** — Added `_fitRow` helper that wraps non-`SizedBox` Row children in `Flexible(fit: FlexFit.loose)`. Live description Rows converted to `_fitRow`; `ClipRect` + `maxLines: 1` retained. Structured Rows preserved.
2. **Width budgets on cell bodies** — `_budget(maxWidth, child)` (`ConstrainedBox` + `ClipRect`) applied to all non-description cells (ردیف / فاکتور / تاریخ / عملیات / وزن / asset / مانده). Invoice icons slightly compacted + `FittedBox`. Qty/datetime/numeric cells no longer expand intrinsically past budgets.
3. **Date sort wiring** — `UserInfoDetailGoldTransactionController.onSortColum` now sorts by `date` when `columnIndex == dateSortColumnIndex` (2), matching `GoldTransactionDataTable.dateSortVisualIndex`. Removed legacy account-name sort on index 0 and stale `sortIndex == 3` remapping.

## Verification

```
flutter test test/gold_transaction_data_table_layout_test.dart
→ 00:01 +5: All tests passed!
```

New/strengthened coverage:
- Dense sell description at `maxWidth: 160` (~1280 desc budget) — no exception / no RenderFlex overflow / no H-scroll
- `onSortColum(2, …)` sorts ascending/descending by date; controller index matches table constant

```
flutter analyze lib/src/domain/users/widgets/user_info_gold_transaction/ \
  test/gold_transaction_data_table_layout_test.dart \
  lib/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart
→ No errors; pre-existing infos/warnings only (string interpolations in description port; controller null/print infos)
```

## Concerns

1. **SelectableText has no `overflow` parameter** in this Flutter SDK (same family as missing `softWrap`). Ellipsis dots cannot be set on `SelectableText`; overflow is prevented via `Flexible` + width constraints + `ClipRect` (hard clip, not `…`). Header/`Text` ops labels still use `TextOverflow.ellipsis`.
2. Visual pass at ~1100px still recommended; budgets unchanged numerically, only enforced on cell bodies.

## Files touched (fix commit)

- `gold_transaction_description_cell.widget.dart` — `_fitRow` / Flexible
- `gold_transaction_data_table.widget.dart` — `_budget` on cells; compact row checkbox Row
- `gold_transaction_invoice_cell.widget.dart`, `qty` / `datetime` / gold/coin/half_quarter/rial cells — fit/ellipsis where applicable
- `user_info_detail_gold_transaction.controller.dart` — date sort on index 2
- `test/gold_transaction_data_table_layout_test.dart` — dense desc + sort tests
- this report
