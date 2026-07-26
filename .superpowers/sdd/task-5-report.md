# Task 5 Report — 7-column grouped DataTable + desktop body

## Status: Complete

**Branch:** `feat/user-balance-grouped-table`

## Files created

| File | Widget | Purpose |
| --- | --- | --- |
| `user_balance_data_table.widget.dart` | `UserBalanceDataTable` | 7-column grouped `DataTable` composing Task 4 cell widgets |
| `user_balance_desktop_body.widget.dart` | `UserBalanceDesktopBody` | Desktop vertical stack: StatsGrid → Toolbar → DataTable → optional footer |

## Implementation notes

### `UserBalanceDataTable`

- **7 columns:** ردیف, نام, مانده ریالی, مانده طلا, مانده سکه, مانده ارز, تراز کل
- **Row/name cells** copied from monolith L1123–1143 (`rowNum` text + underlined `accountName` link to `/userInfoTransaction`)
- **Asset columns (2–6):** `UserBalanceGroupedHeader` with sort indices 2–11 (ارز: `sortEnabled: false`, `swapPolarityColors: true`)
- **Asset cells:** `Column(crossAxisAlignment: center, children: [creditSection, SizedBox(4), debitSection])` via per-asset cell widgets
- **Table chrome:** zebra rows, `dataRowMaxHeight: double.infinity`, monolith border/divider/heading colors
- **Sort wiring:** `sortColumnIndex` / `sortAscending` from controller; controller indices 2–11 mapped to visual columns 2–6 via `_visualSortColumnIndex`

### `UserBalanceDesktopBody`

- Panel uses `UserBalancePageChrome.panelDecoration()`
- Vertical `Column`: `UserBalanceStatsGrid` → `UserBalanceToolbar(isDesktop: true)` → `UserBalanceDataTable`
- **No** horizontal `SingleChildScrollView` around the table
- Optional `Widget? footer` slot for Task 6 (`UserBalanceFooter`)

### Not wired

- `list_user_info_transaction.view.dart` unchanged (Task 6 scope)

## Verification

```
flutter analyze lib/src/domain/users/widgets/list_user_info_transaction/user_balance_data_table.widget.dart \
              lib/src/domain/users/widgets/list_user_info_transaction/user_balance_desktop_body.widget.dart
→ No issues found!
```

| Check | Result |
| --- | --- |
| `DataColumn(` count == 7 | Pass |
| No horizontal scroll in desktop body | Pass |
| Sort indices 2–11 via grouped headers | Pass |
| Cell widgets composed (rial/gold/coin/currency/total) | Pass |
| `dataRowMaxHeight: double.infinity` | Pass |
| View monolith untouched | Pass |

## Concerns / follow-ups

1. **Integration smoke deferred** — widgets exist but are not mounted in the view until Task 6 shell wiring.
2. **Tall rows** — stacked بس/بد cells increase row height; acceptable trade-off per plan.
3. **Footer slot** — `UserBalanceDesktopBody.footer` ready for Task 6 `UserBalanceFooter`.
4. **Currency sort** — ارز chips are display-only (`sortEnabled: false`); matches controller (no case 8/9 in `onSort`).
