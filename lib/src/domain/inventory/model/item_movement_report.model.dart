import 'package:hanigold_admin/src/domain/inventory/model/day_report.model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'item_movement_report.model.g.dart';

ItemMovementReportModel itemMovementReportModelFromJson(String str) => ItemMovementReportModel.fromJson(json.decode(str));

String itemMovementReportModelToJson(ItemMovementReportModel data) => json.encode(data.toJson());

@JsonSerializable()
class ItemMovementReportModel {
  @JsonKey(name: "item")
  final Item? item;
  @JsonKey(name: "fromDate")
  final DateTime? fromDate;
  @JsonKey(name: "toDate")
  final DateTime? toDate;
  @JsonKey(name: "fromPersianDate")
  final String? fromPersianDate;
  @JsonKey(name: "toPersianDate")
  final String? toPersianDate;
  @JsonKey(name: "openingBalance")
  final double? openingBalance;
  @JsonKey(name: "closingBalance")
  final double? closingBalance;
  @JsonKey(name: "inputQuantity")
  final double? inputQuantity;
  @JsonKey(name: "outputQuantity")
  final double? outputQuantity;
  @JsonKey(name: "deletedOperationCount")
  final int? deletedOperationCount;
  @JsonKey(name: "deletedQuantity")
  final int? deletedQuantity;
  @JsonKey(name: "warningCount")
  final int? warningCount;
  @JsonKey(name: "warnings")
  final List<dynamic>? warnings;
  @JsonKey(name: "days")
  final List<DayReportModel>? days;

  ItemMovementReportModel({
    required this.item,
    required this.fromDate,
    required this.toDate,
    required this.fromPersianDate,
    required this.toPersianDate,
    required this.openingBalance,
    required this.closingBalance,
    required this.inputQuantity,
    required this.outputQuantity,
    required this.deletedOperationCount,
    required this.deletedQuantity,
    required this.warningCount,
    required this.warnings,
    required this.days,
  });

  factory ItemMovementReportModel.fromJson(Map<String, dynamic> json) => _$ItemMovementReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemMovementReportModelToJson(this);
}

@JsonSerializable()
class Item {
  @JsonKey(name: "id")
  final int? id;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "unitName")
  final String? unitName;

  Item({
    required this.id,
    required this.name,
    required this.unitName,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}