import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';

/// Balance polarity chip (بستانکار / بدهکار) using the ChatStatusChip recipe.
class UserBalancePolarityChip extends StatelessWidget {
  const UserBalancePolarityChip({
    super.key,
    required this.label,
    required this.isCredit,
    this.isActive = false,
    this.onTap,
  });

  final String label;
  final bool isCredit;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isCredit ? AppColor.primaryColor : AppColor.accentColor;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(isActive ? 56 : 36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(isActive ? 200 : 100)),
      ),
      child: Text(
        label,
        style: AppTextStyle.bodyText.copyWith(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(child: chip),
        ),
      ),
    );
  }
}
