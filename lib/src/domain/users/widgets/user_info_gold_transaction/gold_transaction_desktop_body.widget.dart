import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_data_table.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_toolbar.widget.dart';

/// Desktop panel shell: toolbar → spacer → fit-width [GoldTransactionDataTable].
///
/// Intentionally has no [SingleChildScrollView] with [Axis.horizontal].
class GoldTransactionDesktopBody extends StatelessWidget {
  const GoldTransactionDesktopBody({
    super.key,
    required this.controller,
  });

  final UserInfoDetailGoldTransactionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 20),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 20),
      color: AppColor.backGroundColor1.withAlpha(150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GoldTransactionToolbar(controller: controller),
          const SizedBox(height: 10),
          GoldTransactionDataTable(controller: controller),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
