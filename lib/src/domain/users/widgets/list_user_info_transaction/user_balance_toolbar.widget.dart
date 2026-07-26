import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/filter_dialog_report_setting.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_excel_dialog.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_search_bar.widget.dart';

/// Desktop/mobile action row for the user-balance list.
///
/// Desktop embeds [UserBalanceSearchBar] + Excel + Filter inside chrome.
/// Mobile exposes Excel / Filter icon actions (search lives outside this widget).
class UserBalanceToolbar extends StatelessWidget {
  const UserBalanceToolbar({
    super.key,
    required this.controller,
    required this.isDesktop,
  });

  final UserInfoTransactionController controller;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopToolbar(context);
    }
    return _buildMobileActions(context);
  }

  Widget _buildDesktopToolbar(BuildContext context) {
    return Container(
      decoration: UserBalancePageChrome.toolbarDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 400,
            child: UserBalanceSearchBar(
              searchController: controller.searchController,
              onSearch: controller.getListTransactionInfoPager,
              onClear: controller.clearSearch,
            ),
          ),
          const SizedBox(width: 10),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => _openExcel(context),
            label: Text(
              'خروجی اکسل',
              style: AppTextStyle.labelText.copyWith(
                color: AppColor.primaryColor,
                fontSize: 12,
              ),
            ),
            icon: SvgPicture.asset(
              'assets/svg/excel.svg',
              height: 24,
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () => _openFilter(context),
            icon: SvgPicture.asset(
              'assets/svg/filter3.svg',
              height: 22,
              colorFilter: const ColorFilter.mode(
                AppColor.textColor,
                BlendMode.srcIn,
              ),
            ),
            label: Text(
              'فیلتر',
              style: AppTextStyle.labelText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openExcel(context),
            child: SvgPicture.asset(
              'assets/svg/excel.svg',
              height: 30,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _openFilter(context),
            child: SvgPicture.asset(
              'assets/svg/filter3.svg',
              height: 26,
              colorFilter: const ColorFilter.mode(
                AppColor.textColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openExcel(BuildContext context) async {
    controller.clearFilter();
    await showUserBalanceExcelDialog(
      controller: controller,
      isDesktop: isDesktop,
    );
  }

  Future<void> _openFilter(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColor.backGroundColor,
              ),
              width: isDesktop ? Get.width * 0.5 : Get.width * 0.9,
              height: isDesktop ? Get.height * 0.8 : Get.height * 0.9,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 3,
              ),
              child: FilterDialog(controller: controller),
            ),
          ),
        );
      },
    );
  }
}
