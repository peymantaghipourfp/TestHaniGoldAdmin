// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_withdraw_request_report.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayWithdrawRequestReportModel _$TodayWithdrawRequestReportModelFromJson(
        Map<String, dynamic> json) =>
    TodayWithdrawRequestReportModel(
      accountId: (json['accountId'] as num?)?.toInt(),
      accountName: json['accountName'] as String?,
      withdrawRequestId: (json['withdrawRequestId'] as num?)?.toInt(),
      requestDate: json['requestDate'] == null
          ? null
          : DateTime.parse(json['requestDate'] as String),
      withdrawRequestAmount:
          (json['withdrawRequestAmount'] as num?)?.toDouble(),
      coverageCount: (json['coverageCount'] as num?)?.toInt(),
      coverageAmount: (json['coverageAmount'] as num?)?.toDouble(),
      coveragePercent: (json['coveragePercent'] as num?)?.toDouble(),
      settlementCount: (json['settlementCount'] as num?)?.toInt(),
      settlementAmount: (json['settlementAmount'] as num?)?.toDouble(),
      settlementPercent: (json['settlementPercent'] as num?)?.toDouble(),
      outstandingAmount: (json['outstandingAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TodayWithdrawRequestReportModelToJson(
        TodayWithdrawRequestReportModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'withdrawRequestId': instance.withdrawRequestId,
      'requestDate': instance.requestDate?.toIso8601String(),
      'withdrawRequestAmount': instance.withdrawRequestAmount,
      'coverageCount': instance.coverageCount,
      'coverageAmount': instance.coverageAmount,
      'coveragePercent': instance.coveragePercent,
      'settlementCount': instance.settlementCount,
      'settlementAmount': instance.settlementAmount,
      'settlementPercent': instance.settlementPercent,
      'outstandingAmount': instance.outstandingAmount,
    };
