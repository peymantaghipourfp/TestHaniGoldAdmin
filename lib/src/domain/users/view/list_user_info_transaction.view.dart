import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/utils/num_display.dart';
import 'package:hanigold_admin/src/widget/custom_appbar1.widget.dart';
import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/const/app_color.dart';
import '../../../config/const/app_text_style.dart';
import '../../../widget/app_drawer.widget.dart';
import '../../../widget/background_image_total.widget.dart';
import '../../../widget/chat_floating_button.widget.dart';
import '../../../widget/pager_widget.dart';
import '../controller/user_info_transaction.controller.dart';
import '../widgets/filter_dialog_report_setting.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_desktop_body.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_empty_state.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_error_state.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_footer.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_loading_state.widget.dart';
import '../widgets/list_user_info_transaction/user_balance_search_bar.widget.dart';

class ListUserInfoTransactionView extends GetView<UserInfoTransactionController> {
  const ListUserInfoTransactionView({super.key});

  void _onRetry() {
    controller.clearSearch();
    controller.getListTransactionInfoPager();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Obx(
      () => Scaffold(
        appBar: CustomAppbar1(
          title: 'مانده کاربران',
          onBackTap: () => Get.toNamed('/home'),
        ),
        drawer: const AppDrawer(),
        body: Stack(
          children: [
            const BackgroundImageTotal(),
            SafeArea(
              child: switch (controller.state.value) {
                PageState.loading => const UserBalanceLoadingState(),
                PageState.empty => UserBalanceEmptyState(onRetry: _onRetry),
                PageState.err => UserBalanceErrorState(onRetry: _onRetry),
                PageState.list => _buildListBody(context, isDesktop),
              },
            ),
            if (isDesktop && controller.paginated.value != null) _buildPagerOverlay(),
          ],
        ),
        floatingActionButton: const ChatFloatingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildListBody(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return SizedBox(
        height: Get.height,
        width: Get.width,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: UserBalanceDesktopBody(
            controller: controller,
            footer: UserBalanceFooter(controller: controller),
          ),
        ),
      );
    }

    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: SingleChildScrollView(
        controller: controller.scrollControllerMobile,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: UserBalanceSearchBar(
                searchController: controller.searchController,
                onSearch: controller.getListTransactionInfoPager,
                onClear: controller.clearSearch,
                compact: true,
              ),
            ),
            _buildMobileTransactionList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPagerOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.bottomCenter,
          child: PagerWidget(
            countPage: controller.paginated.value?.totalCount ?? 0,
            callBack: controller.isChangePage,
          ),
        ),
      ],
    );
  }

  // Task 7 will extract mobile list into dedicated widgets.
  Widget _buildMobileTransactionList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        controller.clearFilter();
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                          barrierColor: Colors.black45,
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder: (buildContext, animation, secondaryAnimation) {
                            return Center(
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColor.backGroundColor,
                                  ),
                                  width: Get.width * 0.65,
                                  height: Get.height * 0.5,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
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
                                      Container(color: AppColor.textColor, height: 0.2),
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
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    controller: controller.nameFilterController,
                                                    style: AppTextStyle.labelText.copyWith(fontSize: 15),
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
                                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        width: double.infinity,
                                        height: 40,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            padding: const WidgetStatePropertyAll(
                                              EdgeInsets.symmetric(horizontal: 23),
                                            ),
                                            backgroundColor: WidgetStatePropertyAll(AppColor.appBarColor),
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
                                                  style: AppTextStyle.labelText.copyWith(fontSize: 10),
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
                      },
                      child: SvgPicture.asset('assets/svg/excel.svg', height: 30),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                          barrierColor: Colors.black45,
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder: (buildContext, animation, secondaryAnimation) {
                            return Center(
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColor.backGroundColor,
                                  ),
                                  width: Get.width * 0.9,
                                  height: Get.height * 0.9,
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
                      },
                      child: SvgPicture.asset(
                        'assets/svg/filter3.svg',
                        height: 26,
                        colorFilter: ColorFilter.mode(AppColor.textColor, BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildMobileSortHeader()),
            ],
          ),
          const SizedBox(height: 10),
          ListView.builder(
            itemCount: controller.listTransactionInfo.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, index) {
              final trans = controller.listTransactionInfo[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.appBarColor.withAlpha(200),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.textColor.withAlpha(75)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                '/userInfoTransaction',
                                parameters: {'accountId': trans.accountId.toString()},
                              );
                            },
                            child: Text(
                              trans.accountName ?? '',
                              style: AppTextStyle.labelText.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColor.textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Text(
                          '${trans.rowNum}',
                          style: AppTextStyle.labelText.copyWith(
                            fontSize: 10,
                            color: AppColor.textColor.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(height: 0.5, color: AppColor.dividerColor),
                    const SizedBox(height: 8),
                    if ((trans.cashBalanceBes ?? 0) > 0)
                      _mobileLine(
                        'مانده وجه نقد (بس)',
                        trans.cashBalanceBes!.toStringAsFixed(0).seRagham(),
                        AppColor.primaryColor,
                        'ریال',
                      ),
                    if ((trans.cashBalanceBed ?? 0) < 0)
                      _mobileLine(
                        'مانده وجه نقد (بد)',
                        '-${trans.cashBalanceBed!.abs().toStringAsFixed(0).seRagham()}',
                        AppColor.accentColor,
                        'ریال',
                      ),
                    if ((trans.goldBalanceBes ?? 0) > 0)
                      _mobileLine(
                        'مانده آبشده (بس)',
                        trans.goldBalanceBes!.toStringAsFixed(3),
                        AppColor.primaryColor,
                        'گرم',
                      ),
                    if ((trans.goldBalanceBed ?? 0) < 0)
                      _mobileLine(
                        'مانده آبشده (بد)',
                        '-${trans.goldBalanceBed!.abs().toStringAsFixed(3)}',
                        AppColor.accentColor,
                        'گرم',
                      ),
                    if ((trans.coinBalanceBes ?? 0) != 0 ||
                        (trans.halfCoinBalanceBes ?? 0) != 0 ||
                        (trans.quarterCoinBalanceBes ?? 0) != 0)
                      _mobileLine(
                        'سکه بستانکار',
                        'تمام ${trans.coinBalanceBes?.toDisplayString()} / نیم ${trans.halfCoinBalanceBes?.toDisplayString()} / ربع ${trans.quarterCoinBalanceBes?.toDisplayString()}',
                        AppColor.primaryColor,
                        'عدد',
                      ),
                    if ((trans.coinBalanceBed ?? 0) != 0 ||
                        (trans.halfCoinBalanceBed ?? 0) != 0 ||
                        (trans.quarterCoinBalanceBed ?? 0) != 0)
                      _mobileLine(
                        'سکه بدهکار',
                        '-تمام ${(trans.coinBalanceBed ?? 0).abs().toDisplayString()}- / نیم ${(trans.halfCoinBalanceBed ?? 0).abs().toDisplayString()}- / ربع ${(trans.quarterCoinBalanceBed ?? 0).abs().toDisplayString()}-',
                        AppColor.accentColor,
                        'عدد',
                      ),
                    if ((trans.balances ?? []).any((e) => e.unitName == 'دلار' && (e.balance ?? 0) > 0))
                      _mobileLine(
                        'ارز بستانکار',
                        '${(trans.balances ?? []).where((e) => e.unitName == 'دلار').fold<double>(0, (p, e) => p + (e.balance ?? 0))}',
                        AppColor.primaryColor,
                        'دلار',
                      ),
                    if ((trans.balances ?? []).any((e) => e.unitName == 'دلار' && (e.balance ?? 0) < 0))
                      _mobileLine(
                        'ارز بدهکار',
                        '-${(trans.balances ?? []).where((e) => e.unitName == 'دلار').fold<double>(0, (p, e) => p + (e.balance ?? 0).abs())}',
                        AppColor.accentColor,
                        'دلار',
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColor.backGroundColor.withAlpha(60),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColor.textColor.withAlpha(50)),
                      ),
                      child: Column(
                        children: [
                          if ((trans.currencyValueBes ?? 0) > 0)
                            _mobileLineWithIcon(
                              'تراز کل بس',
                              trans.currencyValueBes!.toStringAsFixed(0).seRagham(),
                              'assets/svg/scales.svg',
                              AppColor.primaryColor,
                              'ریال',
                            ),
                          if ((trans.currencyValueBed ?? 0) < 0)
                            _mobileLineWithIcon(
                              'تراز کل بد',
                              '-${trans.currencyValueBed!.abs().toStringAsFixed(0).seRagham()}',
                              'assets/svg/scales.svg',
                              AppColor.accentColor,
                              'ریال',
                            ),
                          if ((trans.goldValue ?? 0) != 0)
                            _mobileLine(
                              'معادل آبشده',
                              (trans.goldValue ?? 0) < 0
                                  ? '-${trans.goldValue!.abs().toStringAsFixed(3)}'
                                  : trans.goldValue!.toStringAsFixed(3),
                              (trans.goldValue ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
                              'گرم',
                            ),
                          if ((trans.coinValue ?? 0) != 0)
                            _mobileLine(
                              'معادل سکه',
                              (trans.coinValue ?? 0) < 0
                                  ? '-${trans.coinValue!.abs().toStringAsFixed(3)}'
                                  : trans.coinValue!.toStringAsFixed(3),
                              (trans.coinValue ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
                              'عدد',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Obx(() {
            if (controller.isLoading.value && controller.listTransactionInfo.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: const Center(child: HaniGoldLoading()),
              );
            }

            if (!controller.hasMore.value && controller.listTransactionInfo.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'همه تراکنش‌ها نمایش داده شد',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyText.copyWith(
                    color: AppColor.textColor.withValues(alpha: 0.7),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMobileSortHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColor.appBarColor.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.textColor.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(Icons.sort, color: AppColor.textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            'مرتب‌سازی:',
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: controller.sortColumnIndex.value,
                isExpanded: true,
                style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.textColor),
                dropdownColor: AppColor.appBarColor,
                icon: Icon(Icons.arrow_drop_down, color: AppColor.textColor),
                items: const [
                  DropdownMenuItem(value: 2, child: Text('ریال بستانکار')),
                  DropdownMenuItem(value: 3, child: Text('ریال بدهکار')),
                  DropdownMenuItem(value: 4, child: Text('طلا بستانکار')),
                  DropdownMenuItem(value: 5, child: Text('طلا بدهکار')),
                  DropdownMenuItem(value: 6, child: Text('سکه بستانکار')),
                  DropdownMenuItem(value: 7, child: Text('سکه بدهکار')),
                  DropdownMenuItem(value: 10, child: Text('تراز کل بستانکار')),
                  DropdownMenuItem(value: 11, child: Text('تراز کل بدهکار')),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    controller.onSort(newValue, !controller.sortAscending.value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (controller.sortColumnIndex.value != null) {
                controller.onSort(
                  controller.sortColumnIndex.value!,
                  !controller.sortAscending.value,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: controller.sortColumnIndex.value != null
                    ? AppColor.primaryColor.withAlpha(30)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: controller.sortColumnIndex.value != null
                      ? AppColor.primaryColor
                      : AppColor.textColor.withAlpha(30),
                  width: 1,
                ),
              ),
              child: Icon(
                controller.sortAscending.value ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: controller.sortColumnIndex.value != null
                    ? AppColor.primaryColor
                    : AppColor.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileLine(String label, String value, Color color, String itemName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.textColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(width: 4),
          Text(
            itemName,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 10,
              color: AppColor.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileLineWithIcon(
    String label,
    String value,
    String asset,
    Color color,
    String itemName,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SvgPicture.asset(
            asset,
            height: 14,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.textColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(width: 4),
          Text(
            itemName,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 10,
              color: AppColor.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
