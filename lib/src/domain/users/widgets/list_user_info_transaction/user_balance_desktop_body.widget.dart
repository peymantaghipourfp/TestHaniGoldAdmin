import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
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
  });

  final UserInfoTransactionController controller;
  final Widget? footer;

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
          UserBalanceToolbar(controller: controller, isDesktop: true),
          const SizedBox(height: 12),
          UserBalanceDataTable(controller: controller),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}
