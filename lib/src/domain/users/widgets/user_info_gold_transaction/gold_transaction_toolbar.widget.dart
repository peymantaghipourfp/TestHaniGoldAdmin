import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/gold_transaction_filter.widget.dart';

/// Filter + clear-checkboxes actions for the per-account gold transaction list.
class GoldTransactionToolbar extends StatelessWidget {
  const GoldTransactionToolbar({
    super.key,
    required this.controller,
  });

  final UserInfoDetailGoldTransactionController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GoldTransactionFilterWidget(
          controller: controller,
          onFilterApplied: () {
            controller.getTransactionInfoGoldListPager(
              controller.id.value.toString(),
            );
          },
          onFilterCleared: () {
            controller.getTransactionInfoGoldListPager(
              controller.id.value.toString(),
            );
          },
        ),
        const SizedBox(width: 20),
        OutlinedButton.icon(
          onPressed: _showClearCheckboxesDialog,
          label: Text(
            'حذف چک باکس',
            style: AppTextStyle.labelText.copyWith(
              color: AppColor.textColorSecondary.withAlpha(200),
              fontSize: 12,
            ),
          ),
          icon: Icon(
            Icons.check_box_outline_blank,
            color: AppColor.textColor.withAlpha(30),
          ),
        ),
      ],
    );
  }

  void _showClearCheckboxesDialog() {
    Get.defaultDialog(
      backgroundColor: AppColor.backGroundColor,
      title: 'برداشتن تیک چک باکس',
      titleStyle: AppTextStyle.smallTitleText,
      middleText: 'آیا از برداشتن تیک همه چک باکس ها مطمئن هستید؟',
      middleTextStyle: AppTextStyle.bodyText,
      confirm: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(AppColor.primaryColor),
        ),
        onPressed: () {
          Get.back();
          controller.removeCheckedAll(controller.id.value, false);
        },
        child: Text(
          'اعمال تغییر',
          style: AppTextStyle.bodyText,
        ),
      ),
    );
  }
}
