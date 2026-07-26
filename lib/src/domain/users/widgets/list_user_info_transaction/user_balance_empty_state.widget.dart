import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';

/// Empty-list state for the user-balance page.
class UserBalanceEmptyState extends StatelessWidget {
  const UserBalanceEmptyState({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: UserBalancePageChrome.panelDecoration(
          color: AppColor.appBarColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: AppColor.textColor.withAlpha(140),
            ),
            const SizedBox(height: 16),
            Text(
              'مانده‌ای یافت نشد',
              style: AppTextStyle.mediumBodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'برای این جستجو یا فیلتر اطلاعاتی وجود ندارد.',
              style: AppTextStyle.bodyText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColor.secondary3Color,
              ),
              child: Text(
                'تلاش مجدد',
                style: AppTextStyle.mediumBodyText.copyWith(
                  color: AppColor.secondary3Color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
