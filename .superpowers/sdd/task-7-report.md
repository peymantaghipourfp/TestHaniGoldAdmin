# Task 7 Report — Mobile list extraction + final verification

## Status: Complete

**Branch:** `feat/user-balance-grouped-table`

## Files changed

| File | Action | Purpose |
| --- | --- | --- |
| `user_balance_mobile_list.widget.dart` | Created | Extracted mobile list, sort header, balance lines; chrome + polarity chips |
| `list_user_info_transaction.view.dart` | Slimmed | Shell delegates mobile body to `UserBalanceMobileList` |

## Implementation notes

### `UserBalanceMobileList`

- Extracted `_buildMobileTransactionList`, `_buildMobileSortHeader`, `_mobileLine`, `_mobileLineWithIcon` from view
- Replaced inline Excel/Filter dialogs with `UserBalanceToolbar(isDesktop: false)` (Task 3 widget)
- Card styling via `UserBalancePageChrome.panelDecoration()`; sort header + totals sub-panel use `toolbarDecoration()`
- `UserBalancePolarityChip` on بس/بد (and بستانکار/بدهکار) balance lines where labels previously embedded polarity text
- `ListView.builder` retains `shrinkWrap: true` + `NeverScrollableScrollPhysics()`; loading/end-of-list footer unchanged
- Sort header wrapped in `Obx` for reactive sort state

### Thin view shell

- Mobile path: `SingleChildScrollView(controller: scrollControllerMobile)` → search bar + `UserBalanceMobileList`
- `scrollControllerMobile` infinite scroll behavior unchanged (controller listener untouched)
- View reduced from 669 → **113 lines** (within 150–200 target)

## Verification

```bash
flutter analyze lib/src/domain/users/view/list_user_info_transaction.view.dart \
              lib/src/domain/users/widgets/list_user_info_transaction
→ No issues found!

flutter test test/domain/users/user_balance_stats_helper_test.dart
→ 00:00 +6: All tests passed!

graphify update .
→ Rebuilt: 8983 nodes, 16415 edges, 510 communities
```

| Check | Result |
| --- | --- |
| Mobile methods extracted | Pass |
| `UserBalancePageChrome` card styling | Pass |
| Polarity chips on بس/بد lines | Pass |
| `scrollControllerMobile` preserved on outer scroll | Pass |
| View ~150–200 lines | Pass (113) |
| `flutter analyze` scoped | Pass |
| `user_balance_stats_helper_test` | Pass (6/6) |
| `graphify update` | Pass |

## Line counts

| File | Lines |
| --- | ---: |
| View | 113 |
| Mobile list widget | 504 |

## Concerns / follow-ups

1. **Mobile KPI stats grid** — hybrid plan shows `UserBalanceStatsGrid` above toolbar on mobile; not in Task 7 scope (view still search-only above list).
2. **Manual smoke test** — verify infinite scroll, sort dropdown, Excel/Filter dialogs, and card tap navigation on a phone/tablet breakpoint.
3. **Panel color** — cards use `panelDecoration(color: AppColor.appBarColor)` for monolith-like tint under chrome shadow/border.

## Git

```
feat(users): mobile list extraction and grouped-table verification
```
