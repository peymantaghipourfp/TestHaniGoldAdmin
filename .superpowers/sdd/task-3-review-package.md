f287309 feat(users): extract user-balance toolbar
 .../user_balance_excel_dialog.widget.dart          | 165 +++++++++++++++++++++
 .../user_balance_search_bar.widget.dart            | 102 +++++++++++++
 .../user_balance_toolbar.widget.dart               | 158 ++++++++++++++++++++
 3 files changed, 425 insertions(+)
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_excel_dialog.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_excel_dialog.widget.dart
new file mode 100644
index 0000000..58038ae
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_excel_dialog.widget.dart
@@ -0,0 +1,165 @@
+import 'package:flutter/material.dart';
+import 'package:get/get.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
+
+/// Shared Excel export dialog for desktop and mobile toolbars.
+///
+/// Caller must invoke `controller.clearFilter()` **before** opening.
+/// This function does not clear filters itself.
+Future<void> showUserBalanceExcelDialog({
+  required UserInfoTransactionController controller,
+  required bool isDesktop,
+}) {
+  final context = Get.context!;
+  return showGeneralDialog(
+    context: context,
+    barrierDismissible: true,
+    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
+    barrierColor: Colors.black45,
+    transitionDuration: const Duration(milliseconds: 200),
+    pageBuilder: (
+      BuildContext buildContext,
+      Animation animation,
+      Animation secondaryAnimation,
+    ) {
+      return Center(
+        child: Material(
+          color: Colors.transparent,
+          child: Container(
+            decoration: BoxDecoration(
+              borderRadius: BorderRadius.circular(UserBalancePageChrome.radiusMd),
+              color: AppColor.backGroundColor,
+              border: Border.all(
+                color: UserBalancePageChrome.slateBorder.withAlpha(120),
+              ),
+            ),
+            width: isDesktop ? Get.width * 0.2 : Get.width * 0.65,
+            height: isDesktop ? Get.height * 0.5 : Get.height * 0.5,
+            padding: const EdgeInsets.all(20),
+            child: Column(
+              children: [
+                Padding(
+                  padding: const EdgeInsets.all(8.0),
+                  child: Row(
+                    mainAxisAlignment: MainAxisAlignment.end,
+                    children: [
+                      Expanded(
+                        child: Center(
+                          child: Text(
+                            '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
+                            style: AppTextStyle.labelText.copyWith(
+                              fontSize: 15,
+                              fontWeight: FontWeight.normal,
+                            ),
+                          ),
+                        ),
+                      ),
+                    ],
+                  ),
+                ),
+                Container(
+                  color: AppColor.textColor,
+                  height: 0.2,
+                ),
+                Padding(
+                  padding: const EdgeInsets.symmetric(horizontal: 10),
+                  child: Column(
+                    children: [
+                      const SizedBox(height: 8),
+                      Column(
+                        crossAxisAlignment: CrossAxisAlignment.start,
+                        children: [
+                          Text(
+                            '┘å╪º┘à ╪¡╪│╪º╪¿',
+                            style: AppTextStyle.labelText.copyWith(
+                              fontSize: 11,
+                              fontWeight: FontWeight.normal,
+                              color: AppColor.textColor,
+                            ),
+                          ),
+                          const SizedBox(height: 10),
+                          IntrinsicHeight(
+                            child: TextFormField(
+                              autovalidateMode:
+                                  AutovalidateMode.onUserInteraction,
+                              controller: controller.nameFilterController,
+                              style: AppTextStyle.labelText.copyWith(
+                                fontSize: 15,
+                              ),
+                              textAlign: TextAlign.start,
+                              keyboardType: TextInputType.text,
+                              decoration: InputDecoration(
+                                contentPadding: const EdgeInsets.symmetric(
+                                  vertical: 11,
+                                  horizontal: 15,
+                                ),
+                                isDense: true,
+                                border: OutlineInputBorder(
+                                  borderRadius: BorderRadius.circular(6),
+                                ),
+                                filled: true,
+                                fillColor: AppColor.textFieldColor,
+                                errorMaxLines: 1,
+                              ),
+                            ),
+                          ),
+                        ],
+                      ),
+                      const SizedBox(height: 8),
+                    ],
+                  ),
+                ),
+                const Spacer(),
+                Container(
+                  margin: const EdgeInsets.symmetric(
+                    horizontal: 20,
+                    vertical: 10,
+                  ),
+                  width: double.infinity,
+                  height: 40,
+                  child: Obx(
+                    () => ElevatedButton(
+                      style: ButtonStyle(
+                        padding: const WidgetStatePropertyAll(
+                          EdgeInsets.symmetric(horizontal: 23),
+                        ),
+                        backgroundColor: WidgetStatePropertyAll(
+                          AppColor.appBarColor,
+                        ),
+                        shape: WidgetStatePropertyAll(
+                          RoundedRectangleBorder(
+                            side: BorderSide(color: AppColor.textColor),
+                            borderRadius: BorderRadius.circular(5),
+                          ),
+                        ),
+                      ),
+                      onPressed: () async {
+                        controller.getListUserInfoTransactionExcel();
+                        Get.back();
+                      },
+                      child: controller.isLoading.value
+                          ? CircularProgressIndicator(
+                              valueColor: AlwaysStoppedAnimation<Color>(
+                                AppColor.textColor,
+                              ),
+                            )
+                          : Text(
+                              '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
+                              style: AppTextStyle.labelText.copyWith(
+                                fontSize: isDesktop ? 12 : 10,
+                              ),
+                            ),
+                    ),
+                  ),
+                ),
+              ],
+            ),
+          ),
+        ),
+      );
+    },
+  );
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_search_bar.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_search_bar.widget.dart
new file mode 100644
index 0000000..05da928
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_search_bar.widget.dart
@@ -0,0 +1,102 @@
+import 'package:flutter/material.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
+
+/// Premium search field for the user-balance list.
+///
+/// Wire [onSearch] ΓåÆ `getListTransactionInfoPager` and
+/// [onClear] ΓåÆ `clearSearch` at the call site.
+class UserBalanceSearchBar extends StatelessWidget {
+  const UserBalanceSearchBar({
+    super.key,
+    required this.searchController,
+    required this.onSearch,
+    required this.onClear,
+    this.maxWidth,
+    this.compact = false,
+  });
+
+  final TextEditingController searchController;
+  final VoidCallback onSearch;
+  final VoidCallback onClear;
+
+  /// When set, constrains the field width (desktop toolbar uses 400).
+  final double? maxWidth;
+
+  /// Mobile layout uses a fixed height of 41 in the monolith.
+  final bool compact;
+
+  static const double _radius = UserBalancePageChrome.radiusMd;
+
+  @override
+  Widget build(BuildContext context) {
+    final borderSide = BorderSide(
+      color: UserBalancePageChrome.slateBorder.withAlpha(120),
+    );
+
+    final field = TextFormField(
+      controller: searchController,
+      style: AppTextStyle.labelText,
+      textInputAction: TextInputAction.search,
+      onEditingComplete: () {
+        if (searchController.text.isNotEmpty) {
+          onSearch();
+        } else {
+          onClear();
+        }
+      },
+      decoration: InputDecoration(
+        filled: true,
+        fillColor: AppColor.textFieldColor,
+        hintText: '╪¼╪│╪¬╪¼┘ê ... ',
+        hintStyle: AppTextStyle.labelText.copyWith(
+          color: AppColor.textColor.withAlpha(160),
+        ),
+        contentPadding: EdgeInsets.symmetric(
+          horizontal: 12,
+          vertical: compact ? 8 : 10,
+        ),
+        border: OutlineInputBorder(
+          borderRadius: BorderRadius.circular(_radius),
+          borderSide: borderSide,
+        ),
+        enabledBorder: OutlineInputBorder(
+          borderRadius: BorderRadius.circular(_radius),
+          borderSide: borderSide,
+        ),
+        focusedBorder: OutlineInputBorder(
+          borderRadius: BorderRadius.circular(_radius),
+          borderSide: const BorderSide(
+            color: AppColor.secondary3Color,
+            width: 1.5,
+          ),
+        ),
+        prefixIcon: IconButton(
+          onPressed: onSearch,
+          icon: Icon(
+            Icons.search,
+            color: AppColor.textColor,
+            size: compact ? 30 : 26,
+          ),
+        ),
+        suffixIcon: IconButton(
+          onPressed: onClear,
+          icon: Icon(Icons.close, color: AppColor.textColor),
+        ),
+      ),
+    );
+
+    Widget child = field;
+    if (maxWidth != null) {
+      child = ConstrainedBox(
+        constraints: BoxConstraints(maxWidth: maxWidth!),
+        child: child,
+      );
+    }
+    if (compact) {
+      child = SizedBox(height: 41, child: child);
+    }
+    return child;
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_toolbar.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_toolbar.widget.dart
new file mode 100644
index 0000000..6f9b837
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_toolbar.widget.dart
@@ -0,0 +1,158 @@
+import 'package:flutter/material.dart';
+import 'package:flutter_svg/svg.dart';
+import 'package:get/get.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/filter_dialog_report_setting.widget.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_excel_dialog.widget.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_search_bar.widget.dart';
+
+/// Desktop/mobile action row for the user-balance list.
+///
+/// Desktop embeds [UserBalanceSearchBar] + Excel + Filter inside chrome.
+/// Mobile exposes Excel / Filter icon actions (search lives outside this widget).
+class UserBalanceToolbar extends StatelessWidget {
+  const UserBalanceToolbar({
+    super.key,
+    required this.controller,
+    required this.isDesktop,
+  });
+
+  final UserInfoTransactionController controller;
+  final bool isDesktop;
+
+  @override
+  Widget build(BuildContext context) {
+    if (isDesktop) {
+      return _buildDesktopToolbar(context);
+    }
+    return _buildMobileActions(context);
+  }
+
+  Widget _buildDesktopToolbar(BuildContext context) {
+    return Container(
+      decoration: UserBalancePageChrome.toolbarDecoration(),
+      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
+      child: Row(
+        children: [
+          SizedBox(
+            width: 400,
+            child: UserBalanceSearchBar(
+              searchController: controller.searchController,
+              onSearch: controller.getListTransactionInfoPager,
+              onClear: controller.clearSearch,
+            ),
+          ),
+          const SizedBox(width: 10),
+          const Spacer(),
+          OutlinedButton.icon(
+            onPressed: () => _openExcel(context),
+            label: Text(
+              '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
+              style: AppTextStyle.labelText.copyWith(
+                color: AppColor.primaryColor,
+                fontSize: 12,
+              ),
+            ),
+            icon: SvgPicture.asset(
+              'assets/svg/excel.svg',
+              height: 24,
+            ),
+          ),
+          const SizedBox(width: 10),
+          OutlinedButton.icon(
+            onPressed: () => _openFilter(context),
+            icon: SvgPicture.asset(
+              'assets/svg/filter3.svg',
+              height: 22,
+              colorFilter: const ColorFilter.mode(
+                AppColor.textColor,
+                BlendMode.srcIn,
+              ),
+            ),
+            label: Text(
+              '┘ü█î┘ä╪¬╪▒',
+              style: AppTextStyle.labelText,
+            ),
+          ),
+        ],
+      ),
+    );
+  }
+
+  Widget _buildMobileActions(BuildContext context) {
+    return Padding(
+      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
+      child: Row(
+        mainAxisAlignment: MainAxisAlignment.start,
+        children: [
+          GestureDetector(
+            onTap: () => _openExcel(context),
+            child: SvgPicture.asset(
+              'assets/svg/excel.svg',
+              height: 30,
+            ),
+          ),
+          const SizedBox(width: 8),
+          GestureDetector(
+            onTap: () => _openFilter(context),
+            child: SvgPicture.asset(
+              'assets/svg/filter3.svg',
+              height: 26,
+              colorFilter: const ColorFilter.mode(
+                AppColor.textColor,
+                BlendMode.srcIn,
+              ),
+            ),
+          ),
+        ],
+      ),
+    );
+  }
+
+  Future<void> _openExcel(BuildContext context) async {
+    controller.clearFilter();
+    await showUserBalanceExcelDialog(
+      controller: controller,
+      isDesktop: isDesktop,
+    );
+  }
+
+  Future<void> _openFilter(BuildContext context) async {
+    await showGeneralDialog(
+      context: context,
+      barrierDismissible: true,
+      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
+      barrierColor: Colors.black45,
+      transitionDuration: const Duration(milliseconds: 200),
+      pageBuilder: (
+        BuildContext buildContext,
+        Animation animation,
+        Animation secondaryAnimation,
+      ) {
+        return Center(
+          child: Material(
+            color: Colors.transparent,
+            child: Container(
+              decoration: BoxDecoration(
+                borderRadius: BorderRadius.circular(8),
+                color: AppColor.backGroundColor,
+              ),
+              width: isDesktop ? Get.width * 0.5 : Get.width * 0.9,
+              height: isDesktop ? Get.height * 0.8 : Get.height * 0.9,
+              padding: const EdgeInsets.only(
+                left: 20,
+                right: 20,
+                top: 20,
+                bottom: 3,
+              ),
+              child: FilterDialog(controller: controller),
+            ),
+          ),
+        );
+      },
+    );
+  }
+}
