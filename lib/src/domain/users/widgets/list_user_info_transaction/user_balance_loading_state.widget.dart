import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';

/// Full-page loading state for the user-balance list.
class UserBalanceLoadingState extends StatelessWidget {
  const UserBalanceLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: HaniGoldLoading.large(),
    );
  }
}
