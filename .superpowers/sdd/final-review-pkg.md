# Final Review Package — ListUserInfoTransaction UI Redesign
no-git workspace | full feature working tree

## Inventory
user_balance_data_table.widget.dart (1607 lines)
user_balance_empty_state.widget.dart (68 lines)
user_balance_error_state.widget.dart (23 lines)
user_balance_excel_dialog.widget.dart (165 lines)
user_balance_footer.widget.dart (627 lines)
user_balance_footer_item.widget.dart (174 lines)
user_balance_loading_state.widget.dart (14 lines)
user_balance_mobile_list.widget.dart (546 lines)
user_balance_page_chrome.dart (31 lines)
user_balance_polarity_chip.widget.dart (37 lines)
user_balance_search_bar.widget.dart (82 lines)
user_balance_toolbar.widget.dart (158 lines)
VIEW lib\src\domain\users\view\list_user_info_transaction.view.dart (153 lines)

## Progress ledger minors to triage
# Progress Ledger — ListUserInfoTransaction UI Redesign

Plan: c:\Users\Admin\.cursor\plans\transaction_list_ui_redesign_22ba63ed.plan.md
Persisted: docs/superpowers/plans/2026-07-13-list-user-info-transaction-ui-redesign.md
Started: 2026-07-13
Note: No-git workspace; no commits. Reviews use working-tree diffs.
Model: cursor-grok-4.5-high (user-requested)

## Tasks
- Task 1: complete (no-git working tree, review clean - Approved)
- Task 2: complete (no-git working tree, review clean - Approved)
  Minor carry: Excel dialog no soft boxShadow; mobile width plan-mandated 50% vs old 65%
- Task 3: complete (no-git working tree, review clean - Approved)
  Minor carry: unused _openExcel context; dead SizedBox before Spacer
- Task 4: complete (no-git working tree, review clean - Approved)
  Minor carry: section chrome radiusLg vs old circular(8); list.svg when chip zero (pre-existing)
- Task 5: complete (no-git working tree, review clean - Approved)
  Important for Task 7: avoid nested horizontal scroll when wiring DataTable
- Task 6: complete (no-git working tree, review clean - Approved)
  Note for Task 7: MobileList already embeds UserBalanceToolbar(isDesktop:false); keep outer scrollControllerMobile; do not double-mount toolbar
- Task 7: complete (no-git working tree, review clean - Approved)
  ⚠️ Manual regression checklist PENDING_HUMAN (no runtime UI in this session)
  Minor carry: EmptyState redundant callback; pager overlay not gated on PageState.list

## Final review
- pending



## View shell (full)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_data_table.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_empty_state.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_error_state.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_footer.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_loading_state.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_mobile_list.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_search_bar.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_toolbar.widget.dart';
import 'package:hanigold_admin/src/widget/custom_appbar1.widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/const/app_color.dart';
import '../../../widget/app_drawer.widget.dart';
import '../../../widget/background_image_total.widget.dart';
import '../../../widget/chat_floating_button.widget.dart';
import '../../../widget/pager_widget.dart';
import '../controller/user_info_transaction.controller.dart';

