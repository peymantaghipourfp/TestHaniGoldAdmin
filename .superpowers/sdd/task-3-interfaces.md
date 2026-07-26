# Controller API after Task 3 (for Task 4 views)

Both InventoryUpdateReceiveController and InventoryUpdatePaymentController expose:
- RxList<PickedInventoryImage> pickedImages
- RxList<String> imageList (server guids)
- pickImageDesktop()
- pickImageMobile(ImageSource source)  // camera or gallery; delay is inside InventoryImagePicker
- deleteImage(String)
- isUploadingDesktop

Views must:
- Use controller.pickedImages (NOT selectedImagesDesktop)
- Use PickedImageThumbnailRow for picked previews
- After Get.back() on mobile sheet, call controller.pickImageMobile(...) — do NOT add another 300ms delay and do NOT call picker synchronously before back completes (await Get.back then call, or call after back — picker has internal delay)
- Existing imageList: keep NetworkImage + BaseUrl; add errorBuilder + loading placeholder
- Remove import dart:io
