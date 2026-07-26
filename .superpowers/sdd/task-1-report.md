# Task 1 Report: Picked image model + picker utility

**Status:** DONE  
**Date:** 2026-07-22

## Summary

Created the foundation model and shared picker utility for inventory photo preview/upload hardening on mobile browsers. No controllers, views, or widgets were modified — later tasks will wire these APIs.

## Files created

### `lib/src/domain/inventory/model/picked_inventory_image.model.dart`

- `PickedInventoryImage` with `id` (String), `file` (XFile), `previewBytes` (Uint8List) — matches task spec verbatim.

### `lib/src/domain/inventory/utils/inventory_image_picker.dart`

- `InventoryImagePicker` static utility (private constructor).
- **Constants:** `imageQuality: 80`, `maxWidth: 1920`, `maxHeight: 1080`, `_sheetCloseDelay: 300ms`.
- **`pickFromCamera()`** — delays 300ms (post sheet close), picks camera image with iOS-safe limits, `readAsBytes()` immediately, returns `PickedInventoryImage?` (null on cancel).
- **`pickFromGallery()`** — same delay + limits; tries `pickMultiImage`, falls back to single `pickImage(source: gallery)` on failure; reads bytes per file; returns `List<PickedInventoryImage>`.
- **`pickMultipleDesktop()`** — `pickMultiImage` with same quality/size limits, no sheet delay; reads bytes per file.
- **`resolveUploadFileName(XFile)`** — returns `file.name` when non-empty, else `'image_${DateTime.now().millisecondsSinceEpoch}.jpg'`.
- **IDs:** UUID v4 via `package:uuid` per existing inventory convention.
- **Errors:** logged with `AppLogger.e`, rethrown for caller snackbar handling (Task 3+).

## Analyzer

```
flutter analyze lib/src/domain/inventory/model/picked_inventory_image.model.dart lib/src/domain/inventory/utils/inventory_image_picker.dart
No issues found!
```

## Self-review

| Acceptance criterion | Result |
| --- | --- |
| Model matches spec (`id`, `file`, `previewBytes`) | ✅ |
| `pickFromCamera` / `pickFromGallery` / `pickMultipleDesktop` / `resolveUploadFileName` | ✅ |
| iOS-aligned constants (80 / 1920×1080 / 300ms delay) | ✅ |
| Gallery multi → single fallback | ✅ |
| Immediate `readAsBytes()` after each pick | ✅ |
| Package imports (`package:hanigold_admin/...`) | ✅ |
| No controller/view/widget changes | ✅ |
| Commit step skipped (no git repo) | ✅ |
| `graphify update .` run | ✅ |

## Design notes for downstream tasks

- **Task 3 controllers:** call `pickFromCamera()` / `pickFromGallery()` after `Get.back()` from bottom sheet; delay is inside the utility.
- **Task 3 upload:** use `picked.previewBytes` + `InventoryImagePicker.resolveUploadFileName(picked.file)` — no `dart:io` needed.
- **Task 5 widgets:** map `picked.map((p) => p.file).toList()` for existing `recId` callback contract.

## Concerns

None.
