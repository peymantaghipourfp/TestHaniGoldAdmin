# Task 4 Report: Per-asset cell widgets (installment-safe)

## Status: Complete

**Branch:** `feat/user-balance-grouped-table`

## Files created

| File | Class | API |
|------|-------|-----|
| `user_balance_rial_cell.widget.dart` | `UserBalanceRialCell` | `creditSection`, `debitSection` — cash bes/bed + `afterCashBalance` installment rows (`unitName=="ریال"`) + list.svg dialogs |
| `user_balance_gold_cell.widget.dart` | `UserBalanceGoldCell` | `creditSection`, `debitSection` — gold bes/bed + `afterGoldBalance` installment rows (`unitName=="گرم"`) + list.svg dialogs |
| `user_balance_coin_cell.widget.dart` | `UserBalanceCoinCell` | `creditSection`, `debitSection` — full/half/quarter coin bes/bed |
| `user_balance_currency_cell.widget.dart` | `UserBalanceCurrencyCell` | `creditSection`, `debitSection` — per-currency rows from `balances` (دلار filter, monolith parity) |
| `user_balance_total_cell.widget.dart` | `UserBalanceTotalCell` | `creditSection`, `debitSection` — `currencyValueBes/Bed` + scales.svg + gold/coin equivalents |
| `user_balance_grouped_header.widget.dart` | `UserBalanceGroupedHeader` | Asset label + two `UserBalancePolarityChip` wired to `controller.onSort` |

## Sort indices (unchanged)

| Asset | Credit | Debit |
|-------|--------|-------|
| ریال | 2 | 3 |
| طلا | 4 | 5 |
| سکه | 6 | 7 |
| ارز | 8 | 9 (display only — `sortEnabled: false`) |
| تراز | 10 | 11 |

## Analyzer (`flutter analyze`)

```
Analyzing 6 items...
No issues found! (ran in 1.4s)
```

## Concerns / follow-ups

- **Not wired yet** — cells are extracted but monolith `buildDataRows` unchanged; Task 5 composes them in 7-column `UserBalanceDataTable`.
- **Currency filter** — monolith only renders `unitName == "دلار"`; یورو and future units need a separate enhancement if API starts returning them.
- **Currency header colors** — `swapPolarityColors: true` preserves monolith's swapped بستانکار/بدهکار accent/primary on ارز headers.
- **Coin zero checks** — `coinBalanceBes == 0` / `coinBalanceBed == 0` use exact equality (monolith parity); half/quarter may still show when full coin is zero.

## Verification checklist

- [x] Rial cell: `cashBalanceBes/Bed`, `afterCashBalance`, installment `balances` rows, list.svg dialogs
- [x] Gold cell: `goldBalanceBes/Bed`, `afterGoldBalance`, installment breakdown, list.svg dialogs
- [x] Coin cell: full/half/quarter bes/bed
- [x] Currency cell: `balances` iteration (دلار positive/negative)
- [x] Total cell: scales SVG, `currencyValueBes/Bed`, gold/coin equivalents
- [x] Grouped header: polarity chips + `onSort` with active highlight
- [x] `flutter analyze` — 0 issues on new files
- [ ] Integration smoke — deferred to Task 5
