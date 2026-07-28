import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_balance_list_controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_data_table.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_grid.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_toolbar.widget.dart';

/// Desktop content stack: KPI cards → toolbar → grouped table → optional footer.
class UserBalanceDesktopBody extends StatelessWidget {
  const UserBalanceDesktopBody({
    super.key,
    required this.controller,
    this.footer,
    this.filterDialogBuilder,
    this.accountDetailRoute = '/userInfoTransaction',
  });

  final UserBalanceListController controller;
  final Widget? footer;
  final Widget Function(BuildContext context)? filterDialogBuilder;
  final String accountDetailRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 30),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 40),
      decoration: UserBalancePageChrome.panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserBalanceStatsGrid(controller: controller),
          const SizedBox(height: 12),
          UserBalanceToolbar(
            controller: controller,
            isDesktop: true,
            filterDialogBuilder: filterDialogBuilder,
          ),
          const SizedBox(height: 12),
          UserBalanceDataTable(
            controller: controller,
            accountDetailRoute: accountDetailRoute,
          ),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}
