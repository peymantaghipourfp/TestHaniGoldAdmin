import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_report_gold.model.dart';

/// Compact invoice actions (icon buttons + tooltips).
class GoldTransactionInvoiceCell extends StatelessWidget {
  const GoldTransactionInvoiceCell({
    super.key,
    required this.controller,
    required this.trans,
  });

  final UserInfoDetailGoldTransactionController controller;
  final TransactionReportGoldModel trans;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: 'صدور فاکتور با مانده',
            child: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () async {
                await controller.generateInvoiceForGoldTransaction(trans);
              },
              icon: Icon(
                Icons.receipt_long,
                size: 18,
                color: AppColor.secondary2Color.withGreen(150),
              ),
            ),
          ),
          Tooltip(
            message: 'صدور فاکتور بدون مانده',
            child: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () async {
                await controller
                    .generateInvoiceForGoldTransactionWithoutBalance(trans);
              },
              icon: Icon(
                Icons.receipt,
                size: 18,
                color: AppColor.secondary2Color.withGreen(110),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
