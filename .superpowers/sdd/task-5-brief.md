### Task 5: Temp-detail widgets (create flow parity)

**Files:**
- Modify: [item_temp_detail_receive.widget.dart](lib/src/domain/inventory/widget/item_temp_detail_receive.widget.dart)
- Modify: [item_temp_detail_payment.widget.dart](lib/src/domain/inventory/widget/item_temp_detail_payment.widget.dart)

- [ ] **Step 1:** Delete large commented-out `pickImageMobile` blocks (lines ~142â€“344 receive, ~149â€“351 payment).
- [ ] **Step 2:** Maintain `List<XFile> image` callback contract to parent, but internally track `List<PickedInventoryImage>` for preview; on `recId` callback pass `picked.map((p) => p.file).toList()`.
- [ ] **Step 3:** Use shared picker utility + thumbnail row (replace `FileImage` / `dart:io`).
- [ ] **Step 4:** Fix desktop pick to **append** to existing images (currently `selectedImagesDesktop.clear()` replaces prior selection).
- [ ] **Step 5: Run analyzer** on both widgets

---
