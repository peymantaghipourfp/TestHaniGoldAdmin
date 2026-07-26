import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';

/// Gold balance cell (بستانکار / بدهکار) with installment breakdown.
class UserBalanceGoldCell {
  UserBalanceGoldCell._();

  static Widget creditSection({
    required BuildContext context,
    required ListTransactionInfoItemModel trans,
  }) {
    return (trans.goldBalanceBes ?? 0) > 0
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              trans.goldBalanceBes == 0
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
                                    'آبشده ',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 9,
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    trans.goldBalanceBes!.toStringAsFixed(3),
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 11,
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  Text(
                                    ' گرم ',
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
                                          (e) => e.unitName == 'گرم'
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
                                                      '${e.balance ?? 0} گرم ',
                                                      style: AppTextStyle
                                                          .labelText
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color: AppColor
                                                            .backGroundColor,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : SizedBox(),
                                        )
                                        .toList(),
                                  ),
                                  middleText: 'لیست مانده طلای بستانکار',
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
                        (trans.afterGoldBalance ?? 0) > 0
                            ? Divider(
                                height: 0.5,
                                color: AppColor.dividerColor,
                              )
                            : SizedBox.shrink(),
                        SizedBox(height: 5),
                        (trans.afterGoldBalance ?? 0) > 0
                            ? Column(
                                children: trans.balances!
                                    .map(
                                      (e) => e.unitName == 'گرم'
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
                                                            '${e.balance ?? 0}',
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
                                                          ),
                                                          Text(
                                                            ' گرم ',
                                                            style: AppTextStyle
                                                                .bodyText
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: AppColor
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
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
                                                                '-${e.balance?.abs() ?? 0}',
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
                                                                ' گرم ',
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

  static Widget debitSection({
    required BuildContext context,
    required ListTransactionInfoItemModel trans,
  }) {
    return (trans.goldBalanceBed ?? 0) < 0
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              trans.goldBalanceBed == 0
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
                                    'آبشده ',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 9,
                                      color: AppColor.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '-${trans.goldBalanceBed?.abs().toStringAsFixed(3) ?? ''}',
                                    style: AppTextStyle.bodyText.copyWith(
                                      fontSize: 11,
                                      color: AppColor.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  Text(
                                    ' گرم ',
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
                                          (e) => e.unitName == 'گرم'
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
                                                      '${e.balance ?? 0} گرم',
                                                      style: AppTextStyle
                                                          .labelText
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color: AppColor
                                                            .backGroundColor,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : SizedBox(),
                                        )
                                        .toList(),
                                  ),
                                  middleText: 'لیست مانده طلای بدهکار',
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
                        (trans.afterGoldBalance ?? 0) < 0
                            ? Divider(
                                height: 0.5,
                                color: AppColor.dividerColor,
                              )
                            : SizedBox.shrink(),
                        SizedBox(height: 5),
                        (trans.afterGoldBalance ?? 0) < 0
                            ? Column(
                                children: trans.balances!
                                    .map(
                                      (e) => e.unitName == 'گرم'
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
                                                            '${e.balance ?? 0}',
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
                                                          ),
                                                          Text(
                                                            ' گرم ',
                                                            style: AppTextStyle
                                                                .bodyText
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color: AppColor
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
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
                                                                '-${e.balance?.abs() ?? 0}',
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
                                                                ' گرم ',
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
