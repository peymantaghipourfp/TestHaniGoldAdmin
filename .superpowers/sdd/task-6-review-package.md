2b28ebf refactor(users): thin view shell and responsive footer grid
 .superpowers/sdd/task-6-report.md                  |   87 +-
 .../view/list_user_info_transaction.view.dart      | 3377 +++-----------------
 .../user_balance_footer.widget.dart                |  507 +++
 3 files changed, 1020 insertions(+), 2951 deletions(-)
diff --git a/.superpowers/sdd/task-6-report.md b/.superpowers/sdd/task-6-report.md
index 91924a9..c97a707 100644
--- a/.superpowers/sdd/task-6-report.md
+++ b/.superpowers/sdd/task-6-report.md
@@ -1,30 +1,79 @@
-# Task 6 Report: Upload Repository Timeouts
+# Task 6 Report ΓÇö Footer grid + thin view shell
 
-## Status
-**Complete**
+## Status: Complete
 
-## Changes
-Modified `lib/src/config/repository/upload.repository.dart`:
+**Branch:** `feat/user-balance-grouped-table`
 
-- Added Dio timeout options to `UploadRepository` constructor
-- Added identical Dio timeout options to `UploadRepositoryDesktop` constructor
+## Files changed
 
-```dart
-uploadDio.options.connectTimeout = const Duration(seconds: 30);
-uploadDio.options.sendTimeout = const Duration(seconds: 60);
-uploadDio.options.receiveTimeout = const Duration(seconds: 30);
-```
+| File | Action | Purpose |
+| --- | --- | --- |
+| `user_balance_footer.widget.dart` | Created | Responsive footer with `Wrap(spacing: 16, runSpacing: 12)` for credit/debit + net totals |
+| `list_user_info_transaction.view.dart` | Rewritten | Thin shell with `PageState` switch, desktop body wiring, pager overlay |
+
+## Implementation notes
+
+### `UserBalanceFooter`
+
+- Extracted footer UI from monolith L481ΓÇô900 and helpers `_buildFooterItem` / `_buildNetFooterItem` (L2491ΓÇô2633)
+- Replaced horizontal `SingleChildScrollView` with `Wrap(spacing: 16, runSpacing: 12)` for both credit/debit and net sections
+- Preserved detail dialogs for gold/coin breakdowns (list icon ΓåÆ `Get.defaultDialog`)
+- Preserved monolith formatting (`seRagham` for ╪▒█î╪º┘ä, 3-decimal for ┌»╪▒┘à, etc.)
+- Observes `controller.listTransactionInfoFooter` via internal `Obx`
+
+### Thin view shell
+
+- `Scaffold` with `CustomAppbar1`, `AppDrawer`, `BackgroundImageTotal`, `ChatFloatingButton`
+- `SafeArea` + `switch (controller.state.value)`:
+  - `loading` ΓåÆ `UserBalanceLoadingState`
+  - `empty` ΓåÆ `UserBalanceEmptyState(onRetry: _onRetry)`
+  - `err` ΓåÆ `UserBalanceErrorState(onRetry: _onRetry)`
+  - `list` ΓåÆ desktop `UserBalanceDesktopBody(footer: UserBalanceFooter(...))` or mobile column
+- `_onRetry`: `clearSearch` + `getListTransactionInfoPager`
+- Desktop pager overlay retained when `paginated != null`
+- Mobile: `UserBalanceSearchBar` + `_buildMobileTransactionList` (deferred to Task 7)
+
+### Removed from view
+
+- `buildDataColumns` / `buildDataRows` (now in `UserBalanceDataTable`)
+- Inline desktop table, toolbar, stats, footer builders
+- Horizontal scroll wrapper around desktop content
 
-No changes to endpoints, headers, interceptors, or upload method behavior.
+### Line counts
+
+| File | Lines |
+| --- | ---: |
+| View (shell + mobile temp) | 669 |
+| Footer widget | 507 |
+| View shell only (approx.) | ~120 |
+
+Mobile helpers remain in view until Task 7 extraction; shell core meets the ~150ΓÇô200 line target for non-mobile code.
+
+## Verification
 
-## Analyzer
 ```
-flutter analyze lib/src/config/repository/upload.repository.dart
-No issues found!
+flutter analyze lib/src/domain/users/view/list_user_info_transaction.view.dart \
+              lib/src/domain/users/widgets/list_user_info_transaction/user_balance_footer.widget.dart
+ΓåÆ No issues found!
 ```
 
-## Concerns
-None. Minimal scoped change as specified. `sendTimeout` (60s) is longer than connect/receive (30s), appropriate for multipart uploads.
+| Check | Result |
+| --- | --- |
+| Footer uses `Wrap` not horizontal scroll | Pass |
+| `PageState.empty` wired with retry | Pass |
+| Desktop body + footer integrated | Pass |
+| Pager overlay on desktop | Pass |
+| `buildDataColumns`/`buildDataRows` removed from view | Pass |
+| `graphify update .` | Pass |
+
+## Concerns / follow-ups
+
+1. **Mobile extraction (Task 7)** ΓÇö `_buildMobileTransactionList`, sort header, and line helpers still in view (~550 lines).
+2. **Euro debt chip** ΓÇö monolith used `positiveValue` param for █î┘ê╪▒┘ê ╪¿╪»┘ç┌⌐╪º╪▒; preserved for parity.
+3. **Manual smoke test** ΓÇö desktop footer wrap layout and empty-state retry should be verified in app.
 
 ## Git
-Not committed (per instructions).
+
+```
+refactor(users): thin view shell and responsive footer grid
+```
diff --git a/lib/src/domain/users/view/list_user_info_transaction.view.dart b/lib/src/domain/users/view/list_user_info_transaction.view.dart
index 46ec82f..ffe164e 100644
--- a/lib/src/domain/users/view/list_user_info_transaction.view.dart
+++ b/lib/src/domain/users/view/list_user_info_transaction.view.dart
@@ -10,2963 +10,461 @@ import 'package:responsive_framework/responsive_framework.dart';
 import '../../../config/const/app_color.dart';
 import '../../../config/const/app_text_style.dart';
 import '../../../widget/app_drawer.widget.dart';
 import '../../../widget/background_image_total.widget.dart';
 import '../../../widget/chat_floating_button.widget.dart';
-import '../../../widget/err_page.dart';
 import '../../../widget/pager_widget.dart';
-import '../../chat/widget/chat_dialog.widget.dart';
 import '../controller/user_info_transaction.controller.dart';
 import '../widgets/filter_dialog_report_setting.widget.dart';
