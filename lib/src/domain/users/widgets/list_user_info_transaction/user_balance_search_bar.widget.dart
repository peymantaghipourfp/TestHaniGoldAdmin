import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';

/// Premium search field for the user-balance list.
///
/// Wire [onSearch] → `getListTransactionInfoPager` and
/// [onClear] → `clearSearch` at the call site.
class UserBalanceSearchBar extends StatelessWidget {
  const UserBalanceSearchBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onClear,
    this.maxWidth,
    this.compact = false,
  });

  final TextEditingController searchController;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  /// When set, constrains the field width (desktop toolbar uses 400).
  final double? maxWidth;

  /// Mobile layout uses a fixed height of 41 in the monolith.
  final bool compact;

  static const double _radius = UserBalancePageChrome.radiusMd;

  @override
  Widget build(BuildContext context) {
    final borderSide = BorderSide(
      color: UserBalancePageChrome.slateBorder.withAlpha(120),
    );

    final field = TextFormField(
      controller: searchController,
      style: AppTextStyle.labelText,
      textInputAction: TextInputAction.search,
      onEditingComplete: () {
        if (searchController.text.isNotEmpty) {
          onSearch();
        } else {
          onClear();
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColor.textFieldColor,
        hintText: 'جستجو ... ',
        hintStyle: AppTextStyle.labelText.copyWith(
          color: AppColor.textColor.withAlpha(160),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 8 : 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(
            color: AppColor.secondary3Color,
            width: 1.5,
          ),
        ),
        prefixIcon: IconButton(
          onPressed: onSearch,
          icon: Icon(
            Icons.search,
            color: AppColor.textColor,
            size: compact ? 30 : 26,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: onClear,
          icon: Icon(Icons.close, color: AppColor.textColor),
        ),
      ),
    );

    Widget child = field;
    if (maxWidth != null) {
      child = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: child,
      );
    }
    if (compact) {
      child = SizedBox(height: 41, child: child);
    }
    return child;
  }
}
