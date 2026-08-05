// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperationModel _$OperationModelFromJson(Map<String, dynamic> json) =>
    OperationModel(
      inventoryDetailId: (json['inventoryDetailId'] as num?)?.toInt(),
      inventoryId: (json['inventoryId'] as num?)?.toInt(),
      accountId: (json['accountId'] as num?)?.toInt(),
      accountCode: json['accountCode'] as String?,
      accountName: json['accountName'] as String?,
      operationDate: json['operationDate'] == null
          ? null
          : DateTime.parse(json['operationDate'] as String),
      operationPersianDate: json['operationPersianDate'] as String?,
      operationTime: json['operationTime'] as String?,
      type: (json['type'] as num?)?.toInt(),
      movementType: json['movementType'] as String?,
      status: json['status'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      balanceEffect: (json['balanceEffect'] as num?)?.toDouble(),
      balanceAfterOperation:
          (json['balanceAfterOperation'] as num?)?.toDouble(),
      removedOn: json['removedOn'] == null
          ? null
          : DateTime.parse(json['removedOn'] as String),
      removedOnPersian: json['removedOnPersian'] as String?,
      balanceAfterRemoval:
      (json['balanceAfterRemoval'] as num?)?.toDouble(),
      walletId: (json['walletId'] as num?)?.toInt(),
      receiptNumber: json['receiptNumber'] as String?,
      createdOn: json['createdOn'] == null
          ? null
          : DateTime.parse(json['createdOn'] as String),
      modifiedOn: json['modifiedOn'] == null
          ? null
          : DateTime.parse(json['modifiedOn'] as String),
      createdBy: (json['createdBy'] as num?)?.toInt(),
      modifiedBy: (json['modifiedBy'] as num?)?.toInt(),
      isPriorPeriodOperation: json['isPriorPeriodOperation'] as bool?,
      hasDateMismatch: json['hasDateMismatch'] as bool?,
      warningMessage: json['warningMessage'] as String?,
      eventKind: json['eventKind'] as String?,
      eventTitle: json['eventTitle'] as String?,
      eventDescription: json['eventDescription'] as String?,
      createdByName: json['createdByName'] as String?,
      removedBy: (json['removedBy'] as num?)?.toInt(),
      removedByName: json['removedByName'] as String?,
    );

Map<String, dynamic> _$OperationModelToJson(OperationModel instance) =>
    <String, dynamic>{
      'inventoryDetailId': instance.inventoryDetailId,
      'inventoryId': instance.inventoryId,
      'accountId': instance.accountId,
      'accountCode': instance.accountCode,
      'accountName': instance.accountName,
      'operationDate': instance.operationDate?.toIso8601String(),
      'operationPersianDate': instance.operationPersianDate,
      'operationTime': instance.operationTime,
      'type': instance.type,
      'movementType': instance.movementType,
      'status': instance.status,
      'quantity': instance.quantity,
      'balanceEffect': instance.balanceEffect,
      'balanceAfterOperation': instance.balanceAfterOperation,
      'removedOn': instance.removedOn,
      'removedOnPersian': instance.removedOnPersian,
      'balanceAfterRemoval': instance.balanceAfterRemoval,
      'walletId': instance.walletId,
      'receiptNumber': instance.receiptNumber,
      'createdOn': instance.createdOn?.toIso8601String(),
      'modifiedOn': instance.modifiedOn?.toIso8601String(),
      'createdBy': instance.createdBy,
      'modifiedBy': instance.modifiedBy,
      'isPriorPeriodOperation': instance.isPriorPeriodOperation,
      'hasDateMismatch': instance.hasDateMismatch,
      'warningMessage': instance.warningMessage,
      'eventKind': instance.eventKind,
      'eventTitle': instance.eventTitle,
      'eventDescription': instance.eventDescription,
      'createdByName': instance.createdByName,
      'removedBy': instance.removedBy,
      'removedByName': instance.removedByName,
    };
