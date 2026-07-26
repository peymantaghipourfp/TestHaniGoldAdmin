# Task 2 Report — Stats grid + page state widgets

**Status:** Complete  
**Commit:** `2c5574c` — `feat(users): add KPI grid and page states`  
**Branch:** `feat/user-balance-grouped-table`

## Deliverables

| File | Widget | Purpose |
| --- | --- | --- |
| `user_balance_stats_grid.widget.dart` | `UserBalanceStatsGrid` | Obx KPI row via `buildUserBalanceKpis`; responsive 1/2/4-col `Wrap` |
| `user_balance_loading_state.widget.dart` | `UserBalanceLoadingState` | Centered `HaniGoldLoading.large()` |
| `user_balance_empty_state.widget.dart` | `UserBalanceEmptyState` | Dedicated empty copy + `onRetry` callback |
| `user_balance_error_state.widget.dart` | `UserBalanceErrorState` | `ErrPage` wrapper with `onRetry` |

## Implementation notes

- **Stats grid:** Reads `controller.paginated` + `controller.listTransactionInfoFooter` inside `Obx`. Four KPI labels per brief: `تعداد کل کاربران`, `مجموع مانده ریالی`, `مجموع طلا (گرم)`, `تعداد سکه`. Cards use `UserBalancePageChrome.panelDecoration`. `LayoutBuilder` computes column count (1 / 2 / 4) and explicit card widths to avoid unbounded `Wrap` width issues.
- **Formatting:** Rial and counts use `seRagham()`; gold uses 3 decimals (matches monolith footer). Balance KPIs color-coded via `AppColor.primaryColor` / `accentColor`.
- **Empty state:** Persian copy (`مانده‌ای یافت نشد` / filter hint) inside chrome panel; retry via `onRetry` (Task 6 will wire `clearSearch` + `getListTransactionInfoPager`).
- **Error state:** Matches existing view `ErrPage` strings (`خطا در لیست کاربران`).
- **Not wired:** Main view unchanged per Task 6 scope.

## Verification

```
flutter analyze lib/src/domain/users/widgets/list_user_info_transaction/user_balance_*.dart
→ No issues found! (4 files)
```

## Self-review

| Check | Result |
| --- | --- |
| Uses `AppColor` / `AppTextStyle` | Pass |
| Uses `UserBalancePageChrome` | Pass (stats + empty) |
| Uses `buildUserBalanceKpis` | Pass |
| Obx on paginated + footer | Pass |
| Loading = `HaniGoldLoading.large()` | Pass |
| Error = `ErrPage` wrapper | Pass |
| Empty has dedicated copy + retry hook | Pass |
| No view wiring | Pass |
| No API / model changes | Pass |

## Concerns / carry-forward

1. **Wrap constraints:** `LayoutBuilder` mitigates unbounded-width risk; parent must still provide horizontal constraints (Task 6 padding handles this on mobile).
2. **Retry wiring:** Empty/error widgets expose `onRetry`; view should call `clearSearch()` then `getListTransactionInfoPager()` (same as current `ErrPage` fallback).
3. **Zero balances:** KPI cards show `0` even when monolith footer hides zero net rows — intentional for summary cards; confirm with UX if hiding preferred.
4. **No widget tests:** Task scope was widget files only; helper already covered in Task 1 tests.
