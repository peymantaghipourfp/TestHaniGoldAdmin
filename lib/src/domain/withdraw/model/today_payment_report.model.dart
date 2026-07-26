import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'today_payment_report.model.g.dart';

TodayPaymentReportModel todayPaymentReportModelFromJson(String str) => TodayPaymentReportModel.fromJson(json.decode(str));

String todayPaymentReportModelToJson(TodayPaymentReportModel data) => json.encode(data.toJson());

@JsonSerializable()
class TodayPaymentReportModel {
  @JsonKey(name: "accountId") // شناسه حساب
  final int? accountId;
  @JsonKey(name: "accountName") // نام حساب
  final String? accountName;
  @JsonKey(name: "reportDatePersian") // تاریخ فارسی
  final String? reportDatePersian;
  @JsonKey(name: "withdrawRequestCount") // تعداد درخواست‌های برداشت امروز
  final int? withdrawRequestCount;
  @JsonKey(name: "withdrawRequestAmount") // مبلغ درخواست‌های برداشت امروز
  final double? withdrawRequestAmount;
  @JsonKey(name: "withdrawCoverageCount") // تعداد تعهدهای ثبت‌شده برای برداشت‌ها
  final int? withdrawCoverageCount;
  @JsonKey(name: "withdrawCoverageAmount") // مبلغ تعهدشده برای برداشت‌ها
  final double? withdrawCoverageAmount;
  @JsonKey(name: "withdrawCoveragePercent") // درصد پوشش تعهدی برداشت‌ها
  final double? withdrawCoveragePercent;
  @JsonKey(name: "withdrawSettlementCount") // تعداد پرداخت‌های انجام‌شده برای برداشت‌ها
  final int? withdrawSettlementCount;
  @JsonKey(name: "withdrawSettlementAmount") // مبلغ پرداخت‌شده برای برداشت‌ها
  final double? withdrawSettlementAmount;
  @JsonKey(name: "withdrawSettlementPercent") // درصد تأمین واقعی برداشت‌ها
  final double? withdrawSettlementPercent;
  @JsonKey(name: "pledgeCount") // تعداد تعهدات پرداخت این کاربر
  final int? pledgeCount;
  @JsonKey(name: "pledgeAmount") // مبلغ تعهدات پرداخت این کاربر
  final double? pledgeAmount;
  @JsonKey(name: "pledgeProgressPercent") // درصد پیشرفت انجام تعهدات
  final double? pledgeProgressPercent;
  @JsonKey(name: "transferCount") // تعداد پرداخت‌های انجام‌شده
  final int? transferCount;
  @JsonKey(name: "transferAmount") // مبلغ پرداخت‌های انجام‌شده
  final double? transferAmount;
  @JsonKey(name: "outstandingAmount") // مانده تعهدات پرداخت
  final double? outstandingAmount;
  @JsonKey(name: "activePledgeCount") // تعداد تعهدات باز
  final int? activePledgeCount;
  @JsonKey(name: "finishedPledgeCount") // تعداد تعهدات تکمیل‌شده
  final int? finishedPledgeCount;
  @JsonKey(name: "overPaymentCount") // تعداد اضافه‌واریزی‌ها
  final int? overPaymentCount;
  @JsonKey(name: "overPaymentAmount") // مبلغ اضافه‌واریزی‌ها
  final double? overPaymentAmount;

  TodayPaymentReportModel({
    required this.accountId,
    required this.accountName,
    required this.reportDatePersian,
    required this.withdrawRequestCount,
    required this.withdrawRequestAmount,
    required this.withdrawCoverageCount,
    required this.withdrawCoverageAmount,
    required this.withdrawCoveragePercent,
    required this.withdrawSettlementCount,
    required this.withdrawSettlementAmount,
    required this.withdrawSettlementPercent,
    required this.pledgeCount,
    required this.pledgeAmount,
    required this.pledgeProgressPercent,
    required this.transferCount,
    required this.transferAmount,
    required this.outstandingAmount,
    required this.activePledgeCount,
    required this.finishedPledgeCount,
    required this.overPaymentCount,
    required this.overPaymentAmount,
  });

  factory TodayPaymentReportModel.fromJson(Map<String, dynamic> json) => _$TodayPaymentReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodayPaymentReportModelToJson(this);
}