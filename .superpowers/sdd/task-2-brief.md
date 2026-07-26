### Task 2: Shared thumbnail widget

**Files:**
- Create: `lib/src/domain/inventory/widget/picked_image_thumbnail.widget.dart`

**Interfaces:**
- Consumes: `PickedInventoryImage` or `Uint8List previewBytes`
- Produces: reusable thumbnail row + fullscreen dialog (replaces duplicated `showGeneralDialog` + `DecorationImage` blocks)

- [ ] **Step 1: Build thumbnail** using `Image.memory(bytes, fit: BoxFit.cover, cacheWidth: 120, errorBuilder: ...)`
- [ ] **Step 2: Build horizontal list helper** `PickedImageThumbnailRow({required List<PickedInventoryImage> images, required ValueChanged<PickedInventoryImage> onRemove, required void Function(PickedInventoryImage) onTap})`
- [ ] **Step 3: Run analyzer** on new widget file

---
