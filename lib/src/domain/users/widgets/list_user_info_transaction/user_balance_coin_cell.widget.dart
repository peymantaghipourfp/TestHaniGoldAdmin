import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
import 'package:hanigold_admin/src/utils/num_display.dart';

/// Coin balance cell (بستانکار / بدهکار).
class UserBalanceCoinCell {
  UserBalanceCoinCell._();

  static Widget creditSection({
    required ListTransactionInfoItemModel trans,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        trans.coinBalanceBes == 0
            ? SizedBox()
            : Column(
                children: [
                  Row(
                    children: [
                      Text(
                        ' تمام سکه ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        trans.coinBalanceBes?.toDisplayString() ?? '',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 11,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      Text(
                        ' عدد ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        ' نیم سکه ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        trans.halfCoinBalanceBes?.toDisplayString() ?? '',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 11,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      Text(
                        ' عدد ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        ' ربع سکه ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        trans.quarterCoinBalanceBes?.toDisplayString() ?? '',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 11,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      Text(
                        ' عدد ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ],
    );
  }

  static Widget debitSection({
    required ListTransactionInfoItemModel trans,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        trans.coinBalanceBed == 0
            ? SizedBox()
            : Column(
                children: [
                  Row(
                    children: [
                      Text(
                        ' تمام سکه ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '-${trans.coinBalanceBed?.abs().toDisplayString()}',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 11,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      Text(
                        ' عدد ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        ' نیم سکه ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '-${trans.halfCoinBalanceBed?.abs().toDisplayString()}',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 11,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      Text(
                        ' عدد ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        ' ربع سکه ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '-${trans.quarterCoinBalanceBed?.abs().toDisplayString()}',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 11,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      Text(
                        ' عدد ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ],
    );
  }
}
