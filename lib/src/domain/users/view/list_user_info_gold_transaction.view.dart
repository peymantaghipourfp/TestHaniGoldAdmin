import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/domain/users/widgets/filter_dialog_report_setting_gold.widget.dart';
import 'package:hanigold_admin/src/widget/custom_appbar1.widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../widget/app_drawer.widget.dart';
import '../../../widget/background_image_total.widget.dart';
import '../../../widget/chat_floating_button.widget.dart';
import '../../../widget/pager_widget.dart';
import '../controller/user_info_gold_transaction.controller.dart';
import '../widgets/list_user_info_transaction/user_balance_desktop_body.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_empty_state.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_error_state.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_footer.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_loading_state.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_mobile_list.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_search_bar.widget.dart';

class ListUserInfoGoldTransactionView extends GetView<UserInfoGoldTransactionController> {
  const ListUserInfoGoldTransactionView({super.key});

  void _onRetry() {
    controller.clearSearch();
    controller.getListTransactionInfoPager();
  }

  Widget _buildFilterDialog(BuildContext context) {
    return FilterDialogGold(controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Obx(
      () => Scaffold(
        appBar: CustomAppbar1(
          title: 'مانده کاربران طلا',
          onBackTap: () => Get.toNamed('/home'),
        ),
        drawer: const AppDrawer(),
        body: Stack(
          children: [
            const BackgroundImageTotal(),
            SafeArea(
              child: switch (controller.state.value) {
                PageState.loading => const UserBalanceLoadingState(),
                PageState.empty => UserBalanceEmptyState(onRetry: _onRetry),
                PageState.err => UserBalanceErrorState(onRetry: _onRetry),
                PageState.list => _buildListBody(context, isDesktop),
              },
            ),
            if (isDesktop && controller.paginated.value != null) _buildPagerOverlay(),
          ],
        ),
        floatingActionButton: const ChatFloatingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildListBody(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return SizedBox(
        height: Get.height,
        width: Get.width,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: UserBalanceDesktopBody(
            controller: controller,
            footer: UserBalanceFooter(controller: controller),
            filterDialogBuilder: _buildFilterDialog,
            accountDetailRoute: '/userInfoGoldTransaction',
          ),
        ),
      );
    }

    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: SingleChildScrollView(
        controller: controller.scrollControllerMobile,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: UserBalanceSearchBar(
                searchController: controller.searchController,
                onSearch: controller.getListTransactionInfoPager,
                onClear: controller.clearSearch,
                compact: true,
              ),
            ),
            UserBalanceMobileList(
              controller: controller,
              filterDialogBuilder: _buildFilterDialog,
              accountDetailRoute: '/userInfoGoldTransaction',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagerOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.bottomCenter,
          child: PagerWidget(
            countPage: controller.paginated.value?.totalCount ?? 0,
            callBack: controller.isChangePage,
          ),
        ),
      ],
    );
  }
}
