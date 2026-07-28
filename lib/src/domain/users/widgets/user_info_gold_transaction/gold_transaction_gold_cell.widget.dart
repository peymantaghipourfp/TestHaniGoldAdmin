import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_report_gold.model.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// طلا debit / credit / running-balance sections (itemUnit.id == 2).
class GoldTransactionGoldCell {
  GoldTransactionGoldCell._();

  static Widget creditSection({required TransactionReportGoldModel trans}) {
    final amount = trans.amount;
    if (trans.item?.itemUnit?.id != 2) {
      return const SizedBox.shrink();
    }
    return SelectableText(
      amount != null && amount > 0
          ? amount.toStringAsFixed(3).seRagham()
          : '',
      maxLines: 1,
      style: AppTextStyle.bodyText.copyWith(
        color: (amount ?? 0) > 0 ? AppColor.primaryColor : AppColor.textColor,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      textDirection: TextDirection.ltr,
    );
  }

  static Widget debitSection({required TransactionReportGoldModel trans}) {
    final amount = trans.amount;
    if (trans.item?.itemUnit?.id != 2) {
      return const SizedBox.shrink();
    }
    return SelectableText(
      amount != null && amount < 0
          ? '(-${amount.abs().toStringAsFixed(3).seRagham()})'
          : '',
      maxLines: 1,
      style: AppTextStyle.bodyText.copyWith(
        color: (amount ?? 0) < 0 ? AppColor.accentColor : AppColor.textColor,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      textDirection: TextDirection.ltr,
    );
  }

  static Widget balanceSection({required TransactionReportGoldModel trans}) {
    final running = trans.goldTotalRunning;
    final text = running == null
        ? ''
        : running < 0
            ? '(-${running.abs().toStringAsFixed(3).seRagham()})'
            : running > 0
                ? running.toStringAsFixed(3).seRagham()
                : '';
    return SelectableText(
      text,
      maxLines: 1,
      style: AppTextStyle.bodyText.copyWith(
        color: (running ?? 0) > 0
            ? AppColor.primaryColor
            : (running ?? 0) < 0
                ? AppColor.accentColor
                : AppColor.textColor,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      textDirection: TextDirection.ltr,
    );
  }
}