+import '../widgets/list_user_info_transaction/user_balance_desktop_body.widget.dart';
+import '../widgets/list_user_info_transaction/user_balance_empty_state.widget.dart';
+import '../widgets/list_user_info_transaction/user_balance_error_state.widget.dart';
+import '../widgets/list_user_info_transaction/user_balance_footer.widget.dart';
+import '../widgets/list_user_info_transaction/user_balance_loading_state.widget.dart';
+import '../widgets/list_user_info_transaction/user_balance_search_bar.widget.dart';
 
 class ListUserInfoTransactionView extends GetView<UserInfoTransactionController> {
   const ListUserInfoTransactionView({super.key});
 
+  void _onRetry() {
+    controller.clearSearch();
+    controller.getListTransactionInfoPager();
+  }
+
   @override
   Widget build(BuildContext context) {
     final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
-    return Obx(()=>Scaffold(
-      appBar: CustomAppbar1(
-        title: '┘à╪º┘å╪»┘ç ┌⌐╪º╪▒╪¿╪▒╪º┘å',
-        onBackTap: () => Get.toNamed("/home"),
-      ),
-      drawer: const AppDrawer(),
-      body:Stack(
-        children: [
-          BackgroundImageTotal(),
-          SafeArea(
-            child: controller.state.value == PageState.loading
-                ? Center(
-              child: HaniGoldLoading.large(),
-            )
-                : controller.state.value == PageState.list
-                ? SizedBox(
-              height: Get.height,
-              width: Get.width,
-              child: SingleChildScrollView(
-                controller:isDesktop ? null : controller.scrollControllerMobile,
-                child: Column(
-                  children: [
-                    //┘ü█î┘ä╪» ╪¼╪│╪¬╪¼┘ê
-                    isDesktop ? SizedBox.shrink() :
-                    Container(
-                      margin: EdgeInsets.symmetric(
-                          horizontal: 15, vertical: 10),
-                      height: 41,
-                      child: TextFormField(
-                        // onChanged: (value){
-                        //   Future.delayed(const Duration(milliseconds: 3000), () {
-                        //     controller.getListTransactionInfo();
-                        //   });
-                        // },
-                        controller: controller.searchController,
-                        style: AppTextStyle.labelText,
-                        textInputAction: TextInputAction.search,
-                        // onFieldSubmitted: (value) async {
-                        //   // Future.delayed(const Duration(milliseconds: 700), () {
-                        //      controller.getListTransactionInfo();
-                        //   // });
-                        // },
-                        onEditingComplete: () async {
-                          if (controller.searchController.text.isNotEmpty) {
-                            await controller.getListTransactionInfoPager();
-                          }else {
-                            controller.clearSearch();
-                          }
-                      },
-
-                        decoration: InputDecoration(
-                          border: OutlineInputBorder(
-                            borderRadius: BorderRadius.circular(10),
-                          ),
-                          filled: true,
-                          fillColor: AppColor.textFieldColor,
-                          hintText: "╪¼╪│╪¬╪¼┘ê ... ",
-                          hintStyle: AppTextStyle.labelText,
-
-                          prefixIcon: IconButton(
-                              onPressed: () async {
-                                controller.getListTransactionInfoPager();
-                              },
-                              icon: Icon(
-                                Icons.search,
-                                color: AppColor.textColor,
-                                size: 30,
-                              )),
-                            suffixIcon: IconButton(
-                              onPressed: controller.clearSearch,
-                              icon: Icon(Icons.close, color: AppColor.textColor),
-                            )
-                        ),
-                      ),
-                    ),
-                    isDesktop ?
-                    Container(
-                      margin: EdgeInsets.only(left: 30,right: 30, top: 5,bottom: 30),
-                      padding: EdgeInsets.only(left: 20,right: 20, top: 5, bottom: 40),
-                      color: AppColor.backGroundColor1.withAlpha(150),
-                      child: SingleChildScrollView(
-                        scrollDirection: Axis.horizontal,
-                        controller:
-                        controller.scrollController,
-                        physics: ClampingScrollPhysics(),
-                        child: Row(
-                          children: [
-                            SingleChildScrollView(
-                              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
-                                children: [
-                                  Container(
-                                    padding: EdgeInsets.symmetric( vertical: 5),
-                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                                      children: [
-                                        Container(
-                                          width: 400,
-                                          child: TextFormField(
-                                            // onChanged: (value){
-                                            //   Future.delayed(const Duration(milliseconds: 3000), () {
-                                            //     controller.getListTransactionInfo();
-                                            //   });
-                                            // },
-                                            controller: controller.searchController,
-                                            style: AppTextStyle.labelText,
-                                            textInputAction: TextInputAction.search,
-                                            // onFieldSubmitted: (value) async {
-                                            //   // Future.delayed(const Duration(milliseconds: 700), () {
-                                            //      controller.getListTransactionInfo();
-                                            //   // });
-                                            // },
-                                            onEditingComplete: () async {
-                                              if (controller.searchController.text.isNotEmpty) {
-                                                await controller.getListTransactionInfoPager();
-                                              }else {
-                                                controller.clearSearch();
-                                              }
-                                            },
 
-                                            decoration: InputDecoration(
-                                                border: OutlineInputBorder(
-                                                  borderRadius: BorderRadius.circular(10),
-                                                ),
-                                                filled: true,
-                                                fillColor: AppColor.textFieldColor,
-                                                hintText: "╪¼╪│╪¬╪¼┘ê ... ",
-                                                hintStyle: AppTextStyle.labelText,
-
-                                                prefixIcon: IconButton(
-                                                    onPressed: () async {
-                                                      controller.getListTransactionInfoPager();
-                                                    },
-                                                    icon: Icon(
-                                                      Icons.search,
-                                                      color: AppColor.textColor,
-                                                      size: 30,
-                                                    )),
-                                                suffixIcon: IconButton(
-                                                  onPressed: controller.clearSearch,
-                                                  icon: Icon(Icons.close, color: AppColor.textColor),
-                                                )
-                                            ),
-                                          ),
-                                        ),
-                                        SizedBox(width: 10),
-                                        Row(
-                                          children: [
-                                            // ╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä
-                                            OutlinedButton.icon(
-                                              onPressed: () async {
-                                                controller.clearFilter();
-                                                showGeneralDialog(
-                                                    context: context,
-                                                    barrierDismissible: true,
-                                                    barrierLabel:
-                                                    MaterialLocalizations
-                                                        .of(context)
-                                                        .modalBarrierDismissLabel,
-                                                    barrierColor:
-                                                    Colors.black45,
-                                                    transitionDuration:
-                                                    const Duration(
-                                                        milliseconds:
-                                                        200),
-                                                    pageBuilder: (BuildContext
-                                                    buildContext,
-                                                        Animation animation,
-                                                        Animation
-                                                        secondaryAnimation) {
-                                                      return Center(
-                                                        child: Material(
-                                                          color: Colors
-                                                              .transparent,
-                                                          child: Container(
-                                                            decoration: BoxDecoration(
-                                                                borderRadius:
-                                                                BorderRadius
-                                                                    .circular(
-                                                                    8),
-                                                                color: AppColor
-                                                                    .backGroundColor),
-                                                            width: isDesktop
-                                                                ? Get.width *
-                                                                0.2
-                                                                : Get.width *
-                                                                0.5,
-                                                            height: isDesktop
-                                                                ? Get.height *
-                                                                0.5
-                                                                : Get.height *
-                                                                0.7,
-                                                            padding:
-                                                            EdgeInsets
-                                                                .all(20),
-                                                            child: Column(
-                                                              children: [
-                                                                Padding(
-                                                                  padding:
-                                                                  const EdgeInsets
-                                                                      .all(
-                                                                      8.0),
-                                                                  child: Row(
-                                                                    mainAxisAlignment:
-                                                                    MainAxisAlignment
-                                                                        .end,
-                                                                    children: [
-                                                                      Expanded(
-                                                                        child:
-                                                                        Center(
-                                                                          child:
-                                                                          Text(
-                                                                            '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
-                                                                            style: AppTextStyle.labelText.copyWith(
-                                                                              fontSize: 15,
-                                                                              fontWeight: FontWeight.normal,
-                                                                            ),
-                                                                          ),
-                                                                        ),
-                                                                      ),
-                                                                    ],
-                                                                  ),
-                                                                ),
-                                                                Container(
-                                                                  color: AppColor
-                                                                      .textColor,
-                                                                  height: 0.2,
-                                                                ),
-                                                                Padding(
-                                                                  padding: const EdgeInsets
-                                                                      .symmetric(
-                                                                      horizontal:
-                                                                      10),
-                                                                  child:
-                                                                  Column(
-                                                                    children: [
-                                                                      SizedBox(
-                                                                        height:
-                                                                        8,
-                                                                      ),
-                                                                      Column(
-                                                                        crossAxisAlignment:
-                                                                        CrossAxisAlignment.start,
-                                                                        children: [
-                                                                          Text(
-                                                                            '┘å╪º┘à ╪¡╪│╪º╪¿',
-                                                                            style: AppTextStyle.labelText.copyWith(fontSize: 11, fontWeight: FontWeight.normal, color: AppColor.textColor),
-                                                                          ),
-                                                                          SizedBox(
-                                                                            height: 10,
-                                                                          ),
-                                                                          IntrinsicHeight(
-                                                                            child: TextFormField(
-                                                                              autovalidateMode: AutovalidateMode.onUserInteraction,
-                                                                              controller: controller.nameFilterController,
-                                                                              style: AppTextStyle.labelText.copyWith(fontSize: 15),
-                                                                              textAlign: TextAlign.start,
-                                                                              keyboardType: TextInputType.text,
-                                                                              decoration: InputDecoration(
-                                                                                contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 15),
-                                                                                isDense: true,
-                                                                                border: OutlineInputBorder(
-                                                                                  borderRadius: BorderRadius.circular(6),
-                                                                                ),
-                                                                                filled: true,
-                                                                                fillColor: AppColor.textFieldColor,
-                                                                                errorMaxLines: 1,
-                                                                              ),
-                                                                            ),
-                                                                          ),
-                                                                        ],
-                                                                      ),
-                                                                      SizedBox(
-                                                                        height:
-                                                                        8,
-                                                                      ),
-                                                                    ],
-                                                                  ),
-                                                                ),
-                                                                Spacer(),
-                                                                Container(
-                                                                  margin: EdgeInsets.symmetric(
-                                                                      horizontal:
-                                                                      20,
-                                                                      vertical:
-                                                                      10),
-                                                                  width: double
-                                                                      .infinity,
-                                                                  height: 40,
-                                                                  child:
-                                                                  ElevatedButton(
-                                                                    style: ButtonStyle(
-                                                                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 23)),
-                                                                        // elevation: WidgetStatePropertyAll(5),
-                                                                        backgroundColor: WidgetStatePropertyAll(AppColor.appBarColor),
-                                                                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(side: BorderSide(color: AppColor.textColor), borderRadius: BorderRadius.circular(5)))),
-                                                                    onPressed:
-                                                                        () async {
-                                                                      controller.getListUserInfoTransactionExcel();
-                                                                      Get.back();
-                                                                    },
-                                                                    child: controller
-                                                                        .isLoading
-                                                                        .value
-                                                                        ? CircularProgressIndicator(
-                                                                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.textColor),
-                                                                    )
-                                                                        : Text(
-                                                                      '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
-                                                                      style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),
-                                                                    ),
-                                                                  ),
-                                                                ),
-                                                              ],
-                                                            ),
-                                                          ),
-                                                        ),
-                                                      );
-                                                    });
-                                              },
-                                              label: Text(
-                                                '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
-                                                style: AppTextStyle
-                                                    .labelText.copyWith(color: AppColor.primaryColor,fontSize: 12),
-                                              ),
-                                              icon: SvgPicture.asset(
-                                                'assets/svg/excel.svg',
-                                                height: 24,
-                                              ),
-                                            ),
-                                            SizedBox(width: 10),
-                                            // Filter Button
-                                            OutlinedButton.icon(
-                                              onPressed: () async {
-                                                //controller.fetchAccountList();
-                                                showGeneralDialog(
-                                                    context: context,
-                                                    barrierDismissible: true,
-                                                    barrierLabel:
-                                                    MaterialLocalizations
-                                                        .of(context)
-                                                        .modalBarrierDismissLabel,
-                                                    barrierColor:
-                                                    Colors.black45,
-                                                    transitionDuration:
-                                                    const Duration(
-                                                        milliseconds:
-                                                        200),
-                                                    pageBuilder: (BuildContext
-                                                    buildContext,
-                                                        Animation animation,
-                                                        Animation
-                                                        secondaryAnimation) {
-                                                      return Center(
-                                                        child: Material(
-                                                          color: Colors
-                                                              .transparent,
-                                                          child: Container(
-                                                            decoration: BoxDecoration(
-                                                                borderRadius:
-                                                                BorderRadius
-                                                                    .circular(
-                                                                    8),
-                                                                color: AppColor
-                                                                    .backGroundColor),
-                                                            width: isDesktop
-                                                                ? Get.width *
-                                                                0.5
-                                                                : Get.width *
-                                                                0.8,
-                                                            height: isDesktop
-                                                                ? Get.height *
-                                                                0.8
-                                                                : Get.height *
-                                                                0.9,
-                                                            padding:
-                                                            EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 3),
-                                                            child: FilterDialog(controller: controller),
-                                                          ),
-                                                        ),
-                                                      );
-                                                    });
-                                              },
-                                                icon: SvgPicture.asset(
-                                                    'assets/svg/filter3.svg',
-                                                    height: 22,
-                                                    colorFilter:
-                                                    ColorFilter.mode(AppColor.textColor, BlendMode.srcIn,
-                                                    )),
-                                                label: Text(
-                                                  '┘ü█î┘ä╪¬╪▒',
-                                                  style: AppTextStyle
-                                                      .labelText,
-                                                ),
-                                            ),
-                                            /*ElevatedButton(
-                            style: ButtonStyle(
-                                padding: WidgetStatePropertyAll(
-                                  EdgeInsets
-                                      .symmetric(
-                                      horizontal: 15,
-                                      vertical: 7
-                                  ),
-                                ),
-                                fixedSize: WidgetStatePropertyAll(
-                                    Size(100, 30)),
-                                elevation: WidgetStatePropertyAll(
-                                    5),
-                                backgroundColor:
-                                WidgetStatePropertyAll(
-                                    AppColor
-                                        .secondary3Color),
-                                shape: WidgetStatePropertyAll(
-                                    RoundedRectangleBorder(
-                                        borderRadius: BorderRadius
-                                            .circular(
-                                            5)))),
-                            onPressed: () {
-                              controller.getListUserInfoTransactionExcel();
-                              Get.back();
-                            },
-                            child: Text(
-                              '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
-                              style: AppTextStyle
-                                  .labelText,
-                            ),
-                            //onPressed: () => orderController.getOrderExcel(),
-                          ),*/
-                                          ],
-                                        ),
-                                      ],
-                                    ),
-                                  ),
-                                  DataTable(
-                                    columns:
-                                    buildDataColumns(),
-                                    sortColumnIndex: controller
-                                        .sortColumnIndex
-                                        .value,
-                                    sortAscending: controller
-                                        .sortAscending
-                                        .value,
-                                    border: TableBorder.symmetric(inside: BorderSide(color: AppColor.textColor,width: 0.3),
-                                      outside: BorderSide(color: AppColor.textColor,width: 0.3),
-                                      borderRadius: BorderRadius.circular(8),
-                                    ),
-                                    dividerThickness: 0.3,
-                                    rows: buildDataRows(
-                                        context),
-                                    dataRowMaxHeight: double.infinity,
-                                    //dataRowColor: WidgetStatePropertyAll(AppColor.secondaryColor),
-                                    headingRowColor: WidgetStatePropertyAll(AppColor.buttonColor.withAlpha(40)),
-                                    headingRowHeight: 35,
-                                    columnSpacing: 30,
-                                    horizontalMargin: 5,
-                                  ),
-                                  // Footer Section
-                                  Obx(() => controller.listTransactionInfoFooter.isNotEmpty
-                                      ? Container(
-                                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
-                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
-                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color:AppColor.appBarColor.withAlpha(130),),
-                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
-                                          children: [
-                                            Container(
-                                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
-                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
-                                            //decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color:AppColor.appBarColor.withOpacity(0.5),),
-                                            child: SingleChildScrollView(
-                                            scrollDirection: Axis.horizontal,
-                                            child: Row(
-                                              children: [
-                                                // ╪▒█î╪º┘ä ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒
-                                                _buildFooterItem(
-                                                  title: "╪▒█î╪º┘ä ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒",
-                                                  positiveValue: controller.listTransactionInfoFooter
-                                                      .where((item) => item.unitName == "╪▒█î╪º┘ä")
-                                                      .fold(0.0, (sum, item) => sum! + (item.totalPositiveBalance ?? 0)),
-                                                  color: AppColor.primaryColor,
-                                                  unit: "╪▒█î╪º┘ä",
-                                                ),
-                                                SizedBox(width: 20),
-                                                // ╪▒█î╪º┘ä ╪¿╪»┘ç┌⌐╪º╪▒
-                                                _buildFooterItem(
-                                                  title: "╪▒█î╪º┘ä ╪¿╪»┘ç┌⌐╪º╪▒",
-                                                  negativeValue: controller.listTransactionInfoFooter
-                                                      .where((item) => item.unitName == "╪▒█î╪º┘ä")
-                                                      .fold(0.0, (sum, item) => sum! + (item.totalNegativeBalance ?? 0)),
-                                                  color: AppColor.accentColor,
-                                                  unit: "╪▒█î╪º┘ä",
-                                                ),
-                                                SizedBox(width: 20),
-                                                // ╪╖┘ä╪º ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒
-                                                Row(
-                                                  children: [
-                                                    _buildFooterItem(
-                                                      title: "╪╖┘ä╪º ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒",
-                                                      positiveValue: controller.listTransactionInfoFooter
-                                                          .where((item) => item.unitName == "┌»╪▒┘à")
-                                                          .fold(0.0, (sum, item) => sum! + (item.totalPositiveBalance ?? 0)),
-                                                      color: AppColor.primaryColor,
-                                                      unit: "┌»╪▒┘à",
-                                                    ),
-                                                    GestureDetector(
-                                                      onTap: (){
-                                                        Get.defaultDialog(
-                                                          confirm: Column(
-                                                            children: controller.listTransactionInfoFooter.map((e)=>e.unitName=="┌»╪▒┘à" && e.totalPositiveBalance! > 0 ? Row(
-                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                                                              children: [
-                                                                Text(
-                                                                  e.itemName??"",
-                                                                  style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                                                ), Text(
-                                                                  "${e.totalPositiveBalance??0} ┌»╪▒┘à ",
-                                                                  style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                                                ),
-                                                              ],
-                                                            ):SizedBox()).toList(),
-                                                          ),
-                                                          middleText: "┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪╖┘ä╪º█î ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒",
-                                                          middleTextStyle: context
-                                                              .textTheme.bodyMedium!
-                                                              .copyWith(
-                                                              color: AppColor.backGroundColor,
-                                                              fontSize: 13),
-                                                          title: "╪¼╪▓█î█î╪º╪¬",
-                                                          titleStyle: context
-                                                              .textTheme.titleSmall!
-                                                              .copyWith(
-                                                              color: AppColor.backGroundColor,
-                                                              fontSize: 14),
-                                                          backgroundColor: AppColor.textColor,
-                                                          radius: 7,
-                                                          contentPadding: EdgeInsets.symmetric(
-                                                              horizontal: 20, vertical: 20),
-
-
-                                                        );
-                                                      },
-                                                      child: SvgPicture.asset('assets/svg/list.svg',height: 16,
-                                                          colorFilter: ColorFilter.mode(
-                                                            AppColor.textColor,
-                                                            BlendMode.srcIn,
-                                                          )),
-                                                    ),
-                                                  ],
-                                                ),
-                                                SizedBox(width: 20),
-                                                // ╪╖┘ä╪º ╪¿╪»┘ç┌⌐╪º╪▒
-                                                Row(
-                                                  children: [
-                                                    _buildFooterItem(
-                                                      title: "╪╖┘ä╪º ╪¿╪»┘ç┌⌐╪º╪▒",
-                                                      negativeValue: controller.listTransactionInfoFooter
-                                                          .where((item) => item.unitName == "┌»╪▒┘à")
-                                                          .fold(0.0, (sum, item) => sum! + (item.totalNegativeBalance ?? 0)),
-                                                      color: AppColor.accentColor,
-                                                      unit: "┌»╪▒┘à",
-                                                    ),
-                                                    GestureDetector(
-                                                      onTap: (){
-                                                        Get.defaultDialog(
-                                                          confirm: Column(
-                                                            children: controller.listTransactionInfoFooter.map((e)=>e.unitName=="┌»╪▒┘à" && e.totalNegativeBalance! < 0 ? Row(
-                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                                                              children: [
-                                                                Text(
-                                                                  e.itemName??"",
-                                                                  style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                                                ), Text(
-                                                                  "${e.totalNegativeBalance??0} ┌»╪▒┘à ",
-                                                                  style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                                                ),
-                                                              ],
-                                                            ):SizedBox()).toList(),
-                                                          ),
-                                                          middleText: "┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪╖┘ä╪º█î ╪¿╪»┘ç┌⌐╪º╪▒",
-                                                          middleTextStyle: context
-                                                              .textTheme.bodyMedium!
-                                                              .copyWith(
-                                                              color: AppColor.backGroundColor,
-                                                              fontSize: 13),
-                                                          title: "╪¼╪▓█î█î╪º╪¬",
-                                                          titleStyle: context
-                                                              .textTheme.titleSmall!
-                                                              .copyWith(
-                                                              color: AppColor.backGroundColor,
-                                                              fontSize: 14),
-                                                          backgroundColor: AppColor.textColor,
-                                                          radius: 7,
-                                                          contentPadding: EdgeInsets.symmetric(
-                                                              horizontal: 20, vertical: 20),
-
-
-                                                        );
-                                                      },
-                                                      child: SvgPicture.asset('assets/svg/list.svg',height: 16,
-                                                          colorFilter: ColorFilter.mode(
-                                                            AppColor.textColor,
-                                                            BlendMode.srcIn,
-                                                          )),
-                                                    ),
-                                                  ],
-                                                ),
-                                                SizedBox(width: 20),
-                                                // ╪│┌⌐┘ç ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒
-                                                Row(
-                                                  children: [
-                                                    _buildFooterItem(
-                                                      title: "╪│┌⌐┘ç ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒",
-                                                      positiveValue: controller.listTransactionInfoFooter
-                                                          .where((item) => item.unitName == "╪╣╪»╪»")
-                                                          .fold(0.0, (sum, item) => sum! + (item.totalPositiveBalance ?? 0)),
-                                                      color: AppColor.primaryColor,
-                                                      unit: "╪╣╪»╪»",
-                                                    ),
-                                                    GestureDetector(
-                                                      onTap: (){
-                                                        Get.defaultDialog(
-                                                          confirm: Column(
-                                                            children: controller.listTransactionInfoFooter.map((e)=>e.unitName=="╪╣╪»╪»" && e.totalPositiveBalance! > 0 ? Row(
-                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                                                              children: [
-                                                                Text(
-                                                                  e.itemName??"",
-                                                                  style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                                                ), Text(
-                                                                  "${e.totalPositiveBalance??0} ╪╣╪»╪» ",
-                                                                  style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                                                ),
-                                                              ],
-                                                            ):SizedBox()).toList(),
-                                                          ),
-                                                          middleText: "┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪│┌⌐┘ç ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒",
-                                                          middleTextStyle: context
-                                                              .textTheme.bodyMedium!
-                                                              .copyWith(
-                                                              color: AppColor.backGroundColor,
-                                                              fontSize: 13),
-                                                          title: "╪¼╪▓█î█î╪º╪¬",
-                                                          titleStyle: context
-                                                              .textTheme.titleSmall!
-                                                              .copyWith(
-                                                              color: AppColor.backGroundColor,
-                                                              fontSize: 14),
-                                                          backgroundColor: AppColor.textColor,
-                                                          radius: 7,
-                                                          contentPadding: EdgeInsets.symmetric(
-                                                              horizontal: 20, vertical: 20),
-
-
-                                                        );
-                                                      },
-                                                      child: SvgPicture.asset('assets/svg/list.svg',height: 16,
-                                                          colorFilter: ColorFilter.mode(
-                                                            AppColor.textColor,
-                                                            BlendMode.srcIn,
-                                                          )),
-                                                    ),
-                                                  ],
-                                                ),
-                                                SizedBox(width: 20),
-                                                // ╪│┌⌐┘ç ╪¿╪»┘ç┌⌐╪º╪▒
-                                                Row(
-                                                  children: [
-                                                    _buildFooterItem(
-                                                      title: "╪│┌⌐┘ç ╪¿╪»┘ç┌⌐╪º╪▒",
-                                                      negativeValue: controller.listTransactionInfoFooter
-                                                          .where((item) => item.unitName == "╪╣╪»╪»")
-                                                          .fold(0.0, (sum, item) => sum! + (item.totalNegativeBalance ?? 0)),
-                                                      color: AppColor.accentColor,
-                                                      unit: "╪╣╪»╪»",
-                                                    ),
-                                                    GestureDetector(
-                                                      onTap: (){
-                                                        Get.defaultDialog(
-                                                          confirm: Column(
-                                                            children: controller.listTransactionInfoFooter.map((e)=>e.unitName=="╪╣╪»╪»" && e.totalNegativeBalance! < 0 ? Row(
-                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                                                              children: [
-                                                                Text(
-                                                                  e.itemName??"",
-                                                                  style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                                                ), Text(
-                                                                  "${e.totalNegativeBalance??0} ╪╣╪»╪» ",
-                                                                  style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                                                ),
-                                                              ],
-                                                            ):SizedBox()).toList(),
-                                                          ),
-                                                          middleText: "┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪│┌⌐┘ç ╪¿╪»┘ç┌⌐╪º╪▒",
-                                                          middleTextStyle: context
-                                                              .textTheme.bodyMedium!
-                                                              .copyWith(
-                                                              color: AppColor.backGroundColor,
-                                                              fontSize: 13),
-                                                          title: "╪¼╪▓█î█î╪º╪¬",
-                                                          titleStyle: context
-                                                              .textTheme.titleSmall!
-                                                              .copyWith(
-                                                              color: AppColor.backGroundColor,
-                                                              fontSize: 14),
-                                                          backgroundColor: AppColor.textColor,
-                                                          radius: 7,
-                                                          contentPadding: EdgeInsets.symmetric(
-                                                              horizontal: 20, vertical: 20),
-
-
-                                                        );
-                                                      },
-                                                      child: SvgPicture.asset('assets/svg/list.svg',height: 16,
-                                                          colorFilter: ColorFilter.mode(
-                                                            AppColor.textColor,
-                                                            BlendMode.srcIn,
-                                                          )),
-                                                    ),
-                                                  ],
-                                                ),
-                                                SizedBox(width: 20),
-                                                // ╪º╪▒╪▓ ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒
-                                                Column(
-                                                  children: [
-                                                    _buildFooterItem(
-                                                      title: "╪º╪▒╪▓ ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒",
-                                                      positiveValue: controller.listTransactionInfoFooter
-                                                          .where((item) => item.unitName == "╪»┘ä╪º╪▒")
-                                                          .fold(0.0, (sum, item) => sum! + (item.totalPositiveBalance ?? 0)),
-                                                      color: AppColor.primaryColor,
-                                                      unit: "╪»┘ä╪º╪▒",
-                                                    ),
-                                                    _buildFooterItem(
-                                                      title: "",
-                                                      positiveValue: controller.listTransactionInfoFooter
-                                                          .where((item) => item.unitName == "█î┘ê╪▒┘ê")
-                                                          .fold(0.0, (sum, item) => sum! + (item.totalPositiveBalance ?? 0)),
-                                                      color: AppColor.primaryColor,
-                                                      unit: "█î┘ê╪▒┘ê",
-                                                    ),
-                                                  ],
-                                                ),
-                                                SizedBox(width: 20),
-                                                // ╪º╪▒╪▓ ╪¿╪»┘ç┌⌐╪º╪▒
-                                                Column(
-                                                  children: [
-                                                    _buildFooterItem(
-                                                      title: "╪º╪▒╪▓ ╪¿╪»┘ç┌⌐╪º╪▒",
-                                                      negativeValue: controller.listTransactionInfoFooter
-                                                          .where((item) => item.unitName == "╪»┘ä╪º╪▒")
-                                                          .fold(0.0, (sum, item) => sum! + (item.totalNegativeBalance ?? 0)),
-                                                      color: AppColor.accentColor,
-                                                      unit: "╪»┘ä╪º╪▒",
-                                                    ),
-                                                    SizedBox(height: 2,),
-                                                    _buildFooterItem(
-                                                      title: "",
-                                                      positiveValue: controller.listTransactionInfoFooter
-                                                          .where((item) => item.unitName == "█î┘ê╪▒┘ê")
-                                                          .fold(0.0, (sum, item) => sum! + (item.totalNegativeBalance ?? 0)),
-                                                      color: AppColor.primaryColor,
-                                                      unit: "█î┘ê╪▒┘ê",
-                                                    ),
-                                                  ],
-                                                ),
-                                              ],
-                                            ),
-                                                                                ),
-                                                                              ),
-                                            Container(
-                                              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
-                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
-                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: AppColor.backGroundColor1.withAlpha(130),),
-                                              child: Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
-                                                children: [
-                                                  Container(
-                                                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
-                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
-                                                    //decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: AppColor.appBarColor.withOpacity(0.5),),
-                                                    child:  Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
-                                                        children: [
-                                                          // ╪▒█î╪º┘ä ╪«╪º┘ä╪╡
-                                                          _buildNetFooterItem(
-                                                            title: "╪▒█î╪º┘ä ╪«╪º┘ä╪╡",
-                                                            netValue: controller.listTransactionInfoFooter
-                                                                .where((item) => item.unitName == "╪▒█î╪º┘ä")
-                                                                .fold(0.0, (sum, item) => sum + ((item.totalPositiveBalance ?? 0) + (item.totalNegativeBalance ?? 0))),
-                                                            unit: "╪▒█î╪º┘ä",
-                                                          ),
-                                                          SizedBox(width: 50),
-                                                          // ╪╖┘ä╪º ╪«╪º┘ä╪╡
-                                                          _buildNetFooterItem(
-                                                            title: "╪╖┘ä╪º ╪«╪º┘ä╪╡",
-                                                            netValue: controller.listTransactionInfoFooter
-                                                                .where((item) => item.unitName == "┌»╪▒┘à")
-                                                                .fold(0.0, (sum, item) => sum + ((item.totalPositiveBalance ?? 0) + (item.totalNegativeBalance ?? 0))),
-                                                            unit: "┌»╪▒┘à",
-                                                          ),
-                                                          SizedBox(width: 50),
-                                                          // Individual Coin Types
-                                                          Container(
-                                                            child: Column(
-                                                              crossAxisAlignment: CrossAxisAlignment.start,
-                                                              children: controller.listTransactionInfoFooter
-                                                                  .where((item) => item.unitName == "╪╣╪»╪»")
-                                                                  .map((item) {
-                                                                final netValue = (item.totalPositiveBalance ?? 0) + (item.totalNegativeBalance ?? 0);
-                                                                if (netValue == 0.0) return SizedBox();
-                                                                return Padding(
-                                                                  padding: EdgeInsets.only(bottom: 8),
-                                                                  child: _buildNetFooterItem(
-                                                                    title: item.itemName ?? "╪│┌⌐┘ç",
-                                                                    netValue: netValue,
-                                                                    unit: "╪╣╪»╪»",
-                                                                  ),
-                                                                );
-                                                              }).toList(),
-                                                            ),
-                                                          ),
-                                                          SizedBox(width: 50),
-                                                          // Individual Currency Types
-                                                          Container(
-                                                            child: Column(
-                                                              crossAxisAlignment: CrossAxisAlignment.start,
-                                                              children: controller.listTransactionInfoFooter
-                                                                  .where((item) => item.itemGroupName == "╪º╪▒╪▓")
-                                                                  .map((item) {
-                                                                final netValue = (item.totalPositiveBalance ?? 0) + (item.totalNegativeBalance ?? 0);
-                                                                if (netValue == 0.0) return SizedBox();
-                                                                return Padding(
-                                                                  padding: EdgeInsets.only(bottom: 8),
-                                                                  child: _buildNetFooterItem(
-                                                                    title: "",
-                                                                    netValue: netValue,
-                                                                    unit: item.unitName,
-                                                                  ),
-                                                                );
-                                                              }).toList(),
-                                                            ),
-                                                          ),
-                                                        ],
-                                                      ),
-
-                                                  ),
-                                                  Container(
-                                                    width: Get.width*0.2,
-                                                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
-                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
-                                                    //decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: AppColor.appBarColor.withOpacity(0.5),),
-                                                    child:  Column(crossAxisAlignment: CrossAxisAlignment.start,
-                                                      children: [
-                                                        Text(
-                                                          "┘à╪¼┘à┘ê╪╣ ┌⌐┘ä:",
-                                                          style: AppTextStyle.labelText.copyWith(
-                                                            fontSize: 14,
-                                                            fontWeight: FontWeight.bold,
-                                                          ),
-                                                        ),
-                                                        SizedBox(height: 10),
-                                                        _buildNetFooterItem(
-                                                          title: "┘à╪¼┘à┘ê╪╣ ┌⌐┘ä",
-                                                          netValue: controller.listTransactionInfoFooter.fold(0.0, (sum, item) =>
-                                                          sum + ((item.totalPositiveBalance ?? 0) + (item.totalNegativeBalance ?? 0))
-                                                          ),
-                                                          unit: "╪▒█î╪º┘ä",
-                                                        ),
-                                                      ],
-                                                    ),
-
-                                                  ),
-                                                ],
-                                              ),
-                                            ),
-                                          ],
-                                        ),
-                                      )
-                                      : SizedBox()),
-                                ],
-                              ),
-                            ),
-                          ],
-                        ),
-                      ),
-                    ):
-                    _buildMobileTransactionList(context),
-                  ],
-                ),
-              ),
-            )
-                : Center(
-              child: ErrPage(
-                callback: () {
-                  controller.clearSearch();
-                  controller.getListTransactionInfoPager();
-                },
-                title: "╪«╪╖╪º ╪»╪▒ ┘ä█î╪│╪¬ ┌⌐╪º╪▒╪¿╪▒╪º┘å",
-                des: '╪¿╪▒╪º█î ╪»╪▒█î╪º┘ü╪¬ ┘ä█î╪│╪¬ ┌⌐╪º╪▒╪¿╪▒╪º┘å ┘à╪¼╪»╪»╪º ╪¬┘ä╪º╪┤ ┌⌐┘å█î╪»',
-              ),
+    return Obx(
+      () => Scaffold(
+        appBar: CustomAppbar1(
+          title: '┘à╪º┘å╪»┘ç ┌⌐╪º╪▒╪¿╪▒╪º┘å',
+          onBackTap: () => Get.toNamed('/home'),
+        ),
+        drawer: const AppDrawer(),
+        body: Stack(
+          children: [
+            const BackgroundImageTotal(),
+            SafeArea(
+              child: switch (controller.state.value) {
+                PageState.loading => const UserBalanceLoadingState(),
+                PageState.empty => UserBalanceEmptyState(onRetry: _onRetry),
+                PageState.err => UserBalanceErrorState(onRetry: _onRetry),
+                PageState.list => _buildListBody(context, isDesktop),
+              },
             ),
-          ),
-          isDesktop ?
-          Column(
-            mainAxisAlignment: MainAxisAlignment.end,
-            children: [
-              // Pagination
-              controller.paginated.value!=null?   Container(
-                  height: 70,
-                  margin: EdgeInsets.symmetric(horizontal: 50,vertical: 10),
-                  padding: EdgeInsets.symmetric(horizontal: 20),
-                  //color: AppColor.appBarColor.withAlpha(130),
-                  alignment: Alignment.bottomCenter,
-                  child:PagerWidget(countPage: controller.paginated.value?.totalCount??0, callBack: (int index) {
-                    controller.isChangePage(index);
-                  },)):SizedBox(),
-            ],
-          ): SizedBox.shrink(),
-        ],
-      ),
-      floatingActionButton: const ChatFloatingButton(),
-      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
-    ));
-  }
-  List<DataColumn> buildDataColumns() {
-    return [
-      DataColumn(
-          label: ConstrainedBox(
-              constraints: BoxConstraints(maxWidth: 80),
-              child: Text('╪▒╪»█î┘ü',
-                  style: AppTextStyle.labelText)),
-          headingRowAlignment: MainAxisAlignment.center,
-      ),
-      DataColumn(
-          label: ConstrainedBox(
-              constraints: BoxConstraints(maxWidth: 100),
-              child: Text('┘å╪º┘à',
-                  style: AppTextStyle.labelText.copyWith(fontSize: 11))),
-          headingRowAlignment: MainAxisAlignment.center,
-      ),
-
-      DataColumn(
-          label:  Row(
-                children: [
-                  Text('┘à╪º┘å╪»┘ç ╪▒█î╪º┘ä█î',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 11)),
-                  SizedBox(width: 5,),
-                  Text('(╪¿╪│╪¬╪º┘å┌⌐╪º╪▒)',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 12,color: AppColor.primaryColor,fontWeight: FontWeight.bold)),
-                ],
-              ),
-          headingRowAlignment: MainAxisAlignment.center,
-        onSort: (columnIndex, ascending){
-          controller.onSort(columnIndex, ascending);
-        },
-      ),
-      DataColumn(
-          label:  Row(
-                children: [
-                  Text('┘à╪º┘å╪»┘ç ╪▒█î╪º┘ä█î',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 11)),
-                  SizedBox(width: 5,),
-                  Text('(╪¿╪»┘ç┌⌐╪º╪▒)',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 12,color: AppColor.accentColor,fontWeight: FontWeight.bold)),
-                ],
-              ),
-          headingRowAlignment: MainAxisAlignment.center,
-        onSort: (columnIndex, ascending){
-          controller.onSort(columnIndex, ascending);
-        },
-      ),
-
-      DataColumn(
-          label: Row(
-                children: [
-                  Text('┘à╪º┘å╪»┘ç ╪╖┘ä╪º',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 11)),
-                  SizedBox(width: 5,),
-                  Text('(╪¿╪│╪¬╪º┘å┌⌐╪º╪▒)',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 12,color: AppColor.primaryColor,fontWeight: FontWeight.bold)),
-                ],
-              ),
-
-          headingRowAlignment: MainAxisAlignment.center,
-        onSort: (columnIndex, ascending){
-          controller.onSort(columnIndex, ascending);
-        },
-      ),
-      DataColumn(
-          label: Row(
-                children: [
-                  Text('┘à╪º┘å╪»┘ç ╪╖┘ä╪º',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 11)),
-                  SizedBox(width: 5,),
-                  Text('(╪¿╪»┘ç┌⌐╪º╪▒)',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 12,color: AppColor.accentColor,fontWeight: FontWeight.bold)),
-                ],
-              ),
-
-          headingRowAlignment: MainAxisAlignment.center,
-        onSort: (columnIndex, ascending){
-          controller.onSort(columnIndex, ascending);
-        },
-      ),
-
-      DataColumn(
-          label: Row(
-                children: [
-                  Text('┘à╪º┘å╪»┘ç ╪│┌⌐┘ç',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 11)),
-                  SizedBox(width: 5,),
-                  Text('(╪¿╪│╪¬╪º┘å┌⌐╪º╪▒)',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 12,color: AppColor.primaryColor,fontWeight: FontWeight.bold)),
-                ],
-              ),
-
-          headingRowAlignment: MainAxisAlignment.center,
-        onSort: (columnIndex, ascending){
-          controller.onSort(columnIndex, ascending);
-        },
-      ),
-      DataColumn(
-          label: Row(
-                children: [
-                  Text('┘à╪º┘å╪»┘ç ╪│┌⌐┘ç',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 11)),
-                  SizedBox(width: 5,),
-                  Text('(╪¿╪»┘ç┌⌐╪º╪▒)',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 12,color: AppColor.accentColor,fontWeight: FontWeight.bold)),
-                ],
-              ),
-
-          headingRowAlignment: MainAxisAlignment.center,
-        onSort: (columnIndex, ascending){
-          controller.onSort(columnIndex, ascending);
-        },
+            if (isDesktop && controller.paginated.value != null) _buildPagerOverlay(),
+          ],
+        ),
+        floatingActionButton: const ChatFloatingButton(),
+        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
       ),
