import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_report_gold.model.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_toolbar.widget.dart';
import 'package:hanigold_admin/src/utils/num_display.dart';
import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Mobile card list for per-account gold transactions (infinite-scroll footer).
class GoldTransactionMobileList extends StatelessWidget {
  const GoldTransactionMobileList({
    super.key,
    required this.controller,
  });

  final UserInfoDetailGoldTransactionController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.transactionInfoGoldList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColor.textColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'هیچ تراکنشی یافت نشد',
                style: AppTextStyle.labelText.copyWith(
                  fontSize: 16,
                  color: AppColor.textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      child: Column(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GoldTransactionToolbar(controller: controller),
          SizedBox(height: 2),
          ListView.builder(
            itemCount: controller.transactionInfoGoldList.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder:(ctx, index) {
              final trans = controller.transactionInfoGoldList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.only(top: 2,right: 15,left: 15,bottom: 12),
                decoration: BoxDecoration(
                  color: trans.checked == true
                      ? AppColor.backGroundColor.withAlpha(180)
                      : AppColor.secondaryColor.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF64748B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with checkbox and row number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${trans.rowNum ?? 0}",
                              style: AppTextStyle.bodyText.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Checkbox(
                              value: trans.checked ?? false,
                              onChanged: (value) async {
                                if (value != null) {
                                  await controller.updateGoldChecked(
                                      trans.id ?? 0,
                                      value
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMobileCardItem(
                              'تاریخ: ',
                              trans.date?.toPersianDate() ?? 'نامشخص',
                              AppColor.textColor,
                            ),
                            SizedBox(width: 10,),
                            _buildMobileCardItem(
                              'ساعت: ',
                              trans.date != null
                                  ? "${trans.date!.hour.toString().padLeft(2, '0')}:${trans.date!.minute.toString().padLeft(2, '0')}:${trans.date!.second.toString().padLeft(2, '0')}"
                                  : "نامشخص",
                              AppColor.textColor,
                            ),
                          ],
                        ),
                        _buildTransactionTypeChip(trans.type),
                      ],
                    ),
                    Divider(color: AppColor.iconViewColor,height: 0.5,),
                    const SizedBox(height: 5),
                    // Transaction details based on type
                    trans.type=="receive" || trans.type=="payment" ?
                    Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColor.textFieldColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF64748B)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "مقدار: ",
                            style:  AppTextStyle.bodyText,
                          ),
                          Text(
                            trans.item?.itemUnit?.id == 1 && trans.amount!>0
                                ? "${trans.amount?.toStringAsFixed(0).seRagham()}" :
                            trans.item?.itemUnit?.id == 1 && trans.amount!<0 ?
                            "(-${trans.amount?.abs().toStringAsFixed(0).seRagham()})"
                                : trans.item?.itemUnit?.id == 2 && trans.amount!>0
                                ? "${trans.amount?.toDisplayString().seRagham()} "
                                :trans.item?.itemUnit?.id == 2 && trans.amount!<0 ?
                            "(-${trans.amount?.abs().toDisplayString().seRagham()})"
                                :trans.item?.itemUnit?.id == 3 && trans.amount!>0 ?
                            "${trans.amount?.toStringAsFixed(0).seRagham()} " :
                            trans.item?.itemUnit?.id == 3 && trans.amount!<0 ?
                            "(-${trans.amount?.abs().toStringAsFixed(0).seRagham()})"
                                :"${trans.amount?.toStringAsFixed(2).seRagham()} ",
                            style: AppTextStyle.bodyText.copyWith(
                                color: trans.amount!>0 ? AppColor.primaryColor :AppColor.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ):
                        SizedBox.shrink(),
                    _buildTransactionDetails(trans),
                    // Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await controller.generateInvoiceForGoldTransaction(trans);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColor.secondary2Color.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColor.secondary2Color.withAlpha(75)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.receipt_long, size: 18, color: AppColor.secondary2Color),
                                  SizedBox(width: 6),
                                  Text(
                                    "فاکتور با مانده",
                                    style: AppTextStyle.labelText.copyWith(
                                      color: AppColor.secondary2Color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 4,),
                          GestureDetector(
                            onTap: () async {
                              await controller.generateInvoiceForGoldTransactionWithoutBalance(trans);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColor.secondary2Color.withAlpha(45),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColor.secondary2Color.withAlpha(100)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.receipt_long, size: 18, color: AppColor.secondary2Color),
                                  SizedBox(width: 6),
                                  Text(
                                    "فاکتور",
                                    style: AppTextStyle.labelText.copyWith(
                                      color: AppColor.secondary2Color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Description if available
                    if (trans.description != null && trans.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildMobileCardItem(
                          'توضیحات: ',
                          trans.description ?? "",
                          AppColor.dividerColor,
                        ),
                      ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColor.secondary3Color.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColor.textColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if(trans.item?.itemUnit?.id == 2 && (trans.amount ?? 0) != 0)
                              Row(
                                children: [
                                  trans.item?.itemUnit?.id == 2 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) < 0 ?
                                  _buildMobileCardItemTotal( AppColor.textAccentColor,"طلا بدهکار: ",
                                      "(-${trans.amount!.abs().toString().seRagham()})",
                                      AppColor.accentColor )
                                      :
                                  trans.item?.itemUnit?.id == 2 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) > 0 ?
                                  _buildMobileCardItemTotal( AppColor.textPrimaryColor,"طلا بستانکار: ",
                                    trans.amount!.toString().seRagham(),
                                    AppColor.primaryColor,)
                                      : SizedBox.shrink(),
                                ],
                              ),
                              Row(
                                children: [
                                  trans.item?.id == 6 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) < 0 ?
                                  _buildMobileCardItemTotal( AppColor.textAccentColor,"ریال بدهکار: ",
                                      "(-${trans.amount!.abs().toStringAsFixed(0).seRagham()})",
                                      AppColor.accentColor )
                                      : trans.type=="sell" ?
                                  _buildMobileCardItemTotal( AppColor.textAccentColor,"ریال بدهکار: ",
                                      "(-${trans.totalPrice!.abs().toStringAsFixed(0).seRagham()})",
                                      AppColor.accentColor )
                                  : trans.item?.id == 6 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) > 0 ?
                                  _buildMobileCardItemTotal( AppColor.textPrimaryColor,"ریال بستانکار: ",
                                    trans.amount!.toStringAsFixed(0).seRagham(),
                                    AppColor.primaryColor,)
                                      : trans.type=="buy" ?
                                  _buildMobileCardItemTotal( AppColor.textPrimaryColor,"ریال بستانکار: ",
                                    trans.totalPrice!.toStringAsFixed(0).seRagham(),
                                    AppColor.primaryColor,)
                                  : SizedBox.shrink(),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if(trans.item?.id==2 && (trans.amount ?? 0) != 0)
                                Row(
                                  children: [
                                    trans.item?.id==2 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) < 0 ?
                                    _buildMobileCardItemTotal( AppColor.textAccentColor,"تمام سکه بدهکار: ",
                                        "(-${trans.amount!.abs().toStringAsFixed(0).seRagham()})",
                                        AppColor.accentColor )
                                        :
                                    trans.item?.id==2 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) > 0 ?
                                    _buildMobileCardItemTotal( AppColor.textPrimaryColor,"تمام سکه بستانکار: ",
                                      trans.amount!.toStringAsFixed(0).seRagham(),
                                      AppColor.primaryColor,)
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              if(trans.item?.id==3 && (trans.amount ?? 0) != 0)
                                Row(
                                  children: [
                                    trans.item?.id==3 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) < 0 ?
                                    _buildMobileCardItemTotal( AppColor.textAccentColor,"نیم سکه بدهکار: ",
                                        "(-${trans.amount!.abs().toStringAsFixed(0).seRagham()})",
                                        AppColor.accentColor )
                                        :
                                    trans.item?.id==3 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) > 0 ?
                                    _buildMobileCardItemTotal( AppColor.textPrimaryColor,"نیم سکه بستانکار: ",
                                      trans.amount!.toStringAsFixed(0).seRagham(),
                                      AppColor.primaryColor,)
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              if(trans.item?.id==4 && (trans.amount ?? 0) != 0)
                                Row(
                                  children: [
                                    trans.item?.id==4 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) < 0 ?
                                    _buildMobileCardItemTotal( AppColor.textAccentColor,"ربع سکه بدهکار: ",
                                        "(-${trans.amount!.abs().toStringAsFixed(0).seRagham()})",
                                        AppColor.accentColor )
                                        :
                                    trans.item?.id==4 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) > 0 ?
                                    _buildMobileCardItemTotal( AppColor.textPrimaryColor,"ربع سکه بستانکار: ",
                                      trans.amount!.toStringAsFixed(0).seRagham(),
                                      AppColor.primaryColor,)
                                        : SizedBox.shrink(),
                                  ],
                                )
                            ],
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColor.dividerColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColor.textColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if((trans.goldTotalRunning ?? 0) != 0)
                                Expanded(
                                  child: _buildMobileCardItemTotal(AppColor.dividerColor,"مانده طلایی: ",
                                      (trans.goldTotalRunning ?? 0) < 0 ? "(-${trans.goldTotalRunning!.abs().toStringAsFixed(3).seRagham()})" : trans.goldTotalRunning!.toStringAsFixed(3).seRagham(),
                                      (trans.goldTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,),
                                ),
                              if((trans.cashTotalRunning ?? 0) != 0)
                                _buildMobileCardItemTotal(AppColor.dividerColor,"مانده ریالی: ",
                                  (trans.cashTotalRunning ?? 0) < 0 ? "(-${trans.cashTotalRunning!.abs().toStringAsFixed(0).seRagham()})" : trans.cashTotalRunning!.toStringAsFixed(0).seRagham(),
                                  (trans.cashTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if((trans.coinTotalRunning ?? 0) != 0)
                                _buildMobileCardItemTotal(AppColor.dividerColor,"مانده تمام سکه: ",
                                  (trans.coinTotalRunning ?? 0) < 0 ? "(-${trans.coinTotalRunning!.abs().toStringAsFixed(0)})" : trans.coinTotalRunning!.toStringAsFixed(0),
                                  (trans.coinTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,),
                              if((trans.halfCoinTotalRunning ?? 0) != 0)
                                _buildMobileCardItemTotal(AppColor.dividerColor,"مانده نیم: ",
                                    (trans.halfCoinTotalRunning ?? 0) < 0 ? "(-${trans.halfCoinTotalRunning!.abs().toStringAsFixed(0)})" : trans.halfCoinTotalRunning!.toStringAsFixed(0),
                                    (trans.halfCoinTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,),
                              if((trans.quarterCoinTotalRunning ?? 0) != 0)
                                _buildMobileCardItemTotal(AppColor.dividerColor,"مانده ربع: ",
                                  (trans.quarterCoinTotalRunning ?? 0) < 0 ? "(-${trans.quarterCoinTotalRunning!.abs().toStringAsFixed(0)})" : trans.quarterCoinTotalRunning!.toStringAsFixed(0),
                                  (trans.quarterCoinTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,),
                            ],
                          )

                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Obx(() {
            if (controller.isLoading.value && controller.transactionInfoGoldList.isNotEmpty) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: HaniGoldLoading(),
                ),
              );
            }

            if (!controller.hasMore.value && controller.transactionInfoGoldList.isNotEmpty) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  "همه تراکنش‌ها نمایش داده شد",
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyText.copyWith(
                    color: AppColor.textColor.withOpacity(0.7),
                  ),
                ),
              );
            }

            return SizedBox.shrink();
          }),
          SizedBox(height: 20),
        ]
      ),
    );
  }

  Widget _buildTransactionTypeChip(String? type) {
    String typeText = '';
    Color chipColor = AppColor.textColor;

    switch (type) {
      case 'issue':
        typeText = 'حواله دریافتی';
        chipColor = const Color(0xFF3B82F6);
        break;
      case 'receive':
        typeText = 'دریافت';
        chipColor = const Color(0xFF10B981);
        break;
      case 'payment':
        typeText = 'پرداخت';
        chipColor = const Color(0xFFEF4444);
        break;
      case 'sell':
        typeText = 'فروش';
        chipColor = const Color(0xFFF59E0B);
        break;
      case 'buy':
        typeText = 'خرید';
        chipColor = const Color(0xFF10B981);
        break;
      case 'deposit':
        typeText = 'واریز';
        chipColor = const Color(0xFF8B5CF6);
        break;
      case 'withdraw':
        typeText = 'برداشت';
        chipColor = const Color(0xFFEF4444);
        break;
      case 'reciept':
        typeText = 'حواله پرداختی';
        chipColor = const Color(0xFF3B82F6);
        break;
      case 'initial':
        typeText = 'اول دوره';
        chipColor = const Color(0xFF6B7280);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        typeText,
        style: AppTextStyle.labelText.copyWith(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTransactionDetails(TransactionReportGoldModel trans) {
    switch (trans.type) {
      case 'initial':
        return _buildInitialTransactionDetails(trans);
      case 'sell':
      case 'buy':
        return _buildSellBuyTransactionDetails(trans);
      case 'receive':
      case 'payment':
        return _buildReceivePaymentTransactionDetails(trans);
      case 'issue':
        return _buildIssueTransactionDetails(trans);
      case 'reciept':
        return _buildReceiptTransactionDetails(trans);
      case 'deposit':
        return _buildDepositTransactionDetails(trans);
      case 'withdraw':
        return _buildWithdrawTransactionDetails(trans);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInitialTransactionDetails(TransactionReportGoldModel trans) {
    return _buildMobileCardItem(
      'آیتم: ',
      trans.item?.name ?? "",
      AppColor.secondary3Color,
    );
  }

  Widget _buildSellBuyTransactionDetails(TransactionReportGoldModel trans) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'آیتم: ',
                trans.item?.name ?? "",
                AppColor.secondary3Color,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                   _buildMobileCardItem(
                      trans.item?.itemUnit?.id == 2 ? 'وزن: ' :
                      trans.item?.itemUnit?.id == 1 ? 'تعداد: ' : 'مقدار: ',
                      (trans.amount ?? 0) < 0 ? "-${trans.amount?.abs().toString().seRagham() ?? "" }" : trans.amount?.toString().seRagham() ?? "",
                      (trans.amount ?? 0) > 0 ? AppColor.primaryColor :
                      (trans.amount ?? 0) < 0 ? AppColor.accentColor : AppColor.textColor,
                    ),
                  Text(
                    " ${trans.item?.itemUnit?.name ?? ""}",
                    style:  AppTextStyle.labelText,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                 _buildMobileCardItem(
                    'قیمت: ',
                    trans.mesghalPrice?.toString().seRagham() ?? "",
                    AppColor.dividerColor,
                  ),
                Text(
                  ' ریال',
                  style: AppTextStyle.bodyText,
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildReceivePaymentTransactionDetails(TransactionReportGoldModel trans) {
    return Column(
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'آیتم: ',
                trans.item?.name ?? "",
                AppColor.secondary3Color,
              ),
            ),
            Expanded(
              child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   _buildMobileCardItem(
                      trans.item?.itemUnit?.id == 2 ? 'وزن: ' :
                      trans.item?.itemUnit?.id == 1 ? 'تعداد: ' : 'مقدار: ',
                     trans.item?.itemUnit?.id == 2 ? "${trans.detail?.weight ?? ""}" : trans.item?.itemUnit?.id == 1 ?
                     "${trans.amount ?? " "}" : trans.amount?.toString().seRagham() ?? "",
                      //(trans.amount ?? 0) < 0 ? "-${trans.amount?.abs().toString().seRagham() ?? ""}" : trans.amount?.toString().seRagham() ?? "",
                      (trans.amount ?? 0) > 0 ? AppColor.primaryColor :
                      (trans.amount ?? 0) < 0 ? AppColor.accentColor : AppColor.textColor,
                    ),
                  Text(
                    " ${trans.item?.itemUnit?.name ?? ""}",
                    style:  AppTextStyle.labelText,
                  ),
                ],
              ),
            ),
            if (trans.item?.id == 1 || trans.item?.id == 10 || trans.item?.id == 12 ||
                trans.item?.id == 13 || trans.item?.id == 14 || trans.item?.id == 15 || trans.item?.id == 16)
              Expanded(
                child: _buildMobileCardItem(
                  'عیار: ',
                  trans.detail?.carat?.toString() ?? "",
                  AppColor.dividerColor,
                ),
              ),
          ],
        ),
        if (trans.item?.id == 1) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildMobileCardItem(
                  'آز: ',
                  trans.detail?.name ?? "",
                  AppColor.dividerColor,
                ),
              ),
              Expanded(
                child: _buildMobileCardItem(
                  'ش ق: ',
                  trans.detail?.receiptNumber ?? "",
                  AppColor.dividerColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildIssueTransactionDetails(TransactionReportGoldModel trans) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'از: ',
                trans.account?.name ?? "",
                AppColor.accentColor,
              ),
            ),
             Expanded(
               child: _buildMobileCardItem(
                  'به: ',
                  trans.toAccount.name ?? "",
                  AppColor.primaryColor,
                ),
             ),
          ],
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Expanded(
               child: _buildMobileCardItem(
                  'آیتم: ',
                  trans.item?.name ?? "",
                  AppColor.secondary3Color,
                ),
             ),
            Expanded(
              child: Row(
                children: [
                   _buildMobileCardItem(
                      trans.item?.itemUnit?.id == 2 ? 'وزن: ' :
                      trans.item?.itemUnit?.id == 1 ? 'تعداد: ' : 'مقدار: ',
                      "-${trans.amount?.abs().toString().seRagham() ?? ""}",
                      trans.amount! > 0 ? AppColor.primaryColor :
                      trans.amount! < 0 ? AppColor.accentColor : AppColor.textColor,
                    ),
                  Text(
                    " ${trans.item?.itemUnit?.name ?? ""}",
                    style:  AppTextStyle.labelText,
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildReceiptTransactionDetails(TransactionReportGoldModel trans) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'از: ',
                trans.toAccount.name ?? "",
                AppColor.accentColor,
              ),
            ),
            Expanded(
              child: _buildMobileCardItem(
                'به: ',
                trans.account?.name ?? "",
                AppColor.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'آیتم: ',
                trans.item?.name ?? "",
                AppColor.secondary3Color,
              ),
            ),
             Expanded(
               child: Row(
                 children: [
                   _buildMobileCardItem(
                     trans.item?.itemUnit?.id == 2 ? 'وزن: ' :
                     trans.item?.itemUnit?.id == 1 ? 'تعداد: ' : 'مقدار: ',
                     trans.amount?.toString().seRagham() ?? "",
                     trans.amount! > 0 ? AppColor.primaryColor :
                     trans.amount! < 0 ? AppColor.accentColor : AppColor.textColor,
                   ),
                   Text(
                     " ${trans.item?.itemUnit?.name ?? ""}",
                     style:  AppTextStyle.labelText,
                   ),
                 ],
               ),
             )
          ],
        ),
      ],
    );
  }

  Widget _buildDepositTransactionDetails(TransactionReportGoldModel trans) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start,
          children: [
             _buildMobileCardItem(
                'مبلغ: ',
                trans.amount?.toString().seRagham() ?? "",
                AppColor.primaryColor,
              ),
             Expanded(
               child: Text(
                  ' ریال',
                  style: AppTextStyle.bodyText,
                ),
             ),
            if (trans.trackingNumber != null && trans.trackingNumber!.isNotEmpty)
              Expanded(
                child: _buildMobileCardItem(
                  'ش پ: ',
                  trans.trackingNumber!,
                  AppColor.dividerColor,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildWithdrawTransactionDetails(TransactionReportGoldModel trans) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start,
          children: [
             _buildMobileCardItem(
                'مبلغ: ',
                "-${trans.amount?.abs().toString().seRagham() ?? ""}",
                AppColor.accentColor,
              ),
            Expanded(
              child: Text(
                ' ریال',
                style: AppTextStyle.bodyText,
              ),
            ),
            if (trans.trackingNumber != null && trans.trackingNumber!.isNotEmpty)
              Expanded(
                child: _buildMobileCardItem(
                  'ش پ: ',
                  trans.trackingNumber!,
                  AppColor.dividerColor,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileCardItem(String label, String value, Color color) {
    return Row(mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyle.labelText.copyWith(
            color: const Color(0xFF94A3B8),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            value,
            style: AppTextStyle.labelText.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textDirection: value.contains(RegExp(r'[0-9]')) ? TextDirection.ltr : TextDirection.rtl,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCardItemTotal(Color color1,String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyle.labelText.copyWith(
            color: color1,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyle.labelText.copyWith(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textDirection: value.contains(RegExp(r'[0-9]')) ? TextDirection.ltr : TextDirection.rtl,
        ),
      ],
    );
  }
}

