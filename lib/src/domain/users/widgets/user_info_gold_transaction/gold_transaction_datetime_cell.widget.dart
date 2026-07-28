import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_report_gold.model.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Merged تاریخ (above) + ساعت (below) cell.
class GoldTransactionDateTimeCell extends StatelessWidget {
  const GoldTransactionDateTimeCell({
    super.key,
    required this.trans,
  });

  final TransactionReportGoldModel trans;

  @override
  Widget build(BuildContext context) {
    final date = trans.date;
    final dateText = date?.toPersianDate() ?? 'نامشخص';
    final timeText = date != null
        ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}'
        : 'نامشخص';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText(
            '$dateText ',
            maxLines: 1,
            style: AppTextStyle.bodyText.copyWith(
              color: AppColor.textColor,
              fontSize: 11,
            ),
            textDirection: TextDirection.ltr,
          ),
          SelectableText(
            timeText,
            maxLines: 1,
            style: AppTextStyle.bodyText.copyWith(
              color: AppColor.textColor,
              fontSize: 11,
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}
