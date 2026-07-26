# Review package - Task 4 (no git)

## Commits
None (no git repository).

## Files changed
- lib/src/domain/users/view/user_info_transaction.view.dart

## Diff

diff --git "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-4\\user_info_transaction.view.dart" "b/lib\\src\\domain\\users\\view\\user_info_transaction.view.dart"
index ca373a9..d25f274 100644
--- "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-4\\user_info_transaction.view.dart"
+++ "b/lib\\src\\domain\\users\\view\\user_info_transaction.view.dart"
@@ -17,37 +17,107 @@ import 'package:shamsi_date/shamsi_date.dart';
 import '../../../config/const/app_color.dart';
 import '../../../config/const/app_text_style.dart';
 import '../../../config/repository/url/base_url.dart';
 import '../../../widget/app_drawer.widget.dart';
 import '../../../widget/background_image_total.widget.dart';
 import '../../../widget/chat_floating_button.widget.dart';
 import '../../../widget/err_page.dart';
 import '../../../widget/pager_widget.dart';
 import '../../chat/widget/chat_dialog.widget.dart';
 import '../controller/user_info_detail_transaction.controller.dart';
+import '../model/transaction_info_item.model.dart';
+import '../widgets/selected_factor_detail_dialog.widget.dart';
 import '../widgets/tabel_info.widget.dart';
 
 import 'package:flutter/services.dart';
 
 import '../widgets/transaction_filter.widget.dart';
 
 class UserInfoTransactionView extends StatefulWidget {
   const UserInfoTransactionView({super.key});
 
   @override
   State<UserInfoTransactionView> createState() => _UserInfoTransactionViewState();
 }
 
 class _UserInfoTransactionViewState extends State<UserInfoTransactionView> {
   final UserInfoDetailTransactionController controller=Get.find<UserInfoDetailTransactionController>();
   final GlobalKey _balanceKey = GlobalKey();
 
+  Future<void> _onIssueInvoicePressed(
+    TransactionInfoItemModel trans, {
+    required bool showBalance,
+  }) async {
+    final isInventory = trans.type == 'receive' || trans.type == 'payment';
+    if (!isInventory) {
+      if (showBalance) {
+        await controller.generateInvoiceForTransaction(trans);
+      } else {
+        await controller.generateInvoiceForTransactionWithoutBalance(trans);
+      }
+      return;
+    }
+
+    final inventoryId = trans.recordId ?? trans.id;
+    if (inventoryId == null || inventoryId == 0) {
+      Get.snackbar(
+        '╪«╪╖╪º',
+        '╪┤┘å╪º╪│┘ç ┘ü╪º┌⌐╪¬┘ê╪▒ ┘à┘ê╪¼┘ê╪» ┘å█î╪│╪¬',
+        titleText: Text(
+          '╪«╪╖╪º',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+        messageText: Text(
+          '╪┤┘å╪º╪│┘ç ┘ü╪º┌⌐╪¬┘ê╪▒ ┘à┘ê╪¼┘ê╪» ┘å█î╪│╪¬',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+      );
+      return;
+    }
+
+    final inventory = await controller.fetchInventoryForSelectedFactor(inventoryId);
+    final details = inventory?.inventoryDetails ?? [];
+    if (details.isEmpty) {
+      Get.snackbar(
+        '╪º╪╖┘ä╪º╪╣╪º╪¬',
+        '╪▒╪»█î┘ü█î ╪¿╪▒╪º█î ╪╡╪»┘ê╪▒ ┘ü╪º┌⌐╪¬┘ê╪▒ █î╪º┘ü╪¬ ┘å╪┤╪»',
+        titleText: Text(
+          '╪º╪╖┘ä╪º╪╣╪º╪¬',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+        messageText: Text(
+          '╪▒╪»█î┘ü█î ╪¿╪▒╪º█î ╪╡╪»┘ê╪▒ ┘ü╪º┌⌐╪¬┘ê╪▒ █î╪º┘ü╪¬ ┘å╪┤╪»',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+      );
+      return;
+    }
+
+    if (!mounted) return;
+    final selectedIds = await SelectedFactorDetailDialog.show(
+      context,
+      details: details,
+    );
+    if (selectedIds == null || selectedIds.isEmpty) return;
+
+    await controller.issueSelectedFactorPdf(
+      inventoryId: inventoryId,
+      showBalance: showBalance,
+      inventoryDetailIds: selectedIds,
+      inventoryType: inventory?.type,
+    );
+  }
+
   @override
   Widget build(BuildContext context) {
     final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
     return Obx(() => Scaffold(
       appBar: CustomAppbar1(
         title: '╪¼╪▓█î█î╪º╪¬ ╪¬╪▒╪º┌⌐┘å╪┤ ┌⌐╪º╪▒╪¿╪▒',
         //onBackTap: () => Get.offNamed("/listUserInfoTransaction"),
         onBackTap: () => Get.back(),
       ),
       drawer: const AppDrawer(),
@@ -3479,21 +3549,21 @@ class _UserInfoTransactionViewState extends State<UserInfoTransactionView> {
               )),
               // ╪╡╪»┘ê╪▒ ┘ü╪º┌⌐╪¬┘ê╪▒
               DataCell(
                 Row(
                   children: [
                     Tooltip(
                       message: "╪╡╪»┘ê╪▒ ┘ü╪º┌⌐╪¬┘ê╪▒ ╪¿╪º ┘à╪º┘å╪»┘ç",
                       child: Center(
                         child: OutlinedButton.icon(
                           onPressed: () async {
-                            await controller.generateInvoiceForTransaction(trans);
+                            await _onIssueInvoicePressed(trans, showBalance: true);
                           },
                           label: Text(
                             '┘ü╪º┌⌐╪¬┘ê╪▒ ╪¿╪º ┘à╪º┘å╪»┘ç',
                             style: AppTextStyle
                                 .labelText.copyWith(color: AppColor.textColor,fontSize: 11),
                           ),
                           style: ButtonStyle(
                               padding: WidgetStateProperty.all(EdgeInsets.all(3)),
                               shape:WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                               backgroundColor: WidgetStateProperty.all(AppColor.secondary2Color.withGreen(150))
@@ -3501,21 +3571,21 @@ class _UserInfoTransactionViewState extends State<UserInfoTransactionView> {
                         ),
                       ),
                     ),
                     SizedBox(width: 4,),
                     Tooltip(
                       message: "╪╡╪»┘ê╪▒ ┘ü╪º┌⌐╪¬┘ê╪▒ ╪¿╪»┘ê┘å ┘à╪º┘å╪»┘ç",
                       child: Center(
                         child:
                         OutlinedButton.icon(
                           onPressed: () async {
-                            await controller.generateInvoiceForTransactionWithoutBalance(trans);
+                            await _onIssueInvoicePressed(trans, showBalance: false);
                           },
                           label: Text(
                             '┘ü╪º┌⌐╪¬┘ê╪▒',
                             style: AppTextStyle
                                 .labelText.copyWith(color: AppColor.textColor,fontSize: 11),
                           ),
                           style: ButtonStyle(
                               padding: WidgetStateProperty.all(EdgeInsets.all(3)),
                               shape:WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                               backgroundColor: WidgetStateProperty.all(AppColor.secondary2Color.withGreen(110))
@@ -4902,21 +4972,21 @@ class _UserInfoTransactionViewState extends State<UserInfoTransactionView> {
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 5),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           // ╪╡╪»┘ê╪▒ ┘ü╪º┌⌐╪¬┘ê╪▒ (┘à┘ê╪¿╪º█î┘ä)
                               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   GestureDetector(
                                     onTap: () async {
-                                      await controller.generateInvoiceForTransactionWithoutBalance(trans);
+                                      await _onIssueInvoicePressed(trans, showBalance: false);
                                     },
                                     child: Container(
                                       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                       decoration: BoxDecoration(
                                         color: AppColor.secondary2Color.withAlpha(45),
                                         borderRadius: BorderRadius.circular(8),
                                         border: Border.all(color: AppColor.secondary2Color.withAlpha(100)),
                                       ),
                                       child: Row(
                                         mainAxisSize: MainAxisSize.min,
@@ -4930,21 +5000,21 @@ class _UserInfoTransactionViewState extends State<UserInfoTransactionView> {
                                               fontSize: 11,
                                               fontWeight: FontWeight.w500,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                   ),
                                   GestureDetector(
                                     onTap: () async {
-                                      await controller.generateInvoiceForTransaction(trans);
+                                      await _onIssueInvoicePressed(trans, showBalance: true);
                                     },
                                     child: Container(
                                       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                       decoration: BoxDecoration(
                                         color: AppColor.secondary2Color.withAlpha(25),
                                         borderRadius: BorderRadius.circular(8),
                                         border: Border.all(color: AppColor.secondary2Color.withAlpha(75)),
                                       ),
                                       child: Row(
                                         mainAxisSize: MainAxisSize.min,
