### Task 4: Wire view buttons (desktop + mobile)

**Files:**
- Modify: `lib/src/domain/users/view/user_info_transaction.view.dart` (~3480–3525 desktop, ~4907–4965 mobile)

**Interfaces:**
- Consumes: controller fetch/issue + `SelectedFactorDetailDialog.show`
- Produces: receive/payment → dialog → PDF; other types unchanged

- [ ] **Step 1: Add helper on the view State class**

Add to `_UserInfoTransactionViewState` (around other private helpers, not inside build):

```dart
Future<void> _onIssueInvoicePressed(
  TransactionInfoItemModel trans, {
  required bool showBalance,
}) async {
  final isInventory = trans.type == 'receive' || trans.type == 'payment';
  if (!isInventory) {
    if (showBalance) {
      await controller.generateInvoiceForTransaction(trans);
    } else {
      await controller.generateInvoiceForTransactionWithoutBalance(trans);
    }
    return;
  }

  final inventoryId = trans.recordId ?? trans.id;
  if (inventoryId == null || inventoryId == 0) {
    Get.snackbar('خطا', 'شناسه فاکتور موجود نیست', /* titleText/messageText like existing */);
    return;
  }

  final inventory = await controller.fetchInventoryForSelectedFactor(inventoryId);
  final details = inventory?.inventoryDetails ?? [];
  if (details.isEmpty) {
    Get.snackbar('اطلاعات', 'ردیفی برای صدور فاکتور یافت نشد', /* ... */);
    return;
  }

  final selectedIds = await SelectedFactorDetailDialog.show(
    context,
    details: details,
  );
  if (selectedIds == null || selectedIds.isEmpty) return;

  await controller.issueSelectedFactorPdf(
    inventoryId: inventoryId,
    showBalance: showBalance,
    inventoryDetailIds: selectedIds,
    inventoryType: inventory?.type,
  );
}
```

Copy snackbar `titleText`/`messageText` styling from existing controller snackbars (`AppColor.textColor`, centered Text). Add import for `SelectedFactorDetailDialog`.

- [ ] **Step 2: Replace button `onPressed` / `onTap`**

Desktop (~3488, ~3511) and mobile (~4912, ~4940):

```dart
onPressed: () async {
  await _onIssueInvoicePressed(trans, showBalance: true); // با مانده
}
// and
await _onIssueInvoicePressed(trans, showBalance: false); // بدون مانده
```

Exact call sites to change (only these four):
1. Desktop "فاکتور با مانده" `onPressed` (~3488–3490): `showBalance: true`
2. Desktop "فاکتور" `onPressed` (~3510–3512): `showBalance: false`
3. Mobile "فاکتور" `onTap` (~4911–4913): `showBalance: false`
4. Mobile "فاکتور با مانده" `onTap` (~4939–4941): `showBalance: true`

Do **not** modify `user_info_gold_transaction.view.dart`.

- [ ] **Step 3: Analyze view**

Run: `dart analyze lib/src/domain/users/view/user_info_transaction.view.dart`
Expected: no issues (ignore pre-existing warnings unrelated to your change)

- [ ] **Step 4: Commit**

```bash
git add lib/src/domain/users/view/user_info_transaction.view.dart
git commit -m "feat: open detail selection before selected factor PDF on receive/payment"
```

**NO-GIT ADAPTATION:** Workspace has no `.git`. Skip Step 4 commit.

**Already available:**
- `controller.fetchInventoryForSelectedFactor(int)`
- `controller.issueSelectedFactorPdf(...)`
- `SelectedFactorDetailDialog.show(context, details: ...)`