-
-      DataColumn(
-          label: Row(
-                children: [
-                  Text('┘à╪º┘å╪»┘ç ╪º╪▒╪▓',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 11)),
-                  SizedBox(width: 5,),
-                  Text('(╪¿╪│╪¬╪º┘å┌⌐╪º╪▒)',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 12,color: AppColor.accentColor,fontWeight: FontWeight.bold)),
-                ],
-              ),
-
-          headingRowAlignment: MainAxisAlignment.center),
-
-      DataColumn(
-          label: Row(
-                children: [
-                  Text('┘à╪º┘å╪»┘ç ╪º╪▒╪▓',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 11)),
-                  SizedBox(width: 5,),
-                  Text('(╪¿╪»┘ç┌⌐╪º╪▒)',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 12,color: AppColor.primaryColor,fontWeight: FontWeight.bold)),
-                ],
-              ),
-
-          headingRowAlignment: MainAxisAlignment.center),
-
-      DataColumn(
-          label: Row(
-                children: [
-                  Text('╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪│',
-                      style: AppTextStyle.labelText.copyWith(fontSize: 11)),
-                ],
-              ),
-          headingRowAlignment: MainAxisAlignment.center,
-        onSort: (columnIndex, ascending){
-          controller.onSort(columnIndex, ascending);
-        },
-      ),
-      DataColumn(
-          label: Row(
-            children: [
-              Text('╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪»',
-                  style: AppTextStyle.labelText.copyWith(fontSize: 11)),
-            ],
-          ),
-          headingRowAlignment: MainAxisAlignment.center,
-        onSort: (columnIndex, ascending){
-          controller.onSort(columnIndex, ascending);
-        },
-      ),
-    ];
+    );
   }
 
