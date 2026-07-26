// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_transaction_info_item.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListTransactionInfoItemModel _$ListTransactionInfoItemModelFromJson(
        Map<String, dynamic> json) =>
    ListTransactionInfoItemModel(
      accountId: (json['accountId'] as num?)?.toInt(),
      accountName: json['accountName'] as String?,
      currencyValueBes: (json['currencyValueBES'] as num?)?.toDouble(),
      currencyValueBed: (json['currencyValueBED'] as num?)?.toDouble(),
      goldBalanceBes: (json['goldBalanceBES'] as num?)?.toDouble(),
      goldBalanceBed: (json['goldBalanceBED'] as num?)?.toDouble(),
      coinBalanceBes: (json['coinBalanceBES'] as num?)?.toDouble(),
      coinBalanceBed: (json['coinBalanceBED'] as num?)?.toDouble(),
      halfCoinBalanceBes: (json['halfCoinBalanceBES'] as num?)?.toDouble(),
      halfCoinBalanceBed: (json['halfCoinBalanceBED'] as num?)?.toDouble(),
      quarterCoinBalanceBes:
          (json['quarterCoinBalanceBES'] as num?)?.toDouble(),
      quarterCoinBalanceBed:
          (json['quarterCoinBalanceBED'] as num?)?.toDouble(),
      cashBalanceBes: (json['cashBalanceBES'] as num?)?.toDouble(),
      cashBalanceBed: (json['cashBalanceBED'] as num?)?.toDouble(),
      dollarBalanceBes: (json['dollarBalanceBES'] as num?)?.toDouble(),
      dollarBalanceBed: (json['dollarBalanceBED'] as num?)?.toDouble(),
      euroBalanceBes: (json['euroBalanceBES'] as num?)?.toDouble(),
      euroBalanceBed: (json['euroBalanceBED'] as num?)?.toDouble(),
      silverBalanceBes: (json['silverBalanceBES'] as num?)?.toDouble(),
      silverBalanceBed: (json['silverBalanceBED'] as num?)?.toDouble(),
      goldValue: (json['goldValue'] as num?)?.toDouble(),
      coinValue: (json['coinValue'] as num?)?.toDouble(),
      afterGoldBalance: (json['afterGoldBalance'] as num?)?.toDouble(),
      afterCashBalance: (json['afterCashBalance'] as num?)?.toDouble(),
      rowNum: (json['rowNum'] as num?)?.toInt(),
      balances: (json['balances'] as List<dynamic>?)
          ?.map((e) => BalanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListTransactionInfoItemModelToJson(
        ListTransactionInfoItemModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'currencyValueBES': instance.currencyValueBes,
      'currencyValueBED': instance.currencyValueBed,
      'goldBalanceBES': instance.goldBalanceBes,
      'goldBalanceBED': instance.goldBalanceBed,
      'coinBalanceBES': instance.coinBalanceBes,
      'coinBalanceBED': instance.coinBalanceBed,
      'halfCoinBalanceBES': instance.halfCoinBalanceBes,
      'halfCoinBalanceBED': instance.halfCoinBalanceBed,
      'quarterCoinBalanceBES': instance.quarterCoinBalanceBes,
      'quarterCoinBalanceBED': instance.quarterCoinBalanceBed,
      'cashBalanceBES': instance.cashBalanceBes,
      'cashBalanceBED': instance.cashBalanceBed,
      'dollarBalanceBES': instance.dollarBalanceBes,
      'dollarBalanceBED': instance.dollarBalanceBed,
      'euroBalanceBES': instance.euroBalanceBes,
      'euroBalanceBED': instance.euroBalanceBed,
      'silverBalanceBES': instance.silverBalanceBes,
      'silverBalanceBED': instance.silverBalanceBed,
      'goldValue': instance.goldValue,
      'coinValue': instance.coinValue,
      'afterGoldBalance': instance.afterGoldBalance,
      'afterCashBalance': instance.afterCashBalance,
      'rowNum': instance.rowNum,
      'balances': instance.balances,
    };