class ListUserInfoTransactionView
    extends GetView<UserInfoTransactionController> {
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
          title: 'Ù…Ø§Ù†Ø¯Ù‡ Ú©Ø§Ø±Ø¨Ø±Ø§Ù†',
          onBackTap: () => Get.toNamed('/home'),
        ),
        drawer: const AppDrawer(),
        body: Stack(
          children: [
            const BackgroundImageTotal(),
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(controller.state.value),
                  child: _buildStateBody(isDesktop),
                ),
              ),
            ),
            if (isDesktop) _buildDesktopPagerOverlay(),
          ],
        ),
        floatingActionButton: const ChatFloatingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildStateBody(bool isDesktop) {
    switch (controller.state.value) {
      case PageState.loading:
        return const UserBalanceLoadingState();
      case PageState.list:
        return isDesktop
            ? _buildDesktopListBody()
            : _buildMobileListBody();
      case PageState.empty:
        return UserBalanceEmptyState(onRetry: _onRetry);
      case PageState.err:
        return UserBalanceErrorState(onRetry: _onRetry);
    }
  }

  Widget _buildDesktopListBody() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 30,
            right: 30,
            top: 5,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserBalanceToolbar(
                controller: controller,
                isDesktop: true,
              ),
              const SizedBox(height: 12),
              UserBalanceFooter(controller: controller),
              const SizedBox(height: 8),
              UserBalanceDataTable(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileListBody() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: SingleChildScrollView(
        controller: controller.scrollControllerMobile,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: UserBalanceSearchBar(
                searchController: controller.searchController,
                onSearch: controller.getListTransactionInfoPager,
                onClear: controller.clearSearch,
              ),
            ),
            UserBalanceMobileList(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopPagerOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (controller.paginated.value != null)
          Container(
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: UserBalancePageChrome.toolbarDecoration(
              color: AppColor.appBarColor,
            ),
            alignment: Alignment.bottomCenter,
            child: PagerWidget(
              countPage: controller.paginated.value?.totalCount ?? 0,
              callBack: (int index) {
                controller.isChangePage(index);
              },
            ),
          ),
      ],
    );
  }
}

```

### FILE: lib\src\domain\users\widgets\list_user_info_transaction\user_balance_loading_state.widget.dart
```dart
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

```

### FILE: lib\src\domain\users\widgets\list_user_info_transaction\user_balance_empty_state.widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
import 'package:hanigold_admin/src/widget/empty.dart';

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
        child: EmptyPage(
          callback: onRetry,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 56,
                color: AppColor.textColor.withAlpha(140),
              ),
              const SizedBox(height: 16),
              Text(
                'Ù…Ø§Ù†Ø¯Ù‡â€ŒØ§ÛŒ ÛŒØ§ÙØª Ù†Ø´Ø¯',
                style: AppTextStyle.mediumBodyText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Ø¨Ø±Ø§ÛŒ Ø§ÛŒÙ† Ø¬Ø³ØªØ¬Ùˆ ÛŒØ§ ÙÛŒÙ„ØªØ± Ø§Ø·Ù„Ø§Ø¹Ø§ØªÛŒ ÙˆØ¬ÙˆØ¯ Ù†Ø¯Ø§Ø±Ø¯.',
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
                  'ØªÙ„Ø§Ø´ Ù…Ø¬Ø¯Ø¯',
                  style: AppTextStyle.mediumBodyText.copyWith(
                    color: AppColor.secondary3Color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

### FILE: lib\src\domain\users\widgets\list_user_info_transaction\user_balance_error_state.widget.dart
```dart
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
        title: 'Ø®Ø·Ø§ Ø¯Ø± Ù„ÛŒØ³Øª Ú©Ø§Ø±Ø¨Ø±Ø§Ù†',
        des: 'Ø¨Ø±Ø§ÛŒ Ø¯Ø±ÛŒØ§ÙØª Ù„ÛŒØ³Øª Ú©Ø§Ø±Ø¨Ø±Ø§Ù† Ù…Ø¬Ø¯Ø¯Ø§ ØªÙ„Ø§Ø´ Ú©Ù†ÛŒØ¯',
      ),
    );
  }
}

```

### FILE: lib\src\domain\users\widgets\list_user_info_transaction\user_balance_toolbar.widget.dart
```dart
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
              'Ø®Ø±ÙˆØ¬ÛŒ Ø§Ú©Ø³Ù„',
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
              'ÙÛŒÙ„ØªØ±',
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

