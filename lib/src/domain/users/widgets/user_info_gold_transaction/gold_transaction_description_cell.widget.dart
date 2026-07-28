import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_report_gold.model.dart';
import 'package:hanigold_admin/src/utils/num_display.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Type-branched description cell; all texts softWrap: false; width-constrained.
class GoldTransactionDescriptionCell extends StatelessWidget {
  const GoldTransactionDescriptionCell({
    super.key,
    required this.trans,
    this.maxWidth,
  });

  final TransactionReportGoldModel trans;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: ClipRect(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                          trans.type=="initial" ?
                          Row(
                            children: [
                              SelectableText(
                                maxLines: 1,
                                " ${trans.item?.name ?? ""} ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.secondary3Color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ):SizedBox.shrink(),
                          trans.type=="sell" || trans.type=="buy" ?
                          Row(
                            children: [
                              SelectableText(
                                maxLines: 1,
                                " ${trans.item?.name ?? ""} ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.secondary3Color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5,),
                              trans.item?.itemUnit?.id==2 ?
                              SelectableText(
                                maxLines: 1,
                                " وزن: ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ): trans.item?.itemUnit?.id==1 ?
                              SelectableText(
                                maxLines: 1,
                                " تعداد: ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ):
                              SelectableText(
                                maxLines: 1,
                                " مقدار: ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(textDirection: TextDirection.ltr,
                                maxLines: 1,
                                "${trans.amount?.toDisplayString() ?? ""}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color:trans.amount!>0 ? AppColor.primaryColor :trans.amount!<0 ?AppColor.accentColor:AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
                                maxLines: 1,
                                "${trans.item?.itemUnit?.name}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: trans.amount!>0 ? AppColor.primaryColor :trans.amount!<0 ?AppColor.accentColor:AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5,),
                              SelectableText(
                                maxLines: 1,
                                " قیمت: ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(textDirection: TextDirection.ltr,
                                maxLines: 1,
                                trans.mesghalPrice?.toStringAsFixed(0).seRagham(separator: ',') ?? "",
                                style: AppTextStyle.bodyText.copyWith(
                                  color: AppColor.dividerColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,),
                              ),
                            ],
                          ):SizedBox.shrink(),
                          trans.type=="receive" || trans.type=="payment" ?
                          Row(
                            children: [
                              SelectableText(
                                maxLines: 1,
                                " ${trans.item?.name ?? ""} ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.secondary3Color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5,),
                              trans.item?.itemUnit?.id==2 ?
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " وزن: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    "${trans.detail?.weight ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.dividerColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ): trans.item?.itemUnit?.id==1 ?
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " تعداد: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(textDirection: TextDirection.ltr,
                                    maxLines: 1,
                                    "${trans.amount?.toDisplayString() ?? " "}",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:trans.amount!>0 ? AppColor.primaryColor : trans.amount!<0 ? AppColor.accentColor :AppColor.textColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ):
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " مقدار: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    trans.amount?.toStringAsFixed(0).seRagham() ?? "",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.dividerColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              trans.item?.id==1 || trans.item?.id==10 ||trans.item?.id==12 ||trans.item?.id==13 ||trans.item?.id==14 ||trans.item?.id==15 ||trans.item?.id==16?
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " عیار: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    "${trans.detail?.carat ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.dividerColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ) : SizedBox.shrink(),
                              SizedBox(width: 5,),
                              trans.item?.id==1 ?
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " آز: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(textDirection: TextDirection.ltr,
                                    maxLines: 1,
                                    "${trans.detail?.name ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.dividerColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ) : SizedBox.shrink(),
                              SizedBox(width: 5,),
                              trans.item?.id==1 ?
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " ش ق: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(textDirection: TextDirection.ltr,
                                    maxLines: 1,
                                    trans.detail?.receiptNumber ?? "",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.dividerColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ) : SizedBox.shrink(),
                            ],
                          ):SizedBox.shrink(),
                          trans.type=="issue" ?
                          Row(
                            children: [
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " از: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    "${trans.account?.name ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.accentColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " به: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    trans.toAccount.name ?? "",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.primaryColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              SelectableText(
                                maxLines: 1,
                                " ${trans.item?.name ?? ""} ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.secondary3Color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5,),
                              trans.item?.itemUnit?.id==2 ?
                              SelectableText(
                                maxLines: 1,
                                " وزن: ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ): trans.item?.itemUnit?.id==1 ?
                              SelectableText(
                                maxLines: 1,
                                " تعداد: ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ):
                              SelectableText(
                                maxLines: 1,
                                " مقدار: ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(textDirection: TextDirection.ltr,
                                maxLines: 1,
                                "-${trans.amount?.abs().toDisplayString().seRagham() ?? ""}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color:trans.amount!>0 ? AppColor.primaryColor :trans.amount!<0 ?AppColor.accentColor:AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
                                maxLines: 1,
                                "${trans.item?.itemUnit?.name}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: trans.amount!>0 ? AppColor.primaryColor :trans.amount!<0 ?AppColor.accentColor:AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ):SizedBox.shrink(),
                          trans.type=="reciept" ?
                          Row(
                            children: [
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " از: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    trans.toAccount.name ?? "",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.accentColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " به: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    "${trans.account?.name ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.primaryColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              SelectableText(
                                maxLines: 1,
                                " ${trans.item?.name ?? ""} ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.secondary3Color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5,),
                              trans.item?.itemUnit?.id==2 ?
                              SelectableText(
                                maxLines: 1,
                                " وزن: ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ): trans.item?.itemUnit?.id==1 ?
                              SelectableText(
                                maxLines: 1,
                                " تعداد: ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ):
                              SelectableText(
                                maxLines: 1,
                                " مقدار: ",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: AppColor.textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(textDirection: TextDirection.ltr,
                                maxLines: 1,
                                "${trans.amount?.toDisplayString().seRagham() ?? ""}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color:trans.amount!>0 ? AppColor.primaryColor :trans.amount!<0 ?AppColor.accentColor:AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
                                maxLines: 1,
                                "${trans.item?.itemUnit?.name}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: trans.amount!>0 ? AppColor.primaryColor :trans.amount!<0 ?AppColor.accentColor:AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ):SizedBox.shrink(),
                          trans.type=="deposit" ?
                          Row(
                            children: [
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " مبلغ: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    "${trans.amount?.toStringAsFixed(0).seRagham() ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.primaryColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    " ریال ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    "(${trans.description ?? ""})",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.dividerColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " ش پ: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    trans.trackingNumber ?? "",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.dividerColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ):SizedBox.shrink(),
                          trans.type=="withdraw" ?
                          Row(
                            children: [
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " مبلغ: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(textDirection: TextDirection.ltr,
                                    maxLines: 1,
                                    "-${trans.amount?.abs().toStringAsFixed(0).seRagham() ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.accentColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    " ریال ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    "(${trans.description ?? ""})",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.dividerColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    maxLines: 1,
                                    " ش پ: ",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color: AppColor.textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    maxLines: 1,
                                    trans.trackingNumber ?? "",
                                    style: AppTextStyle.bodyText.copyWith(
                                        color:AppColor.dividerColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ):SizedBox.shrink(),
                          /*Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: trans.detail!
                      .map((e) => Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColor.textColor),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SelectableText(
                                  maxLines: 1,
                                  "وزن ترازو : ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .appBarColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                SelectableText(
                                  maxLines: 1,
                                  "${e.weight ?? 0} گرم ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .iconViewColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SelectableText(
                                  maxLines: 1,
                                  "عیار : ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .appBarColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                SelectableText(
                                  maxLines: 1,
                                  "${e.carat ?? 0} ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .iconViewColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SelectableText(
                                  maxLines: 1,
                                  "وزن : ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .appBarColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                SelectableText(
                                  maxLines: 1,
                                  "${e.quantity ?? 0} گرم ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .iconViewColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SelectableText(
                                  maxLines: 1,
                                  "ناخالصی : ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .appBarColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                SelectableText(
                                  maxLines: 1,
                                  "${e.impurity ?? 0} گرم ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .iconViewColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SelectableText(
                                  maxLines: 1,
                                  "آزمایشگاه : ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .appBarColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                SelectableText(
                                  maxLines: 1,
                                  "${e.laboratoryName ?? ""} ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .iconViewColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SelectableText(
                                  maxLines: 1,
                                  "شماره آزمایشگاه : ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .appBarColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                SelectableText(
                                  maxLines: 1,
                                  "${e.receiptNumber ?? ""} ",
                                  style: AppTextStyle.bodyText
                                      .copyWith(
                                      color: AppColor
                                          .iconViewColor,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
