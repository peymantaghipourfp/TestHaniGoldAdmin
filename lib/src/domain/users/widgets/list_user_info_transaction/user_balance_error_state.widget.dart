import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/widget/err_page.dart';

/// Error state wrapper for the user-balance list.
class UserBalanceErrorState extends StatelessWidget {
  const UserBalanceErrorState({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ErrPage(
        callback: onRetry,
        title: 'خطا در لیست کاربران',
        des: 'برای دریافت لیست کاربران مجددا تلاش کنید',
      ),
    );
  }
}
