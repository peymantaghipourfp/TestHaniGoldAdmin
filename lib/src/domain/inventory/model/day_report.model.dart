import 'package:hanigold_admin/src/domain/inventory/model/operation.model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'day_report.model.g.dart';

DayReportModel dayReportModelFromJson(String str) => DayReportModel.fromJson(json.decode(str));

String dayReportModelToJson(DayReportModel data) => json.encode(data.toJson());

@JsonSerializable()
class DayReportModel {
  @JsonKey(name: "date")
  final DateTime? date;
  @JsonKey(name: "persianDate")
  final String? persianDate;
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
  @JsonKey(name: "operations")
  final List<OperationModel>? operations;

  DayReportModel({
    required this.date,
    required this.persianDate,
    required this.openingBalance,
    required this.closingBalance,
    required this.inputQuantity,
    required this.outputQuantity,
    required this.deletedOperationCount,
    required this.deletedQuantity,
    required this.operations,
  });

  factory DayReportModel.fromJson(Map<String, dynamic> json) => _$DayReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$DayReportModelToJson(this);
}