-  List<DataRow> buildDataRows(BuildContext context) {
-    return controller.listTransactionInfo.asMap().entries.map((entry) {
-      final index = entry.key;
-      final trans = entry.value;
-      final rowColor = index.isEven
-          ? AppColor.backGroundColor
-          : AppColor.secondaryColor.withAlpha(100);
-      return DataRow(
-        color: WidgetStateProperty.all(rowColor),
-        cells: [
-          // ╪▒╪»█î┘ü
-          DataCell(
-              Center(
-                child: Text(
-                  "${trans.rowNum}",
-                  style: AppTextStyle.bodyText,
-                ),
-              )),
-          // ┘å╪º┘à
-          DataCell(Center(
-            child: GestureDetector(
-              onTap: (){
-                Get.toNamed("/userInfoTransaction",parameters: {"accountId":trans.accountId.toString()});
-                // /controller.getInfo(trans.accountId);
-              },
-              child: Text(
-                "${trans.accountName} ",
-                style: AppTextStyle.bodyText
-                    .copyWith(color: AppColor.textColor, fontSize: 11,decoration: TextDecoration.underline,decorationColor: AppColor.textColor,decorationThickness: 3),),
-            ),
-          )),
-          // ┘à╪º┘å╪»┘ç ╪▒█î╪º┘ä█î ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒
-          DataCell(Center(
-            child:
-            (trans.cashBalanceBes ?? 0)>0 ?
-            Row(
-              mainAxisAlignment: MainAxisAlignment.center,
-              children: [
-                trans.cashBalanceBes==0
-                    ? SizedBox()
-                    :
-                Column(mainAxisAlignment: MainAxisAlignment.center,
-                  children: [
-                    Row(
-                      children: [
-                        SizedBox(
-                          //width: 150,
-                          child: Row(
-                            children: [
-                              Text("┘ê╪¼┘ç ┘å┘é╪» ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 9,
-                                      color:  AppColor
-                                          .primaryColor,
-                                      fontWeight:
-                                      FontWeight
-                                          .bold)),
-                              Text(
-                                trans.cashBalanceBes!.toStringAsFixed(0).seRagham(),
-                                style: AppTextStyle.bodyText
-                                    .copyWith(
-                                    fontSize: 12,
-                                    color:  AppColor
-                                        .primaryColor,
-                                    fontWeight:
-                                    FontWeight.bold),
-                                textDirection:
-                                TextDirection.ltr,
-                              ),
-                              Text(" ╪▒█î╪º┘ä ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 9,
-                                      color:  AppColor
-                                          .primaryColor,
-                                      fontWeight:
-                                      FontWeight.bold)
-                                //  textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ),
-                        ),
-                        GestureDetector(
-                          onTap: (){
-                            Get.defaultDialog(
-                              confirm: Column(
-                                children: trans.balances!.map((e)=>e.unitName=="╪▒█î╪º┘ä" ? Row(
-                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                                  children: [
-                                    Text(
-                                      e.itemName??"",
-                                      style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                    ), Text(
-                                      "${e.balance?.toStringAsFixed(0).seRagham() ?? 0} ╪▒█î╪º┘ä ",
-                                      style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                      textDirection: TextDirection.ltr,
-                                    ),
-                                  ],
-                                ):SizedBox()).toList(),
-                              ),
-                              middleText: "┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪▒█î╪º┘ä ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒",
-                              middleTextStyle: context
-                                  .textTheme.bodyMedium!
-                                  .copyWith(
-                                  color: AppColor.backGroundColor,
-                                  fontSize: 13),
-                              title: "╪¼╪▓█î█î╪º╪¬",
-                              titleStyle: context
-                                  .textTheme.titleSmall!
-                                  .copyWith(
-                                  color: AppColor.backGroundColor,
-                                  fontSize: 14),
-                              backgroundColor: AppColor.textColor,
-                              radius: 7,
-                              contentPadding: EdgeInsets.symmetric(
-                                  horizontal: 20, vertical: 20),
-
-
-                            );
-                          },
-                          child: SvgPicture.asset('assets/svg/list.svg',height: 16,
-                              colorFilter: ColorFilter.mode(
-                                AppColor.textColor,
-                                BlendMode.srcIn,
-                              )),
-                        ),
-                      ],
-                    ),
-                    SizedBox(height: 5,),
-                    (trans.afterCashBalance ?? 0) > 0 ?
-                    Divider(height: 0.5,color: AppColor.dividerColor,) : SizedBox.shrink(),
-                    SizedBox(height: 5,),
-                    (trans.afterCashBalance ?? 0) > 0 ?
-                    Column(
-                      children: trans.balances!.map((e)=>e.unitName=="╪▒█î╪º┘ä" ?
-                      Row(
-                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                        children: [
-                          (e.balance ?? 0) > 0 ?
-                          Row(
-                            children: [
-                              Text(
-                                e.itemName??"",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  10,color: AppColor.primaryColor,fontWeight: FontWeight.bold),
-                              ),
-                              Text(
-                                "${e.balance?.toStringAsFixed(0).seRagham() ?? 0}",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.primaryColor,fontWeight: FontWeight.bold),
-                                textDirection: TextDirection.ltr,
-                              ),
-                              Text(" ╪▒█î╪º┘ä ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color:  AppColor
-                                        .primaryColor,
-                                    fontWeight:
-                                    FontWeight.bold)
-                                ,textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ): (e.balance ?? 0) < 0 ?
-                          Row(
-                            children: [
-                              Text(
-                                e.itemName??"",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  10,color: AppColor.accentColor , fontWeight: FontWeight.bold),
-                              ),
-                              Text(
-                                "-${e.balance?.abs().toStringAsFixed(0).seRagham() ?? 0}",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.accentColor,fontWeight: FontWeight.bold),
-                                textDirection: TextDirection.ltr,
-                              ),
-                              Text(" ╪▒█î╪º┘ä ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 10,
-                                      color:  AppColor
-                                          .accentColor,
-                                      fontWeight:
-                                      FontWeight.bold)
-                                //  textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ) : SizedBox.shrink(),
-                        ],
-                      ):SizedBox()).toList(),
-                    ):
-                    SizedBox.shrink(),
-                  ],
-                ),
-
-
-              ],
-            ):
-            SizedBox.shrink(),
-          ),
-          ),
-          // ┘à╪º┘å╪»┘ç ╪▒█î╪º┘ä█î ╪¿╪»┘ç┌⌐╪º╪▒
-          DataCell(Center(
-            child:
-            (trans.cashBalanceBed ?? 0)<0 ?
-            Column(
-              mainAxisAlignment: MainAxisAlignment.center,
-              children: [
-                trans.cashBalanceBed==0
-                    ? SizedBox()
-                    :
-                Column(mainAxisAlignment: MainAxisAlignment.center,
-                  children: [
-                    Row(
-                      children: [
-                        SizedBox(
-                          //width: 150,
-                          child: Row(
-                            children: [
-                              Text("┘ê╪¼┘ç ┘å┘é╪» ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 9,
-                                      color:  AppColor
-                                          .accentColor,
-                                      fontWeight:
-                                      FontWeight
-                                          .bold)),
-                              Text(
-                                "-${trans.cashBalanceBed?.abs().toStringAsFixed(0).seRagham() ?? ""}",
-                                style: AppTextStyle.bodyText
-                                    .copyWith(
-                                    fontSize: 12,
-                                    color:  AppColor
-                                        .accentColor
-                                    ,
-                                    fontWeight:
-                                    FontWeight.bold),
-                                textDirection:
-                                TextDirection.ltr,
-                              ),
-                              Text(" ╪▒█î╪º┘ä ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 9,
-                                      color:  AppColor
-                                          .accentColor,
-                                      fontWeight:
-                                      FontWeight.bold)
-                                //  textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ),
-                        ),
-                        GestureDetector(
-                          onTap: (){
-                            Get.defaultDialog(
-                              confirm: Column(
-                                children: trans.balances!.map((e)=>e.unitName=="╪▒█î╪º┘ä" ? Row(
-                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                                  children: [
-                                    Text(
-                                      e.itemName??"",
-                                      style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                    ), Text(
-                                      "-${e.balance?.abs().toStringAsFixed(0).seRagham() ?? 0} ╪▒█î╪º┘ä ",
-                                      style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor,),
-                                      textDirection: TextDirection.ltr,
-                                    ),
-                                  ],
-                                ):SizedBox()).toList(),
-                              ),
-                              middleText: "┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪▒█î╪º┘ä ╪¿╪»┘ç┌⌐╪º╪▒",
-                              middleTextStyle: context
-                                  .textTheme.bodyMedium!
-                                  .copyWith(
-                                  color: AppColor.backGroundColor,
-                                  fontSize: 13),
-                              title: "╪¼╪▓█î█î╪º╪¬",
-                              titleStyle: context
-                                  .textTheme.titleSmall!
-                                  .copyWith(
-                                  color: AppColor.backGroundColor,
-                                  fontSize: 14),
-                              backgroundColor: AppColor.textColor,
-                              radius: 7,
-                              contentPadding: EdgeInsets.symmetric(
-                                  horizontal: 20, vertical: 20),
-
-
-                            );
-                          },
-                          child: SvgPicture.asset('assets/svg/list.svg',height: 16,
-                              colorFilter: ColorFilter.mode(
-                                AppColor.textColor,
-                                BlendMode.srcIn,
-                              )),
-                        ),
-                      ],
-                    ),
-                    SizedBox(height: 5,),
-                    (trans.afterCashBalance ?? 0) < 0 ?
-                    Divider(height: 0.5,color: AppColor.dividerColor,) : SizedBox.shrink(),
-                    SizedBox(height: 5,),
-                    (trans.afterCashBalance ?? 0) < 0 ?
-                    Column(
-                      children: trans.balances!.map((e)=>e.unitName=="╪▒█î╪º┘ä" ?
-                      Row(
-                        children: [
-                          (e.balance ?? 0) < 0 ?
-                          Row(
-                            children: [
-                              Text(
-                                e.itemName??"",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  10,color: AppColor.accentColor , fontWeight: FontWeight.bold),
-                              ),
-                              Text(
-                                "-${e.balance?.abs().toStringAsFixed(0).seRagham() ?? 0}",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.accentColor,fontWeight: FontWeight.bold),
-                                textDirection: TextDirection.ltr,
-                              ),
-                              Text(" ╪▒█î╪º┘ä ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 10,
-                                      color:  AppColor
-                                          .accentColor,
-                                      fontWeight:
-                                      FontWeight.bold)
-                                //  textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ) : (e.balance ?? 0) > 0 ?
-                          Row(
-                            children: [
-                              Text(
-                                e.itemName??"",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  10,color: AppColor.primaryColor,fontWeight: FontWeight.bold),
-                              ),
-                              Text(
-                                "${e.balance?.toStringAsFixed(0).seRagham() ?? 0}",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.primaryColor,fontWeight: FontWeight.bold),
-                                textDirection: TextDirection.ltr,
-                              ),
-                              Text(" ╪▒█î╪º┘ä ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color:  AppColor
-                                        .primaryColor,
-                                    fontWeight:
-                                    FontWeight.bold)
-                                ,textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ): SizedBox.shrink(),
-                        ],
-                      ):SizedBox()).toList(),
-                    ):SizedBox.shrink(),
-                  ],
-                ),
-
-              ],
-            ):
-            SizedBox.shrink(),
-          ),
-          ),
-          // ┘à╪º┘å╪»┘ç ╪╖┘ä╪º ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒
-          DataCell(Center(
-            child:
-            (trans.goldBalanceBes ?? 0)>0 ?
-            Row(
-              mainAxisAlignment: MainAxisAlignment.center,
-              children: [
-                trans.goldBalanceBes==0
-                    ? SizedBox()
-                    :
-                Column(mainAxisAlignment: MainAxisAlignment.center,
-                  children: [
-                    Row(
-                      children: [
-                        SizedBox(
-                          //width: 150,
-                          child: Row(
-                            children: [
-                              Text("╪ó╪¿╪┤╪»┘ç ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 9,
-                                      color:  AppColor
-                                          .primaryColor,
-                                      fontWeight:
-                                      FontWeight
-                                          .bold)),
-                              Text(
-                                trans.goldBalanceBes!.toStringAsFixed(3),
-                                style: AppTextStyle.bodyText
-                                    .copyWith(
-                                    fontSize: 11,
-                                    color:  AppColor
-                                        .primaryColor,
-                                    fontWeight:
-                                    FontWeight.bold),
-                                textDirection:
-                                TextDirection.ltr,
-                              ),
-                              Text(" ┌»╪▒┘à ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 9,
-                                      color:  AppColor
-                                          .primaryColor,
-                                      fontWeight:
-                                      FontWeight.bold)
-                                //  textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ),
-                        ),
-                        GestureDetector(
-                          onTap: (){
-                            Get.defaultDialog(
-                              confirm: Column(
-                                children: trans.balances!.map((e)=>e.unitName=="┌»╪▒┘à" ? Row(
-                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                                  children: [
-                                    Text(
-                                      e.itemName??"",
-                                      style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                    ), Text(
-                                      "${e.balance??0} ┌»╪▒┘à ",
-                                      style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                    ),
-                                  ],
-                                ):SizedBox()).toList(),
-                              ),
-                              middleText: "┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪╖┘ä╪º█î ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒",
-                              middleTextStyle: context
-                                  .textTheme.bodyMedium!
-                                  .copyWith(
-                                  color: AppColor.backGroundColor,
-                                  fontSize: 13),
-                              title: "╪¼╪▓█î█î╪º╪¬",
-                              titleStyle: context
-                                  .textTheme.titleSmall!
-                                  .copyWith(
-                                  color: AppColor.backGroundColor,
-                                  fontSize: 14),
-                              backgroundColor: AppColor.textColor,
-                              radius: 7,
-                              contentPadding: EdgeInsets.symmetric(
-                                  horizontal: 20, vertical: 20),
-
-
-                            );
-                          },
-                          child: SvgPicture.asset('assets/svg/list.svg',height: 16,
-                              colorFilter: ColorFilter.mode(
-                                AppColor.textColor,
-                                BlendMode.srcIn,
-                              )),
-                        ),
-                      ],
-                    ),
-                    SizedBox(height: 5,),
-                    (trans.afterGoldBalance ?? 0) > 0 ?
-                    Divider(height: 0.5,color: AppColor.dividerColor,) : SizedBox.shrink(),
-                    SizedBox(height: 5,),
-                    (trans.afterGoldBalance ?? 0) > 0 ?
-                    Column(
-                      children: trans.balances!.map((e)=>e.unitName=="┌»╪▒┘à" ?
-                      Row(
-                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                        children: [
-                          (e.balance ?? 0) > 0 ?
-                          Row(
-                            children: [
-                              Text(
-                                e.itemName??"",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  10,color: AppColor.primaryColor,fontWeight: FontWeight.bold),
-                              ),
-                              Text(
-                                "${e.balance??0}",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.primaryColor,fontWeight: FontWeight.bold),
-                              ),
-                              Text(" ┌»╪▒┘à ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 10,
-                                      color:  AppColor
-                                          .primaryColor,
-                                      fontWeight: FontWeight.bold)
-                                //  textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ): (e.balance ?? 0) < 0 ?
-                          Row(
-                            children: [
-                              Text(
-                                e.itemName??"",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  10,color: AppColor.accentColor,fontWeight: FontWeight.bold),
-                              ),
-                              Text(
-                                "-${e.balance?.abs() ?? 0}",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.accentColor,fontWeight: FontWeight.bold),textDirection: TextDirection.ltr,
-                              ),
-                              Text(" ┌»╪▒┘à ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 10,
-                                    color:  AppColor
-                                        .accentColor,
-                                    fontWeight: FontWeight.bold)
-                                ,textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ) : SizedBox.shrink(),
-                        ],
-                      ):SizedBox()).toList(),
-                    ):
-                    SizedBox.shrink(),
-                  ],
-                ),
-
-
-              ],
-            ):
-            SizedBox.shrink(),
+  Widget _buildListBody(BuildContext context, bool isDesktop) {
+    if (isDesktop) {
+      return SizedBox(
+        height: Get.height,
+        width: Get.width,
+        child: SingleChildScrollView(
+          physics: const ClampingScrollPhysics(),
+          child: UserBalanceDesktopBody(
+            controller: controller,
+            footer: UserBalanceFooter(controller: controller),
           ),
-          ),
-          // ┘à╪º┘å╪»┘ç ╪╖┘ä╪º ╪¿╪»┘ç┌⌐╪º╪▒
-          DataCell(Center(
-            child:
-            (trans.goldBalanceBed ?? 0)<0 ?
-            Row(
-              mainAxisAlignment: MainAxisAlignment.center,
-              children: [
-                trans.goldBalanceBed==0
-                    ? SizedBox()
-                    :
-                Column(mainAxisAlignment: MainAxisAlignment.center,
-                  children: [
-                    Row(
-                      children: [
-                        SizedBox(
-                          //width: 150,
-                          child: Row(
-                            children: [
-                              Text("╪ó╪¿╪┤╪»┘ç ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 9,
-                                      color:  AppColor
-                                          .accentColor,
-                                      fontWeight:
-                                      FontWeight
-                                          .bold)),
-                              Text(
-                                "-${trans.goldBalanceBed?.abs().toStringAsFixed(3) ?? ""}",
-                                style: AppTextStyle.bodyText
-                                    .copyWith(
-                                    fontSize: 11,
-                                    color:  AppColor
-                                        .accentColor
-                                    ,
-                                    fontWeight:
-                                    FontWeight.bold),
-                                textDirection:
-                                TextDirection.ltr,
-                              ),
-                              Text(" ┌»╪▒┘à ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 9,
-                                      color:  AppColor
-                                          .accentColor,
-                                      fontWeight:
-                                      FontWeight.bold)
-                                //  textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ),
-                        ),
-                        GestureDetector(
-                          onTap: (){
-                            Get.defaultDialog(
-                              confirm: Column(
-                                children: trans.balances!.map((e)=>e.unitName=="┌»╪▒┘à" ? Row(
-                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                                  children: [
-                                    Text(
-                                      e.itemName??"",
-                                      style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                    ), Text(
-                                      "${e.balance??0} ┌»╪▒┘à",
-                                      style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.backGroundColor),
-                                    ),
-                                  ],
-                                ):SizedBox()).toList(),
-                              ),
-                              middleText: "┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪╖┘ä╪º█î ╪¿╪»┘ç┌⌐╪º╪▒",
-                              middleTextStyle: context
-                                  .textTheme.bodyMedium!
-                                  .copyWith(
-                                  color: AppColor.backGroundColor,
-                                  fontSize: 13),
-                              title: "╪¼╪▓█î█î╪º╪¬",
-                              titleStyle: context
-                                  .textTheme.titleSmall!
-                                  .copyWith(
-                                  color: AppColor.backGroundColor,
-                                  fontSize: 14),
-                              backgroundColor: AppColor.textColor,
-                              radius: 7,
-                              contentPadding: EdgeInsets.symmetric(
-                                  horizontal: 20, vertical: 20),
-
-
-                            );
-                          },
-                          child: SvgPicture.asset('assets/svg/list.svg',height: 16,
-                              colorFilter: ColorFilter.mode(
-                                AppColor.textColor,
-                                BlendMode.srcIn,
-                              )),
-                        ),
-                      ],
-                    ),
-                    SizedBox(height: 5,),
-                    (trans.afterGoldBalance ?? 0) < 0 ?
-                    Divider(height: 0.5,color: AppColor.dividerColor,) : SizedBox.shrink(),
-                    SizedBox(height: 5,),
-                    (trans.afterGoldBalance ?? 0) < 0 ?
-                    Column(
-                      children: trans.balances!.map((e)=>e.unitName=="┌»╪▒┘à" ?
-                      Row(
-                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
-                        children: [
-                          (e.balance ?? 0) > 0 ?
-                          Row(
-                            children: [
-                              Text(
-                                e.itemName??"",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  10,color: AppColor.primaryColor,fontWeight: FontWeight.bold),
-                              ),
-                              Text(
-                                "${e.balance??0}",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.primaryColor,fontWeight: FontWeight.bold),
-                              ),
-                              Text(" ┌»╪▒┘à ",
-                                  style: AppTextStyle
-                                      .bodyText
-                                      .copyWith(
-                                      fontSize: 10,
-                                      color:  AppColor
-                                          .primaryColor,
-                                      fontWeight: FontWeight.bold)
-                                //  textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ): (e.balance ?? 0) < 0 ?
-                          Row(
-                            children: [
-                              Text(
-                                e.itemName??"",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  10,color: AppColor.accentColor,fontWeight: FontWeight.bold),
-                              ),
-                              Text(
-                                "-${e.balance?.abs() ?? 0}",
-                                style: AppTextStyle.labelText.copyWith(fontSize:  12,color: AppColor.accentColor,fontWeight: FontWeight.bold),textDirection: TextDirection.ltr,
-                              ),
-                              Text(" ┌»╪▒┘à ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 10,
-                                    color:  AppColor
-                                        .accentColor,
-                                    fontWeight: FontWeight.bold)
-                                ,textDirection: TextDirection.ltr,
-                              ),
-                            ],
-                          ) : SizedBox.shrink(),
-                        ],
-                      ):SizedBox()).toList(),
-                    ):
-                    SizedBox.shrink(),
-                  ],
-                ),
-
-              ],
-            ):
-            SizedBox.shrink(),
-          ),
-          ),
-          // ┘à╪º┘å╪»┘ç ╪│┌⌐┘ç ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒
-          DataCell(Center(
-              child: Column(
-                mainAxisAlignment: MainAxisAlignment.center,
-                children: [
-                  trans.coinBalanceBes==0
-                      ? SizedBox()
-                      : Column(
-                      children: [
-                        Row(
-                          children: [
-                            Text(" ╪¬┘à╪º┘à ╪│┌⌐┘ç ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color: AppColor
-                                        .primaryColor,
-                                    fontWeight:
-                                    FontWeight
-                                        .bold)),
-                            Text(
-                              trans.coinBalanceBes?.toDisplayString() ?? "",
-                              style: AppTextStyle.bodyText
-                                  .copyWith(
-                                  fontSize: 11,
-                                  color:  AppColor
-                                      .primaryColor,
-                                  fontWeight:
-                                  FontWeight.bold),
-                              textDirection:
-                              TextDirection.ltr,
-                            ),
-                            Text(" ╪╣╪»╪» ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color:  AppColor
-                                        .primaryColor,
-                                    fontWeight:
-                                    FontWeight.bold)
-                              //  textDirection: TextDirection.ltr,
-                            ),
-                          ],
-                        ),
-                        Row(
-                          children: [
-                            Text(" ┘å█î┘à ╪│┌⌐┘ç ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color: AppColor
-                                        .primaryColor,
-                                    fontWeight:
-                                    FontWeight
-                                        .bold)),
-                            Text(
-                              trans.halfCoinBalanceBes?.toDisplayString() ?? "",
-                              style: AppTextStyle.bodyText
-                                  .copyWith(
-                                  fontSize: 11,
-                                  color:  AppColor
-                                      .primaryColor,
-                                  fontWeight:
-                                  FontWeight.bold),
-                              textDirection:
-                              TextDirection.ltr,
-                            ),
-                            Text(" ╪╣╪»╪» ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color:  AppColor
-                                        .primaryColor,
-                                    fontWeight:
-                                    FontWeight.bold)
-                              //  textDirection: TextDirection.ltr,
-                            ),
-                          ],
-                        ),
-                        Row(
-                          children: [
-                            Text(" ╪▒╪¿╪╣ ╪│┌⌐┘ç ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color: AppColor
-                                        .primaryColor,
-                                    fontWeight:
-                                    FontWeight
-                                        .bold)),
-                            Text(
-                              trans.quarterCoinBalanceBes?.toDisplayString() ?? "",
-                              style: AppTextStyle.bodyText
-                                  .copyWith(
-                                  fontSize: 11,
-                                  color:  AppColor
-                                      .primaryColor,
-                                  fontWeight:
-                                  FontWeight.bold),
-                              textDirection:
-                              TextDirection.ltr,
-                            ),
-                            Text(" ╪╣╪»╪» ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color:  AppColor
-                                        .primaryColor,
-                                    fontWeight:
-                                    FontWeight.bold)
-                              //  textDirection: TextDirection.ltr,
-                            ),
-                          ],
-                        )
-                      ]
-                  ),
-                ],
-              ))),
-          // ┘à╪º┘å╪»┘ç ╪│┌⌐┘ç ╪¿╪»┘ç┌⌐╪º╪▒
-          DataCell(Center(
-              child: Column(
-                mainAxisAlignment: MainAxisAlignment.center,
-                children: [
-                  trans.coinBalanceBed==0
-                      ? SizedBox()
-                      : Column(
-                      children: [
-                        Row(
-                          children: [
-                            Text(" ╪¬┘à╪º┘à ╪│┌⌐┘ç ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color: AppColor
-                                        .accentColor,
-                                    fontWeight:
-                                    FontWeight
-                                        .bold)),
-                            Text(
-                              "-${trans.coinBalanceBed?.abs().toDisplayString()}",
-                              style: AppTextStyle.bodyText
-                                  .copyWith(
-                                  fontSize: 11,
-                                  color:  AppColor
-                                      .accentColor,
-                                  fontWeight:
-                                  FontWeight.bold),
-                              textDirection:
-                              TextDirection.ltr,
-                            ),
-                            Text(" ╪╣╪»╪» ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color:  AppColor
-                                        .accentColor,
-                                    fontWeight:
-                                    FontWeight.bold)
-                              //  textDirection: TextDirection.ltr,
-                            ),
-                          ],
-                        ),
-                        Row(
-                          children: [
-                            Text(" ┘å█î┘à ╪│┌⌐┘ç ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color: AppColor
-                                        .accentColor,
-                                    fontWeight:
-                                    FontWeight
-                                        .bold)),
-                            Text(
-                              "-${trans.halfCoinBalanceBed?.abs().toDisplayString()}",
-                              style: AppTextStyle.bodyText
-                                  .copyWith(
-                                  fontSize: 11,
-                                  color:  AppColor
-                                      .accentColor,
-                                  fontWeight:
-                                  FontWeight.bold),
-                              textDirection:
-                              TextDirection.ltr,
-                            ),
-                            Text(" ╪╣╪»╪» ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color:  AppColor
-                                        .accentColor,
-                                    fontWeight:
-                                    FontWeight.bold)
-                              //  textDirection: TextDirection.ltr,
-                            ),
-                          ],
-                        ),
-                        Row(
-                          children: [
-                            Text(" ╪▒╪¿╪╣ ╪│┌⌐┘ç ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color: AppColor
-                                        .accentColor,
-                                    fontWeight:
-                                    FontWeight
-                                        .bold)),
-                            Text(
-                              "-${trans.quarterCoinBalanceBed?.abs().toDisplayString()}",
-                              style: AppTextStyle.bodyText
-                                  .copyWith(
-                                  fontSize: 11,
-                                  color:  AppColor
-                                      .accentColor,
-                                  fontWeight:
-                                  FontWeight.bold),
-                              textDirection:
-                              TextDirection.ltr,
-                            ),
-                            Text(" ╪╣╪»╪» ",
-                                style: AppTextStyle
-                                    .bodyText
-                                    .copyWith(
-                                    fontSize: 9,
-                                    color:  AppColor
-                                        .accentColor,
-                                    fontWeight:
-                                    FontWeight.bold)
-                              //  textDirection: TextDirection.ltr,
-                            ),
-                          ],
-                        )
-                      ]
-                  ),
-                ],
-              ))),
-          // ┘à╪º┘å╪»┘ç ╪º╪▒╪▓ ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒
-          DataCell(Center(
-              child: Column(
-                mainAxisAlignment: MainAxisAlignment.center,
-                children: [
-                  trans.balances!.isEmpty
-                      ? SizedBox()
-                      : Column(
-                    children: trans.balances
-                    !.map((e) => Container(
-                      child: e.unitName == "╪»┘ä╪º╪▒" && e.balance! > 0
-                          ? Row(
-                        children: [
-                          Text(" ${e.itemName} ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:  AppColor
-                                      .primaryColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                          Text(
-                            e.balance?.toDisplayString() ?? "",
-                            style: AppTextStyle.bodyText
-                                .copyWith(
-                                fontSize: 10,
-                                color:  AppColor
-                                    .primaryColor
-                                ,
-                                fontWeight:
-                                FontWeight.bold),
-                            textDirection:
-                            TextDirection.ltr,
-                          ),
-                          Text(" ${e.unitName} ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:  AppColor
-                                      .primaryColor,
-                                  fontWeight:
-                                  FontWeight.bold)
-                            //  textDirection: TextDirection.ltr,
-                          ),
-                        ],
-                      )
-                          : Row(
-                        children: [
-                          SizedBox(width: 120,),
-                        ],
-                      ),
-                    ))
-                        .toList(),
-                  ),
-                ],
-              ))),
-          // ┘à╪º┘å╪»┘ç ╪º╪▒╪▓ ╪¿╪»┘ç┌⌐╪º╪▒
-          DataCell(Center(
-              child: Column(
-                mainAxisAlignment: MainAxisAlignment.center,
-                children: [
-                  trans.balances!.isEmpty
-                      ? SizedBox()
-                      : Column(
-                    children: trans.balances
-                    !.map((e) => Container(
-                      child: e.unitName == "╪»┘ä╪º╪▒" && e.balance! < 0
-                          ? Row(
-                        children: [
-                          Text(" ${e.itemName} ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:  AppColor
-                                      .accentColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                          Text(
-                            e.balance?.toDisplayString() ?? "",
-                            style: AppTextStyle.bodyText
-                                .copyWith(
-                                fontSize: 10,
-                                color:  AppColor
-                                    .accentColor
-                                ,
-                                fontWeight:
-                                FontWeight.bold),
-                            textDirection:
-                            TextDirection.ltr,
-                          ),
-                          Text(" ${e.unitName} ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:  AppColor
-                                      .accentColor,
-                                  fontWeight:
-                                  FontWeight.bold)
-                            //  textDirection: TextDirection.ltr,
-                          ),
-                        ],
-                      )
-                          : Row(
-                        children: [
-                          SizedBox(width: 120,),
-                        ],
-                      ),
-                    ))
-                        .toList(),
-                  ),
-                ],
-              ))),
-          // ╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒
-          DataCell(Center(
-              child: Column(
-                mainAxisAlignment: MainAxisAlignment.center,
-                children: [
-                  (trans.currencyValueBes ?? 0) > 0 ?
-                  Column(
-                    children: [
-                      SizedBox(height: 5,),
-                      Row(
-                        children: [
-                          SvgPicture.asset(
-                              'assets/svg/scales.svg',
-                              height: 15,
-                              colorFilter:
-                              ColorFilter
-                                  .mode(
-                                AppColor
-                                    .primaryColor,
-                                BlendMode
-                                    .srcIn,
-                              )),
-                          SizedBox(width: 5,),
-                          Text(trans.currencyValueBes?.toStringAsFixed(0).seRagham() ?? "",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 10,
-                                  color:AppColor
-                                      .primaryColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-
-                          Text(" ╪▒█î╪º┘ä ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 8,
-                                  color:AppColor.primaryColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-
-                          SizedBox(width: 5,)
-                        ],
-                      ),
-                      Container(
-                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
-                        height: 0.5,color: AppColor.textColor,
-                      ),
-                      Row(
-                        children: [
-                          Text(" ┘à╪╣╪º╪»┘ä ╪ó╪¿╪┤╪»┘ç : ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:AppColor
-                                      .textColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                          (trans.goldValue ?? 0) <0 ?
-                          Text("-${trans.goldValue?.abs().toStringAsFixed(3) ?? ""} ",
-                            style: AppTextStyle
-                                .bodyText
-                                .copyWith(
-                                fontSize: 9,
-                                color:AppColor
-                                    .accentColor,
-                                fontWeight:
-                                FontWeight
-                                    .bold),textDirection:
-                            TextDirection.ltr,):
-                          Text(" ${trans.goldValue?.toStringAsFixed(3) ?? ""} ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:AppColor
-                                      .primaryColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-
-                          Text(" ┌»╪▒┘à ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 8,
-                                  color:AppColor
-                                      .textColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                        ],
-                      ),
-                      SizedBox(height: 5,),
-                      Row(
-                        children: [
-                          Text(" ┘à╪╣╪º╪»┘ä ╪│┌⌐┘ç : ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:AppColor
-                                      .textColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                          (trans.coinValue ?? 0) <0 ?
-                          Text("-${trans.coinValue?.abs().toStringAsFixed(3) ?? ""} ",
-                            style: AppTextStyle
-                                .bodyText
-                                .copyWith(
-                                fontSize: 9,
-                                color:AppColor
-                                    .accentColor,
-                                fontWeight:
-                                FontWeight
-                                    .bold),textDirection:
-                            TextDirection.ltr,):
-                          Text(" ${trans.coinValue?.toStringAsFixed(3) ?? ""} ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:AppColor
-                                      .primaryColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                          Text(" ╪╣╪»╪» ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 8,
-                                  color:AppColor
-                                      .textColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                        ],
-                      ),
-                      SizedBox(height: 5,),
-                    ],
-                  ):SizedBox.shrink(),
-                ],
-              ))),
-          // ╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪»┘ç┌⌐╪º╪▒
-          DataCell(Center(
-              child: Column(
-                mainAxisAlignment: MainAxisAlignment.center,
-                children: [
-                  (trans.currencyValueBed ?? 0) < 0 ?
-                  Column(
-                    children: [
-                      SizedBox(height: 5,),
-                      Row(
-                        children: [
-                          SvgPicture.asset(
-                              'assets/svg/scales.svg',
-                              height: 15,
-                              colorFilter:
-                              ColorFilter
-                                  .mode(AppColor
-                                  .accentColor,
-                                BlendMode
-                                    .srcIn,
-                              )),
-                          SizedBox(width: 5,),
-                          Text("-${trans.currencyValueBed?.abs().toStringAsFixed(0).seRagham() ?? ""}",
-                            style: AppTextStyle
-                                .bodyText
-                                .copyWith(
-                              fontSize: 10,
-                              color:AppColor
-                                  .accentColor,
-                              fontWeight:
-                              FontWeight
-                                  .bold,),textDirection:
-                            TextDirection.ltr,),
-                          Text(" ╪▒█î╪º┘ä ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 8,
-                                  color:AppColor
-                                      .accentColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-
-                          SizedBox(width: 5,)
-                        ],
-                      ),
-                      Container(
-                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
-                        height: 0.5,color: AppColor.textColor,
-                      ),
-                      Row(
-                        children: [
-                          Text(" ┘à╪╣╪º╪»┘ä ╪ó╪¿╪┤╪»┘ç : ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:AppColor
-                                      .textColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                          (trans.goldValue ?? 0) <0 ?
-                          Text("-${trans.goldValue?.abs().toStringAsFixed(3) ?? ""} ",
-                            style: AppTextStyle
-                                .bodyText
-                                .copyWith(
-                                fontSize: 9,
-                                color:AppColor
-                                    .accentColor,
-                                fontWeight:
-                                FontWeight
-                                    .bold),textDirection:
-                            TextDirection.ltr,):
-                          Text(" ${trans.goldValue?.toStringAsFixed(3) ?? ""} ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:AppColor
-                                      .primaryColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-
-                          Text(" ┌»╪▒┘à ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 8,
-                                  color:AppColor
-                                      .textColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                        ],
-                      ),
-                      SizedBox(height: 5,),
-                      Row(
-                        children: [
-                          Text(" ┘à╪╣╪º╪»┘ä ╪│┌⌐┘ç : ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:AppColor
-                                      .textColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                          (trans.coinValue ?? 0) <0 ?
-                          Text("-${trans.coinValue?.abs().toStringAsFixed(3) ?? ""} ",
-                            style: AppTextStyle
-                                .bodyText
-                                .copyWith(
-                                fontSize: 9,
-                                color:AppColor
-                                    .accentColor,
-                                fontWeight:
-                                FontWeight
-                                    .bold),textDirection:
-                            TextDirection.ltr,):
-                          Text(" ${trans.coinValue?.toStringAsFixed(3) ?? ""} ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 9,
-                                  color:AppColor
-                                      .primaryColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                          Text(" ╪╣╪»╪» ",
-                              style: AppTextStyle
-                                  .bodyText
-                                  .copyWith(
-                                  fontSize: 8,
-                                  color:AppColor
-                                      .textColor,
-                                  fontWeight:
-                                  FontWeight
-                                      .bold)),
-                        ],
-                      ),
-                      SizedBox(height: 5,),
-                    ],
-                  ):SizedBox.shrink(),
-                ],
-              ))),
-        ],
+        ),
       );
     }
-    ).toList();
-  }
-
-  Widget _buildFooterItem({
-    required String title,
-    double? positiveValue,
-    double? negativeValue,
-    required Color color,
-    String? unit,
-  }) {
-    final value = positiveValue ?? negativeValue ?? 0.0;
-
-    // Don't display if value is zero
-    if (value == 0.0) {
-      return SizedBox();
-    }
-
-    String formattedValue;
-    if (unit == "╪▒█î╪º┘ä") {
-      // For Rial, use seRagham formatting
-      formattedValue = value.toStringAsFixed(3).seRagham();
-    } else if(unit == "┌»╪▒┘à") {
-      // For other units, use 3 decimal places
-      formattedValue = value.toStringAsFixed(3);
-    }else{
-      formattedValue = value.toString();
-    }
 
-    return Container(
-      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
-      decoration: BoxDecoration(
-        border: Border.all(color: color, width: 1),
-        borderRadius: BorderRadius.circular(8),
-      ),
-      child: Row(
-        mainAxisSize: MainAxisSize.min,
-        children: [
-          Text(
-            title,
-            style: AppTextStyle.labelText.copyWith(
-              fontSize: 12,
-              fontWeight: FontWeight.bold,
-            ),
-          ),
-          SizedBox(width: 3),
-          Row(
-            mainAxisSize: MainAxisSize.min,
-            children: [
-              Text(
-                formattedValue,
-                style: AppTextStyle.bodyText.copyWith(
-                  fontSize: 14,
-                  color: color,
-                  fontWeight: FontWeight.bold,
-                ),
-                textDirection: TextDirection.ltr,
+    return SizedBox(
+      height: Get.height,
+      width: Get.width,
+      child: SingleChildScrollView(
+        controller: controller.scrollControllerMobile,
+        child: Column(
+          children: [
+            Container(
+              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
+              child: UserBalanceSearchBar(
+                searchController: controller.searchController,
+                onSearch: controller.getListTransactionInfoPager,
+                onClear: controller.clearSearch,
+                compact: true,
               ),
-              if (unit != null) ...[
-                SizedBox(width: 4),
-                Text(
-                  unit,
-                  style: AppTextStyle.bodyText.copyWith(
-                    fontSize: 12,
-                    color: color,
-                    fontWeight: FontWeight.bold,
-                  ),
-                ),
-              ],
-            ],
-          ),
-        ],
+            ),
+            _buildMobileTransactionList(context),
+          ],
+        ),
       ),
     );
   }
 
-  Widget _buildNetFooterItem({
-    required String title,
-    required double netValue,
-    String? unit,
-  }) {
-    // Don't display if net value is zero
-    if (netValue == 0.0) {
-      return SizedBox();
-    }
-
-    // Determine color based on net value
-    final color = netValue > 0 ? AppColor.primaryColor : AppColor.accentColor;
-
-    String formattedValue;
-    if (unit == "╪▒█î╪º┘ä") {
-      // For Rial, use seRagham formatting
-      formattedValue = netValue.toStringAsFixed(0).seRagham();
-    } else if(unit == "┌»╪▒┘à") {
-      // For other units, use 3 decimal places
-      formattedValue = netValue.toStringAsFixed(3);
-    }else{
-      formattedValue = netValue.toStringAsFixed(3);
-    }
-
-    return Container(
-      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
-      decoration: BoxDecoration(
-        border: Border.all(color: color, width: 1),
-        borderRadius: BorderRadius.circular(8),
-      ),
-      child: Row(
-        mainAxisSize: MainAxisSize.min,
-        children: [
-          Text(
-            title,
-            style: AppTextStyle.labelText.copyWith(
-              fontSize: 12,
-              fontWeight: FontWeight.bold,
-            ),
-          ),
-          SizedBox(width: 3),
-          Row(
-            mainAxisSize: MainAxisSize.min,
-            children: [
-              Text(
-                formattedValue,
-                style: AppTextStyle.bodyText.copyWith(
-                  fontSize: 14,
-                  color: color,
-                  fontWeight: FontWeight.bold,
-                ),
-                textDirection: TextDirection.ltr,
-              ),
-              if (unit != null) ...[
-                SizedBox(width: 4),
-                Text(
-                  unit,
-                  style: AppTextStyle.bodyText.copyWith(
-                    fontSize: 12,
-                    color: color,
-                    fontWeight: FontWeight.bold,
-                  ),
-                ),
-              ],
-            ],
+  Widget _buildPagerOverlay() {
+    return Column(
+      mainAxisAlignment: MainAxisAlignment.end,
+      children: [
+        Container(
+          height: 70,
+          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
+          padding: const EdgeInsets.symmetric(horizontal: 20),
+          alignment: Alignment.bottomCenter,
+          child: PagerWidget(
+            countPage: controller.paginated.value?.totalCount ?? 0,
+            callBack: controller.isChangePage,
           ),
-        ],
-      ),
+        ),
+      ],
     );
   }
 
-  Widget _buildMobileTransactionList(BuildContext context){
+  // Task 7 will extract mobile list into dedicated widgets.
+  Widget _buildMobileTransactionList(BuildContext context) {
     return Container(
-      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
+      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
       child: Column(
         children: [
           Row(
             children: [
               Container(
-                //margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
-                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
-                child: Row(mainAxisAlignment: MainAxisAlignment.start,
+                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
+                child: Row(
+                  mainAxisAlignment: MainAxisAlignment.start,
                   children: [
-                    // ╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä
                     GestureDetector(
                       onTap: () async {
                         controller.clearFilter();
                         showGeneralDialog(
-                            context: context,
-                            barrierDismissible: true,
-                            barrierLabel:
-                            MaterialLocalizations
-                                .of(context)
-                                .modalBarrierDismissLabel,
-                            barrierColor:
-                            Colors.black45,
-                            transitionDuration:
-                            const Duration(
-                                milliseconds:
-                                200),
-                            pageBuilder: (BuildContext
-                            buildContext,
-                                Animation animation,
-                                Animation
-                                secondaryAnimation) {
-                              return Center(
-                                child: Material(
-                                  color: Colors
-                                      .transparent,
-                                  child: Container(
-                                    decoration: BoxDecoration(
-                                        borderRadius:
-                                        BorderRadius
-                                            .circular(
-                                            8),
-                                        color: AppColor
-                                            .backGroundColor),
-                                    width: Get.width * 0.65,
-                                    height: Get.height * 0.5,
-                                    padding:
-                                    EdgeInsets
-                                        .all(20),
-                                    child: Column(
-                                      children: [
-                                        Padding(
-                                          padding:
-                                          const EdgeInsets
-                                              .all(
-                                              8.0),
-                                          child: Row(
-                                            mainAxisAlignment:
-                                            MainAxisAlignment
-                                                .end,
-                                            children: [
-                                              Expanded(
-                                                child:
-                                                Center(
-                                                  child:
-                                                  Text(
-                                                    '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
-                                                    style: AppTextStyle.labelText.copyWith(
-                                                      fontSize: 15,
-                                                      fontWeight: FontWeight.normal,
-                                                    ),
+                          context: context,
+                          barrierDismissible: true,
+                          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
+                          barrierColor: Colors.black45,
+                          transitionDuration: const Duration(milliseconds: 200),
+                          pageBuilder: (buildContext, animation, secondaryAnimation) {
+                            return Center(
+                              child: Material(
+                                color: Colors.transparent,
+                                child: Container(
+                                  decoration: BoxDecoration(
+                                    borderRadius: BorderRadius.circular(8),
+                                    color: AppColor.backGroundColor,
+                                  ),
+                                  width: Get.width * 0.65,
+                                  height: Get.height * 0.5,
+                                  padding: const EdgeInsets.all(20),
+                                  child: Column(
+                                    children: [
+                                      Padding(
+                                        padding: const EdgeInsets.all(8),
+                                        child: Row(
+                                          mainAxisAlignment: MainAxisAlignment.end,
+                                          children: [
+                                            Expanded(
+                                              child: Center(
+                                                child: Text(
+                                                  '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
+                                                  style: AppTextStyle.labelText.copyWith(
+                                                    fontSize: 15,
+                                                    fontWeight: FontWeight.normal,
                                                   ),
                                                 ),
                                               ),
-                                            ],
-                                          ),
-                                        ),
-                                        Container(
-                                          color: AppColor
-                                              .textColor,
-                                          height: 0.2,
+                                            ),
+                                          ],
                                         ),
-                                        Padding(
-                                          padding: const EdgeInsets
-                                              .symmetric(
-                                              horizontal:
-                                              10),
-                                          child:
-                                          Column(
-                                            children: [
-                                              SizedBox(
-                                                height:
-                                                8,
-                                              ),
-                                              Column(
-                                                crossAxisAlignment:
-                                                CrossAxisAlignment.start,
-                                                children: [
-                                                  Text(
-                                                    '┘å╪º┘à ╪¡╪│╪º╪¿',
-                                                    style: AppTextStyle.labelText.copyWith(fontSize: 11, fontWeight: FontWeight.normal, color: AppColor.textColor),
-                                                  ),
-                                                  SizedBox(
-                                                    height: 10,
+                                      ),
+                                      Container(color: AppColor.textColor, height: 0.2),
+                                      Padding(
+                                        padding: const EdgeInsets.symmetric(horizontal: 10),
+                                        child: Column(
+                                          children: [
+                                            const SizedBox(height: 8),
+                                            Column(
+                                              crossAxisAlignment: CrossAxisAlignment.start,
+                                              children: [
+                                                Text(
+                                                  '┘å╪º┘à ╪¡╪│╪º╪¿',
+                                                  style: AppTextStyle.labelText.copyWith(
+                                                    fontSize: 11,
+                                                    fontWeight: FontWeight.normal,
+                                                    color: AppColor.textColor,
                                                   ),
-                                                  IntrinsicHeight(
-                                                    child: TextFormField(
-                                                      autovalidateMode: AutovalidateMode.onUserInteraction,
-                                                      controller: controller.nameFilterController,
-                                                      style: AppTextStyle.labelText.copyWith(fontSize: 15),
-                                                      textAlign: TextAlign.start,
-                                                      keyboardType: TextInputType.text,
-                                                      decoration: InputDecoration(
-                                                        contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 15),
-                                                        isDense: true,
-                                                        border: OutlineInputBorder(
-                                                          borderRadius: BorderRadius.circular(6),
-                                                        ),
-                                                        filled: true,
-                                                        fillColor: AppColor.textFieldColor,
-                                                        errorMaxLines: 1,
+                                                ),
+                                                const SizedBox(height: 10),
+                                                IntrinsicHeight(
+                                                  child: TextFormField(
+                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
+                                                    controller: controller.nameFilterController,
+                                                    style: AppTextStyle.labelText.copyWith(fontSize: 15),
+                                                    textAlign: TextAlign.start,
+                                                    keyboardType: TextInputType.text,
+                                                    decoration: InputDecoration(
+                                                      contentPadding: const EdgeInsets.symmetric(
+                                                        vertical: 11,
+                                                        horizontal: 15,
+                                                      ),
+                                                      isDense: true,
+                                                      border: OutlineInputBorder(
+                                                        borderRadius: BorderRadius.circular(6),
                                                       ),
+                                                      filled: true,
+                                                      fillColor: AppColor.textFieldColor,
+                                                      errorMaxLines: 1,
                                                     ),
                                                   ),
-                                                ],
-                                              ),
-                                              SizedBox(
-                                                height:
-                                                8,
-                                              ),
-                                            ],
-                                          ),
+                                                ),
+                                              ],
+                                            ),
+                                            const SizedBox(height: 8),
+                                          ],
                                         ),
-                                        Spacer(),
-                                        Container(
-                                          margin: EdgeInsets.symmetric(
-                                              horizontal:
-                                              20,
-                                              vertical:
-                                              10),
-                                          width: double
-                                              .infinity,
-                                          height: 40,
-                                          child:
-                                          ElevatedButton(
-                                            style: ButtonStyle(
-                                                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 23)),
-                                                // elevation: WidgetStatePropertyAll(5),
-                                                backgroundColor: WidgetStatePropertyAll(AppColor.appBarColor),
-                                                shape: WidgetStatePropertyAll(RoundedRectangleBorder(side: BorderSide(color: AppColor.textColor), borderRadius: BorderRadius.circular(5)))),
-                                            onPressed:
-                                                () async {
-                                              controller.getListUserInfoTransactionExcel();
-                                              Get.back();
-                                            },
-                                            child: controller
-                                                .isLoading
-                                                .value
-                                                ? CircularProgressIndicator(
-                                              valueColor: AlwaysStoppedAnimation<Color>(AppColor.textColor),
-                                            )
-                                                : Text(
-                                              '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
-                                              style: AppTextStyle.labelText.copyWith(fontSize: 10),
+                                      ),
+                                      const Spacer(),
+                                      Container(
+                                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
+                                        width: double.infinity,
+                                        height: 40,
+                                        child: ElevatedButton(
+                                          style: ButtonStyle(
+                                            padding: const WidgetStatePropertyAll(
+                                              EdgeInsets.symmetric(horizontal: 23),
+                                            ),
+                                            backgroundColor: WidgetStatePropertyAll(AppColor.appBarColor),
+                                            shape: WidgetStatePropertyAll(
+                                              RoundedRectangleBorder(
+                                                side: BorderSide(color: AppColor.textColor),
+                                                borderRadius: BorderRadius.circular(5),
+                                              ),
                                             ),
                                           ),
+                                          onPressed: () async {
+                                            controller.getListUserInfoTransactionExcel();
+                                            Get.back();
+                                          },
+                                          child: controller.isLoading.value
+                                              ? CircularProgressIndicator(
+                                                  valueColor: AlwaysStoppedAnimation<Color>(
+                                                    AppColor.textColor,
+                                                  ),
+                                                )
+                                              : Text(
+                                                  '╪«╪▒┘ê╪¼█î ╪º┌⌐╪│┘ä',
+                                                  style: AppTextStyle.labelText.copyWith(fontSize: 10),
+                                                ),
                                         ),
-                                      ],
-                                    ),
+                                      ),
+                                    ],
                                   ),
                                 ),
-                              );
-                            });
+                              ),
+                            );
+                          },
+                        );
                       },
-                      child: SvgPicture.asset(
-                        'assets/svg/excel.svg',
-                        height: 30,
-                      ),
+                      child: SvgPicture.asset('assets/svg/excel.svg', height: 30),
                     ),
-                    SizedBox(width: 8,),
-                    // ┘ü█î┘ä╪¬╪▒
+                    const SizedBox(width: 8),
                     GestureDetector(
                       onTap: () async {
-                        //controller.fetchAccountList();
                         showGeneralDialog(
-                            context: context,
-                            barrierDismissible: true,
-                            barrierLabel:
-                            MaterialLocalizations
-                                .of(context)
-                                .modalBarrierDismissLabel,
-                            barrierColor:
-                            Colors.black45,
-                            transitionDuration:
-                            const Duration(
-                                milliseconds:
-                                200),
-                            pageBuilder: (BuildContext
-                            buildContext,
-                                Animation animation,
-                                Animation
-                                secondaryAnimation) {
-                              return Center(
-                                child: Material(
-                                  color: Colors
-                                      .transparent,
-                                  child: Container(
-                                    decoration: BoxDecoration(
-                                        borderRadius:
-                                        BorderRadius
-                                            .circular(
-                                            8),
-                                        color: AppColor
-                                            .backGroundColor),
-                                    width:Get.width * 0.9,
-                                    height:Get.height * 0.9,
-                                    padding:
-                                    EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 3),
-                                    child: FilterDialog(controller: controller),
+                          context: context,
+                          barrierDismissible: true,
+                          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
+                          barrierColor: Colors.black45,
+                          transitionDuration: const Duration(milliseconds: 200),
+                          pageBuilder: (buildContext, animation, secondaryAnimation) {
+                            return Center(
+                              child: Material(
+                                color: Colors.transparent,
+                                child: Container(
+                                  decoration: BoxDecoration(
+                                    borderRadius: BorderRadius.circular(8),
+                                    color: AppColor.backGroundColor,
+                                  ),
+                                  width: Get.width * 0.9,
+                                  height: Get.height * 0.9,
+                                  padding: const EdgeInsets.only(
+                                    left: 20,
+                                    right: 20,
+                                    top: 20,
+                                    bottom: 3,
                                   ),
+                                  child: FilterDialog(controller: controller),
                                 ),
-                              );
-                            });
+                              ),
+                            );
+                          },
+                        );
                       },
                       child: SvgPicture.asset(
-                          'assets/svg/filter3.svg',
-                          height: 26,
-                          colorFilter:
-                          ColorFilter.mode(
-                             AppColor.textColor,
-                            BlendMode.srcIn,
-                          )
+                        'assets/svg/filter3.svg',
+                        height: 26,
+                        colorFilter: ColorFilter.mode(AppColor.textColor, BlendMode.srcIn),
                       ),
                     ),
                   ],
                 ),
               ),
               Expanded(child: _buildMobileSortHeader()),
             ],
           ),
-          SizedBox(height: 10),
+          const SizedBox(height: 10),
           ListView.builder(
             itemCount: controller.listTransactionInfo.length,
             shrinkWrap: true,
-            physics: NeverScrollableScrollPhysics(),
-            itemBuilder: (ctx, index){
+            physics: const NeverScrollableScrollPhysics(),
+            itemBuilder: (ctx, index) {
               final trans = controller.listTransactionInfo[index];
               return Container(
-                margin: EdgeInsets.only(bottom: 12),
-                padding: EdgeInsets.all(12),
+                margin: const EdgeInsets.only(bottom: 12),
+                padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: AppColor.appBarColor.withAlpha(200),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: AppColor.textColor.withAlpha(75)),
                 ),
-                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
+                child: Column(
+                  crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
-                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
+                    Row(
+                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Expanded(
                           child: GestureDetector(
-                            onTap: (){
-                              Get.toNamed("/userInfoTransaction",parameters: {"accountId":trans.accountId.toString()});
+                            onTap: () {
+                              Get.toNamed(
+                                '/userInfoTransaction',
+                                parameters: {'accountId': trans.accountId.toString()},
+                              );
                             },
                             child: Text(
-                              trans.accountName ?? "",
-                              style: AppTextStyle.labelText.copyWith(fontSize: 13, fontWeight: FontWeight.bold, color: AppColor.textColor),
+                              trans.accountName ?? '',
+                              style: AppTextStyle.labelText.copyWith(
+                                fontSize: 13,
+                                fontWeight: FontWeight.bold,
+                                color: AppColor.textColor,
+                              ),
                               overflow: TextOverflow.ellipsis,
                             ),
                           ),
                         ),
-                        Text("${trans.rowNum}", style: AppTextStyle.labelText.copyWith(fontSize: 10, color: AppColor.textColor.withAlpha(200))),
+                        Text(
+                          '${trans.rowNum}',
+                          style: AppTextStyle.labelText.copyWith(
+                            fontSize: 10,
+                            color: AppColor.textColor.withAlpha(200),
+                          ),
+                        ),
                       ],
                     ),
-                    SizedBox(height: 8),
-                    Divider(height: 0.5,color: AppColor.dividerColor),
-                    SizedBox(height: 8),
-                    // Rial balances
-                    if((trans.cashBalanceBes ?? 0) > 0)
-                      _mobileLine("┘à╪º┘å╪»┘ç ┘ê╪¼┘ç ┘å┘é╪» (╪¿╪│)",
-                          "${trans.cashBalanceBes!.toStringAsFixed(0).seRagham()}", AppColor.primaryColor,"╪▒█î╪º┘ä"),
-                    if((trans.cashBalanceBed ?? 0) < 0)
-                      _mobileLine("┘à╪º┘å╪»┘ç ┘ê╪¼┘ç ┘å┘é╪» (╪¿╪»)",
-                          "-${trans.cashBalanceBed!.abs().toStringAsFixed(0).seRagham()}", AppColor.accentColor,"╪▒█î╪º┘ä"),
-                    // Gold balances
-                    if((trans.goldBalanceBes ?? 0) > 0)
-                      _mobileLine("┘à╪º┘å╪»┘ç ╪ó╪¿╪┤╪»┘ç (╪¿╪│)",
-                          "${trans.goldBalanceBes!.toStringAsFixed(3)}", AppColor.primaryColor,"┌»╪▒┘à"),
-                    if((trans.goldBalanceBed ?? 0) < 0)
-                      _mobileLine("┘à╪º┘å╪»┘ç ╪ó╪¿╪┤╪»┘ç (╪¿╪»)",
-                          "-${trans.goldBalanceBed!.abs().toStringAsFixed(3)}", AppColor.accentColor,"┌»╪▒┘à"),
-                    // Coin balances
-                    if((trans.coinBalanceBes ?? 0) != 0 || (trans.halfCoinBalanceBes ?? 0) != 0 || (trans.quarterCoinBalanceBes ?? 0) != 0)
-                      _mobileLine("╪│┌⌐┘ç ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒",
-                          "╪¬┘à╪º┘à ${trans.coinBalanceBes?.toDisplayString()} / ┘å█î┘à ${trans.halfCoinBalanceBes?.toDisplayString()} / ╪▒╪¿╪╣ ${trans.quarterCoinBalanceBes?.toDisplayString()}", AppColor.primaryColor,"╪╣╪»╪»"),
-                    if((trans.coinBalanceBed ?? 0) != 0 || (trans.halfCoinBalanceBed ?? 0) != 0 || (trans.quarterCoinBalanceBed ?? 0) != 0)
-                      _mobileLine("╪│┌⌐┘ç ╪¿╪»┘ç┌⌐╪º╪▒",
-                          "-╪¬┘à╪º┘à ${(trans.coinBalanceBed??0).abs().toDisplayString()}- / ┘å█î┘à ${(trans.halfCoinBalanceBed??0).abs().toDisplayString()}- / ╪▒╪¿╪╣ ${(trans.quarterCoinBalanceBed??0).abs().toDisplayString()}", AppColor.accentColor,"╪╣╪»╪»"),
-                    // Currency sample (USD)
-                    if((trans.balances??[]).any((e)=> e.unitName=="╪»┘ä╪º╪▒" && (e.balance??0)>0))
-                      _mobileLine("╪º╪▒╪▓ ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒",
-                          "${(trans.balances??[]).where((e)=>e.unitName=="╪»┘ä╪º╪▒").fold<double>(0, (p, e)=> p + (e.balance??0))}", AppColor.primaryColor,"╪»┘ä╪º╪▒"),
-                    if((trans.balances??[]).any((e)=> e.unitName=="╪»┘ä╪º╪▒" && (e.balance??0)<0))
-                      _mobileLine("╪º╪▒╪▓ ╪¿╪»┘ç┌⌐╪º╪▒",
-                          "-${(trans.balances??[]).where((e)=>e.unitName=="╪»┘ä╪º╪▒").fold<double>(0, (p, e)=> p + (e.balance??0).abs())}", AppColor.accentColor,"╪»┘ä╪º╪▒"),
-                    SizedBox(height: 8),
+                    const SizedBox(height: 8),
+                    Divider(height: 0.5, color: AppColor.dividerColor),
+                    const SizedBox(height: 8),
+                    if ((trans.cashBalanceBes ?? 0) > 0)
+                      _mobileLine(
+                        '┘à╪º┘å╪»┘ç ┘ê╪¼┘ç ┘å┘é╪» (╪¿╪│)',
+                        trans.cashBalanceBes!.toStringAsFixed(0).seRagham(),
+                        AppColor.primaryColor,
+                        '╪▒█î╪º┘ä',
+                      ),
+                    if ((trans.cashBalanceBed ?? 0) < 0)
+                      _mobileLine(
+                        '┘à╪º┘å╪»┘ç ┘ê╪¼┘ç ┘å┘é╪» (╪¿╪»)',
+                        '-${trans.cashBalanceBed!.abs().toStringAsFixed(0).seRagham()}',
+                        AppColor.accentColor,
+                        '╪▒█î╪º┘ä',
+                      ),
+                    if ((trans.goldBalanceBes ?? 0) > 0)
+                      _mobileLine(
+                        '┘à╪º┘å╪»┘ç ╪ó╪¿╪┤╪»┘ç (╪¿╪│)',
+                        trans.goldBalanceBes!.toStringAsFixed(3),
+                        AppColor.primaryColor,
+                        '┌»╪▒┘à',
+                      ),
+                    if ((trans.goldBalanceBed ?? 0) < 0)
+                      _mobileLine(
+                        '┘à╪º┘å╪»┘ç ╪ó╪¿╪┤╪»┘ç (╪¿╪»)',
+                        '-${trans.goldBalanceBed!.abs().toStringAsFixed(3)}',
+                        AppColor.accentColor,
+                        '┌»╪▒┘à',
+                      ),
+                    if ((trans.coinBalanceBes ?? 0) != 0 ||
+                        (trans.halfCoinBalanceBes ?? 0) != 0 ||
+                        (trans.quarterCoinBalanceBes ?? 0) != 0)
+                      _mobileLine(
+                        '╪│┌⌐┘ç ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                        '╪¬┘à╪º┘à ${trans.coinBalanceBes?.toDisplayString()} / ┘å█î┘à ${trans.halfCoinBalanceBes?.toDisplayString()} / ╪▒╪¿╪╣ ${trans.quarterCoinBalanceBes?.toDisplayString()}',
+                        AppColor.primaryColor,
+                        '╪╣╪»╪»',
+                      ),
+                    if ((trans.coinBalanceBed ?? 0) != 0 ||
+                        (trans.halfCoinBalanceBed ?? 0) != 0 ||
+                        (trans.quarterCoinBalanceBed ?? 0) != 0)
+                      _mobileLine(
+                        '╪│┌⌐┘ç ╪¿╪»┘ç┌⌐╪º╪▒',
+                        '-╪¬┘à╪º┘à ${(trans.coinBalanceBed ?? 0).abs().toDisplayString()}- / ┘å█î┘à ${(trans.halfCoinBalanceBed ?? 0).abs().toDisplayString()}- / ╪▒╪¿╪╣ ${(trans.quarterCoinBalanceBed ?? 0).abs().toDisplayString()}-',
+                        AppColor.accentColor,
+                        '╪╣╪»╪»',
+                      ),
+                    if ((trans.balances ?? []).any((e) => e.unitName == '╪»┘ä╪º╪▒' && (e.balance ?? 0) > 0))
+                      _mobileLine(
+                        '╪º╪▒╪▓ ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                        '${(trans.balances ?? []).where((e) => e.unitName == '╪»┘ä╪º╪▒').fold<double>(0, (p, e) => p + (e.balance ?? 0))}',
+                        AppColor.primaryColor,
+                        '╪»┘ä╪º╪▒',
+                      ),
+                    if ((trans.balances ?? []).any((e) => e.unitName == '╪»┘ä╪º╪▒' && (e.balance ?? 0) < 0))
+                      _mobileLine(
+                        '╪º╪▒╪▓ ╪¿╪»┘ç┌⌐╪º╪▒',
+                        '-${(trans.balances ?? []).where((e) => e.unitName == '╪»┘ä╪º╪▒').fold<double>(0, (p, e) => p + (e.balance ?? 0).abs())}',
+                        AppColor.accentColor,
+                        '╪»┘ä╪º╪▒',
+                      ),
+                    const SizedBox(height: 8),
                     Container(
-                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
+                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                       decoration: BoxDecoration(
                         color: AppColor.backGroundColor.withAlpha(60),
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: AppColor.textColor.withAlpha(50)),
                       ),
                       child: Column(
                         children: [
-                          if((trans.currencyValueBes ?? 0) > 0)
-                            _mobileLineWithIcon("╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪│",
-                                "${trans.currencyValueBes!.toStringAsFixed(0).seRagham()}",
-                                'assets/svg/scales.svg', AppColor.primaryColor,"╪▒█î╪º┘ä"),
-                          if((trans.currencyValueBed ?? 0) < 0)
-                            _mobileLineWithIcon("╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪»",
-                                "-${trans.currencyValueBed!.abs().toStringAsFixed(0).seRagham()}",
-                                'assets/svg/scales.svg', AppColor.accentColor,"╪▒█î╪º┘ä"),
-                          if((trans.goldValue ?? 0) != 0)
-                            _mobileLine("┘à╪╣╪º╪»┘ä ╪ó╪¿╪┤╪»┘ç",
-                                (trans.goldValue ?? 0) < 0 ? "-${trans.goldValue!.abs().toStringAsFixed(3)}" : "${trans.goldValue!.toStringAsFixed(3)}",
-                                (trans.goldValue ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,"┌»╪▒┘à"),
-                          if((trans.coinValue ?? 0) != 0)
-                            _mobileLine("┘à╪╣╪º╪»┘ä ╪│┌⌐┘ç",
-                                (trans.coinValue ?? 0) < 0 ? "-${trans.coinValue!.abs().toStringAsFixed(3)}" : "${trans.coinValue!.toStringAsFixed(3)}",
-                                (trans.coinValue ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,"╪╣╪»╪»"),
+                          if ((trans.currencyValueBes ?? 0) > 0)
+                            _mobileLineWithIcon(
+                              '╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪│',
+                              trans.currencyValueBes!.toStringAsFixed(0).seRagham(),
+                              'assets/svg/scales.svg',
+                              AppColor.primaryColor,
+                              '╪▒█î╪º┘ä',
+                            ),
+                          if ((trans.currencyValueBed ?? 0) < 0)
+                            _mobileLineWithIcon(
+                              '╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪»',
+                              '-${trans.currencyValueBed!.abs().toStringAsFixed(0).seRagham()}',
+                              'assets/svg/scales.svg',
+                              AppColor.accentColor,
+                              '╪▒█î╪º┘ä',
+                            ),
+                          if ((trans.goldValue ?? 0) != 0)
+                            _mobileLine(
+                              '┘à╪╣╪º╪»┘ä ╪ó╪¿╪┤╪»┘ç',
+                              (trans.goldValue ?? 0) < 0
+                                  ? '-${trans.goldValue!.abs().toStringAsFixed(3)}'
+                                  : trans.goldValue!.toStringAsFixed(3),
+                              (trans.goldValue ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
+                              '┌»╪▒┘à',
+                            ),
+                          if ((trans.coinValue ?? 0) != 0)
+                            _mobileLine(
+                              '┘à╪╣╪º╪»┘ä ╪│┌⌐┘ç',
+                              (trans.coinValue ?? 0) < 0
+                                  ? '-${trans.coinValue!.abs().toStringAsFixed(3)}'
+                                  : trans.coinValue!.toStringAsFixed(3),
+                              (trans.coinValue ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
+                              '╪╣╪»╪»',
+                            ),
                         ],
                       ),
                     ),
                   ],
                 ),
@@ -2974,128 +472,94 @@ class ListUserInfoTransactionView extends GetView<UserInfoTransactionController>
             },
           ),
           Obx(() {
             if (controller.isLoading.value && controller.listTransactionInfo.isNotEmpty) {
               return Container(
-                padding: EdgeInsets.all(16),
-                child: Center(
-                  child: HaniGoldLoading(),
-                ),
+                padding: const EdgeInsets.all(16),
+                child: const Center(child: HaniGoldLoading()),
               );
             }
 
             if (!controller.hasMore.value && controller.listTransactionInfo.isNotEmpty) {
               return Container(
-                padding: EdgeInsets.all(16),
+                padding: const EdgeInsets.all(16),
                 child: Text(
-                  "┘ç┘à┘ç ╪¬╪▒╪º┌⌐┘å╪┤ΓÇî┘ç╪º ┘å┘à╪º█î╪┤ ╪»╪º╪»┘ç ╪┤╪»",
+                  '┘ç┘à┘ç ╪¬╪▒╪º┌⌐┘å╪┤ΓÇî┘ç╪º ┘å┘à╪º█î╪┤ ╪»╪º╪»┘ç ╪┤╪»',
                   textAlign: TextAlign.center,
                   style: AppTextStyle.bodyText.copyWith(
-                    color: AppColor.textColor.withOpacity(0.7),
+                    color: AppColor.textColor.withValues(alpha: 0.7),
                   ),
                 ),
               );
             }
-            return SizedBox.shrink();
+            return const SizedBox.shrink();
           }),
-          SizedBox(height: 20),
+          const SizedBox(height: 20),
         ],
       ),
     );
   }
 
   Widget _buildMobileSortHeader() {
     return Container(
-      padding: EdgeInsets.symmetric(horizontal: 12,),
+      padding: const EdgeInsets.symmetric(horizontal: 12),
       decoration: BoxDecoration(
         color: AppColor.appBarColor.withAlpha(80),
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: AppColor.textColor.withAlpha(80)),
       ),
       child: Row(
         children: [
-          Icon(
-            Icons.sort,
-            color: AppColor.textColor,
-            size: 18,
-          ),
-          SizedBox(width: 8),
+          Icon(Icons.sort, color: AppColor.textColor, size: 18),
+          const SizedBox(width: 8),
           Text(
             '┘à╪▒╪¬╪¿ΓÇî╪│╪º╪▓█î:',
             style: AppTextStyle.labelText.copyWith(
               fontSize: 12,
               fontWeight: FontWeight.bold,
               color: AppColor.textColor,
             ),
           ),
-          SizedBox(width: 12),
+          const SizedBox(width: 12),
           Expanded(
             child: DropdownButtonHideUnderline(
               child: DropdownButton<int>(
                 value: controller.sortColumnIndex.value,
                 isExpanded: true,
-                style: AppTextStyle.labelText.copyWith(
-                  fontSize: 11,
-                  color: AppColor.textColor,
-                ),
+                style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.textColor),
                 dropdownColor: AppColor.appBarColor,
-                icon: Icon(
-                  Icons.arrow_drop_down,
-                  color: AppColor.textColor,
-                ),
-                items: [
-                  DropdownMenuItem(
-                    value: 2,
-                    child: Text('╪▒█î╪º┘ä ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒'),
-                  ),
-                  DropdownMenuItem(
-                    value: 3,
-                    child: Text('╪▒█î╪º┘ä ╪¿╪»┘ç┌⌐╪º╪▒'),
-                  ),
-                  DropdownMenuItem(
-                    value: 4,
-                    child: Text('╪╖┘ä╪º ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒'),
-                  ),
-                  DropdownMenuItem(
-                    value: 5,
-                    child: Text('╪╖┘ä╪º ╪¿╪»┘ç┌⌐╪º╪▒'),
-                  ),
-                  DropdownMenuItem(
-                    value: 6,
-                    child: Text('╪│┌⌐┘ç ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒'),
-                  ),
-                  DropdownMenuItem(
-                    value: 7,
-                    child: Text('╪│┌⌐┘ç ╪¿╪»┘ç┌⌐╪º╪▒'),
-                  ),
-                  DropdownMenuItem(
-                    value: 10,
-                    child: Text('╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒'),
-                  ),
-                  DropdownMenuItem(
-                    value: 11,
-                    child: Text('╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪»┘ç┌⌐╪º╪▒'),
-                  ),
+                icon: Icon(Icons.arrow_drop_down, color: AppColor.textColor),
+                items: const [
+                  DropdownMenuItem(value: 2, child: Text('╪▒█î╪º┘ä ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒')),
+                  DropdownMenuItem(value: 3, child: Text('╪▒█î╪º┘ä ╪¿╪»┘ç┌⌐╪º╪▒')),
+                  DropdownMenuItem(value: 4, child: Text('╪╖┘ä╪º ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒')),
+                  DropdownMenuItem(value: 5, child: Text('╪╖┘ä╪º ╪¿╪»┘ç┌⌐╪º╪▒')),
+                  DropdownMenuItem(value: 6, child: Text('╪│┌⌐┘ç ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒')),
+                  DropdownMenuItem(value: 7, child: Text('╪│┌⌐┘ç ╪¿╪»┘ç┌⌐╪º╪▒')),
+                  DropdownMenuItem(value: 10, child: Text('╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒')),
+                  DropdownMenuItem(value: 11, child: Text('╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪»┘ç┌⌐╪º╪▒')),
                 ],
                 onChanged: (int? newValue) {
                   if (newValue != null) {
                     controller.onSort(newValue, !controller.sortAscending.value);
                   }
                 },
               ),
             ),
           ),
-          SizedBox(width: 8),
-          // Sort direction toggle button
+          const SizedBox(width: 8),
           GestureDetector(
             onTap: () {
               if (controller.sortColumnIndex.value != null) {
-                controller.onSort(controller.sortColumnIndex.value!, !controller.sortAscending.value);
+                controller.onSort(
+                  controller.sortColumnIndex.value!,
+                  !controller.sortAscending.value,
+                );
               }
             },
             child: Container(
-              padding: EdgeInsets.all(4),
+              padding: const EdgeInsets.all(4),
               decoration: BoxDecoration(
                 color: controller.sortColumnIndex.value != null
                     ? AppColor.primaryColor.withAlpha(30)
                     : Colors.transparent,
                 borderRadius: BorderRadius.circular(4),
@@ -3118,39 +582,88 @@ class ListUserInfoTransactionView extends GetView<UserInfoTransactionController>
         ],
       ),
     );
   }
 
-  Widget _mobileLine(String label, String value, Color color , String itemName){
+  Widget _mobileLine(String label, String value, Color color, String itemName) {
     return Padding(
-      padding: EdgeInsets.only(bottom: 6),
+      padding: const EdgeInsets.only(bottom: 6),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
-          Expanded(child: Text(label, style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.textColor))),
-          SizedBox(width: 8),
-          Text(value, style: AppTextStyle.labelText.copyWith(fontSize: 12, color: color, fontWeight: FontWeight.bold), textDirection: TextDirection.ltr),
-          SizedBox(width: 4),
-          Text(itemName, style: AppTextStyle.labelText.copyWith(fontSize: 10, color: AppColor.textColor, fontWeight: FontWeight.bold),),
+          Expanded(
+            child: Text(
+              label,
+              style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.textColor),
+            ),
+          ),
+          const SizedBox(width: 8),
+          Text(
+            value,
+            style: AppTextStyle.labelText.copyWith(
+              fontSize: 12,
+              color: color,
+              fontWeight: FontWeight.bold,
+            ),
+            textDirection: TextDirection.ltr,
+          ),
+          const SizedBox(width: 4),
+          Text(
+            itemName,
+            style: AppTextStyle.labelText.copyWith(
+              fontSize: 10,
+              color: AppColor.textColor,
+              fontWeight: FontWeight.bold,
+            ),
+          ),
         ],
       ),
     );
   }
 
-  Widget _mobileLineWithIcon(String label, String value, String asset, Color color,String itemName){
+  Widget _mobileLineWithIcon(
+    String label,
+    String value,
+    String asset,
+    Color color,
+    String itemName,
+  ) {
     return Padding(
-      padding: EdgeInsets.only(bottom: 6),
+      padding: const EdgeInsets.only(bottom: 6),
       child: Row(
         children: [
-          SvgPicture.asset(asset, height: 14, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
-          SizedBox(width: 6),
-          Expanded(child: Text(label, style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.textColor))),
-          SizedBox(width: 8),
-          Text(value, style: AppTextStyle.labelText.copyWith(fontSize: 12, color: color, fontWeight: FontWeight.bold), textDirection: TextDirection.ltr),
-          SizedBox(width: 4),
-          Text(itemName, style: AppTextStyle.labelText.copyWith(fontSize: 10, color: AppColor.textColor, fontWeight: FontWeight.bold),),
+          SvgPicture.asset(
+            asset,
+            height: 14,
+            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
+          ),
+          const SizedBox(width: 6),
+          Expanded(
+            child: Text(
+              label,
+              style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.textColor),
+            ),
+          ),
+          const SizedBox(width: 8),
+          Text(
+            value,
+            style: AppTextStyle.labelText.copyWith(
+              fontSize: 12,
+              color: color,
+              fontWeight: FontWeight.bold,
+            ),
+            textDirection: TextDirection.ltr,
+          ),
+          const SizedBox(width: 4),
+          Text(
+            itemName,
+            style: AppTextStyle.labelText.copyWith(
+              fontSize: 10,
+              color: AppColor.textColor,
+              fontWeight: FontWeight.bold,
+            ),
+          ),
         ],
       ),
     );
   }
-
 }
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_footer.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_footer.widget.dart
new file mode 100644
index 0000000..0874e6d
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_footer.widget.dart
@@ -0,0 +1,507 @@
+import 'package:flutter/material.dart';
+import 'package:flutter_svg/svg.dart';
+import 'package:get/get.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
+import 'package:hanigold_admin/src/domain/users/model/transaction_info_footer.model.dart';
+import 'package:persian_number_utility/persian_number_utility.dart';
+
+/// Responsive footer grid for desktop user-balance totals (credit/debit + net).
+class UserBalanceFooter extends StatelessWidget {
+  const UserBalanceFooter({
+    super.key,
+    required this.controller,
+  });
+
+  final UserInfoTransactionController controller;
+
+  @override
+  Widget build(BuildContext context) {
+    return Obx(() {
+      final footer = controller.listTransactionInfoFooter;
+      if (footer.isEmpty) {
+        return const SizedBox.shrink();
+      }
+
+      return Container(
+        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
+        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
+        decoration: BoxDecoration(
+          borderRadius: BorderRadius.circular(8),
+          color: AppColor.appBarColor.withAlpha(130),
+        ),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Container(
+              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
+              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
+              child: Wrap(
+                spacing: 16,
+                runSpacing: 12,
+                alignment: WrapAlignment.start,
+                children: [
+                  _buildFooterItem(
+                    title: '╪▒█î╪º┘ä ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                    positiveValue: _sumPositive(footer, '╪▒█î╪º┘ä'),
+                    color: AppColor.primaryColor,
+                    unit: '╪▒█î╪º┘ä',
+                  ),
+                  _buildFooterItem(
+                    title: '╪▒█î╪º┘ä ╪¿╪»┘ç┌⌐╪º╪▒',
+                    negativeValue: _sumNegative(footer, '╪▒█î╪º┘ä'),
+                    color: AppColor.accentColor,
+                    unit: '╪▒█î╪º┘ä',
+                  ),
+                  _footerItemWithDetail(
+                    context: context,
+                    title: '╪╖┘ä╪º ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                    positiveValue: _sumPositive(footer, '┌»╪▒┘à'),
+                    color: AppColor.primaryColor,
+                    unit: '┌»╪▒┘à',
+                    dialogTitle: '╪¼╪▓█î█î╪º╪¬',
+                    dialogMiddleText: '┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪╖┘ä╪º█î ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                    detailRows: footer
+                        .where((e) =>
+                            e.unitName == '┌»╪▒┘à' && (e.totalPositiveBalance ?? 0) > 0)
+                        .map((e) => _DetailRow(
+                              label: e.itemName ?? '',
+                              value: '${e.totalPositiveBalance ?? 0} ┌»╪▒┘à ',
+                            ))
+                        .toList(),
+                  ),
+                  _footerItemWithDetail(
+                    context: context,
+                    title: '╪╖┘ä╪º ╪¿╪»┘ç┌⌐╪º╪▒',
+                    negativeValue: _sumNegative(footer, '┌»╪▒┘à'),
+                    color: AppColor.accentColor,
+                    unit: '┌»╪▒┘à',
+                    dialogTitle: '╪¼╪▓█î█î╪º╪¬',
+                    dialogMiddleText: '┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪╖┘ä╪º█î ╪¿╪»┘ç┌⌐╪º╪▒',
+                    detailRows: footer
+                        .where((e) =>
+                            e.unitName == '┌»╪▒┘à' && (e.totalNegativeBalance ?? 0) < 0)
+                        .map((e) => _DetailRow(
+                              label: e.itemName ?? '',
+                              value: '${e.totalNegativeBalance ?? 0} ┌»╪▒┘à ',
+                            ))
+                        .toList(),
+                  ),
+                  _footerItemWithDetail(
+                    context: context,
+                    title: '╪│┌⌐┘ç ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                    positiveValue: _sumPositive(footer, '╪╣╪»╪»'),
+                    color: AppColor.primaryColor,
+                    unit: '╪╣╪»╪»',
+                    dialogTitle: '╪¼╪▓█î█î╪º╪¬',
+                    dialogMiddleText: '┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪│┌⌐┘ç ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                    detailRows: footer
+                        .where((e) =>
+                            e.unitName == '╪╣╪»╪»' && (e.totalPositiveBalance ?? 0) > 0)
+                        .map((e) => _DetailRow(
+                              label: e.itemName ?? '',
+                              value: '${e.totalPositiveBalance ?? 0} ╪╣╪»╪» ',
+                            ))
+                        .toList(),
+                  ),
+                  _footerItemWithDetail(
+                    context: context,
+                    title: '╪│┌⌐┘ç ╪¿╪»┘ç┌⌐╪º╪▒',
+                    negativeValue: _sumNegative(footer, '╪╣╪»╪»'),
+                    color: AppColor.accentColor,
+                    unit: '╪╣╪»╪»',
+                    dialogTitle: '╪¼╪▓█î█î╪º╪¬',
+                    dialogMiddleText: '┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪│┌⌐┘ç ╪¿╪»┘ç┌⌐╪º╪▒',
+                    detailRows: footer
+                        .where((e) =>
+                            e.unitName == '╪╣╪»╪»' && (e.totalNegativeBalance ?? 0) < 0)
+                        .map((e) => _DetailRow(
+                              label: e.itemName ?? '',
+                              value: '${e.totalNegativeBalance ?? 0} ╪╣╪»╪» ',
+                            ))
+                        .toList(),
+                  ),
+                  Column(
+                    crossAxisAlignment: CrossAxisAlignment.start,
+                    children: [
+                      _buildFooterItem(
+                        title: '╪º╪▒╪▓ ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                        positiveValue: _sumPositive(footer, '╪»┘ä╪º╪▒'),
+                        color: AppColor.primaryColor,
+                        unit: '╪»┘ä╪º╪▒',
+                      ),
+                      _buildFooterItem(
+                        title: '',
+                        positiveValue: _sumPositive(footer, '█î┘ê╪▒┘ê'),
+                        color: AppColor.primaryColor,
+                        unit: '█î┘ê╪▒┘ê',
+                      ),
+                    ],
+                  ),
+                  Column(
+                    crossAxisAlignment: CrossAxisAlignment.start,
+                    children: [
+                      _buildFooterItem(
+                        title: '╪º╪▒╪▓ ╪¿╪»┘ç┌⌐╪º╪▒',
+                        negativeValue: _sumNegative(footer, '╪»┘ä╪º╪▒'),
+                        color: AppColor.accentColor,
+                        unit: '╪»┘ä╪º╪▒',
+                      ),
+                      const SizedBox(height: 2),
+                      _buildFooterItem(
+                        title: '',
+                        positiveValue: _sumNegative(footer, '█î┘ê╪▒┘ê'),
+                        color: AppColor.primaryColor,
+                        unit: '█î┘ê╪▒┘ê',
+                      ),
+                    ],
+                  ),
+                ],
+              ),
+            ),
+            Container(
+              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
+              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
+              decoration: BoxDecoration(
+                borderRadius: BorderRadius.circular(8),
+                color: AppColor.backGroundColor1.withAlpha(130),
+              ),
+              child: Wrap(
+                spacing: 16,
+                runSpacing: 12,
+                alignment: WrapAlignment.start,
+                crossAxisAlignment: WrapCrossAlignment.start,
+                children: [
+                  _buildNetFooterItem(
+                    title: '╪▒█î╪º┘ä ╪«╪º┘ä╪╡',
+                    netValue: _netSum(footer, '╪▒█î╪º┘ä'),
+                    unit: '╪▒█î╪º┘ä',
+                  ),
+                  _buildNetFooterItem(
+                    title: '╪╖┘ä╪º ╪«╪º┘ä╪╡',
+                    netValue: _netSum(footer, '┌»╪▒┘à'),
+                    unit: '┌»╪▒┘à',
+                  ),
+                  ...footer
+                      .where((item) => item.unitName == '╪╣╪»╪»')
+                      .map((item) {
+                    final netValue = (item.totalPositiveBalance ?? 0) +
+                        (item.totalNegativeBalance ?? 0);
+                    if (netValue == 0.0) return const SizedBox.shrink();
+                    return Padding(
+                      padding: const EdgeInsets.only(bottom: 8),
+                      child: _buildNetFooterItem(
+                        title: item.itemName ?? '╪│┌⌐┘ç',
+                        netValue: netValue,
+                        unit: '╪╣╪»╪»',
+                      ),
+                    );
+                  }),
+                  ...footer.where((item) => item.itemGroupName == '╪º╪▒╪▓').map((item) {
+                    final netValue = (item.totalPositiveBalance ?? 0) +
+                        (item.totalNegativeBalance ?? 0);
+                    if (netValue == 0.0) return const SizedBox.shrink();
+                    return Padding(
+                      padding: const EdgeInsets.only(bottom: 8),
+                      child: _buildNetFooterItem(
+                        title: '',
+                        netValue: netValue,
+                        unit: item.unitName,
+                      ),
+                    );
+                  }),
+                  Column(
+                    crossAxisAlignment: CrossAxisAlignment.start,
+                    children: [
+                      Text(
+                        '┘à╪¼┘à┘ê╪╣ ┌⌐┘ä:',
+                        style: AppTextStyle.labelText.copyWith(
+                          fontSize: 14,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      const SizedBox(height: 10),
+                      _buildNetFooterItem(
+                        title: '┘à╪¼┘à┘ê╪╣ ┌⌐┘ä',
+                        netValue: footer.fold<double>(
+                          0.0,
+                          (sum, item) =>
+                              sum +
+                              ((item.totalPositiveBalance ?? 0) +
+                                  (item.totalNegativeBalance ?? 0)),
+                        ),
+                        unit: '╪▒█î╪º┘ä',
+                      ),
+                    ],
+                  ),
+                ],
+              ),
+            ),
+          ],
+        ),
+      );
+    });
+  }
+
+  static double _sumPositive(
+    List<TransactionInfoFooterModel> footer,
+    String unitName,
+  ) {
+    return footer
+        .where((item) => item.unitName == unitName)
+        .fold(0.0, (sum, item) => sum + (item.totalPositiveBalance ?? 0));
+  }
+
+  static double _sumNegative(
+    List<TransactionInfoFooterModel> footer,
+    String unitName,
+  ) {
+    return footer
+        .where((item) => item.unitName == unitName)
+        .fold(0.0, (sum, item) => sum + (item.totalNegativeBalance ?? 0));
+  }
+
+  static double _netSum(List<TransactionInfoFooterModel> footer, String unitName) {
+    return footer
+        .where((item) => item.unitName == unitName)
+        .fold(
+          0.0,
+          (sum, item) =>
+              sum +
+              ((item.totalPositiveBalance ?? 0) + (item.totalNegativeBalance ?? 0)),
+        );
+  }
+
+  static Widget _footerItemWithDetail({
+    required BuildContext context,
+    required String title,
+    double? positiveValue,
+    double? negativeValue,
+    required Color color,
+    required String unit,
+    required String dialogTitle,
+    required String dialogMiddleText,
+    required List<_DetailRow> detailRows,
+  }) {
+    return Row(
+      mainAxisSize: MainAxisSize.min,
+      children: [
+        _buildFooterItem(
+          title: title,
+          positiveValue: positiveValue,
+          negativeValue: negativeValue,
+          color: color,
+          unit: unit,
+        ),
+        GestureDetector(
+          onTap: () => _showDetailDialog(
+            context: context,
+            title: dialogTitle,
+            middleText: dialogMiddleText,
+            rows: detailRows,
+          ),
+          child: SvgPicture.asset(
+            'assets/svg/list.svg',
+            height: 16,
+            colorFilter: ColorFilter.mode(
+              AppColor.textColor,
+              BlendMode.srcIn,
+            ),
+          ),
+        ),
+      ],
+    );
+  }
+
+  static void _showDetailDialog({
+    required BuildContext context,
+    required String title,
+    required String middleText,
+    required List<_DetailRow> rows,
+  }) {
+    Get.defaultDialog(
+      confirm: Column(
+        children: rows
+            .map(
+              (row) => Row(
+                mainAxisAlignment: MainAxisAlignment.spaceBetween,
+                children: [
+                  Text(
+                    row.label,
+                    style: AppTextStyle.labelText.copyWith(
+                      fontSize: 12,
+                      color: AppColor.backGroundColor,
+                    ),
+                  ),
+                  Text(
+                    row.value,
+                    style: AppTextStyle.labelText.copyWith(
+                      fontSize: 12,
+                      color: AppColor.backGroundColor,
+                    ),
+                  ),
+                ],
+              ),
+            )
+            .toList(),
+      ),
+      middleText: middleText,
+      middleTextStyle: context.textTheme.bodyMedium!.copyWith(
+        color: AppColor.backGroundColor,
+        fontSize: 13,
+      ),
+      title: title,
+      titleStyle: context.textTheme.titleSmall!.copyWith(
+        color: AppColor.backGroundColor,
+        fontSize: 14,
+      ),
+      backgroundColor: AppColor.textColor,
+      radius: 7,
+      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
+    );
+  }
+
+  static Widget _buildFooterItem({
+    required String title,
+    double? positiveValue,
+    double? negativeValue,
+    required Color color,
+    String? unit,
+  }) {
+    final value = positiveValue ?? negativeValue ?? 0.0;
+
+    if (value == 0.0) {
+      return const SizedBox.shrink();
+    }
+
+    String formattedValue;
+    if (unit == '╪▒█î╪º┘ä') {
+      formattedValue = value.toStringAsFixed(3).seRagham();
+    } else if (unit == '┌»╪▒┘à') {
+      formattedValue = value.toStringAsFixed(3);
+    } else {
+      formattedValue = value.toString();
+    }
+
+    return Container(
+      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
+      decoration: BoxDecoration(
+        border: Border.all(color: color, width: 1),
+        borderRadius: BorderRadius.circular(8),
+      ),
+      child: Row(
+        mainAxisSize: MainAxisSize.min,
+        children: [
+          Text(
+            title,
+            style: AppTextStyle.labelText.copyWith(
+              fontSize: 12,
+              fontWeight: FontWeight.bold,
+            ),
+          ),
+          const SizedBox(width: 3),
+          Row(
+            mainAxisSize: MainAxisSize.min,
+            children: [
+              Text(
+                formattedValue,
+                style: AppTextStyle.bodyText.copyWith(
+                  fontSize: 14,
+                  color: color,
+                  fontWeight: FontWeight.bold,
+                ),
+                textDirection: TextDirection.ltr,
+              ),
+              if (unit != null) ...[
+                const SizedBox(width: 4),
+                Text(
+                  unit,
+                  style: AppTextStyle.bodyText.copyWith(
+                    fontSize: 12,
+                    color: color,
+                    fontWeight: FontWeight.bold,
+                  ),
+                ),
+              ],
+            ],
+          ),
+        ],
+      ),
+    );
+  }
+
+  static Widget _buildNetFooterItem({
+    required String title,
+    required double netValue,
+    String? unit,
+  }) {
+    if (netValue == 0.0) {
+      return const SizedBox.shrink();
+    }
+
+    final color = netValue > 0 ? AppColor.primaryColor : AppColor.accentColor;
+
+    String formattedValue;
+    if (unit == '╪▒█î╪º┘ä') {
+      formattedValue = netValue.toStringAsFixed(0).seRagham();
+    } else if (unit == '┌»╪▒┘à') {
+      formattedValue = netValue.toStringAsFixed(3);
+    } else {
+      formattedValue = netValue.toStringAsFixed(3);
+    }
+
+    return Container(
+      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
+      decoration: BoxDecoration(
+        border: Border.all(color: color, width: 1),
+        borderRadius: BorderRadius.circular(8),
+      ),
+      child: Row(
+        mainAxisSize: MainAxisSize.min,
+        children: [
+          Text(
+            title,
+            style: AppTextStyle.labelText.copyWith(
+              fontSize: 12,
+              fontWeight: FontWeight.bold,
+            ),
+          ),
+          const SizedBox(width: 3),
+          Row(
+            mainAxisSize: MainAxisSize.min,
+            children: [
+              Text(
+                formattedValue,
+                style: AppTextStyle.bodyText.copyWith(
+                  fontSize: 14,
+                  color: color,
+                  fontWeight: FontWeight.bold,
+                ),
+                textDirection: TextDirection.ltr,
+              ),
+              if (unit != null) ...[
+                const SizedBox(width: 4),
+                Text(
+                  unit,
+                  style: AppTextStyle.bodyText.copyWith(
+                    fontSize: 12,
+                    color: color,
+                    fontWeight: FontWeight.bold,
+                  ),
+                ),
+              ],
+            ],
+          ),
+        ],
+      ),
+    );
+  }
+}
+
+class _DetailRow {
+  const _DetailRow({required this.label, required this.value});
+
+  final String label;
+  final String value;
+}
