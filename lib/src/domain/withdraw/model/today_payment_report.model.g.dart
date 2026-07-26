// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_payment_report.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayPaymentReportModel _$TodayPaymentReportModelFromJson(
        Map<String, dynamic> json) =>
    TodayPaymentReportModel(
      accountId: (json['accountId'] as num?)?.toInt(),
      accountName: json['accountName'] as String?,
      reportDatePersian: json['reportDatePersian'] as String?,
      withdrawRequestCount: (json['withdrawRequestCount'] as num?)?.toInt(),
      withdrawRequestAmount:
          (json['withdrawRequestAmount'] as num?)?.toDouble(),
      withdrawCoverageCount: (json['withdrawCoverageCount'] as num?)?.toInt(),
      withdrawCoverageAmount:
          (json['withdrawCoverageAmount'] as num?)?.toDouble(),
      withdrawCoveragePercent:
          (json['withdrawCoveragePercent'] as num?)?.toDouble(),
      withdrawSettlementCount:
          (json['withdrawSettlementCount'] as num?)?.toInt(),
      withdrawSettlementAmount:
          (json['withdrawSettlementAmount'] as num?)?.toDouble(),
      withdrawSettlementPercent:
          (json['withdrawSettlementPercent'] as num?)?.toDouble(),
      pledgeCount: (json['pledgeCount'] as num?)?.toInt(),
      pledgeAmount: (json['pledgeAmount'] as num?)?.toDouble(),
      pledgeProgressPercent:
          (json['pledgeProgressPercent'] as num?)?.toDouble(),
      transferCount: (json['transferCount'] as num?)?.toInt(),
      transferAmount: (json['transferAmount'] as num?)?.toDouble(),
      outstandingAmount: (json['outstandingAmount'] as num?)?.toDouble(),
      activePledgeCount: (json['activePledgeCount'] as num?)?.toInt(),
      finishedPledgeCount: (json['finishedPledgeCount'] as num?)?.toInt(),
      overPaymentCount: (json['overPaymentCount'] as num?)?.toInt(),
      overPaymentAmount: (json['overPaymentAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TodayPaymentReportModelToJson(
        TodayPaymentReportModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'reportDatePersian': instance.reportDatePersian,
      'withdrawRequestCount': instance.withdrawRequestCount,
      'withdrawRequestAmount': instance.withdrawRequestAmount,
      'withdrawCoverageCount': instance.withdrawCoverageCount,
      'withdrawCoverageAmount': instance.withdrawCoverageAmount,
      'withdrawCoveragePercent': instance.withdrawCoveragePercent,
      'withdrawSettlementCount': instance.withdrawSettlementCount,
      'withdrawSettlementAmount': instance.withdrawSettlementAmount,
      'withdrawSettlementPercent': instance.withdrawSettlementPercent,
      'pledgeCount': instance.pledgeCount,
      'pledgeAmount': instance.pledgeAmount,
      'pledgeProgressPercent': instance.pledgeProgressPercent,
      'transferCount': instance.transferCount,
      'transferAmount': instance.transferAmount,
      'outstandingAmount': instance.outstandingAmount,
      'activePledgeCount': instance.activePledgeCount,
      'finishedPledgeCount': instance.finishedPledgeCount,
      'overPaymentCount': instance.overPaymentCount,
      'overPaymentAmount': instance.overPaymentAmount,
    };
