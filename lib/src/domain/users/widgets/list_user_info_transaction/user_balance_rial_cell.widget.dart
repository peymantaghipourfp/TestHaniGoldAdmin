import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Rial balance cell (بستانکار / بدهکار) with installment breakdown.
class UserBalanceRialCell {
  UserBalanceRialCell._();

  static Widget creditSection({
    required BuildContext context,
    required ListTransactionInfoItemModel trans,
  }) {
    return (trans.cashBalanceBes ?? 0) > 0
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              trans.cashBalanceBes == 0
                  ? SizedBox()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              child: Row(
                                children: [
                                  Text(
                                    'وجه نقد ',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 9,
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    trans.cashBalanceBes!
                                        .toStringAsFixed(0)
                                        .seRagham(),
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 12,
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  Text(
                                    ' ریال ',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 9,
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                  confirm: Column(
                                    children: trans.balances!
                                        .map(
                                          (e) => e.unitName == 'ریال'
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      e.itemName ?? '',
                                                      style: AppTextStyle
                                                          .labelText
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color: AppColor
                                                            .backGroundColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${e.balance?.toStringAsFixed(0).seRagham() ?? 0} ریال ',
                                                      style: AppTextStyle
                                                          .labelText
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color: AppColor
                                                            .backGroundColor,
                                                      ),
                                                      textDirection:
                                                          TextDirection.ltr,
                                                    ),
                                                  ],
                                                )
                                              : SizedBox(),
                                        )
                                        .toList(),
                                  ),
                                  middleText: 'لیست مانده ریال بستانکار',
                                  middleTextStyle: context
                                      .textTheme.bodyMedium!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 13,
                                  ),
                                  title: 'جزییات',
                                  titleStyle: context.textTheme.titleSmall!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 14,
                                  ),
                                  backgroundColor: AppColor.textColor,
                                  radius: 7,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                );
                              },
                              child: SvgPicture.asset(
                                'assets/svg/list.svg',
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  AppColor.textColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        (trans.afterCashBalance ?? 0) > 0
                            ? Divider(
                                height: 0.5,
                                color: AppColor.dividerColor,
                              )
                            : SizedBox.shrink(),
                        SizedBox(height: 5),
                        (trans.afterCashBalance ?? 0) > 0
                            ? Column(
                                children: trans.balances!
                                    .map(
                                      (e) => e.unitName == 'ریال'
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                (e.balance ?? 0) > 0
                                                    ? Row(
                                                        children: [
                                                          Text(
                                                            e.itemName ?? '',
                                                            style: AppTextStyle
                                                                .labelText
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: AppColor
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${e.balance?.toStringAsFixed(0).seRagham() ?? 0}',
                                                            style: AppTextStyle
                                                                .labelText
                                                                .copyWith(
                                                              fontSize: 12,
                                                              color: AppColor
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                          ),
                                                          Text(
                                                            ' ریال ',
                                                            style: AppTextStyle
                                                                .bodyText
                                                                .copyWith(
                                                              fontSize: 9,
                                                              color: AppColor
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                          ),
                                                        ],
                                                      )
                                                    : (e.balance ?? 0) < 0
                                                        ? Row(
                                                            children: [
                                                              Text(
                                                                e.itemName ??
                                                                    '',
                                                                style: AppTextStyle
                                                                    .labelText
                                                                    .copyWith(
                                                                  fontSize: 10,
                                                                  color: AppColor
                                                                      .accentColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                '-${e.balance?.abs().toStringAsFixed(0).seRagham() ?? 0}',
                                                                style: AppTextStyle
                                                                    .labelText
                                                                    .copyWith(
                                                                  fontSize: 12,
                                                                  color: AppColor
                                                                      .accentColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                textDirection:
                                                                    TextDirection
                                                                        .ltr,
                                                              ),
                                                              Text(
                                                                ' ریال ',
                                                                style: AppTextStyle
                                                                    .bodyText
                                                                    .copyWith(
                                                                  fontSize: 10,
                                                                  color: AppColor
                                                                      .accentColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : SizedBox.shrink(),
                                              ],
                                            )
                                          : SizedBox(),
                                    )
                                    .toList(),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
            ],
          )
        : SizedBox.shrink();
  }

  static Widget debitSection({
    required BuildContext context,
    required ListTransactionInfoItemModel trans,
  }) {
    return (trans.cashBalanceBed ?? 0) < 0
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              trans.cashBalanceBed == 0
                  ? SizedBox()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              child: Row(
                                children: [
                                  Text(
                                    'وجه نقد ',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 9,
                                      color: AppColor.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '-${trans.cashBalanceBed?.abs().toStringAsFixed(0).seRagham() ?? ''}',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 12,
                                      color: AppColor.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  Text(
                                    ' ریال ',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 9,
                                      color: AppColor.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                  confirm: Column(
                                    children: trans.balances!
                                        .map(
                                          (e) => e.unitName == 'ریال'
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      e.itemName ?? '',
                                                      style: AppTextStyle
                                                          .labelText
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color: AppColor
                                                            .backGroundColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      '-${e.balance?.abs().toStringAsFixed(0).seRagham() ?? 0} ریال ',
                                                      style: AppTextStyle
                                                          .labelText
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color: AppColor
                                                            .backGroundColor,
                                                      ),
                                                      textDirection:
                                                          TextDirection.ltr,
                                                    ),
                                                  ],
                                                )
                                              : SizedBox(),
                                        )
                                        .toList(),
                                  ),
                                  middleText: 'لیست مانده ریال بدهکار',
                                  middleTextStyle: context
                                      .textTheme.bodyMedium!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 13,
                                  ),
                                  title: 'جزییات',
                                  titleStyle: context.textTheme.titleSmall!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 14,
                                  ),
                                  backgroundColor: AppColor.textColor,
                                  radius: 7,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                );
                              },
                              child: SvgPicture.asset(
                                'assets/svg/list.svg',
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  AppColor.textColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        (trans.afterCashBalance ?? 0) < 0
                            ? Divider(
                                height: 0.5,
                                color: AppColor.dividerColor,
                              )
                            : SizedBox.shrink(),
                        SizedBox(height: 5),
                        (trans.afterCashBalance ?? 0) < 0
                            ? Column(
                                children: trans.balances!
                                    .map(
                                      (e) => e.unitName == 'ریال'
                                          ? Row(
                                              children: [
                                                (e.balance ?? 0) < 0
                                                    ? Row(
                                                        children: [
                                                          Text(
                                                            e.itemName ?? '',
                                                            style: AppTextStyle
                                                                .labelText
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: AppColor
                                                                  .accentColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            '-${e.balance?.abs().toStringAsFixed(0).seRagham() ?? 0}',
                                                            style: AppTextStyle
                                                                .labelText
                                                                .copyWith(
                                                              fontSize: 12,
                                                              color: AppColor
                                                                  .accentColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                          ),
                                                          Text(
                                                            ' ریال ',
                                                            style: AppTextStyle
                                                                .bodyText
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: AppColor
                                                                  .accentColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : (e.balance ?? 0) > 0
                                                        ? Row(
                                                            children: [
                                                              Text(
                                                                e.itemName ??
                                                                    '',
                                                                style: AppTextStyle
                                                                    .labelText
                                                                    .copyWith(
                                                                  fontSize: 10,
                                                                  color: AppColor
                                                                      .primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${e.balance?.toStringAsFixed(0).seRagham() ?? 0}',
                                                                style: AppTextStyle
                                                                    .labelText
                                                                    .copyWith(
                                                                  fontSize: 12,
                                                                  color: AppColor
                                                                      .primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                textDirection:
                                                                    TextDirection
                                                                        .ltr,
                                                              ),
                                                              Text(
                                                                ' ریال ',
                                                                style: AppTextStyle
                                                                    .bodyText
                                                                    .copyWith(
                                                                  fontSize: 9,
                                                                  color: AppColor
                                                                      .primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                textDirection:
                                                                    TextDirection
                                                                        .ltr,
                                                              ),
                                                            ],
                                                          )
                                                        : SizedBox.shrink(),
                                              ],
                                            )
                                          : SizedBox(),
                                    )
                                    .toList(),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
            ],
          )
        : SizedBox.shrink();
  }
}
