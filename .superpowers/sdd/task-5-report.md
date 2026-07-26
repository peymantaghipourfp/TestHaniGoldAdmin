# Task 5 Report — Temp-detail widgets (create flow parity)

## Status: Complete

Both create-flow temp detail widgets now match the update-view image picking pattern.

## Files modified

- `lib/src/domain/inventory/widget/item_temp_detail_receive.widget.dart`
- `lib/src/domain/inventory/widget/item_temp_detail_payment.widget.dart`

## Changes

1. **Removed dead code** — Deleted ~200-line commented `pickImageMobile` blocks from both widgets.
2. **Removed platform-specific preview** — Dropped `dart:io`, `FileImage`, and direct `ImagePicker` usage.
3. **Internal preview state** — Added `RxList<PickedInventoryImage> pickedImages`; existing `widget.image` entries loaded in `initState` via `readAsBytes()`.
4. **Shared utilities** — `InventoryImagePicker` for camera/gallery/desktop; `PickedImageThumbnailRow` + `showPickedImageFullscreenDialog` for UI.
5. **Parent callback contract preserved** — `recId` still `Function(String, List<XFile>)?`; passes only newly picked files via `images.map((p) => p.file).toList()`.
6. **Desktop append fix** — Removed `selectedImagesDesktop.clear()`; new desktop picks append to `pickedImages` via `addAll`.
7. **No double delay** — Mobile sheet closes first; `InventoryImagePicker` handles the 300ms delay internally.

## Public API

Unchanged — same constructor parameters (`detail`, `image`, `recId`, plus payment-specific `quantity` / `onQuantityChanged`).

## Analyzer

```
flutter analyze lib/src/domain/inventory/widget/item_temp_detail_receive.widget.dart \
              lib/src/domain/inventory/widget/item_temp_detail_payment.widget.dart
→ No issues found!
```

## Concerns / notes

- **Remove without recId** — Image removal still mutates `widget.image` in place (same as before); parent `updateDetail` is not called on remove. Pre-existing behavior.
- **initState hydration** — If parent replaces `widget.image` with a new list after mount (without remounting the State), `pickedImages` won't auto-sync; unlikely for temp-detail flow since items are added fresh.
- **Thumbnail sizing** — Mobile now uses shared 60×60 thumbnails (was 50×50); consistent with update views.

## Manual test suggestions

1. Create receive/payment flow → add temp item → pick images on mobile (camera + gallery) and desktop.
2. Pick multiple times on desktop → verify thumbnails accumulate (append, not replace).
3. Remove a thumbnail → verify it disappears and `widget.image` shrinks.
4. Tap thumbnail → fullscreen preview opens.
5. Submit temp item with images → verify upload still receives `recId` + merged `listXfile` in controller.
