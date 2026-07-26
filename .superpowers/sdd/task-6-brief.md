### Task 6: Footer grid + thin view shell

**Files:** `user_balance_footer.widget.dart`, modify `list_user_info_transaction.view.dart`

- [ ] **Step 1:** Extract `_buildFooterItem` / `_buildNetFooterItem` (L2491–2633) into footer widget
- [ ] **Step 2:** Replace footer `SingleChildScrollView(horizontal)` (L493–791) with `Wrap(spacing: 16, runSpacing: 12, alignment: WrapAlignment.start)`; net totals section similarly wrapped
- [ ] **Step 3:** Thin view shell with PageState switch using Task 2 state widgets, desktop UserBalanceDesktopBody with footer, mobile keeps existing until Task 7
- [ ] **Step 4:** Delete moved private methods from view; view should be ~150–200 lines
- [ ] **Step 5:** Commit `refactor(users): thin view shell and responsive footer grid`

**Target view structure from plan** — use switch on PageState, wire empty state fix, desktop body with footer, pager overlay, mobile can still call monolith mobile builder temporarily if Task 7 not done yet OR extract minimal mobile path.

**Global:** Keep CustomAppbar1, AppDrawer, ChatFloatingButton, BackgroundImageTotal, pager overlay for desktop.
