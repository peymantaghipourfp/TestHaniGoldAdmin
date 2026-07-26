# After Task 4 — for Task 5 temp widgets

Update views pattern to mirror:
- Internal List/RxList of PickedInventoryImage for preview
- Parent callback still List<XFile> — pass picked.map((p) => p.file).toList()
- Use InventoryImagePicker + PickedImageThumbnailRow
- Delete large commented pickImageMobile blocks
- Desktop pick must APPEND (no clear before add)
- Remove dart:io / FileImage
- Do NOT double-delay (picker has 300ms)
