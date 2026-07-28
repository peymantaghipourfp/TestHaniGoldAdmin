import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_report_gold.model.dart';
import 'package:hanigold_admin/src/utils/num_display.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// وزن یا تعداد cell — ports amount display rules from the ledger view.
class GoldTransactionQtyCell extends StatelessWidget {
  const GoldTransactionQtyCell({
    super.key,
    required this.trans,
  });

  final TransactionReportGoldModel trans;

  @override
  Widget build(BuildContext context) {
    if (trans.item?.id == 6) {
      return const SizedBox.shrink();
    }

    final amount = trans.amount;
    final unitId = trans.item?.itemUnit?.id;
    final String text;
    if (unitId == 1 && amount != null && amount > 0) {
      text = amount.toStringAsFixed(0).seRagham();
    } else if (unitId == 1 && amount != null && amount < 0) {
      text = '(-${amount.abs().toStringAsFixed(0).seRagham()})';
    } else if (unitId == 2 && amount != null && amount > 0) {
      text = '${amount.toDisplayString().seRagham()} ';
    } else if (unitId == 2 && amount != null && amount < 0) {
      text = '(-${amount.abs().toDisplayString().seRagham()})';
    } else if (unitId == 3 && amount != null && amount > 0) {
      text = '${amount.toStringAsFixed(0).seRagham()} ';
    } else if (unitId == 3 && amount != null && amount < 0) {
      text = '(-${amount.abs().toStringAsFixed(0).seRagham()})';
    } else {
      text = '${amount?.toStringAsFixed(2).seRagham() ?? ''} ';
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectableText(
            text,
            maxLines: 1,
            style: AppTextStyle.bodyText.copyWith(
              color: (amount ?? 0) > 0
                  ? AppColor.primaryColor
                  : AppColor.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}
