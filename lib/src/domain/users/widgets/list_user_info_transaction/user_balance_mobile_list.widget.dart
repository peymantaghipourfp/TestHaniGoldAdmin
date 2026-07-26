import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_polarity_chip.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_toolbar.widget.dart';
import 'package:hanigold_admin/src/utils/num_display.dart';
import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Mobile transaction cards with sort header, infinite-scroll footer, and chrome styling.
class UserBalanceMobileList extends StatelessWidget {
  const UserBalanceMobileList({
    super.key,
    required this.controller,
  });

  final UserInfoTransactionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              UserBalanceToolbar(controller: controller, isDesktop: false),
              Expanded(child: _MobileSortHeader(controller: controller)),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            return ListView.builder(
              itemCount: controller.listTransactionInfo.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) {
                final trans = controller.listTransactionInfo[index];
                return _MobileTransactionCard(trans: trans);
              },
            );
          }),
          Obx(() {
            if (controller.isLoading.value && controller.listTransactionInfo.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: const Center(child: HaniGoldLoading()),
              );
            }

            if (!controller.hasMore.value && controller.listTransactionInfo.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'همه تراکنش‌ها نمایش داده شد',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyText.copyWith(
                    color: AppColor.textColor.withValues(alpha: 0.7),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MobileSortHeader extends StatelessWidget {
  const _MobileSortHeader({required this.controller});

  final UserInfoTransactionController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeIndex = controller.sortColumnIndex.value;
      final ascending = controller.sortAscending.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: UserBalancePageChrome.toolbarDecoration(),
        child: Row(
          children: [
            Icon(Icons.sort, color: AppColor.textColor, size: 18),
            const SizedBox(width: 8),
            Text(
              'مرتب‌سازی:',
              style: AppTextStyle.labelText.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColor.textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: activeIndex,
                  isExpanded: true,
                  style: AppTextStyle.labelText.copyWith(
                    fontSize: 11,
                    color: AppColor.textColor,
                  ),
                  dropdownColor: AppColor.appBarColor,
                  icon: Icon(Icons.arrow_drop_down, color: AppColor.textColor),
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('ریال بستانکار')),
                    DropdownMenuItem(value: 3, child: Text('ریال بدهکار')),
                    DropdownMenuItem(value: 4, child: Text('طلا بستانکار')),
                    DropdownMenuItem(value: 5, child: Text('طلا بدهکار')),
                    DropdownMenuItem(value: 6, child: Text('سکه بستانکار')),
                    DropdownMenuItem(value: 7, child: Text('سکه بدهکار')),
                    DropdownMenuItem(value: 10, child: Text('تراز کل بستانکار')),
                    DropdownMenuItem(value: 11, child: Text('تراز کل بدهکار')),
                  ],
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      controller.onSort(newValue, !ascending);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (activeIndex != null) {
                  controller.onSort(activeIndex, !ascending);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: activeIndex != null
                      ? AppColor.primaryColor.withAlpha(30)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: activeIndex != null
                        ? AppColor.primaryColor
                        : AppColor.textColor.withAlpha(30),
                    width: 1,
                  ),
                ),
                child: Icon(
                  ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: activeIndex != null ? AppColor.primaryColor : AppColor.textColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MobileTransactionCard extends StatelessWidget {
  const _MobileTransactionCard({required this.trans});

  final ListTransactionInfoItemModel trans;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: UserBalancePageChrome.panelDecoration(
        color: AppColor.appBarColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      '/userInfoTransaction',
                      parameters: {'accountId': trans.accountId.toString()},
                    );
                  },
                  child: Text(
                    trans.accountName ?? '',
                    style: AppTextStyle.labelText.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Text(
                '${trans.rowNum}',
                style: AppTextStyle.labelText.copyWith(
                  fontSize: 10,
                  color: AppColor.textColor.withAlpha(200),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 0.5, color: AppColor.dividerColor),
          const SizedBox(height: 8),
          if ((trans.cashBalanceBes ?? 0) > 0)
            _MobileBalanceLine(
              label: 'مانده وجه نقد',
              value: trans.cashBalanceBes!.toStringAsFixed(0).seRagham(),
              color: AppColor.primaryColor,
              unit: 'ریال',
              isCredit: true,
              chipLabel: 'بس',
            ),
          if ((trans.cashBalanceBed ?? 0) < 0)
            _MobileBalanceLine(
              label: 'مانده وجه نقد',
              value: '-${trans.cashBalanceBed!.abs().toStringAsFixed(0).seRagham()}',
              color: AppColor.accentColor,
              unit: 'ریال',
              isCredit: false,
              chipLabel: 'بد',
            ),
          if ((trans.goldBalanceBes ?? 0) > 0)
            _MobileBalanceLine(
              label: 'مانده آبشده',
              value: trans.goldBalanceBes!.toStringAsFixed(3),
              color: AppColor.primaryColor,
              unit: 'گرم',
              isCredit: true,
              chipLabel: 'بس',
            ),
          if ((trans.goldBalanceBed ?? 0) < 0)
            _MobileBalanceLine(
              label: 'مانده آبشده',
              value: '-${trans.goldBalanceBed!.abs().toStringAsFixed(3)}',
              color: AppColor.accentColor,
              unit: 'گرم',
              isCredit: false,
              chipLabel: 'بد',
            ),
          if ((trans.coinBalanceBes ?? 0) != 0 ||
              (trans.halfCoinBalanceBes ?? 0) != 0 ||
              (trans.quarterCoinBalanceBes ?? 0) != 0)
            _MobileBalanceLine(
              label: 'سکه',
              value:
                  'تمام ${trans.coinBalanceBes?.toDisplayString()} / نیم ${trans.halfCoinBalanceBes?.toDisplayString()} / ربع ${trans.quarterCoinBalanceBes?.toDisplayString()}',
              color: AppColor.primaryColor,
              unit: 'عدد',
              isCredit: true,
              chipLabel: 'بستانکار',
            ),
          if ((trans.coinBalanceBed ?? 0) != 0 ||
              (trans.halfCoinBalanceBed ?? 0) != 0 ||
              (trans.quarterCoinBalanceBed ?? 0) != 0)
            _MobileBalanceLine(
              label: 'سکه',
              value:
                  '-تمام ${(trans.coinBalanceBed ?? 0).abs().toDisplayString()}- / نیم ${(trans.halfCoinBalanceBed ?? 0).abs().toDisplayString()}- / ربع ${(trans.quarterCoinBalanceBed ?? 0).abs().toDisplayString()}-',
              color: AppColor.accentColor,
              unit: 'عدد',
              isCredit: false,
              chipLabel: 'بدهکار',
            ),
          if ((trans.balances ?? []).any((e) => e.unitName == 'دلار' && (e.balance ?? 0) > 0))
            _MobileBalanceLine(
              label: 'ارز',
              value:
                  '${(trans.balances ?? []).where((e) => e.unitName == 'دلار').fold<double>(0, (p, e) => p + (e.balance ?? 0))}',
              color: AppColor.primaryColor,
              unit: 'دلار',
              isCredit: true,
              chipLabel: 'بستانکار',
            ),
          if ((trans.balances ?? []).any((e) => e.unitName == 'دلار' && (e.balance ?? 0) < 0))
            _MobileBalanceLine(
              label: 'ارز',
              value:
                  '-${(trans.balances ?? []).where((e) => e.unitName == 'دلار').fold<double>(0, (p, e) => p + (e.balance ?? 0).abs())}',
              color: AppColor.accentColor,
              unit: 'دلار',
              isCredit: false,
              chipLabel: 'بدهکار',
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: UserBalancePageChrome.toolbarDecoration(),
            child: Column(
              children: [
                if ((trans.currencyValueBes ?? 0) > 0)
                  _MobileBalanceLineWithIcon(
                    label: 'تراز کل',
                    value: trans.currencyValueBes!.toStringAsFixed(0).seRagham(),
                    asset: 'assets/svg/scales.svg',
                    color: AppColor.primaryColor,
                    unit: 'ریال',
                    isCredit: true,
                    chipLabel: 'بس',
                  ),
                if ((trans.currencyValueBed ?? 0) < 0)
                  _MobileBalanceLineWithIcon(
                    label: 'تراز کل',
                    value: '-${trans.currencyValueBed!.abs().toStringAsFixed(0).seRagham()}',
                    asset: 'assets/svg/scales.svg',
                    color: AppColor.accentColor,
                    unit: 'ریال',
                    isCredit: false,
                    chipLabel: 'بد',
                  ),
                if ((trans.goldValue ?? 0) != 0)
                  _MobileBalanceLine(
                    label: 'معادل آبشده',
                    value: (trans.goldValue ?? 0) < 0
                        ? '-${trans.goldValue!.abs().toStringAsFixed(3)}'
                        : trans.goldValue!.toStringAsFixed(3),
                    color: (trans.goldValue ?? 0) < 0
                        ? AppColor.accentColor
                        : AppColor.primaryColor,
                    unit: 'گرم',
                  ),
                if ((trans.coinValue ?? 0) != 0)
                  _MobileBalanceLine(
                    label: 'معادل سکه',
                    value: (trans.coinValue ?? 0) < 0
                        ? '-${trans.coinValue!.abs().toStringAsFixed(3)}'
                        : trans.coinValue!.toStringAsFixed(3),
                    color: (trans.coinValue ?? 0) < 0
                        ? AppColor.accentColor
                        : AppColor.primaryColor,
                    unit: 'عدد',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBalanceLine extends StatelessWidget {
  const _MobileBalanceLine({
    required this.label,
    required this.value,
    required this.color,
    required this.unit,
    this.isCredit,
    this.chipLabel,
  });

  final String label;
  final String value;
  final Color color;
  final String unit;
  final bool? isCredit;
  final String? chipLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyle.labelText.copyWith(
                      fontSize: 11,
                      color: AppColor.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCredit != null && chipLabel != null) ...[
                  const SizedBox(width: 6),
                  UserBalancePolarityChip(
                    label: chipLabel!,
                    isCredit: isCredit!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(width: 4),
          Text(
            unit,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 10,
              color: AppColor.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBalanceLineWithIcon extends StatelessWidget {
  const _MobileBalanceLineWithIcon({
    required this.label,
    required this.value,
    required this.asset,
    required this.color,
    required this.unit,
    this.isCredit,
    this.chipLabel,
  });

  final String label;
  final String value;
  final String asset;
  final Color color;
  final String unit;
  final bool? isCredit;
  final String? chipLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SvgPicture.asset(
            asset,
            height: 14,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyle.labelText.copyWith(
                      fontSize: 11,
                      color: AppColor.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCredit != null && chipLabel != null) ...[
                  const SizedBox(width: 6),
                  UserBalancePolarityChip(
                    label: chipLabel!,
                    isCredit: isCredit!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(width: 4),
          Text(
            unit,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 10,
              color: AppColor.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
