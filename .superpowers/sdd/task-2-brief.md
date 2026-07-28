### Task 2: Fit-width DataTable with meta merge + Ø¨Ø¯Ù‡Ú©Ø§Ø±/Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø± grouping

**Files:**
- Create: `gold_transaction_data_table.widget.dart`, `gold_transaction_grouped_header.widget.dart`, cell widgets in file map
- Modify: desktop body to host `GoldTransactionDataTable`
- Modify: view to use `GoldTransactionDesktopBody` instead of H-scroll block
- Test: assert **14** columns; merged datetime; **4** grouped asset headers; **4** separate Ù…Ø§Ù†Ø¯Ù‡ headers; no separate Â«Ø·Ù„Ø§ Ø¨Ø¯Ù‡Ú©Ø§Ø±Â» / Â«Ø·Ù„Ø§ Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±Â» column titles

**Interfaces:**
- Produces: `GoldTransactionDataTable({required controller})` â†’ `Obx` â†’ `LayoutBuilder` â†’ `DataTable`
- Cell factories: `creditSection` / `debitSection` / `balanceSection` preserve current business rules (amount sign, `itemUnit.id`, `item.id` 3/4 for Ù†ÛŒÙ…/Ø±Ø¨Ø¹, running totals)

- [ ] **Step 1:** Implement `GoldTransactionGroupedHeader` (label + display-only polarity chips; reuse `UserBalancePolarityChip` with `onTap: null` or equivalent).
- [ ] **Step 2:** Move row/column logic into `GoldTransactionDataTable` with the **14-column** model and `_assetCell` stacking.
- [ ] **Step 3:** Merge Ø³Ø§Ø¹Øª+ØªØ§Ø±ÛŒØ® into `GoldTransactionDateTimeCell`.
- [ ] **Step 4:** Compact invoice cell (icon buttons + tooltips).
- [ ] **Step 5:** Port description cell; all inner texts `softWrap: false`; width-constrained; prefer intrinsic height over nested vertical scroll.
- [ ] **Step 6:** Port gold/coin/half_quarter/rial factories; wire grouped debit/credit columns + separate Ù…Ø§Ù†Ø¯Ù‡ columns; vertical-stack Ù†ÛŒÙ…/Ø±Ø¨Ø¹ inside polarity sections.
- [ ] **Step 7:** Remove desktop `Axis.horizontal` scroll from the view; parent page remains vertical `SingleChildScrollView`.
- [ ] **Step 8:** Run test + `flutter analyze`. Commit: `feat(users): grouped debit/credit gold ledger table without horizontal scroll`.