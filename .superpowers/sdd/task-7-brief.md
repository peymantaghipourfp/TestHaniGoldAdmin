### Task 7: Mobile list extraction + final verification

**Files:** `user_balance_mobile_list.widget.dart`

- [ ] **Step 1:** Extract `_buildMobileTransactionList`, `_buildMobileSortHeader`, `_mobileLine`, `_mobileLineWithIcon` from view; apply `UserBalancePageChrome` card styling + polarity chips on بس/بد lines
- [ ] **Step 2:** Ensure `scrollControllerMobile` infinite scroll unchanged
- [ ] **Step 3:** Run verification:

```bash
flutter analyze lib/src/domain/users/view/list_user_info_transaction.view.dart lib/src/domain/users/widgets/list_user_info_transaction
flutter test test/domain/users/user_balance_stats_helper_test.dart
graphify update .
```

- [ ] **Step 4:** Commit `feat(users): mobile list extraction and grouped-table verification`

View should be ~150-200 lines after extraction.
