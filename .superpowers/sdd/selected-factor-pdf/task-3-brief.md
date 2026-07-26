### Task 3: Selectable detail dialog widget

**Files:**
- Create: `lib/src/domain/users/widgets/selected_factor_detail_dialog.widget.dart`

**Interfaces:**
- Consumes: `InventoryDetailModel` list, `showBalance`, callbacks
- Produces: `SelectedFactorDetailDialog` widget shown via `Get.dialog` / `showDialog`

- [ ] **Step 1: Implement dialog**

Stateful widget with:
- Title: `انتخاب ردیف‌های فاکتور`
- `CheckboxListTile` (or row + Checkbox) per detail: show `itemName`/`item?.name`, `quantity`, `weight`, `receiptNumber` (fallback `نامشخص`)
- Select-all toggle optional but useful
- Actions: `انصراف` → pop; `صدور` → if none selected show snackbar, else `Navigator.pop(context, selectedIds)` returning `List<int>`
- Style with `AppColor.backGroundColor`, `AppTextStyle`, rounded border like other user dialogs

Signature sketch:

```dart
class SelectedFactorDetailDialog extends StatefulWidget {
  final List<InventoryDetailModel> details;
  const SelectedFactorDetailDialog({super.key, required this.details});
  // ...
}

/// Returns selected detail ids, or null if cancelled.
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

Filter out details where `id == null` or `isDeleted == true` before display.

- [ ] **Step 2: Analyze widget**

Run: `dart analyze lib/src/domain/users/widgets/selected_factor_detail_dialog.widget.dart`
Expected: no issues

- [ ] **Step 3: Commit**

```bash
git add lib/src/domain/users/widgets/selected_factor_detail_dialog.widget.dart
git commit -m "feat: add selectable inventory detail dialog for factor PDF"
```

**NO-GIT ADAPTATION:** Workspace has no `.git`. Skip Step 3 commit.

**Style reference:** See `lib/src/domain/users/widgets/user_update_dialog.widget.dart` for `AppColor.backGroundColor` / dialog chrome. Use package imports (`package:hanigold_admin/...`) for cross-folder files.

**InventoryDetailModel** fields of interest (`lib/src/domain/inventory/model/inventory_detail.model.dart`): `id`, `itemName`, `item` (with name), `quantity`, `weight`, `receiptNumber`, `isDeleted`.
