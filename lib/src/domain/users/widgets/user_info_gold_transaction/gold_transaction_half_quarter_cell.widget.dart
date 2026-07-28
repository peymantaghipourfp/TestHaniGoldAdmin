import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_report_gold.model.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// نیم/ربع debit / credit / running-balance (item.id 3 = نیم, 4 = ربع).
/// Polarity sections stack نیم above ربع vertically.
class GoldTransactionHalfQuarterCell {
  GoldTransactionHalfQuarterCell._();

  static Widget creditSection({required TransactionReportGoldModel trans}) {
    final amount = trans.amount;
    final itemId = trans.item?.id;
    final half = itemId == 3 && amount != null && amount > 0
        ? '${amount.toStringAsFixed(0).seRagham()} نیم '
        : '';
    final quarter = itemId == 4 && amount != null && amount > 0
        ? '${amount.toStringAsFixed(0).seRagham()} ربع '
        : '';
    if (half.isEmpty && quarter.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (half.isNotEmpty)
          SelectableText(
            half,
            maxLines: 1,
            style: AppTextStyle.bodyText.copyWith(
              color: AppColor.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
        if (half.isNotEmpty && quarter.isNotEmpty)
          Divider(color: AppColor.dividerColor, height: 4),
        if (quarter.isNotEmpty)
          SelectableText(
            quarter,
            maxLines: 1,
            style: AppTextStyle.bodyText.copyWith(
              color: AppColor.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
      ],
    );
  }

  static Widget debitSection({required TransactionReportGoldModel trans}) {
    final amount = trans.amount;
    final itemId = trans.item?.id;
    final half = itemId == 3 && amount != null && amount < 0
        ? '(-${amount.abs().toStringAsFixed(0).seRagham()})نیم '
        : '';
    final quarter = itemId == 4 && amount != null && amount < 0
        ? '(-${amount.abs().toStringAsFixed(0).seRagham()})ربع '
        : '';
    if (half.isEmpty && quarter.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (half.isNotEmpty)
          SelectableText(
            half,
            maxLines: 1,
            style: AppTextStyle.bodyText.copyWith(
              color: AppColor.accentColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
        if (half.isNotEmpty && quarter.isNotEmpty)
          Divider(color: AppColor.dividerColor, height: 4),
        if (quarter.isNotEmpty)
          SelectableText(
            quarter,
            maxLines: 1,
            style: AppTextStyle.bodyText.copyWith(
              color: AppColor.accentColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
      ],
    );
  }

  static Widget balanceSection({required TransactionReportGoldModel trans}) {
    final halfRunning = trans.halfCoinTotalRunning;
    final quarterRunning = trans.quarterCoinTotalRunning;

    final halfText = halfRunning == null
        ? ''
        : halfRunning < 0
            ? '(-${halfRunning.abs().toStringAsFixed(0).seRagham()})نیم '
            : halfRunning > 0
                ? '${halfRunning.toStringAsFixed(0).seRagham()} نیم '
                : '';
    final quarterText = quarterRunning == null
        ? ''
        : quarterRunning < 0
            ? '(-${quarterRunning.abs().toStringAsFixed(0).seRagham()}) ربع '
            : quarterRunning > 0
                ? '${quarterRunning.toStringAsFixed(0).seRagham()} ربع '
                : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(
          halfText,
          maxLines: 1,
          style: AppTextStyle.bodyText.copyWith(
            color: (halfRunning ?? 0) > 0
                ? AppColor.primaryColor
                : (halfRunning ?? 0) < 0
                    ? AppColor.accentColor
                    : AppColor.textColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.ltr,
        ),
        if (halfText.isNotEmpty || quarterText.isNotEmpty)
          Divider(color: AppColor.dividerColor, height: 4),
        SelectableText(
          quarterText,
          maxLines: 1,
          style: AppTextStyle.bodyText.copyWith(
            color: (quarterRunning ?? 0) > 0
                ? AppColor.primaryColor
                : (quarterRunning ?? 0) < 0
                    ? AppColor.accentColor
                    : AppColor.textColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}
