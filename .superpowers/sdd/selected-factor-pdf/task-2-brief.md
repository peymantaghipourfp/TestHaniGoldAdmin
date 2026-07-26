### Task 2: Controller — load details + issue selected PDF

**Files:**
- Modify: `lib/src/domain/users/controller/user_info_detail_transaction.controller.dart`

**Interfaces:**
- Consumes: `InventoryRepository.getOneInventory`, `UserInfoTransactionRepository.getSelectedFactorPdf`
- Produces:
  - `Future<InventoryModel?> fetchInventoryForSelectedFactor(int inventoryId)`
  - `Future<void> issueSelectedFactorPdf({required int inventoryId, required bool showBalance, required List<int> inventoryDetailIds, int? inventoryType})`
  - private `_shareSelectedFactorPdf(Uint8List bytes, {int? inventoryType})` (web blob / `Printing.sharePdf`, prefix `factorInventoryReceive` / `factorInventoryPayment` like inventory controller)

- [ ] **Step 1: Register `InventoryRepository` on controller**

```dart
final InventoryRepository inventoryRepository = InventoryRepository();
```

Add import for `inventory.repository.dart` and `inventory.model.dart`.

- [ ] **Step 2: Implement fetch + issue methods**

```dart
Future<InventoryModel?> fetchInventoryForSelectedFactor(int inventoryId) async {
  try {
    EasyLoading.show(status: 'در حال دریافت جزئیات...');
    final inventory = await inventoryRepository.getOneInventory(id: inventoryId);
    EasyLoading.dismiss();
    return inventory;
  } catch (e) {
    EasyLoading.dismiss();
    Get.snackbar('خطا', 'خطا در دریافت جزئیات فاکتور: $e', /* titleText/messageText as existing */);
    return null;
  }
}

Future<void> issueSelectedFactorPdf({
  required int inventoryId,
  required bool showBalance,
  required List<int> inventoryDetailIds,
  int? inventoryType,
}) async {
  if (inventoryDetailIds.isEmpty) {
    Get.snackbar('اطلاعات', 'حداقل یک ردیف را انتخاب کنید', /* ... */);
    return;
  }
  try {
    EasyLoading.show(status: 'در حال تولید فاکتور...');
    final bytes = await userInfoTransactionRepository.getSelectedFactorPdf(
      id: inventoryId,
      showBalance: showBalance,
      inventoryDetailIds: inventoryDetailIds,
      showHaniGold: false,
    );
    await _shareSelectedFactorPdf(bytes, inventoryType: inventoryType);
    EasyLoading.dismiss();
    Get.snackbar('موفقیت', 'فاکتور با موفقیت تولید شد', /* ... */);
  } catch (e) {
    EasyLoading.dismiss();
    Get.snackbar('خطا', 'خطا در تولید فاکتور: $e', /* ... */);
  }
}
```

Copy snackbar `titleText`/`messageText` styling from existing `generateInvoiceForTransaction`. Copy `_shareSelectedFactorPdf` from inventory `_shareFactorPdf` (same web/`Printing` pattern already imported in this controller).

Reference for `_shareSelectedFactorPdf` (from inventory.controller.dart):

```dart
Future<void> _shareSelectedFactorPdf(Uint8List bytes, {int? inventoryType}) async {
  final prefix = (inventoryType ?? 0) == 0 ? 'factorInventoryReceive' : 'factorInventoryPayment';
  final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  if (kIsWeb) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..download = fileName
      ..click();
    html.Url.revokeObjectUrl(url);
  } else {
    await Printing.sharePdf(
      bytes: bytes,
      filename: '$prefix.pdf',
    );
  }
}
```

- [ ] **Step 3: Analyze controller**

Run: `dart analyze lib/src/domain/users/controller/user_info_detail_transaction.controller.dart`
Expected: no issues

- [ ] **Step 4: Commit**

```bash
git add lib/src/domain/users/controller/user_info_detail_transaction.controller.dart
git commit -m "feat: issue selected inventory factor PDF from transaction controller"
```

**NO-GIT ADAPTATION:** Workspace has no `.git`. Skip Step 4 commit.

**Already available from Task 1 (do not re-implement):**
- `InventoryRepository.getOneInventory({required int id})`
- `UserInfoTransactionRepository.getSelectedFactorPdf({required int id, required bool showBalance, required List<int> inventoryDetailIds, bool showHaniGold = false})`
