### Task 3: Harden update controllers (receive + payment)

**Files:**
- Modify: [inventory_update_receive.controller.dart](lib/src/domain/inventory/controller/inventory_update_receive.controller.dart)
- Modify: [inventory_update_payment.controller.dart](lib/src/domain/inventory/controller/inventory_update_payment.controller.dart)

**Key changes (both controllers, mirror each other):**

1. Replace `RxList<XFile?> selectedImagesDesktop` with `RxList<PickedInventoryImage> pickedImages`.
2. Replace `pickImageDesktop` / `pickImageMobile` bodies with calls to `InventoryImagePicker`, appending via `pickedImages.addAll(...); pickedImages.refresh()`.
3. Refactor `uploadImagesDesktopUpdate`:

```dart
Future<void> uploadImagesDesktopUpdate(String type, String entityType) async {
  final recId = inventoryDetail?.recId ?? '';
  if (pickedImages.isEmpty) {
    await updateInventoryDetailReceive(recId); // or Payment variant
    return;
  }
  if (recId.isEmpty) {
    Get.snackbar('Ø®Ø·Ø§', 'Ø´Ù†Ø§Ø³Ù‡ Ù¾ÛŒÙˆØ³Øª ÛŒØ§ÙØª Ù†Ø´Ø¯');
    return;
  }
  isUploadingDesktop.value = true;
  EasyLoading.show(status: 'Ø¯Ø± Ø­Ø§Ù„ Ø¢Ù¾Ù„ÙˆØ¯ ØªØµØ§ÙˆÛŒØ±...');
  final statuses = List<bool>.filled(pickedImages.length, false);
  try {
    for (var i = 0; i < pickedImages.length; i++) {
      final picked = pickedImages[i];
      try {
        final fileName = InventoryImagePicker.resolveUploadFileName(picked.file);
        final success = await uploadRepositoryDesktop.uploadImageDesktop(
          imageBytes: picked.previewBytes,
          fileName: fileName,
          recordId: recId,
          type: type,
          entityType: entityType,
        );
        statuses[i] = success.isNotEmpty;
      } catch (e, s) {
        AppLogger.e('upload image failed', e, s);
        Get.snackbar('Ø®Ø·Ø§', 'Ø®Ø·Ø§ Ø¯Ø± Ø¢Ù¾Ù„ÙˆØ¯ ØªØµÙˆÛŒØ± ${i + 1}');
      }
    }
    if (statuses.every((s) => s)) {
      await getImage(recId, 'InventoryDetail');
      pickedImages.clear();
      await updateInventoryDetailReceive(recId);
    } else {
      Get.snackbar('Ø®Ø·Ø§', 'Ø¨Ø±Ø®ÛŒ ØªØµØ§ÙˆÛŒØ± Ø¢Ù¾Ù„ÙˆØ¯ Ù†Ø´Ø¯Ù†Ø¯. Ø¯ÙˆØ¨Ø§Ø±Ù‡ ØªÙ„Ø§Ø´ Ú©Ù†ÛŒØ¯');
    }
  } finally {
    isUploadingDesktop.value = false;
    EasyLoading.dismiss();
  }
}
```

4. Remove extra `Get.back()` inside upload success path (navigation stays in update method).
5. Update `clearList()` to clear `pickedImages`.
6. Remove unused `import 'dart:io'` from receive controller.

- [ ] **Step 4: Run analyzer** on both controllers

---
