### Task 5: Validation + graphify

- [ ] **Step 1: Run tests + analyze**

```bash
flutter test test/selected_factor_pdf_query_test.dart
dart analyze lib/src/config/repository/inventory.repository.dart lib/src/config/repository/user_info_transaction.repository.dart lib/src/domain/users/controller/user_info_detail_transaction.controller.dart lib/src/domain/users/widgets/selected_factor_detail_dialog.widget.dart lib/src/domain/users/view/user_info_transaction.view.dart
```

Expected: tests pass; analyzer clean on touched files (pre-existing warnings OK if none introduced by this feature).

- [ ] **Step 2: Manual validation path (local — required)**

Automated UI/PDF E2E is not available in this repo’s sparse test suite. Document a checklist file for human local verification:

1. Open user transaction detail with a `receive` or `payment` row that has multiple inventory details
2. Click «فاکتور با مانده» → dialog lists details → select ≥1 → صدور → PDF downloads/shares; confirm request uses `showBalance=true` and `InventoryDetailIds`
3. Click «فاکتور» → same with `showBalance=false`
4. Cancel dialog / select none → no PDF call (or snackbar for empty)
5. Non-inventory row still uses old client invoice path

Write checklist to: `.superpowers/sdd/selected-factor-pdf/manual-validation-checklist.md` marked PENDING_HUMAN.

- [ ] **Step 3: Update knowledge graph**

```bash
graphify update .
```

- [ ] **Step 4: Commit graphify if it changed tracked outputs**

```bash
git add graphify-out/
git commit -m "chore: update graphify after selected factor PDF"
```

**NO-GIT ADAPTATION:** Skip Step 4 commit. Still run graphify update.
