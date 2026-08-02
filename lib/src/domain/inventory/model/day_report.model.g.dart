// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_report.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayReportModel _$DayReportModelFromJson(Map<String, dynamic> json) =>
    DayReportModel(
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      persianDate: json['persianDate'] as String?,
      openingBalance: (json['openingBalance'] as num?)?.toDouble(),
      closingBalance: (json['closingBalance'] as num?)?.toDouble(),
      inputQuantity: (json['inputQuantity'] as num?)?.toDouble(),
      outputQuantity: (json['outputQuantity'] as num?)?.toDouble(),
      deletedOperationCount: (json['deletedOperationCount'] as num?)?.toInt(),
      deletedQuantity: (json['deletedQuantity'] as num?)?.toInt(),
      operations: (json['operations'] as List<dynamic>?)
          ?.map((e) => OperationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DayReportModelToJson(DayReportModel instance) =>
    <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'persianDate': instance.persianDate,
      'openingBalance': instance.openingBalance,
      'closingBalance': instance.closingBalance,
      'inputQuantity': instance.inputQuantity,
      'outputQuantity': instance.outputQuantity,
      'deletedOperationCount': instance.deletedOperationCount,
      'deletedQuantity': instance.deletedQuantity,
      'operations': instance.operations,
    };
