### Task 1: Picked image model + picker utility

**Files:**
- Create: `lib/src/domain/inventory/model/picked_inventory_image.model.dart`
- Create: `lib/src/domain/inventory/utils/inventory_image_picker.dart`

**Interfaces:**
- Produces: `PickedInventoryImage`, `InventoryImagePicker.pickFromCamera()`, `.pickFromGallery()`, `.pickMultipleDesktop()`, `resolveUploadFileName(XFile)`

- [ ] **Step 1: Add model**

```dart
class PickedInventoryImage {
  PickedInventoryImage({required this.id, required this.file, required this.previewBytes});
  final String id;
  final XFile file;
  final Uint8List previewBytes;
}
```

- [ ] **Step 2: Implement picker utility** with constants aligned to commented iOS fixes:
  - `imageQuality: 80`
  - `maxWidth: 1920`, `maxHeight: 1080`
  - After bottom-sheet / `Get.back()`, `await Future.delayed(const Duration(milliseconds: 300))` before opening picker
  - Gallery: try `pickMultiImage`, fallback to single `pickImage(source: gallery)` on failure
  - Immediately `readAsBytes()` after each pick â†’ return `PickedInventoryImage`
  - `resolveUploadFileName`: if `file.name` empty, return `'image_${DateTime.now().millisecondsSinceEpoch}.jpg'`

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze lib/src/domain/inventory/model/picked_inventory_image.model.dart lib/src/domain/inventory/utils/inventory_image_picker.dart`
Expected: no issues

---
