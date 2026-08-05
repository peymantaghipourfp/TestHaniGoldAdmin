import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_balance_list.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_helper.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// KPI summary row for the user-balance list (users, rial, gold, coin).
class UserBalanceStatsGrid extends StatelessWidget {
  const UserBalanceStatsGrid({
    super.key,
    required this.controller,
  });

  final UserBalanceListController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final snapshot = buildUserBalanceKpis(
        totalCount: controller.paginated.value?.totalCount,
        footer: controller.listTransactionInfoFooter,
      );

      final cards = <_KpiCardData>[
        _KpiCardData(
          label: 'تعداد کل کاربران',
          value: _formatUserCount(snapshot.totalUsers),
          valueColor: AppColor.textColor,
        ),
        _KpiCardData(
          label: 'مجموع مانده ریالی',
          value: _formatRial(snapshot.netRial),
          valueColor: _balanceColor(snapshot.netRial),
        ),
        _KpiCardData(
          label: 'مجموع طلا (گرم)',
          value: _formatGold(snapshot.netGoldGrams),
          valueColor: _balanceColor(snapshot.netGoldGrams),
        ),
        _KpiCardData(
          label: 'تعداد سکه',
          value: _formatCoin(snapshot.netCoinCount),
          valueColor: _balanceColor(snapshot.netCoinCount),
        ),
      ];

      return LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final columns = !maxWidth.isFinite || maxWidth <= 0
              ? 1
              : maxWidth >= 900
                  ? 4
                  : maxWidth >= 480
                      ? 2
                      : 1;
          const spacing = 12.0;
          final cardWidth = maxWidth.isFinite && maxWidth > 0
              ? (maxWidth - (columns - 1) * spacing) / columns
              : null;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final card in cards)
                SizedBox(
                  width: cardWidth,
                  child: _KpiCard(data: card),
                ),
            ],
          );
        },
      );
    });
  }

  static String _formatUserCount(int? count) {
    if (count == null) {
      return '—';
    }
    return count.toString().seRagham();
  }

  static String _formatRial(double value) {
    if (value < 0) {
      return '-${value.abs().toStringAsFixed(0).seRagham()}';
    } else {
      return value.toStringAsFixed(0).seRagham();
    }
  }

  static String _formatGold(double value) {
    return value.toStringAsFixed(3);
  }

  static String _formatCoin(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString().seRagham();
    }
    return value.toStringAsFixed(3);
  }

  static Color _balanceColor(double value) {
    if (value > 0) {
      return AppColor.primaryColor;
    }
    if (value < 0) {
      return AppColor.accentColor;
    }
    return AppColor.textColor;
  }
}

class _KpiCardData {
  const _KpiCardData({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});

  final _KpiCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: UserBalancePageChrome.panelDecoration(
        color: AppColor.appBarColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 11,
              color: AppColor.textColor.withAlpha(180),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: AppTextStyle.mediumBodyText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: data.valueColor,
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}