```

### FILE: lib\src\domain\users\widgets\list_user_info_transaction\user_balance_search_bar.widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';

/// Premium search field for the user-balance list.
///
/// Wire [onSearch] â†’ `getListTransactionInfoPager` and
/// [onClear] â†’ `clearSearch` at the call site.
class UserBalanceSearchBar extends StatelessWidget {
  const UserBalanceSearchBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onClear,
  });

  final TextEditingController searchController;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  static const double _radius = UserBalancePageChrome.radiusMd;

  @override
  Widget build(BuildContext context) {
    final borderSide = BorderSide(
      color: UserBalancePageChrome.slateBorder.withAlpha(120),
    );

    return TextFormField(
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
        hintText: 'Ø¬Ø³ØªØ¬Ùˆ Ø¯Ø± Ù…Ø§Ù†Ø¯Ù‡ Ú©Ø§Ø±Ø¨Ø±Ø§Ù†...',
        hintStyle: AppTextStyle.labelText.copyWith(
          color: AppColor.textColor.withAlpha(160),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
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
            size: 26,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: onClear,
          icon: Icon(Icons.close, color: AppColor.textColor),
        ),
      ),
    );
  }
}

```

### FILE: lib\src\domain\users\widgets\list_user_info_transaction\user_balance_excel_dialog.widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';

