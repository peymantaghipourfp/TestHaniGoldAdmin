### Task 3: Toolbar, search, excel dialog

**Files:** `user_balance_search_bar.widget.dart`, `user_balance_excel_dialog.widget.dart`, `user_balance_toolbar.widget.dart`

- [ ] **Step 1:** Move desktop search (L117–168), excel dialog (L174–250), filter opener (L251–415) without behavior change
- [ ] **Step 2:** Apply `UserBalancePageChrome` decorations; desktop max search width ~400
- [ ] **Step 3:** Commit `feat(users): extract user-balance toolbar`

**Global Constraints (binding):**
- Do not change behavior — copy logic verbatim from monolith
- Apply UserBalancePageChrome toolbarDecoration
- Desktop search max width ~400
- Filter dialog: existing `FilterDialogReportSetting` widget
- Controller: UserInfoTransactionController
- Do NOT wire into main view yet (Task 6)
