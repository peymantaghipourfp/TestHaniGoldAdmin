import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_polarity_chip.widget.dart';

/// Asset label + display-only بستانکار/بدهکار chips (no debit/credit sort).
///
/// Chips stack vertically to match cell polarity order and fit narrow columns.
class GoldTransactionGroupedHeader extends StatelessWidget {
  const GoldTransactionGroupedHeader({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyle.labelText.copyWith(fontSize: 11),
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        const UserBalancePolarityChip(
          label: 'بستانکار',
          isCredit: true,
          onTap: null,
        ),
        const SizedBox(height: 2),
        const UserBalancePolarityChip(
          label: 'بدهکار',
          isCredit: false,
          onTap: null,
        ),
      ],
    );
  }
}