/// Shared Excel export dialog for desktop and mobile toolbars.
///
/// Caller must invoke `controller.clearFilter()` **before** opening.
/// This function does not clear filters itself.
Future<void> showUserBalanceExcelDialog({
  required UserInfoTransactionController controller,
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
            width: isDesktop ? Get.width * 0.2 : Get.width * 0.5,
            height: isDesktop ? Get.height * 0.5 : Get.height * 0.7,
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
                            'Ø®Ø±ÙˆØ¬ÛŒ Ø§Ú©Ø³Ù„',
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
                            'Ù†Ø§Ù… Ø­Ø³Ø§Ø¨',
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
                              'Ø®Ø±ÙˆØ¬ÛŒ Ø§Ú©Ø³Ù„',
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

```

### FILE: lib\src\domain\users\widgets\list_user_info_transaction\user_balance_page_chrome.dart
```dart
import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';

/// Shared panel / toolbar decorations for the user-balance transaction list.
class UserBalancePageChrome {
  UserBalancePageChrome._();

  static const double radiusLg = 16;
  static const double radiusMd = 12;
  static const Color slateBorder = Color(0xFF64748B);

  static BoxDecoration panelDecoration({Color? color}) => BoxDecoration(
        color: (color ?? AppColor.backGroundColor1).withAlpha(150),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: slateBorder.withAlpha(120)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Soft toolbar strip â€” matches order/withdraw `appBarColor.withAlpha(30)` panels.
  static BoxDecoration toolbarDecoration({Color? color}) => BoxDecoration(
        color: (color ?? AppColor.appBarColor).withAlpha(30),
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: slateBorder.withAlpha(120)),
      );
}

```

### FILE: lib\src\domain\users\widgets\list_user_info_transaction\user_balance_polarity_chip.widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';

/// Balance polarity chip (Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø± / Ø¨Ø¯Ù‡Ú©Ø§Ø±) using the ChatStatusChip recipe.
class UserBalancePolarityChip extends StatelessWidget {
  const UserBalancePolarityChip({
    super.key,
    required this.label,
    required this.isCredit,
  });

  final String label;
  final bool isCredit;

  @override
  Widget build(BuildContext context) {
    final color =
        isCredit ? AppColor.primaryColor : AppColor.accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
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
  }
}

```

### FILE: lib\src\domain\users\widgets\list_user_info_transaction\user_balance_footer.widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_footer_item.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';

/// Desktop aggregate footer for the user-balance transaction list.
///
/// Visibility, fold math, and detail dialogs match the previous inline view.
class UserBalanceFooter extends StatelessWidget {
  const UserBalanceFooter({
    super.key,
    required this.controller,
  });

  final UserInfoTransactionController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.listTransactionInfoFooter.isNotEmpty
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: UserBalancePageChrome.panelDecoration(
              color: AppColor.appBarColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Ø±ÛŒØ§Ù„ Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±
                        UserBalanceFooterItem(
                          title: "Ø±ÛŒØ§Ù„ Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±",
                          positiveValue: controller.listTransactionInfoFooter
                              .where((item) => item.unitName == "Ø±ÛŒØ§Ù„")
                              .fold(
                                  0.0,
                                  (sum, item) =>
                                      sum! + (item.totalPositiveBalance ?? 0)),
                          color: AppColor.primaryColor,
                          unit: "Ø±ÛŒØ§Ù„",
                        ),
                        const SizedBox(width: 20),
                        // Ø±ÛŒØ§Ù„ Ø¨Ø¯Ù‡Ú©Ø§Ø±
                        UserBalanceFooterItem(
                          title: "Ø±ÛŒØ§Ù„ Ø¨Ø¯Ù‡Ú©Ø§Ø±",
                          negativeValue: controller.listTransactionInfoFooter
                              .where((item) => item.unitName == "Ø±ÛŒØ§Ù„")
                              .fold(
                                  0.0,
                                  (sum, item) =>
                                      sum! + (item.totalNegativeBalance ?? 0)),
                          color: AppColor.accentColor,
                          unit: "Ø±ÛŒØ§Ù„",
                        ),
                        const SizedBox(width: 20),
                        // Ø·Ù„Ø§ Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±
                        Row(
                          children: [
                            UserBalanceFooterItem(
                              title: "Ø·Ù„Ø§ Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±",
                              positiveValue: controller
                                  .listTransactionInfoFooter
                                  .where((item) => item.unitName == "Ú¯Ø±Ù…")
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum! +
                                          (item.totalPositiveBalance ?? 0)),
                              color: AppColor.primaryColor,
                              unit: "Ú¯Ø±Ù…",
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                  confirm: Column(
                                    children: controller
                                        .listTransactionInfoFooter
                                        .map((e) => e.unitName == "Ú¯Ø±Ù…" &&
                                                e.totalPositiveBalance! > 0
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    e.itemName ?? "",
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: AppColor
                                                          .backGroundColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${e.totalPositiveBalance ?? 0} Ú¯Ø±Ù… ",
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: AppColor
                                                          .backGroundColor,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox())
                                        .toList(),
                                  ),
                                  middleText: "Ù„ÛŒØ³Øª Ù…Ø§Ù†Ø¯Ù‡ Ø·Ù„Ø§ÛŒ Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±",
                                  middleTextStyle: context
                                      .textTheme.bodyMedium!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 13,
                                  ),
                                  title: "Ø¬Ø²ÛŒÛŒØ§Øª",
                                  titleStyle: context.textTheme.titleSmall!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 14,
                                  ),
                                  backgroundColor: AppColor.textColor,
                                  radius: 7,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                );
                              },
                              child: SvgPicture.asset(
                                'assets/svg/list.svg',
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  AppColor.textColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Ø·Ù„Ø§ Ø¨Ø¯Ù‡Ú©Ø§Ø±
                        Row(
                          children: [
                            UserBalanceFooterItem(
                              title: "Ø·Ù„Ø§ Ø¨Ø¯Ù‡Ú©Ø§Ø±",
                              negativeValue: controller
                                  .listTransactionInfoFooter
                                  .where((item) => item.unitName == "Ú¯Ø±Ù…")
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum! +
                                          (item.totalNegativeBalance ?? 0)),
                              color: AppColor.accentColor,
                              unit: "Ú¯Ø±Ù…",
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                  confirm: Column(
                                    children: controller
                                        .listTransactionInfoFooter
                                        .map((e) => e.unitName == "Ú¯Ø±Ù…" &&
                                                e.totalNegativeBalance! < 0
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    e.itemName ?? "",
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: AppColor
                                                          .backGroundColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${e.totalNegativeBalance ?? 0} Ú¯Ø±Ù… ",
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: AppColor
                                                          .backGroundColor,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox())
                                        .toList(),
                                  ),
                                  middleText: "Ù„ÛŒØ³Øª Ù…Ø§Ù†Ø¯Ù‡ Ø·Ù„Ø§ÛŒ Ø¨Ø¯Ù‡Ú©Ø§Ø±",
                                  middleTextStyle: context
                                      .textTheme.bodyMedium!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 13,
                                  ),
                                  title: "Ø¬Ø²ÛŒÛŒØ§Øª",
                                  titleStyle: context.textTheme.titleSmall!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 14,
                                  ),
                                  backgroundColor: AppColor.textColor,
                                  radius: 7,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                );
                              },
                              child: SvgPicture.asset(
                                'assets/svg/list.svg',
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  AppColor.textColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Ø³Ú©Ù‡ Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±
                        Row(
                          children: [
                            UserBalanceFooterItem(
                              title: "Ø³Ú©Ù‡ Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±",
                              positiveValue: controller
                                  .listTransactionInfoFooter
                                  .where((item) => item.unitName == "Ø¹Ø¯Ø¯")
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum! +
                                          (item.totalPositiveBalance ?? 0)),
                              color: AppColor.primaryColor,
                              unit: "Ø¹Ø¯Ø¯",
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                  confirm: Column(
                                    children: controller
                                        .listTransactionInfoFooter
                                        .map((e) => e.unitName == "Ø¹Ø¯Ø¯" &&
                                                e.totalPositiveBalance! > 0
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    e.itemName ?? "",
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: AppColor
                                                          .backGroundColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${e.totalPositiveBalance ?? 0} Ø¹Ø¯Ø¯ ",
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: AppColor
                                                          .backGroundColor,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox())
                                        .toList(),
                                  ),
                                  middleText: "Ù„ÛŒØ³Øª Ù…Ø§Ù†Ø¯Ù‡ Ø³Ú©Ù‡ Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±",
                                  middleTextStyle: context
                                      .textTheme.bodyMedium!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 13,
                                  ),
                                  title: "Ø¬Ø²ÛŒÛŒØ§Øª",
                                  titleStyle: context.textTheme.titleSmall!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 14,
                                  ),
                                  backgroundColor: AppColor.textColor,
                                  radius: 7,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                );
                              },
                              child: SvgPicture.asset(
                                'assets/svg/list.svg',
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  AppColor.textColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Ø³Ú©Ù‡ Ø¨Ø¯Ù‡Ú©Ø§Ø±
                        Row(
                          children: [
                            UserBalanceFooterItem(
                              title: "Ø³Ú©Ù‡ Ø¨Ø¯Ù‡Ú©Ø§Ø±",
                              negativeValue: controller
                                  .listTransactionInfoFooter
                                  .where((item) => item.unitName == "Ø¹Ø¯Ø¯")
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum! +
                                          (item.totalNegativeBalance ?? 0)),
                              color: AppColor.accentColor,
                              unit: "Ø¹Ø¯Ø¯",
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                  confirm: Column(
                                    children: controller
                                        .listTransactionInfoFooter
                                        .map((e) => e.unitName == "Ø¹Ø¯Ø¯" &&
                                                e.totalNegativeBalance! < 0
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    e.itemName ?? "",
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: AppColor
                                                          .backGroundColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${e.totalNegativeBalance ?? 0} Ø¹Ø¯Ø¯ ",
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: AppColor
                                                          .backGroundColor,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox())
                                        .toList(),
                                  ),
                                  middleText: "Ù„ÛŒØ³Øª Ù…Ø§Ù†Ø¯Ù‡ Ø³Ú©Ù‡ Ø¨Ø¯Ù‡Ú©Ø§Ø±",
                                  middleTextStyle: context
                                      .textTheme.bodyMedium!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 13,
                                  ),
                                  title: "Ø¬Ø²ÛŒÛŒØ§Øª",
                                  titleStyle: context.textTheme.titleSmall!
                                      .copyWith(
                                    color: AppColor.backGroundColor,
                                    fontSize: 14,
                                  ),
                                  backgroundColor: AppColor.textColor,
                                  radius: 7,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                );
                              },
                              child: SvgPicture.asset(
                                'assets/svg/list.svg',
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  AppColor.textColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Ø§Ø±Ø² Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±
                        Column(
                          children: [
                            UserBalanceFooterItem(
                              title: "Ø§Ø±Ø² Ø¨Ø³ØªØ§Ù†Ú©Ø§Ø±",
                              positiveValue: controller
                                  .listTransactionInfoFooter
                                  .where((item) => item.unitName == "Ø¯Ù„Ø§Ø±")
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum! +
                                          (item.totalPositiveBalance ?? 0)),
                              color: AppColor.primaryColor,
                              unit: "Ø¯Ù„Ø§Ø±",
                            ),
                            UserBalanceFooterItem(
                              title: "",
                              positiveValue: controller
                                  .listTransactionInfoFooter
                                  .where((item) => item.unitName == "ÛŒÙˆØ±Ùˆ")
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum! +
                                          (item.totalPositiveBalance ?? 0)),
                              color: AppColor.primaryColor,
                              unit: "ÛŒÙˆØ±Ùˆ",
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Ø§Ø±Ø² Ø¨Ø¯Ù‡Ú©Ø§Ø±
                        Column(
                          children: [
                            UserBalanceFooterItem(
                              title: "Ø§Ø±Ø² Ø¨Ø¯Ù‡Ú©Ø§Ø±",
                              negativeValue: controller
                                  .listTransactionInfoFooter
                                  .where((item) => item.unitName == "Ø¯Ù„Ø§Ø±")
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum! +
                                          (item.totalNegativeBalance ?? 0)),
                              color: AppColor.accentColor,
                              unit: "Ø¯Ù„Ø§Ø±",
                            ),
                            const SizedBox(height: 2),
                            // Preserved quirk: ÛŒÙˆØ±Ùˆ debit uses positiveValue + primaryColor
                            UserBalanceFooterItem(
                              title: "",
                              positiveValue: controller
                                  .listTransactionInfoFooter
                                  .where((item) => item.unitName == "ÛŒÙˆØ±Ùˆ")
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum! +
                                          (item.totalNegativeBalance ?? 0)),
                              color: AppColor.primaryColor,
                              unit: "ÛŒÙˆØ±Ùˆ",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: UserBalancePageChrome.toolbarDecoration(
                    color: AppColor.backGroundColor1,
                  ).copyWith(
                    color: AppColor.backGroundColor1.withAlpha(130),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ø±ÛŒØ§Ù„ Ø®Ø§Ù„Øµ
                            UserBalanceNetFooterItem(
                              title: "Ø±ÛŒØ§Ù„ Ø®Ø§Ù„Øµ",
                              netValue: controller.listTransactionInfoFooter
                                  .where((item) => item.unitName == "Ø±ÛŒØ§Ù„")
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum +
                                          ((item.totalPositiveBalance ?? 0) +
                                              (item.totalNegativeBalance ??
                                                  0))),
                              unit: "Ø±ÛŒØ§Ù„",
                            ),
                            const SizedBox(width: 50),
                            // Ø·Ù„Ø§ Ø®Ø§Ù„Øµ
                            UserBalanceNetFooterItem(
                              title: "Ø·Ù„Ø§ Ø®Ø§Ù„Øµ",
                              netValue: controller.listTransactionInfoFooter
                                  .where((item) => item.unitName == "Ú¯Ø±Ù…")
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum +
                                          ((item.totalPositiveBalance ?? 0) +
                                              (item.totalNegativeBalance ??
                                                  0))),
                              unit: "Ú¯Ø±Ù…",
                            ),
                            const SizedBox(width: 50),
                            // Individual Coin Types
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: controller.listTransactionInfoFooter
                                  .where((item) => item.unitName == "Ø¹Ø¯Ø¯")
                                  .map((item) {
                                final netValue =
                                    (item.totalPositiveBalance ?? 0) +
                                        (item.totalNegativeBalance ?? 0);
                                if (netValue == 0.0) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: UserBalanceNetFooterItem(
                                    title: item.itemName ?? "Ø³Ú©Ù‡",
                                    netValue: netValue,
                                    unit: "Ø¹Ø¯Ø¯",
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(width: 50),
                            // Individual Currency Types
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: controller.listTransactionInfoFooter
                                  .where(
                                      (item) => item.itemGroupName == "Ø§Ø±Ø²")
                                  .map((item) {
                                final netValue =
                                    (item.totalPositiveBalance ?? 0) +
                                        (item.totalNegativeBalance ?? 0);
                                if (netValue == 0.0) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: UserBalanceNetFooterItem(
                                    title: "",
                                    netValue: netValue,
                                    unit: item.unitName,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: Get.width * 0.2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ù…Ø¬Ù…ÙˆØ¹ Ú©Ù„:",
                              style: AppTextStyle.labelText.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            UserBalanceNetFooterItem(
                              title: "Ù…Ø¬Ù…ÙˆØ¹ Ú©Ù„",
                              netValue: controller.listTransactionInfoFooter
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum +
                                          ((item.totalPositiveBalance ?? 0) +
                                              (item.totalNegativeBalance ??
                                                  0))),
                              unit: "Ø±ÛŒØ§Ù„",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : const SizedBox());
  }
}

```

### FILE: lib\src\domain\users\widgets\list_user_info_transaction\user_balance_footer_item.widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Single credit/debit aggregate chip in the user-balance desktop footer.
///
/// Hides when the resolved value is exactly `0.0` (unchanged from the view).
class UserBalanceFooterItem extends StatelessWidget {
  const UserBalanceFooterItem({
    super.key,
    required this.title,
    this.positiveValue,
    this.negativeValue,
    required this.color,
    this.unit,
  });

  final String title;
  final double? positiveValue;
  final double? negativeValue;
  final Color color;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final value = positiveValue ?? negativeValue ?? 0.0;

    // Don't display if value is zero
    if (value == 0.0) {
      return const SizedBox();
    }

    String formattedValue;
    if (unit == "Ø±ÛŒØ§Ù„") {
      formattedValue = value.toStringAsFixed(3).seRagham();
    } else if (unit == "Ú¯Ø±Ù…") {
      formattedValue = value.toStringAsFixed(3);
    } else {
      formattedValue = value.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        border: Border.all(color: color.withAlpha(100), width: 1),
        borderRadius: BorderRadius.circular(UserBalancePageChrome.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedValue,
                style: AppTextStyle.bodyText.copyWith(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.ltr,
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: AppTextStyle.bodyText.copyWith(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Net (positive + negative) aggregate chip; polarity from sign of [netValue].
///
/// Hides when [netValue] is exactly `0.0` (unchanged from the view).
class UserBalanceNetFooterItem extends StatelessWidget {
  const UserBalanceNetFooterItem({
    super.key,
    required this.title,
    required this.netValue,
    this.unit,
  });

  final String title;
  final double netValue;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    // Don't display if net value is zero
    if (netValue == 0.0) {
      return const SizedBox();
    }

    final color =
        netValue > 0 ? AppColor.primaryColor : AppColor.accentColor;

    String formattedValue;
    if (unit == "Ø±ÛŒØ§Ù„") {
      formattedValue = netValue.toStringAsFixed(0).seRagham();
    } else if (unit == "Ú¯Ø±Ù…") {
      formattedValue = netValue.toStringAsFixed(3);
    } else {
      formattedValue = netValue.toStringAsFixed(3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        border: Border.all(color: color.withAlpha(100), width: 1),
        borderRadius: BorderRadius.circular(UserBalancePageChrome.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedValue,
                style: AppTextStyle.bodyText.copyWith(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.ltr,
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: AppTextStyle.bodyText.copyWith(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

```

### LARGE FILES — read on disk if needed
- user_balance_data_table.widget.dart (~1607 lines)
- user_balance_mobile_list.widget.dart (~546 lines)
- user_balance_footer.widget.dart included above

