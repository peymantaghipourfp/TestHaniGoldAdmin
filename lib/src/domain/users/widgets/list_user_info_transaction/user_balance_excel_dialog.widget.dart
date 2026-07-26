import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_balance_list_controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';

/// Shared Excel export dialog for desktop and mobile toolbars.
///
/// Caller must invoke `controller.clearFilter()` **before** opening.
/// This function does not clear filters itself.
Future<void> showUserBalanceExcelDialog({
  required UserBalanceListController controller,
  required bool isDesktop,
}) {
  final context = Get.context!;
  return showGeneralDialog(
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
              borderRadius: BorderRadius.circular(UserBalancePageChrome.radiusMd),
              color: AppColor.backGroundColor,
              border: Border.all(
                color: UserBalancePageChrome.slateBorder.withAlpha(120),
              ),
            ),
            width: isDesktop ? Get.width * 0.2 : Get.width * 0.65,
            height: isDesktop ? Get.height * 0.5 : Get.height * 0.5,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'خروجی اکسل',
                            style: AppTextStyle.labelText.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: AppColor.textColor,
                  height: 0.2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نام حساب',
                            style: AppTextStyle.labelText.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: AppColor.textColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          IntrinsicHeight(
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: controller.nameFilterController,
                              style: AppTextStyle.labelText.copyWith(
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                  horizontal: 15,
                                ),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                filled: true,
                                fillColor: AppColor.textFieldColor,
                                errorMaxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  width: double.infinity,
                  height: 40,
                  child: Obx(
                    () => ElevatedButton(
                      style: ButtonStyle(
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 23),
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          AppColor.appBarColor,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            side: BorderSide(color: AppColor.textColor),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        controller.getListUserInfoTransactionExcel();
                        Get.back();
                      },
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColor.textColor,
                              ),
                            )
                          : Text(
                              'خروجی اکسل',
                              style: AppTextStyle.labelText.copyWith(
                                fontSize: isDesktop ? 12 : 10,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
