### Task 2: Stats grid + page state widgets

**Files:** `user_balance_stats_grid.widget.dart`, `user_balance_loading_state.widget.dart`, `user_balance_empty_state.widget.dart`, `user_balance_error_state.widget.dart`

- [ ] **Step 1:** `UserBalanceStatsGrid` — `Obx` on `paginated` + `listTransactionInfoFooter`; labels: `تعداد کل کاربران`, `مجموع مانده ریالی`, `مجموع طلا (گرم)`, `تعداد سکه`; responsive `Wrap`
- [ ] **Step 2:** Loading = `HaniGoldLoading.large()`; empty = dedicated copy + retry (`getListTransactionInfoPager`); error = `ErrPage` wrapper — **fixes bug** where `PageState.empty` currently falls through to error UI
- [ ] **Step 3:** `flutter analyze` on new files
- [ ] **Step 4:** Commit `feat(users): add KPI grid and page states`

**Global Constraints (binding):**
- Do not change API contracts, repository methods, or `*.g.dart` files
- Use `AppColor` and `AppTextStyle`
- Widget files under `lib/src/domain/users/widgets/list_user_info_transaction/`
- Use `UserBalancePageChrome` decorations from Task 1
- Use `buildUserBalanceKpis` from `user_balance_stats_helper.dart` for KPI values
- Controller: `UserInfoTransactionController` at `lib/src/domain/users/controller/user_info_transaction.controller.dart`
- `PageState` enum from base controller
- Loading widget: `HaniGoldLoading.large()`
- Error widget: wrap existing `ErrPage` pattern from codebase
- Empty state must call `getListTransactionInfoPager` on retry
