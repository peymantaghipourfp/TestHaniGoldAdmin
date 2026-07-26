import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'today_withdraw_request_report.model.g.dart';

List<TodayWithdrawRequestReportModel> todayWithdrawRequestReportModelFromJson(String str) => List<TodayWithdrawRequestReportModel>.from(json.decode(str).map((x) => TodayWithdrawRequestReportModel.fromJson(x)));

String todayWithdrawRequestReportModelToJson(List<TodayWithdrawRequestReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable()
class TodayWithdrawRequestReportModel {
  @JsonKey(name: "accountId") // شناسه حساب
  final int? accountId;
  @JsonKey(name: "accountName") // نام حساب
  final String? accountName;
  @JsonKey(name: "withdrawRequestId") // شناسه برداشت
  final int? withdrawRequestId;
  @JsonKey(name: "requestDate") // تاریخ ثبت برداشت
  final DateTime? requestDate;
  @JsonKey(name: "withdrawRequestAmount") // مبلغ برداشت
  final double? withdrawRequestAmount;
  @JsonKey(name: "coverageCount") // تعداد تعهدهای ثبت‌شده
  final int? coverageCount;
  @JsonKey(name: "coverageAmount") // مبلغ تعهدشده
  final double? coverageAmount;
  @JsonKey(name: "coveragePercent") // درصد پوشش تعهدی
  final double? coveragePercent;
  @JsonKey(name: "settlementCount") // تعداد پرداخت‌های انجام‌شده
  final int? settlementCount;
  @JsonKey(name: "settlementAmount") // مبلغ پرداخت‌شده
  final double? settlementAmount;
  @JsonKey(name: "settlementPercent") // درصد تأمین واقعی
  final double? settlementPercent;
  @JsonKey(name: "outstandingAmount") // مبلغ باقیمانده برداشت
  final double? outstandingAmount;

  TodayWithdrawRequestReportModel({
    required this.accountId,
    required this.accountName,
    required this.withdrawRequestId,
    required this.requestDate,
    required this.withdrawRequestAmount,
    required this.coverageCount,
    required this.coverageAmount,
    required this.coveragePercent,
    required this.settlementCount,
    required this.settlementAmount,
    required this.settlementPercent,
    required this.outstandingAmount,
  });

  factory TodayWithdrawRequestReportModel.fromJson(Map<String, dynamic> json) => _$TodayWithdrawRequestReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodayWithdrawRequestReportModelToJson(this);
}