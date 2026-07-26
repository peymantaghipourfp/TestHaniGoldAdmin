# Task 6 Report — Footer grid + thin view shell

## Status: Complete

**Branch:** `feat/user-balance-grouped-table`

## Files changed

| File | Action | Purpose |
| --- | --- | --- |
| `user_balance_footer.widget.dart` | Created | Responsive footer with `Wrap(spacing: 16, runSpacing: 12)` for credit/debit + net totals |
| `list_user_info_transaction.view.dart` | Rewritten | Thin shell with `PageState` switch, desktop body wiring, pager overlay |

## Implementation notes

### `UserBalanceFooter`

- Extracted footer UI from monolith L481–900 and helpers `_buildFooterItem` / `_buildNetFooterItem` (L2491–2633)
- Replaced horizontal `SingleChildScrollView` with `Wrap(spacing: 16, runSpacing: 12)` for both credit/debit and net sections
- Preserved detail dialogs for gold/coin breakdowns (list icon → `Get.defaultDialog`)
- Preserved monolith formatting (`seRagham` for ریال, 3-decimal for گرم, etc.)
- Observes `controller.listTransactionInfoFooter` via internal `Obx`

### Thin view shell

- `Scaffold` with `CustomAppbar1`, `AppDrawer`, `BackgroundImageTotal`, `ChatFloatingButton`
- `SafeArea` + `switch (controller.state.value)`:
  - `loading` → `UserBalanceLoadingState`
  - `empty` → `UserBalanceEmptyState(onRetry: _onRetry)`
  - `err` → `UserBalanceErrorState(onRetry: _onRetry)`
  - `list` → desktop `UserBalanceDesktopBody(footer: UserBalanceFooter(...))` or mobile column
- `_onRetry`: `clearSearch` + `getListTransactionInfoPager`
- Desktop pager overlay retained when `paginated != null`
- Mobile: `UserBalanceSearchBar` + `_buildMobileTransactionList` (deferred to Task 7)

### Removed from view

- `buildDataColumns` / `buildDataRows` (now in `UserBalanceDataTable`)
- Inline desktop table, toolbar, stats, footer builders
- Horizontal scroll wrapper around desktop content

### Line counts

| File | Lines |
| --- | ---: |
| View (shell + mobile temp) | 669 |
| Footer widget | 507 |
| View shell only (approx.) | ~120 |

Mobile helpers remain in view until Task 7 extraction; shell core meets the ~150–200 line target for non-mobile code.

## Verification

```
flutter analyze lib/src/domain/users/view/list_user_info_transaction.view.dart \
              lib/src/domain/users/widgets/list_user_info_transaction/user_balance_footer.widget.dart
→ No issues found!
```

| Check | Result |
| --- | --- |
| Footer uses `Wrap` not horizontal scroll | Pass |
| `PageState.empty` wired with retry | Pass |
| Desktop body + footer integrated | Pass |
| Pager overlay on desktop | Pass |
| `buildDataColumns`/`buildDataRows` removed from view | Pass |
| `graphify update .` | Pass |

## Concerns / follow-ups

1. **Mobile extraction (Task 7)** — `_buildMobileTransactionList`, sort header, and line helpers still in view (~550 lines).
2. **Euro debt chip** — monolith used `positiveValue` param for یورو بدهکار; preserved for parity.
3. **Manual smoke test** — desktop footer wrap layout and empty-state retry should be verified in app.

## Git

```
refactor(users): thin view shell and responsive footer grid
```
