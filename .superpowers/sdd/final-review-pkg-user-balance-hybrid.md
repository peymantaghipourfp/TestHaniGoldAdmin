# Final Review Package - User Balance Hybrid UI
No-git workspace; working-tree deliverable inventory

## Inventory
- widgets/user_balance_data_table.widget.dart (1607 lines)
- widgets/user_balance_desktop_body.widget.dart (56 lines)
- widgets/user_balance_empty_state.widget.dart (64 lines)
- widgets/user_balance_error_state.widget.dart (23 lines)
- widgets/user_balance_excel_dialog.widget.dart (182 lines)
- widgets/user_balance_footer.widget.dart (736 lines)
- widgets/user_balance_loading_state.widget.dart (14 lines)
- widgets/user_balance_mobile_list.widget.dart (499 lines)
- widgets/user_balance_page_chrome.dart (31 lines)
- widgets/user_balance_polarity_chip.widget.dart (36 lines)
- widgets/user_balance_search_bar.widget.dart (60 lines)
- widgets/user_balance_stats_grid.widget.dart (134 lines)
- widgets/user_balance_stats_helper.dart (39 lines)
- widgets/user_balance_toolbar.widget.dart (170 lines)
- view/list_user_info_transaction.view.dart (141 lines)
- test/user_balance_stats_helper_test.dart (92 lines)

## Progress ledger
# Progress Ledger - User Balance Hybrid UI
Plan: c:\Users\Admin\.cursor\plans\user_balance_hybrid_ui_d79ddc4c.plan.md
Started: 2026-07-13
Note: No-git workspace; no commits. Reviews use working-tree diffs.
Model: cursor-grok-4.5-high (user-requested)

Task 1: complete (no-git working tree, review clean - Approved)
Task 2: complete (no-git working tree, review clean - Approved)
Minor (carry to final): stats grid Wrap unbounded-width risk when parent lacks constraints
Task 3: complete (no-git working tree, review clean - Approved)
Minor (carry): filter dialog shell radius 8; excel isLoading not Obx (monolith parity)
Task 4: complete (no-git working tree, review clean - Approved)
Minor (carry): no dedicated row hover; large extracted table file (~1607 lines)
Task 5: complete (no-git working tree, review clean - Approved)
Minor (carry): euro debit positiveValue quirk (monolith parity); nested scroll
Task 6: complete (no-git working tree, review clean - Approved)
Note: view ~580 lines until Task 7 extracts mobile list
Task 7: complete (no-git working tree, review clean - Approved; analyze+test re-verified by controller)
Manual smoke: PENDING_HUMAN
Task 6: complete (no-git working tree)
Minor (carry): mobile list still inlined (~580 view lines); sort header not Obx-wrapped



## View file (full)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_desktop_body.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_empty_state.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_error_state.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_loading_state.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_mobile_list.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_search_bar.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_grid.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_toolbar.widget.dart';
import 'package:hanigold_admin/src/widget/app_drawer.widget.dart';
import 'package:hanigold_admin/src/widget/background_image_total.widget.dart';
import 'package:hanigold_admin/src/widget/chat_floating_button.widget.dart';
import 'package:hanigold_admin/src/widget/custom_appbar1.widget.dart';
import 'package:hanigold_admin/src/widget/pager_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ListUserInfoTransactionView
    extends GetView<UserInfoTransactionController> {
  const ListUserInfoTransactionView({super.key});

  void _onRetry() {
    controller.clearSearch();
    controller.getListTransactionInfoPager();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    return Scaffold(
      appBar: CustomAppbar1(
        title: 'مانده کاربران',
        onBackTap: () => Get.toNamed('/home'),
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          const BackgroundImageTotal(),
          SafeArea(
            child: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(controller.state.value),
                  child: _buildStateBody(isDesktop),
                ),
              ),
            ),
          ),
          if (isDesktop)
            Obx(() {
              if (controller.state.value != PageState.list ||
                  controller.paginated.value == null) {
                return const SizedBox.shrink();
              }
              return _buildDesktopPagerOverlay();
            }),
        ],
      ),
      floatingActionButton: const ChatFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStateBody(bool isDesktop) {
    switch (controller.state.value) {
      case PageState.loading:
        return const UserBalanceLoadingState();
      case PageState.empty:
        return UserBalanceEmptyState(onRetry: _onRetry);
      case PageState.err:
        return UserBalanceErrorState(onRetry: _onRetry);
      case PageState.list:
        return _buildListBody(isDesktop);
    }
  }

  Widget _buildListBody(bool isDesktop) {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: SingleChildScrollView(
        controller: isDesktop ? null : controller.scrollControllerMobile,
        child: Column(
          children: [
            if (isDesktop)
              UserBalanceDesktopBody(controller: controller)
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: UserBalanceSearchBar(
                  controller: controller,
                  maxWidth: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: UserBalanceStatsGrid(controller: controller),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: UserBalanceToolbar(
                  controller: controller,
                  isDesktop: false,
                ),
              ),
              UserBalanceMobileList(controller: controller),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopPagerOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: UserBalancePageChrome.toolbarDecoration(
            color: AppColor.appBarColor,
          ),
          alignment: Alignment.bottomCenter,
          child: PagerWidget(
            countPage: controller.paginated.value?.totalCount ?? 0,
            callBack: (int index) {
              controller.isChangePage(index);
            },
          ),
        ),
      ],
    );
  }
}

```

## Desktop body + helper signatures (grep)
### user_balance_desktop_body.widget.dart
10:class UserBalanceDesktopBody extends StatelessWidget {
### user_balance_stats_helper.dart
3:class UserBalanceKpiSnapshot {
17:UserBalanceKpiSnapshot buildUserBalanceKpis({
### user_balance_page_chrome.dart
5:class UserBalancePageChrome {
8:static const double radiusLg = 16;
9:static const double radiusMd = 12;
10:static const Color slateBorder = Color(0xFF64748B);
12:static BoxDecoration panelDecoration({Color? color}) => BoxDecoration(
26:static BoxDecoration toolbarDecoration({Color? color}) => BoxDecoration(
### user_balance_data_table.widget.dart
13:class UserBalanceDataTable extends StatelessWidget {
1582:class _RowNumChip extends StatelessWidget {
### user_balance_footer.widget.dart
11:class UserBalanceFooter extends StatelessWidget {
### user_balance_mobile_list.widget.dart
15:class UserBalanceMobileList extends StatelessWidget {
### user_balance_toolbar.widget.dart
14:class UserBalanceToolbar extends StatelessWidget {

## Controller mtime / PageState
mtime: 05/20/2026 10:08:39
25:enum PageState{loading,err,empty,list}
39:ScrollController scrollControllerMobile = ScrollController();
69:void onSort(int columnIndex, bool ascending) {
162:scrollControllerMobile.dispose();
167:scrollControllerMobile.addListener(() {
168:if (scrollControllerMobile.position.pixels >=
169:scrollControllerMobile.position.maxScrollExtent - 200 &&
172:loadMore();
176:Future<void> loadMore() async {
177:if (!scrollControllerMobile.hasClients || hasMore.value && !isLoading.value) {
349:Future<int> loadMoreOnMobile() async {
DataColumn count in data table: 12
