import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
import 'package:hanigold_admin/src/utils/num_display.dart';

/// Foreign-currency balance cell (بستانکار / بدهکار) from [balances].
class UserBalanceCurrencyCell {
  UserBalanceCurrencyCell._();

  static Widget creditSection({
    required ListTransactionInfoItemModel trans,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        trans.balances!.isEmpty
            ? SizedBox()
            : Column(
                children: trans.balances!
                    .map(
                      (e) => Container(
                        child: e.unitName == 'دلار' && e.balance! > 0
                            ? Row(
                                children: [
                                  Text(
                                    ' ${e.itemName} ',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 9,
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    e.balance?.toDisplayString() ?? '',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 10,
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  Text(
                                    ' ${e.unitName} ',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 9,
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  SizedBox(width: 120),
                                ],
                              ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  static Widget debitSection({
    required ListTransactionInfoItemModel trans,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        trans.balances!.isEmpty
            ? SizedBox()
            : Column(
                children: trans.balances!
                    .map(
                      (e) => Container(
                        child: e.unitName == 'دلار' && e.balance! < 0
                            ? Row(
                                children: [
                                  Text(
                                    ' ${e.itemName} ',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 9,
                                      color: AppColor.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    e.balance?.toDisplayString() ?? '',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 10,
                                      color: AppColor.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  Text(
                                    ' ${e.unitName} ',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 9,
                                      color: AppColor.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  SizedBox(width: 120),
                                ],
                              ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}
