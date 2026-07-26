### Task 4: Update views (receive + payment)

**Files:**
- Modify: [inventory_detail_update_receive.view.dart](lib/src/domain/inventory/view/inventory_detail_update_receive.view.dart)
- Modify: [inventory_detail_update_payment.view.dart](lib/src/domain/inventory/view/inventory_detail_update_payment.view.dart)

- [ ] **Step 1:** Remove `import 'dart:io'`.
- [ ] **Step 2:** Replace `selectedImagesDesktop.map(... FileImage ...)` block (~lines 1083â€“1180 receive, ~1088 payment) with `PickedImageThumbnailRow(images: controller.pickedImages, ...)`.
- [ ] **Step 3:** For **existing server images** (`imageList`), keep `NetworkImage` with `BaseUrl` (unchanged) but add `errorBuilder` + loading placeholder.
- [ ] **Step 4:** Mobile bottom sheet: after `Get.back()`, call controller method that internally applies the 300ms delay (do not call picker synchronously from `onTap`).
- [ ] **Step 5: Run analyzer** on both views

---
