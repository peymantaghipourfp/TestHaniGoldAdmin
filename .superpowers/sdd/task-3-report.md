# Task 3 Report — Toolbar, search, excel dialog

**Status:** Complete  
**Commit:** `f287309` — `feat(users): extract user-balance toolbar`  
**Branch:** `feat/user-balance-grouped-table`

## Deliverables

| File | Widget / API | Purpose |
| --- | --- | --- |
| `user_balance_search_bar.widget.dart` | `UserBalanceSearchBar` | Reusable search field with chrome borders; optional `maxWidth` + `compact` for mobile |
| `user_balance_excel_dialog.widget.dart` | `showUserBalanceExcelDialog` | Shared Excel export dialog (name filter + `getListUserInfoTransactionExcel`) |
| `user_balance_toolbar.widget.dart` | `UserBalanceToolbar` | Desktop row (search 400px + Excel + Filter in chrome); mobile icon actions |

## Implementation notes

- **Search bar:** Extracted from monolith L50–101 (mobile) and L117–168 (desktop). Uses `UserBalancePageChrome.radiusMd` / `slateBorder` for borders and focused state. Callbacks `onSearch` / `onClear` wire to `getListTransactionInfoPager` / `clearSearch` at call site. Hint text preserved (`جستجو ... `).
- **Excel dialog:** Extracted from L174–344 (desktop) and mobile duplicate (~L2648). `Obx` wraps export button for `isLoading`. Caller clears filters before open (`toolbar._openExcel`). Dialog chrome uses `radiusMd` + slate border.
- **Toolbar:** Desktop uses `UserBalancePageChrome.toolbarDecoration()` with 400px search slot + `Spacer` + outlined Excel/Filter buttons. Mobile exposes Excel/Filter `GestureDetector` icons (search remains external per hybrid layout). Filter opens existing `FilterDialog` via `showGeneralDialog` with monolith dimensions (0.5/0.8 desktop, 0.9/0.9 mobile).
- **Not wired:** `list_user_info_transaction.view.dart` unchanged per Task 6 scope.

## Verification

```
flutter analyze lib/src/domain/users/widgets/list_user_info_transaction/user_balance_search_bar.widget.dart \
  lib/src/domain/users/widgets/list_user_info_transaction/user_balance_excel_dialog.widget.dart \
  lib/src/domain/users/widgets/list_user_info_transaction/user_balance_toolbar.widget.dart
→ No issues found! (3 files)
```

## Self-review

| Check | Result |
| --- | --- |
| Uses `AppColor` / `AppTextStyle` | Pass |
| Uses `UserBalancePageChrome` (toolbar + search + excel) | Pass |
| Desktop search max width 400 | Pass |
| Filter uses `FilterDialog` | Pass |
| Excel calls `getListUserInfoTransactionExcel` + `clearFilter` before open | Pass |
| No view wiring | Pass |
| No API / model changes | Pass |

## Concerns / carry-forward

1. **Excel dialog context:** `showUserBalanceExcelDialog` uses `Get.context!` rather than the toolbar's `BuildContext`; works under GetX but less ideal for tests.
2. **Mobile excel size:** Kept monolith mobile dimensions (65% × 50% height); redesign plan had 50% × 70% — confirm in Task 6 if UX wants the planned resize.
3. **Search chrome vs monolith:** Search field gains chrome borders/focus ring (intentional per brief Step 2); visual delta from plain `OutlineInputBorder(10)`.
4. **Double toolbar on mobile:** Task 6 must mount mobile search outside toolbar and toolbar icons below stats — avoid duplicating search inside `UserBalanceToolbar(isDesktop: false)`.
5. **No widget tests:** Extraction-only scope; dialog/filter flows need manual regression in Task 7.
