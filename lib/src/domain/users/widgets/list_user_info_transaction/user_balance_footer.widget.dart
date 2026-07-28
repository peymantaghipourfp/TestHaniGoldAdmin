import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_balance_list_controller.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_info_footer.model.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Responsive footer grid for desktop user-balance totals (credit/debit + net).
class UserBalanceFooter extends StatelessWidget {
  const UserBalanceFooter({
    super.key,
    required this.controller,
  });

  final UserBalanceListController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final footer = controller.listTransactionInfoFooter;
      if (footer.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.appBarColor.withAlpha(130),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                children: [
                  _buildFooterItem(
                    title: 'ریال بستانکار',
                    positiveValue: _sumPositive(footer, 'ریال'),
                    color: AppColor.primaryColor,
                    unit: 'ریال',
                  ),
                  _buildFooterItem(
                    title: 'ریال بدهکار',
                    negativeValue: _sumNegative(footer, 'ریال'),
                    color: AppColor.accentColor,
                    unit: 'ریال',
                  ),
                  _footerItemWithDetail(
                    context: context,
                    title: 'طلا بستانکار',
                    positiveValue: _sumPositive(footer, 'گرم'),
                    color: AppColor.primaryColor,
                    unit: 'گرم',
                    dialogTitle: 'جزییات',
                    dialogMiddleText: 'لیست مانده طلای بستانکار',
                    detailRows: footer
                        .where((e) =>
                            e.unitName == 'گرم' && (e.totalPositiveBalance ?? 0) > 0)
                        .map((e) => _DetailRow(
                              label: e.itemName ?? '',
                              value: '${e.totalPositiveBalance ?? 0} گرم ',
                            ))
                        .toList(),
                  ),
                  _footerItemWithDetail(
                    context: context,
                    title: 'طلا بدهکار',
                    negativeValue: _sumNegative(footer, 'گرم'),
                    color: AppColor.accentColor,
                    unit: 'گرم',
                    dialogTitle: 'جزییات',
                    dialogMiddleText: 'لیست مانده طلای بدهکار',
                    detailRows: footer
                        .where((e) =>
                            e.unitName == 'گرم' && (e.totalNegativeBalance ?? 0) < 0)
                        .map((e) => _DetailRow(
                              label: e.itemName ?? '',
                              value: '${e.totalNegativeBalance ?? 0} گرم ',
                            ))
                        .toList(),
                  ),
                  _footerItemWithDetail(
                    context: context,
                    title: 'سکه بستانکار',
                    positiveValue: _sumPositive(footer, 'عدد'),
                    color: AppColor.primaryColor,
                    unit: 'عدد',
                    dialogTitle: 'جزییات',
                    dialogMiddleText: 'لیست مانده سکه بستانکار',
                    detailRows: footer
                        .where((e) =>
                            e.unitName == 'عدد' && (e.totalPositiveBalance ?? 0) > 0)
                        .map((e) => _DetailRow(
                              label: e.itemName ?? '',
                              value: '${e.totalPositiveBalance ?? 0} عدد ',
                            ))
                        .toList(),
                  ),
                  _footerItemWithDetail(
                    context: context,
                    title: 'سکه بدهکار',
                    negativeValue: _sumNegative(footer, 'عدد'),
                    color: AppColor.accentColor,
                    unit: 'عدد',
                    dialogTitle: 'جزییات',
                    dialogMiddleText: 'لیست مانده سکه بدهکار',
                    detailRows: footer
                        .where((e) =>
                            e.unitName == 'عدد' && (e.totalNegativeBalance ?? 0) < 0)
                        .map((e) => _DetailRow(
                              label: e.itemName ?? '',
                              value: '${e.totalNegativeBalance ?? 0} عدد ',
                            ))
                        .toList(),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFooterItem(
                        title: 'دلار بستانکار',
                        positiveValue: _sumPositive(footer, 'دلار'),
                        color: AppColor.primaryColor,
                        unit: 'دلار',
                      ),
                      _buildFooterItem(
                        title: 'یورو بستانکار',
                        positiveValue: _sumPositive(footer, 'یورو'),
                        color: AppColor.primaryColor,
                        unit: 'یورو',
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFooterItem(
                        title: 'دلار بدهکار',
                        negativeValue: _sumNegative(footer, 'دلار'),
                        color: AppColor.accentColor,
                        unit: 'دلار',
                      ),
                      const SizedBox(height: 2),
                      _buildFooterItem(
                        title: 'یورو بدهکار',
                        negativeValue: _sumNegative(footer, 'یورو'),
                        color: AppColor.accentColor,
                        unit: 'یورو',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColor.backGroundColor1.withAlpha(130),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  _buildNetFooterItem(
                    title: 'ریال خالص',
                    netValue: _netSum(footer, 'ریال'),
                    unit: 'ریال',
                  ),
                  _buildNetFooterItem(
                    title: 'طلا خالص',
                    netValue: _netSum(footer, 'گرم'),
                    unit: 'گرم',
                  ),
                  ...footer
                      .where((item) => item.unitName == 'عدد')
                      .map((item) {
                    final netValue = (item.totalPositiveBalance ?? 0) +
                        (item.totalNegativeBalance ?? 0);
                    if (netValue == 0.0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildNetFooterItem(
                        title: item.itemName ?? 'سکه',
                        netValue: netValue,
                        unit: 'عدد',
                      ),
                    );
                  }),
                  /* ...footer.where((item) => item.itemGroupName == 'ارز').map((item) {
                    final netValue = (item.totalPositiveBalance ?? 0) +
                        (item.totalNegativeBalance ?? 0);
                    if (netValue == 0.0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildNetFooterItem(
                        title: '',
                        netValue: netValue,
                        unit: item.unitName,
                      ),
                    );
                  }), */
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNetFooterItem(
                        title: 'مجموع کل',
                        netValue: footer.fold<double>(
                          0.0,
                          (sum, item) =>
                              sum +
                              ((item.totalPositiveBalance ?? 0) +
                                  (item.totalNegativeBalance ?? 0)),
                        ),
                        unit: 'ریال',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  static double _sumPositive(
    List<TransactionInfoFooterModel> footer,
    String unitName,
  ) {
    return footer
        .where((item) => item.unitName == unitName)
        .fold(0.0, (sum, item) => sum + (item.totalPositiveBalance ?? 0));
  }

  static double _sumNegative(
    List<TransactionInfoFooterModel> footer,
    String unitName,
  ) {
    return footer
        .where((item) => item.unitName == unitName)
        .fold(0.0, (sum, item) => sum + (item.totalNegativeBalance ?? 0));
  }

  static double _netSum(List<TransactionInfoFooterModel> footer, String unitName) {
    return footer
        .where((item) => item.unitName == unitName)
        .fold(
          0.0,
          (sum, item) =>
              sum +
              ((item.totalPositiveBalance ?? 0) + (item.totalNegativeBalance ?? 0)),
        );
  }

  static Widget _footerItemWithDetail({
    required BuildContext context,
    required String title,
    double? positiveValue,
    double? negativeValue,
    required Color color,
    required String unit,
    required String dialogTitle,
    required String dialogMiddleText,
    required List<_DetailRow> detailRows,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFooterItem(
          title: title,
          positiveValue: positiveValue,
          negativeValue: negativeValue,
          color: color,
          unit: unit,
        ),
        GestureDetector(
          onTap: () => _showDetailDialog(
            context: context,
            title: dialogTitle,
            middleText: dialogMiddleText,
            rows: detailRows,
          ),
          child: SvgPicture.asset(
            'assets/svg/list.svg',
            height: 16,
            colorFilter: ColorFilter.mode(
              AppColor.textColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  static void _showDetailDialog({
    required BuildContext context,
    required String title,
    required String middleText,
    required List<_DetailRow> rows,
  }) {
    Get.defaultDialog(
      confirm: Column(
        children: rows
            .map(
              (row) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: AppTextStyle.labelText.copyWith(
                      fontSize: 12,
                      color: AppColor.backGroundColor,
                    ),
                  ),
                  Text(
                    row.value,
                    style: AppTextStyle.labelText.copyWith(
                      fontSize: 12,
                      color: AppColor.backGroundColor,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
      middleText: middleText,
      middleTextStyle: context.textTheme.bodyMedium!.copyWith(
        color: AppColor.backGroundColor,
        fontSize: 13,
      ),
      title: title,
      titleStyle: context.textTheme.titleSmall!.copyWith(
        color: AppColor.backGroundColor,
        fontSize: 14,
      ),
      backgroundColor: AppColor.textColor,
      radius: 7,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }

  static Widget _buildFooterItem({
    required String title,
    double? positiveValue,
    double? negativeValue,
    required Color color,
    String? unit,
  }) {
    final value = positiveValue ?? negativeValue ?? 0.0;

    if (value == 0.0) {
      return const SizedBox.shrink();
    }

    String formattedValue;
    if (unit == 'ریال') {
      formattedValue = value.toStringAsFixed(3).seRagham();
    } else if (unit == 'گرم') {
      formattedValue = value.toStringAsFixed(3);
    } else {
      formattedValue = value.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedValue,
                style: AppTextStyle.bodyText.copyWith(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.ltr,
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: AppTextStyle.bodyText.copyWith(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildNetFooterItem({
    required String title,
    required double netValue,
    String? unit,
  }) {
    if (netValue == 0.0) {
      return const SizedBox.shrink();
    }

    final color = netValue > 0 ? AppColor.primaryColor : AppColor.accentColor;

    String formattedValue;
    if (unit == 'ریال') {
      formattedValue = netValue.toStringAsFixed(0).seRagham();
    } else if (unit == 'گرم') {
      formattedValue = netValue.toStringAsFixed(3);
    } else {
      formattedValue = netValue.toStringAsFixed(3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedValue,
                style: AppTextStyle.bodyText.copyWith(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.ltr,
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: AppTextStyle.bodyText.copyWith(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;
}
