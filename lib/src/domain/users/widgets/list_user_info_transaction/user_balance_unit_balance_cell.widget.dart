import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
import 'package:hanigold_admin/src/utils/num_display.dart';

/// Simple بستانکار/بدهکار cell for a single unit balance pair.
class UserBalanceUnitBalanceCell {
  UserBalanceUnitBalanceCell._();

  static Widget creditSection({
    required double? balanceBes,
    required String unit,
    String? title,
  }) {
    if ((balanceBes ?? 0) <= 0) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title != null)
          Text(
            ' $title ',
            style: AppTextStyle.bodyText.copyWith(
              fontSize: 9,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          balanceBes!.toDisplayString(),
          style: AppTextStyle.bodyText.copyWith(
            fontSize: 11,
            color: AppColor.primaryColor,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.ltr,
        ),
        Text(
          ' $unit ',
          style: AppTextStyle.bodyText.copyWith(
            fontSize: 9,
            color: AppColor.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static Widget debitSection({
    required double? balanceBed,
    required String unit,
    String? title,
  }) {
    if (balanceBed == 0 || balanceBed == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title != null)
          Text(
            ' $title ',
            style: AppTextStyle.bodyText.copyWith(
              fontSize: 9,
              color: AppColor.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          '-${balanceBed.abs().toDisplayString()}',
          style: AppTextStyle.bodyText.copyWith(
            fontSize: 11,
            color: AppColor.accentColor,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.ltr,
        ),
        Text(
          ' $unit ',
          style: AppTextStyle.bodyText.copyWith(
            fontSize: 9,
            color: AppColor.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class UserBalanceDollarCell {
  UserBalanceDollarCell._();

  static Widget creditSection({required ListTransactionInfoItemModel trans}) {
    return UserBalanceUnitBalanceCell.creditSection(
      balanceBes: trans.dollarBalanceBes,
      unit: 'دلار',
      title: '',
    );
  }

  static Widget debitSection({required ListTransactionInfoItemModel trans}) {
    return UserBalanceUnitBalanceCell.debitSection(
      balanceBed: trans.dollarBalanceBed,
      unit: 'دلار',
      title: '',
    );
  }
}

class UserBalanceEuroCell {
  UserBalanceEuroCell._();

  static Widget creditSection({required ListTransactionInfoItemModel trans}) {
    return UserBalanceUnitBalanceCell.creditSection(
      balanceBes: trans.euroBalanceBes,
      unit: 'یورو',
      title: '',
    );
  }

  static Widget debitSection({required ListTransactionInfoItemModel trans}) {
    return UserBalanceUnitBalanceCell.debitSection(
      balanceBed: trans.euroBalanceBed,
      unit: 'یورو',
      title: '',
    );
  }
}

class UserBalanceSilverCell {
  UserBalanceSilverCell._();

  static Widget creditSection({required ListTransactionInfoItemModel trans}) {
    return UserBalanceUnitBalanceCell.creditSection(
      balanceBes: trans.silverBalanceBes,
      unit: 'گرم',
      title: 'نقره',
    );
  }

  static Widget debitSection({required ListTransactionInfoItemModel trans}) {
    return UserBalanceUnitBalanceCell.debitSection(
      balanceBed: trans.silverBalanceBed,
      unit: 'گرم',
      title: 'نقره',
    );
  }
}
