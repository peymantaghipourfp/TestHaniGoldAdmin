# Review package - Task 2 (no git)

## Commits
None (no git repository).

## Files changed
- lib/src/domain/users/controller/user_info_detail_transaction.controller.dart

## Diff

diff --git "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-2\\user_info_detail_transaction.controller.dart" "b/lib\\src\\domain\\users\\controller\\user_info_detail_transaction.controller.dart"
index 86c7311..7c1dc91 100644
--- "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-2\\user_info_detail_transaction.controller.dart"
+++ "b/lib\\src\\domain\\users\\controller\\user_info_detail_transaction.controller.dart"
@@ -10,25 +10,27 @@ import 'package:flutter_easyloading/flutter_easyloading.dart';
 import 'package:get/get.dart';
 import 'package:hanigold_admin/src/config/repository/account.repository.dart';
 import 'package:hanigold_admin/src/config/repository/wallet.repository.dart';
 import 'package:hanigold_admin/src/domain/remittance/model/balance.model.dart';
 import 'package:hanigold_admin/src/domain/users/service/transaction_invoice_generation_without_balance.service.dart';
 import 'package:path_provider/path_provider.dart';
 import 'package:permission_handler/permission_handler.dart';
 import 'package:persian_number_utility/persian_number_utility.dart';
 import '../../../config/const/app_color.dart';
 import '../../../config/network/error/network.error.dart';
+import '../../../config/repository/inventory.repository.dart';
 import '../../../config/repository/item.repository.dart';
 import '../../../config/repository/remittance.repository.dart';
 import '../../../config/repository/url/base_url.dart';
 import '../../../config/repository/user_info_transaction.repository.dart';
 import '../../account/model/social.model.dart';
+import '../../inventory/model/inventory.model.dart';
 import '../../product/model/item.model.dart';
 import '../model/balance_item.model.dart';
 import '../model/header_info_user_transaction.model.dart';
 import '../model/paginated.model.dart';
 import '../model/transaction_info_item.model.dart';
 import 'dart:ui' as ui;
 import 'dart:typed_data';
 import 'package:flutter/services.dart';
 import 'package:universal_html/html.dart' as html;
 import 'package:path/path.dart' as path;
@@ -48,20 +50,21 @@ class TypeModel{
 class UserInfoDetailTransactionController extends GetxController{
 
   Rx<PageStateDe> state=Rx<PageStateDe>(PageStateDe.list);
   RxInt currentPageIndex = 1.obs;
   RxInt currentPage = 1.obs;
   RxInt itemsPerPage = 25.obs;
   RxBool hasMore = true.obs;
   RxBool isOpenMore = false.obs;
   RxBool isOpenMoreB = false.obs;
   UserInfoTransactionRepository userInfoTransactionRepository=UserInfoTransactionRepository();
+  final InventoryRepository inventoryRepository = InventoryRepository();
   final RemittanceRepository remittanceRepository=RemittanceRepository();
   final ItemRepository itemRepository=ItemRepository();
   final AccountRepository accountRepository=AccountRepository();
   final WalletRepository walletRepository=WalletRepository();
   ScrollController scrollController = ScrollController();
   ScrollController scrollControllerMobile = ScrollController();
   final TextEditingController searchController=TextEditingController();
   final TextEditingController dateStartController=TextEditingController();
   final TextEditingController dateEndController=TextEditingController();
   final TextEditingController amountFilterController=TextEditingController();
@@ -1011,12 +1014,121 @@ class UserInfoDetailTransactionController extends GetxController{
         ),
         messageText: Text(
           "╪«╪╖╪º ╪»╪▒ ╪º╪▒╪│╪º┘ä ╪¿┘ç ╪¬┘ä┌»╪▒╪º┘à: ${e.toString()}",
           textAlign: TextAlign.center,
           style: TextStyle(color: AppColor.textColor),
         ),
       );
     }
   }
 
