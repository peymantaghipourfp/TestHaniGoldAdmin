import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
import 'package:hanigold_admin/src/utils/num_display.dart';

/// Coin balance cell (بستانکار / بدهکار).
class UserBalanceCoinCell {
  UserBalanceCoinCell._();

  static bool _hasCredit(ListTransactionInfoItemModel trans) =>
      (trans.coinBalanceBes ?? 0) != 0 ||
      (trans.halfCoinBalanceBes ?? 0) != 0 ||
      (trans.quarterCoinBalanceBes ?? 0) != 0;

  static bool _hasDebit(ListTransactionInfoItemModel trans) =>
      (trans.coinBalanceBed ?? 0) != 0 ||
      (trans.halfCoinBalanceBed ?? 0) != 0 ||
      (trans.quarterCoinBalanceBed ?? 0) != 0;

  static Widget _coinRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Text(
          ' $label ',
          style: AppTextStyle.bodyText.copyWith(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: AppTextStyle.bodyText.copyWith(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.ltr,
        ),
        Text(
          ' عدد ',
          style: AppTextStyle.bodyText.copyWith(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static Widget creditSection({
    required ListTransactionInfoItemModel trans,
  }) {
    if (!_hasCredit(trans)) {
      return const SizedBox();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            if ((trans.coinBalanceBes ?? 0) != 0)
              _coinRow(
                label: 'تمام سکه',
                value: trans.coinBalanceBes!.toDisplayString(),
                color: AppColor.primaryColor,
              ),
            if ((trans.halfCoinBalanceBes ?? 0) != 0)
              _coinRow(
                label: 'نیم سکه',
                value: trans.halfCoinBalanceBes!.toDisplayString(),
                color: AppColor.primaryColor,
              ),
            if ((trans.quarterCoinBalanceBes ?? 0) != 0)
              _coinRow(
                label: 'ربع سکه',
                value: trans.quarterCoinBalanceBes!.toDisplayString(),
                color: AppColor.primaryColor,
              ),
          ],
        ),
      ],
    );
  }

  static Widget debitSection({
    required ListTransactionInfoItemModel trans,
  }) {
    if (!_hasDebit(trans)) {
      return const SizedBox();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            if ((trans.coinBalanceBed ?? 0) != 0)
              _coinRow(
                label: 'تمام سکه',
                value: '-${trans.coinBalanceBed!.abs().toDisplayString()}',
                color: AppColor.accentColor,
              ),
            if ((trans.halfCoinBalanceBed ?? 0) != 0)
              _coinRow(
                label: 'نیم سکه',
                value: '-${trans.halfCoinBalanceBed!.abs().toDisplayString()}',
                color: AppColor.accentColor,
              ),
            if ((trans.quarterCoinBalanceBed ?? 0) != 0)
              _coinRow(
                label: 'ربع سکه',
                value:
                    '-${trans.quarterCoinBalanceBed!.abs().toDisplayString()}',
                color: AppColor.accentColor,
              ),
          ],
        ),
      ],
    );
  }
}
