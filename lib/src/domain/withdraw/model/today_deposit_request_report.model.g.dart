// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_deposit_request_report.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayDepositRequestReportModel _$TodayDepositRequestReportModelFromJson(
        Map<String, dynamic> json) =>
    TodayDepositRequestReportModel(
      accountId: (json['accountId'] as num?)?.toInt(),
      accountName: json['accountName'] as String?,
      depositRequestId: (json['depositRequestId'] as num?)?.toInt(),
      withdrawRequestId: (json['withdrawRequestId'] as num?)?.toInt(),
      requestDate: json['requestDate'] == null
          ? null
          : DateTime.parse(json['requestDate'] as String),
      pledgeAmount: (json['pledgeAmount'] as num?)?.toDouble(),
      transferCount: (json['transferCount'] as num?)?.toInt(),
      transferAmount: (json['transferAmount'] as num?)?.toDouble(),
      progressPercent: (json['progressPercent'] as num?)?.toDouble(),
      outstandingAmount: (json['outstandingAmount'] as num?)?.toDouble(),
      isFinished: json['isFinished'] as bool?,
      overPaymentCount: (json['overPaymentCount'] as num?)?.toInt(),
      overPaymentAmount: (json['overPaymentAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TodayDepositRequestReportModelToJson(
        TodayDepositRequestReportModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'depositRequestId': instance.depositRequestId,
      'withdrawRequestId': instance.withdrawRequestId,
      'requestDate': instance.requestDate?.toIso8601String(),
      'pledgeAmount': instance.pledgeAmount,
      'transferCount': instance.transferCount,
      'transferAmount': instance.transferAmount,
      'progressPercent': instance.progressPercent,
      'outstandingAmount': instance.outstandingAmount,
      'isFinished': instance.isFinished,
      'overPaymentCount': instance.overPaymentCount,
      'overPaymentAmount': instance.overPaymentAmount,
    };
