# Task 1 Report: Chrome, polarity chip, KPI helper + tests

**Status:** DONE  
**Date:** 2026-07-26  
**Branch:** `feat/user-balance-grouped-table`  
**Commit:** `68d3104` — `feat(users): add user-balance chrome, polarity chip, KPI helper`

## Summary

Created foundational shared tokens, a polarity chip widget, and a pure KPI aggregation helper for the user-balance transaction list refactor. No controllers, views, repositories, or `*.g.dart` files were modified.

## TDD Evidence

### RED (tests first, implementation missing)

```
flutter test test/domain/users/user_balance_stats_helper_test.dart
```

Result: **FAIL** — compilation error: `user_balance_stats_helper.dart` not found; `buildUserBalanceKpis` undefined (6 test cases could not load).

### GREEN (after implementation)

```
flutter test test/domain/users/user_balance_stats_helper_test.dart
```

Result: **PASS** — `00:00 +6: All tests passed!`

## Files Created

| File | Purpose |
| --- | --- |
| `lib/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart` | Shared `panelDecoration`, `toolbarDecoration`, `radiusLg=16`, `radiusMd=12`, `slateBorder` |
| `lib/src/domain/users/widgets/list_user_info_transaction/user_balance_polarity_chip.widget.dart` | Credit/debit chip (`AppColor.primaryColor` / `AppColor.accentColor`), optional `isActive` + `onTap` with 44×44 min touch target |
| `lib/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_helper.dart` | `UserBalanceKpiSnapshot` + `buildUserBalanceKpis()` |
| `test/domain/users/user_balance_stats_helper_test.dart` | Unit tests for KPI aggregation |

## Implementation Notes

### `UserBalancePageChrome`

- `panelDecoration`: `backGroundColor1.withAlpha(150)`, `radiusLg`, `slateBorder.withAlpha(120)` border, soft shadow.
- `toolbarDecoration`: `appBarColor.withAlpha(30)`, `radiusMd`, matching border.
- Only hard-coded color: `slateBorder = Color(0xFF64748B)` per spec.

### `UserBalancePolarityChip`

- ChatStatusChip-style container: tinted fill + border + `AppTextStyle.bodyText` at 10px.
- `isCredit` → `AppColor.primaryColor`; debit → `AppColor.accentColor`.
- `isActive` strengthens fill/border alpha.
- When `onTap` is set, wraps chip in `InkWell` inside `ConstrainedBox(minWidth: 44, minHeight: 44)`.

### `buildUserBalanceKpis`

Mirrors existing footer fold logic in `list_user_info_transaction.view.dart` (L805+):

```dart
footer.where((item) => item.unitName == unit).fold(
  0.0,
  (sum, item) => sum + (item.totalPositiveBalance ?? 0) + (item.totalNegativeBalance ?? 0),
);
```

- `netRial` → `unitName == "ریال"`
- `netGoldGrams` → `unitName == "گرم"`
- `netCoinCount` → `unitName == "عدد"` (aggregate sum across all coin rows)
- `totalUsers` → passthrough `totalCount` (nullable)

## Test Coverage

| Test | Assertion |
| --- | --- |
| Empty footer | All nets 0; `totalUsers` = `totalCount` |
| Null `totalCount` | `totalUsers` is null |
| Rial rows | Sums positive + negative per ریال item |
| Gold rows | Sums per گرم item |
| Coin rows | Sums per عدد item |
| Null balances | Treated as 0 |

## Analyzer

```
flutter analyze lib/src/domain/users/widgets/list_user_info_transaction/
No issues found!
```

## Self-Review

| Criterion | Result |
| --- | --- |
| TDD: RED then GREEN | ✅ |
| Chrome tokens match spec | ✅ |
| Polarity chip API (`label`, `isCredit`, `isActive`, `onTap`) | ✅ |
| KPI helper matches footer fold math | ✅ |
| Package imports | ✅ |
| No API / `*.g.dart` changes | ✅ |
| `flutter test` passes | ✅ (6/6) |
| `flutter analyze` clean | ✅ |
| Commit with requested message | ✅ |
| `graphify update .` run | ✅ (not committed — large generated diff) |

## Concerns

- **No widget tests** for `UserBalancePolarityChip` or `UserBalancePageChrome` (task scope was helper unit tests only; downstream tasks will exercise widgets in context).
- **`netCoinCount` is an aggregate** across all `عدد` footer rows; the monolith footer shows per-coin breakdowns separately — acceptable for KPI snapshot card use in Task 2+.
