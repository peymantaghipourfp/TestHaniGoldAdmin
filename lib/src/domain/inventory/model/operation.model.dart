import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'operation.model.g.dart';

OperationModel operationModelFromJson(String str) => OperationModel.fromJson(json.decode(str));

String operationModelToJson(OperationModel data) => json.encode(data.toJson());

@JsonSerializable()
class OperationModel {
  @JsonKey(name: "inventoryDetailId")
  final int? inventoryDetailId;
  @JsonKey(name: "inventoryId")
  final int? inventoryId;
  @JsonKey(name: "accountId")
  final int? accountId;
  @JsonKey(name: "accountCode")
  final String? accountCode;
  @JsonKey(name: "accountName")
  final String? accountName;
  @JsonKey(name: "operationDate")
  final DateTime? operationDate;
  @JsonKey(name: "operationPersianDate")
  final String? operationPersianDate;
  @JsonKey(name: "operationTime")
  final String? operationTime;
  @JsonKey(name: "type")
  final int? type;
  @JsonKey(name: "movementType")
  final String? movementType;
  @JsonKey(name: "status")
  final String? status;
  @JsonKey(name: "quantity")
  final double? quantity;
  @JsonKey(name: "balanceEffect")
  final double? balanceEffect;
  @JsonKey(name: "balanceAfterOperation")
  final double? balanceAfterOperation;
  @JsonKey(name: "removedOn")
  final DateTime? removedOn;
  @JsonKey(name: "removedOnPersian")
  final String? removedOnPersian;
  @JsonKey(name: "balanceAfterRemoval")
  final double? balanceAfterRemoval;
  @JsonKey(name: "walletId")
  final int? walletId;
  @JsonKey(name: "receiptNumber")
  final String? receiptNumber;
  @JsonKey(name: "createdOn")
  final DateTime? createdOn;
  @JsonKey(name: "modifiedOn")
  final DateTime? modifiedOn;
  @JsonKey(name: "createdBy")
  final int? createdBy;
  @JsonKey(name: "modifiedBy")
  final int? modifiedBy;
  @JsonKey(name: "isPriorPeriodOperation")
  final bool? isPriorPeriodOperation;
  @JsonKey(name: "hasDateMismatch")
  final bool? hasDateMismatch;
  @JsonKey(name: "warningMessage")
  final String? warningMessage;
  @JsonKey(name: "eventKind")
  final String? eventKind;
  @JsonKey(name: "eventTitle")
  final String? eventTitle;
  @JsonKey(name: "eventDescription")
  final String? eventDescription;
  @JsonKey(name: "createdByName")
  final String? createdByName;
  @JsonKey(name: "removedBy")
  final int? removedBy;
  @JsonKey(name: "removedByName")
  final String? removedByName;

  OperationModel({
    required this.inventoryDetailId,
    required this.inventoryId,
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.operationDate,
    required this.operationPersianDate,
    required this.operationTime,
    required this.type,
    required this.movementType,
    required this.status,
    required this.quantity,
    required this.balanceEffect,
    required this.balanceAfterOperation,
    required this.removedOn,
    required this.removedOnPersian,
    required this.balanceAfterRemoval,
    required this.walletId,
    required this.receiptNumber,
    required this.createdOn,
    required this.modifiedOn,
    required this.createdBy,
    required this.modifiedBy,
    required this.isPriorPeriodOperation,
    required this.hasDateMismatch,
    required this.warningMessage,
    required this.eventKind,
    required this.eventTitle,
    required this.eventDescription,
    required this.createdByName,
    required this.removedBy,
    required this.removedByName,
  });

  factory OperationModel.fromJson(Map<String, dynamic> json) => _$OperationModelFromJson(json);

  Map<String, dynamic> toJson() => _$OperationModelToJson(this);
}