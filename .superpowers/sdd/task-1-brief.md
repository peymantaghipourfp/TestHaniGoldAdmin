### Task 1: Scaffold widgets + toolbar + desktop body shell

**Files:**
- Create: `lib/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_toolbar.widget.dart`
- Create: `lib/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_desktop_body.widget.dart`
- Test: `test/gold_transaction_data_table_layout_test.dart` (failing stub first)

**Interfaces:**
- Consumes: `UserInfoDetailGoldTransactionController`, existing `GoldTransactionFilterWidget`
- Produces: `GoldTransactionToolbar({required controller})`, `GoldTransactionDesktopBody({required controller})`

- [ ] **Step 1:** Add failing test asserting desktop body build tree contains no `scrollDirection: Axis.horizontal`.
- [ ] **Step 2:** Implement toolbar by moving the filter + Â«Ø­Ø°Ù Ú†Ú© Ø¨Ø§Ú©Ø³Â» dialog from the view (~2639â€“2682 and mobile ~4443â€“4486).
- [ ] **Step 3:** Implement desktop body as a `Column`: toolbar â†’ `SizedBox(height: 10)` â†’ placeholder for table (Task 2 fills it). Panel margins match current desktop container (~left/right 10).
- [ ] **Step 4:** `flutter analyze` on new files. Commit: `feat(users): scaffold gold transaction desktop toolbar shell`.