+  Future<InventoryModel?> fetchInventoryForSelectedFactor(int inventoryId) async {
+    try {
+      EasyLoading.show(status: '╪»╪▒ ╪¡╪º┘ä ╪»╪▒█î╪º┘ü╪¬ ╪¼╪▓╪ª█î╪º╪¬...');
+      final inventory = await inventoryRepository.getOneInventory(id: inventoryId);
+      EasyLoading.dismiss();
+      return inventory;
+    } catch (e) {
+      EasyLoading.dismiss();
+      Get.snackbar(
+        '╪«╪╖╪º',
+        '╪«╪╖╪º ╪»╪▒ ╪»╪▒█î╪º┘ü╪¬ ╪¼╪▓╪ª█î╪º╪¬ ┘ü╪º┌⌐╪¬┘ê╪▒: $e',
+        titleText: Text(
+          '╪«╪╖╪º',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+        messageText: Text(
+          '╪«╪╖╪º ╪»╪▒ ╪»╪▒█î╪º┘ü╪¬ ╪¼╪▓╪ª█î╪º╪¬ ┘ü╪º┌⌐╪¬┘ê╪▒: $e',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+      );
+      return null;
+    }
+  }
+
+  Future<void> issueSelectedFactorPdf({
+    required int inventoryId,
+    required bool showBalance,
+    required List<int> inventoryDetailIds,
+    int? inventoryType,
+  }) async {
+    if (inventoryDetailIds.isEmpty) {
+      Get.snackbar(
+        '╪º╪╖┘ä╪º╪╣╪º╪¬',
+        '╪¡╪»╪º┘é┘ä █î┌⌐ ╪▒╪»█î┘ü ╪▒╪º ╪º┘å╪¬╪«╪º╪¿ ┌⌐┘å█î╪»',
+        titleText: Text(
+          '╪º╪╖┘ä╪º╪╣╪º╪¬',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+        messageText: Text(
+          '╪¡╪»╪º┘é┘ä █î┌⌐ ╪▒╪»█î┘ü ╪▒╪º ╪º┘å╪¬╪«╪º╪¿ ┌⌐┘å█î╪»',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+      );
+      return;
+    }
+    try {
+      EasyLoading.show(status: '╪»╪▒ ╪¡╪º┘ä ╪¬┘ê┘ä█î╪» ┘ü╪º┌⌐╪¬┘ê╪▒...');
+      final bytes = await userInfoTransactionRepository.getSelectedFactorPdf(
+        id: inventoryId,
+        showBalance: showBalance,
+        inventoryDetailIds: inventoryDetailIds,
+        showHaniGold: false,
+      );
+      await _shareSelectedFactorPdf(bytes, inventoryType: inventoryType);
+      EasyLoading.dismiss();
+      Get.snackbar(
+        '┘à┘ê┘ü┘é█î╪¬',
+        '┘ü╪º┌⌐╪¬┘ê╪▒ ╪¿╪º ┘à┘ê┘ü┘é█î╪¬ ╪¬┘ê┘ä█î╪» ╪┤╪»',
+        titleText: Text(
+          '┘à┘ê┘ü┘é█î╪¬',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+        messageText: Text(
+          '┘ü╪º┌⌐╪¬┘ê╪▒ ╪¿╪º ┘à┘ê┘ü┘é█î╪¬ ╪¬┘ê┘ä█î╪» ╪┤╪»',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+      );
+    } catch (e) {
+      EasyLoading.dismiss();
+      Get.snackbar(
+        '╪«╪╖╪º',
+        '╪«╪╖╪º ╪»╪▒ ╪¬┘ê┘ä█î╪» ┘ü╪º┌⌐╪¬┘ê╪▒: $e',
+        titleText: Text(
+          '╪«╪╖╪º',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+        messageText: Text(
+          '╪«╪╖╪º ╪»╪▒ ╪¬┘ê┘ä█î╪» ┘ü╪º┌⌐╪¬┘ê╪▒: $e',
+          textAlign: TextAlign.center,
+          style: TextStyle(color: AppColor.textColor),
+        ),
+      );
+    }
+  }
+
+  Future<void> _shareSelectedFactorPdf(Uint8List bytes, {int? inventoryType}) async {
+    final prefix = (inventoryType ?? 0) == 0 ? 'factorInventoryReceive' : 'factorInventoryPayment';
+    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf';
+    if (kIsWeb) {
+      final blob = html.Blob([bytes], 'application/pdf');
+      final url = html.Url.createObjectUrlFromBlob(blob);
+      html.AnchorElement(href: url)
+        ..download = fileName
+        ..click();
+      html.Url.revokeObjectUrl(url);
+    } else {
+      await Printing.sharePdf(
+        bytes: bytes,
+        filename: '$prefix.pdf',
+      );
+    }
+  }
 
 }
\ No newline at end of file
