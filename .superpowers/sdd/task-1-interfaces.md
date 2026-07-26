# Interfaces from Task 1 (for later tasks)

## PickedInventoryImage
- id: String
- file: XFile
- previewBytes: Uint8List

## InventoryImagePicker
- pickFromCamera() -> Future<PickedInventoryImage?>
- pickFromGallery() -> Future<List<PickedInventoryImage>>
- pickMultipleDesktop() -> Future<List<PickedInventoryImage>>
- resolveUploadFileName(XFile) -> String
- Internal delay 300ms on camera/gallery (NOT desktop)
- Callers must NOT add a second 300ms delay
