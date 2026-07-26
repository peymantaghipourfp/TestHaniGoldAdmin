# Task 3 Report: Selectable detail dialog widget

## Status: DONE

## Scope

Created only: `lib/src/domain/users/widgets/selected_factor_detail_dialog.widget.dart`

No view wiring (Task 4). No git repository in workspace — commit skipped per instructions.

## Changes Implemented

### `SelectedFactorDetailDialog`

Stateful multi-select dialog matching the brief signature:

- Constructor: `SelectedFactorDetailDialog({required List<InventoryDetailModel> details})`
- Static helper:
  ```dart
  static Future<List<int>?> show(
    BuildContext context, {
    required List<InventoryDetailModel> details,
  }) async {
    return Get.dialog<List<int>>(
      SelectedFactorDetailDialog(details: details),
      barrierDismissible: true,
    );
  }
  ```

### Behavior

| Behavior | Implementation |
| --- | --- |
| Title | `انتخاب ردیف‌های فاکتور` |
| Filter | Drops rows where `id == null` or `isDeleted == true` before display |
| Row UI | `CheckboxListTile` with `itemName` / `item?.name`, quantity, weight, `receiptNumber` (fallback `نامشخص`) |
| Select-all | Header `CheckboxListTile` labeled `انتخاب همه` |
| Pre-select | All visible rows selected on open (convenience; not required by brief) |
| `انصراف` / close | `Navigator.pop(context)` → returns `null` |
| `صدور` with none selected | `Get.snackbar` warning; dialog stays open |
| `صدور` with selection | `Navigator.pop(context, selectedIds)` → `List<int>` |
| Empty list | Shows empty-state message; Issue still snackbars if pressed with no selection |

### Styling

Matches existing user dialogs (`check_result.widget.dart` / `user_update_dialog.widget.dart`):

- `AppColor.backGroundColor` dialog background
- `RoundedRectangleBorder(borderRadius: 12)` + `AppColor.secondaryColor` border
- `AppTextStyle.smallTitleText` / `bodyText` / `bodyTextBold` / `labelText`
- Primary / accent elevated buttons for `صدور` / `انصراف`

Package imports used for cross-folder deps (`hanigold_admin/...`).

## Validation

### `dart analyze lib/src/domain/users/widgets/selected_factor_detail_dialog.widget.dart`

```
Analyzing selected_factor_detail_dialog.widget.dart...
No issues found!
```

Exit code: **0**

### Graphify

Ran `graphify update .` after creating the widget (AST-only).

## Self-Review

### Checklist vs brief

- [x] File path/name exact
- [x] Class + `show` signature match sketch
- [x] Filter null-id / deleted
- [x] Fields shown: name, quantity, weight, receiptNumber with `نامشخص` fallback
- [x] Select-all toggle
- [x] Cancel → null; Issue → `List<int>` or snackbar
- [x] AppColor / AppTextStyle / rounded chrome
- [x] Analyze clean
- [x] Commit skipped (NO-GIT)
- [x] View **not** wired (Task 4)

### Notes / non-blocking

1. **Interfaces vs signature:** Plan “Consumes” line mentions `showBalance` and callbacks; the authoritative signature sketch only takes `details`. `showBalance` belongs to Task 4 when calling `issueSelectedFactorPdf` after the dialog returns ids — not part of this widget.
2. **Pre-select all:** Brief required select-all toggle optionally; dialog additionally pre-selects all visible rows so “صدور” works immediately. Easy to change to empty selection if product prefers opt-in.
3. **Not wired:** Callers do not yet use this widget; Task 4 will call `SelectedFactorDetailDialog.show(...)`.

## Files

| Path | Action |
| --- | --- |
| `lib/src/domain/users/widgets/selected_factor_detail_dialog.widget.dart` | **Created** |

## Commits

none (no git)
