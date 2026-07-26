import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Total balance cell (تراز کل بس / بد) with scales icon.
class UserBalanceTotalCell {
  UserBalanceTotalCell._();

  static Widget creditSection({
    required ListTransactionInfoItemModel trans,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (trans.currencyValueBes ?? 0) > 0
            ? Column(
                children: [
                  SizedBox(height: 5),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/scales.svg',
                        height: 15,
                        colorFilter: ColorFilter.mode(
                          AppColor.primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        trans.currencyValueBes
                                ?.toStringAsFixed(0)
                                .seRagham() ??
                            '',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 10,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' ریال ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 8,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    height: 0.5,
                    color: AppColor.textColor,
                  ),
                  Row(
                    children: [
                      Text(
                        ' معادل آبشده : ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      (trans.goldValue ?? 0) < 0
                          ? Text(
                              '-${trans.goldValue?.abs().toStringAsFixed(3) ?? ''} ',
                              style: AppTextStyle.bodyText.copyWith(
                                fontSize: 9,
                                color: AppColor.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.ltr,
                            )
                          : Text(
                              ' ${trans.goldValue?.toStringAsFixed(3) ?? ''} ',
                              style: AppTextStyle.bodyText.copyWith(
                                fontSize: 9,
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      Text(
                        ' گرم ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 8,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        ' معادل سکه : ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      (trans.coinValue ?? 0) < 0
                          ? Text(
                              '-${trans.coinValue?.abs().toStringAsFixed(3) ?? ''} ',
                              style: AppTextStyle.bodyText.copyWith(
                                fontSize: 9,
                                color: AppColor.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.ltr,
                            )
                          : Text(
                              ' ${trans.coinValue?.toStringAsFixed(3) ?? ''} ',
                              style: AppTextStyle.bodyText.copyWith(
                                fontSize: 9,
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      Text(
                        ' عدد ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 8,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              )
            : SizedBox.shrink(),
      ],
    );
  }

  static Widget debitSection({
    required ListTransactionInfoItemModel trans,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (trans.currencyValueBed ?? 0) < 0
            ? Column(
                children: [
                  SizedBox(height: 5),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/scales.svg',
                        height: 15,
                        colorFilter: ColorFilter.mode(
                          AppColor.accentColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '-${trans.currencyValueBed?.abs().toStringAsFixed(0).seRagham() ?? ''}',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 10,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      Text(
                        ' ریال ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 8,
                          color: AppColor.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    height: 0.5,
                    color: AppColor.textColor,
                  ),
                  Row(
                    children: [
                      Text(
                        ' معادل آبشده : ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      (trans.goldValue ?? 0) < 0
                          ? Text(
                              '-${trans.goldValue?.abs().toStringAsFixed(3) ?? ''} ',
                              style: AppTextStyle.bodyText.copyWith(
                                fontSize: 9,
                                color: AppColor.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.ltr,
                            )
                          : Text(
                              ' ${trans.goldValue?.toStringAsFixed(3) ?? ''} ',
                              style: AppTextStyle.bodyText.copyWith(
                                fontSize: 9,
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      Text(
                        ' گرم ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 8,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        ' معادل سکه : ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 9,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      (trans.coinValue ?? 0) < 0
                          ? Text(
                              '-${trans.coinValue?.abs().toStringAsFixed(3) ?? ''} ',
                              style: AppTextStyle.bodyText.copyWith(
                                fontSize: 9,
                                color: AppColor.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.ltr,
                            )
                          : Text(
                              ' ${trans.coinValue?.toStringAsFixed(3) ?? ''} ',
                              style: AppTextStyle.bodyText.copyWith(
                                fontSize: 9,
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      Text(
                        ' عدد ',
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 8,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
