import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_balance_list_controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_polarity_chip.widget.dart';

/// Grouped column header: asset label + بستانکار/بدهکار sort chips.
class UserBalanceGroupedHeader extends StatelessWidget {
  const UserBalanceGroupedHeader({
    super.key,
    required this.label,
    required this.creditSortIndex,
    required this.debitSortIndex,
    required this.controller,
    this.sortEnabled = true,
    this.swapPolarityColors = false,
  });

  final String label;
  final int creditSortIndex;
  final int debitSortIndex;
  final UserBalanceListController controller;
  final bool sortEnabled;

  /// Currency headers swap بستانکار/بدهکار colors (monolith parity).
  final bool swapPolarityColors;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeIndex = controller.sortColumnIndex.value;
      final ascending = controller.sortAscending.value;

      final creditIsCredit = !swapPolarityColors;
      final debitIsCredit = swapPolarityColors;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyle.labelText.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserBalancePolarityChip(
                label: 'بستانکار',
                isCredit: creditIsCredit,
                isActive: activeIndex == creditSortIndex,
                onTap: sortEnabled
                    ? () => _onChipTap(creditSortIndex, ascending, activeIndex)
                    : null,
              ),
              const SizedBox(width: 4),
              UserBalancePolarityChip(
                label: 'بدهکار',
                isCredit: debitIsCredit,
                isActive: activeIndex == debitSortIndex,
                onTap: sortEnabled
                    ? () => _onChipTap(debitSortIndex, ascending, activeIndex)
                    : null,
              ),
            ],
          ),
        ],
      );
    });
  }

  void _onChipTap(int columnIndex, bool ascending, int? activeIndex) {
    if (activeIndex == columnIndex) {
      controller.onSort(columnIndex, !ascending);
    } else {
      controller.onSort(columnIndex, true);
    }
  }
}
