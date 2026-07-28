### Task 3: Extract mobile list + thin the view

**Files:**
- Create: `gold_transaction_mobile_list.widget.dart`
- Modify: view â€” replace `_buildMobileTransactionCards(...)` with `GoldTransactionMobileList(controller: controller)`
- Modify: controller â€” desktop horizontal `scrollController` unused cleanup only if safe

- [ ] **Step 1:** Move mobile card UI + helpers into `GoldTransactionMobileList` (mobile can keep showing debit/credit/balance as separate card rows â€” no UX requirement to group cards).
- [ ] **Step 2:** Reuse `GoldTransactionToolbar` on mobile.
- [ ] **Step 3:** Confirm view no longer contains `buildDataColumns` / `buildDataRows` / `_buildMobileTransactionCards`.
- [ ] **Step 4:** Analyze + smoke on Chrome. Commit: `refactor(users): extract gold transaction mobile list`.