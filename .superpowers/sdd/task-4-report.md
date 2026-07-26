# Task 4 Report: Update views (receive + payment)

## Status: Complete

## Files modified
- `lib/src/domain/inventory/view/inventory_detail_update_receive.view.dart`
- `lib/src/domain/inventory/view/inventory_detail_update_payment.view.dart`

## Changes

### Step 1 — Remove `dart:io`
- Removed `import 'dart:io'` from both views.
- Removed unused `import 'package:flutter/foundation.dart'` (only used for `kIsWeb` in removed `FileImage` branches).

### Step 2 — Picked images via `PickedImageThumbnailRow`
- Replaced `selectedImagesDesktop.map(... FileImage ...)` `Obx` block with `PickedImageThumbnailRow`.
- `images`: `controller.pickedImages`
- `onRemove`: removes item from `pickedImages` and calls `.refresh()`
- `onTap`: `showPickedImageFullscreenDialog(context, previewBytes: image.previewBytes)`
- Added import for `picked_image_thumbnail.widget.dart`.

### Step 3 — Server images (`imageList`)
- Kept `BaseUrl` + `Attachment/downloadAttachment?fileName=` URL pattern.
- Replaced `DecorationImage(NetworkImage(...))` with `Image.network(...)` so `loadingBuilder` and `errorBuilder` are supported.
- Loading: `HaniGoldLoading()` centered placeholder.
- Error: `ColoredBox` + `Icons.broken_image_outlined` (matches picked-image widget style).
- Applied to both thumbnail (60×60) and fullscreen dialog.

### Step 4 — Mobile bottom sheet
- No change required — already calls `Get.back()` then `controller.pickImageMobile(ImageSource.gallery|camera)`.

## Analyzer (`flutter analyze`)

```
12 issues — 0 errors
```

| File | Errors | Warnings | Info |
|------|--------|----------|------|
| receive.view.dart | 0 | 1 (pre-existing unused `chat_dialog` import) | 2 (pre-existing `withOpacity`) |
| payment.view.dart | 0 | 1 (pre-existing unused `chat_dialog` import) | 7 (pre-existing `withOpacity`, `use_build_context_synchronously`) |

No new issues introduced by Task 4 changes.

## Concerns / follow-ups
- **Insert views** (`inventory_detail_insert_receive.view.dart`, `inventory_detail_insert_payment.view.dart`) still use `selectedImagesDesktop` + `FileImage` — out of scope for Task 4 but same migration may be needed later.
- Server-image fullscreen dialog in payment view now uses responsive sizing (`isMobile` margins) where it previously used fixed `Get.height * 0.8` — intentional alignment with receive view.

## Verification checklist
- [x] `dart:io` removed
- [x] `selectedImagesDesktop` / `FileImage` removed
- [x] `PickedImageThumbnailRow` wired
- [x] Server `imageList` has loading + error placeholders
- [x] Mobile sheet unchanged (Get.back → pickImageMobile)
- [x] `flutter analyze` — no errors
