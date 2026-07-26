import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'today_deposit_request_report.model.g.dart';

List<TodayDepositRequestReportModel> todayDepositRequestReportModelFromJson(String str) => List<TodayDepositRequestReportModel>.from(json.decode(str).map((x) => TodayDepositRequestReportModel.fromJson(x)));

String todayDepositRequestReportModelToJson(List<TodayDepositRequestReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable()
class TodayDepositRequestReportModel {
  @JsonKey(name: "accountId") // شناسه حساب
  final int? accountId;
  @JsonKey(name: "accountName") // نام حساب
  final String? accountName;
  @JsonKey(name: "depositRequestId") // شناسه تعهد
  final int? depositRequestId;
  @JsonKey(name: "withdrawRequestId") // شناسه برداشت مرتبط
  final int? withdrawRequestId;
  @JsonKey(name: "requestDate") // تاریخ ثبت تعهد
  final DateTime? requestDate;
  @JsonKey(name: "pledgeAmount") // مبلغ تعهد
  final double? pledgeAmount;
  @JsonKey(name: "transferCount") // تعداد پرداخت‌ها
  final int? transferCount;
  @JsonKey(name: "transferAmount") // مبلغ پرداخت‌شده
  final double? transferAmount;
  @JsonKey(name: "progressPercent") // درصد انجام تعهد
  final double? progressPercent;
  @JsonKey(name: "outstandingAmount") // مبلغ باقیمانده تعهد
  final double? outstandingAmount;
  @JsonKey(name: "isFinished") // وضعیت تکمیل تعهد
  final bool? isFinished;
  @JsonKey(name: "overPaymentCount") // تعداد اضافه‌واریزی‌ها
  final int? overPaymentCount;
  @JsonKey(name: "overPaymentAmount") // مبلغ اضافه‌واریزی‌ها
  final double? overPaymentAmount;

  TodayDepositRequestReportModel({
    required this.accountId,
    required this.accountName,
    required this.depositRequestId,
    required this.withdrawRequestId,
    required this.requestDate,
    required this.pledgeAmount,
    required this.transferCount,
    required this.transferAmount,
    required this.progressPercent,
    required this.outstandingAmount,
    required this.isFinished,
    required this.overPaymentCount,
    required this.overPaymentAmount,
  });

  factory TodayDepositRequestReportModel.fromJson(Map<String, dynamic> json) => _$TodayDepositRequestReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodayDepositRequestReportModelToJson(this);
}