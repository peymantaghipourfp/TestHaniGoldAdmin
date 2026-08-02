// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_movement_report.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemMovementReportModel _$ItemMovementReportModelFromJson(
        Map<String, dynamic> json) =>
    ItemMovementReportModel(
      item: json['item'] == null
          ? null
          : Item.fromJson(json['item'] as Map<String, dynamic>),
      fromDate: json['fromDate'] == null
          ? null
          : DateTime.parse(json['fromDate'] as String),
      toDate: json['toDate'] == null
          ? null
          : DateTime.parse(json['toDate'] as String),
      fromPersianDate: json['fromPersianDate'] as String?,
      toPersianDate: json['toPersianDate'] as String?,
      openingBalance: (json['openingBalance'] as num?)?.toDouble(),
      closingBalance: (json['closingBalance'] as num?)?.toDouble(),
      inputQuantity: (json['inputQuantity'] as num?)?.toDouble(),
      outputQuantity: (json['outputQuantity'] as num?)?.toDouble(),
      deletedOperationCount: (json['deletedOperationCount'] as num?)?.toInt(),
      deletedQuantity: (json['deletedQuantity'] as num?)?.toInt(),
      warningCount: (json['warningCount'] as num?)?.toInt(),
      warnings: json['warnings'] as List<dynamic>?,
      days: (json['days'] as List<dynamic>?)
          ?.map((e) => DayReportModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItemMovementReportModelToJson(
        ItemMovementReportModel instance) =>
    <String, dynamic>{
      'item': instance.item,
      'fromDate': instance.fromDate?.toIso8601String(),
      'toDate': instance.toDate?.toIso8601String(),
      'fromPersianDate': instance.fromPersianDate,
      'toPersianDate': instance.toPersianDate,
      'openingBalance': instance.openingBalance,
      'closingBalance': instance.closingBalance,
      'inputQuantity': instance.inputQuantity,
      'outputQuantity': instance.outputQuantity,
      'deletedOperationCount': instance.deletedOperationCount,
      'deletedQuantity': instance.deletedQuantity,
      'warningCount': instance.warningCount,
      'warnings': instance.warnings,
      'days': instance.days,
    };

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      unitName: json['unitName'] as String?,
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unitName': instance.unitName,
    };
