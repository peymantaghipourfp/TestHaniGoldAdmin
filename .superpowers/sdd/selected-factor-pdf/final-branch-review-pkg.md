# Final whole-branch review package — Selected Factor PDF (no git)

## Commits
None (no git repository). All work is in the working tree.

## Progress ledger
Task 1: complete (Approved)
Task 2: complete (Approved)
Task 3: complete (Approved)
Task 4: complete (Approved)
Task 5: complete (DONE_WITH_CONCERNS — PENDING_HUMAN manual UI/PDF)

## Minor carry-forward from task reviews
- T1: query helper/repo map drift risk
- T2: trailing newline; $e vs toString
- T3: pre-select-all on open; unused context param
- T4: double snackbar on fetch failure
- T5: PENDING_HUMAN manual checklist

## Files changed (feature)
- lib/src/config/repository/inventory.repository.dart
- lib/src/config/repository/user_info_transaction.repository.dart
- lib/src/domain/users/controller/user_info_detail_transaction.controller.dart
- lib/src/domain/users/widgets/selected_factor_detail_dialog.widget.dart (new)
- lib/src/domain/users/view/user_info_transaction.view.dart
- test/selected_factor_pdf_query_test.dart (new)

## Combined diffs

### inventory.repository.dart
diff --git "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-1\\inventory.repository.dart" "b/lib\\src\\config\\repository\\inventory.repository.dart"
index 8f45591..ab8c5b1 100644
--- "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-1\\inventory.repository.dart"
+++ "b/lib\\src\\config\\repository\\inventory.repository.dart"
@@ -1086,6 +1086,20 @@ class InventoryRepository {
       AppLogger.e('getFactorPdf failed', e, s);
       throw ErrorException(ErrorHandler.handle(e));
     }
   }
 
+  Future<InventoryModel> getOneInventory({required int id}) async {
+    try {
+      Map<String, dynamic> inventoryData = {'id': id};
+      var response = await inventoryDio.get(
+        'Inventory/getOne',
+        queryParameters: inventoryData,
+      );
+      return InventoryModel.fromJson(response.data);
+    } catch (e, s) {
+      AppLogger.e('getOneInventory failed', e, s);
+      throw ErrorException(ErrorHandler.handle(e));
+    }
+  }
+
 }
\ No newline at end of file

### user_info_transaction.repository.dart

diff --git "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-1\\user_info_transaction.repository.dart" "b/lib\\src\\config\\repository\\user_info_transaction.repository.dart"
index 30b3100..5c6e2bb 100644
--- "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-1\\user_info_transaction.repository.dart"
+++ "b/lib\\src\\config\\repository\\user_info_transaction.repository.dart"
@@ -1129,6 +1129,31 @@ class UserInfoTransactionRepository{
   //   }
   //   catch(e){
   //     throw ErrorException('╪«╪╖╪º ╪»╪▒ ╪»╪▒╪¼ ╪º╪╖┘ä╪º╪╣╪º╪¬:$e');
   //   }
   // }
+
+  Future<Uint8List> getSelectedFactorPdf({
+    required int id,
+    required bool showBalance,
+    required List<int> inventoryDetailIds,
+    bool showHaniGold = false,
+  }) async {
+    try {
+      Map<String, dynamic> option = {
+        'id': id,
+        'showBalance': showBalance,
+        'showHaniGold': showHaniGold,
+        'InventoryDetailIds': inventoryDetailIds,
+      };
+      final response = await userInfoTransactionDio.get(
+        'Inventory/getSelectedFactorPdf',
+        queryParameters: option,
+        options: Options(responseType: ResponseType.bytes),
+      );
+      return Uint8List.fromList(response.data);
+    } catch (e, s) {
+      AppLogger.e('getSelectedFactorPdf failed', e, s);
+      throw ErrorException(ErrorHandler.handle(e));
+    }
+  }
 }
\ No newline at end of file

### user_info_detail_transaction.controller.dart

diff --git "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-2\\user_info_detail_transaction.controller.dart" "b/lib\\src\\domain\\users\\controller\\user_info_detail_transaction.controller.dart"
index 86c7311..7c1dc91 100644
--- "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-2\\user_info_detail_transaction.controller.dart"
+++ "b/lib\\src\\domain\\users\\controller\\user_info_detail_transaction.controller.dart"
@@ -15,15 +15,17 @@ import 'package:hanigold_admin/src/domain/users/service/transaction_invoice_gene
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
@@ -53,10 +55,11 @@ class UserInfoDetailTransactionController extends GetxController{
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
@@ -1016,7 +1019,116 @@ class UserInfoDetailTransactionController extends GetxController{
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

### selected_factor_detail_dialog.widget.dart (NEW)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/inventory/model/inventory_detail.model.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Multi-select dialog for inventory detail rows when issuing a factor PDF.
///
/// Returns selected detail ids via [show], or null if cancelled.
class SelectedFactorDetailDialog extends StatefulWidget {
  final List<InventoryDetailModel> details;

  const SelectedFactorDetailDialog({super.key, required this.details});

  /// Returns selected detail ids, or null if cancelled.
  static Future<List<int>?> show(
    BuildContext context, {
    required List<InventoryDetailModel> details,
  }) async {
    return Get.dialog<List<int>>(
      SelectedFactorDetailDialog(details: details),
      barrierDismissible: true,
    );
  }

  @override
  State<SelectedFactorDetailDialog> createState() =>
      _SelectedFactorDetailDialogState();
}

class _SelectedFactorDetailDialogState
    extends State<SelectedFactorDetailDialog> {
  late final List<InventoryDetailModel> _visibleDetails;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _visibleDetails = widget.details
        .where((d) => d.id != null && d.isDeleted != true)
        .toList();
    // Pre-select all visible rows for convenience.
    _selectedIds.addAll(_visibleDetails.map((d) => d.id!));
  }

  bool get _allSelected =>
      _visibleDetails.isNotEmpty &&
      _selectedIds.length == _visibleDetails.length;

  bool get _noneSelected => _selectedIds.isEmpty;

  void _toggleAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds
          ..clear()
          ..addAll(_visibleDetails.map((d) => d.id!));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleOne(int id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onIssue() {
    if (_noneSelected) {
      Get.snackbar(
        'ØªÙˆØ¬Ù‡',
        'Ù„Ø·ÙØ§Ù‹ Ø­Ø¯Ø§Ù‚Ù„ ÛŒÚ© Ø±Ø¯ÛŒÙ Ø±Ø§ Ø§Ù†ØªØ®Ø§Ø¨ Ú©Ù†ÛŒØ¯',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.secondaryColor,
        colorText: AppColor.textColor,
      );
      return;
    }
    Navigator.pop(context, _selectedIds.toList());
  }

  String _displayName(InventoryDetailModel detail) {
    final name = detail.itemName ?? detail.item?.name;
    if (name == null || name.trim().isEmpty) {
      return 'Ù†Ø§Ù…Ø´Ø®Øµ';
    }
    return name;
  }

  String _formatNumber(double? value) {
    if (value == null) return 'Ù†Ø§Ù…Ø´Ø®Øµ';
    final asInt = value == value.roundToDouble() ? value.toInt() : value;
    return asInt.toString().seRagham(separator: ',');
  }

  String _subtitle(InventoryDetailModel detail) {
    final quantity = _formatNumber(detail.quantity);
    final weight = _formatNumber(detail.weight);
    final receipt = (detail.receiptNumber == null ||
            detail.receiptNumber!.trim().isEmpty)
        ? 'Ù†Ø§Ù…Ø´Ø®Øµ'
        : detail.receiptNumber!;
    return 'Ù…Ù‚Ø¯Ø§Ø±: $quantity  |  ÙˆØ²Ù†: $weight  |  Ø±Ø³ÛŒØ¯: $receipt';
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context).width > 700 ? 520.0 : Get.width * 0.92;
    final maxHeight = Get.height * 0.75;

    return Dialog(
      backgroundColor: AppColor.backGroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColor.secondaryColor),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.checklist, color: AppColor.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ø§Ù†ØªØ®Ø§Ø¨ Ø±Ø¯ÛŒÙâ€ŒÙ‡Ø§ÛŒ ÙØ§Ú©ØªÙˆØ±',
                      style: AppTextStyle.smallTitleText.copyWith(
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _onCancel,
                    icon: Icon(Icons.close, color: AppColor.textColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Container(
                height: 0.6,
                color: AppColor.textColor.withValues(alpha: 0.4),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              if (_visibleDetails.isNotEmpty)
                CheckboxListTile(
                  value: _allSelected,
                  onChanged: _toggleAll,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColor.primaryColor,
                  checkColor: AppColor.backGroundColor,
                  title: Text(
                    'Ø§Ù†ØªØ®Ø§Ø¨ Ù‡Ù…Ù‡',
                    style: AppTextStyle.bodyTextBold,
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              Flexible(
                child: _visibleDetails.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Ø±Ø¯ÛŒÙÛŒ Ø¨Ø±Ø§ÛŒ Ø§Ù†ØªØ®Ø§Ø¨ ÙˆØ¬ÙˆØ¯ Ù†Ø¯Ø§Ø±Ø¯',
                            style: AppTextStyle.bodyText.copyWith(
                              color: AppColor.textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _visibleDetails.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: AppColor.secondaryColor,
                        ),
                        itemBuilder: (context, index) {
                          final detail = _visibleDetails[index];
                          final id = detail.id!;
                          return CheckboxListTile(
                            value: _selectedIds.contains(id),
                            onChanged: (value) => _toggleOne(id, value),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColor.primaryColor,
                            checkColor: AppColor.backGroundColor,
                            title: Text(
                              _displayName(detail),
                              style: AppTextStyle.bodyTextBold,
                            ),
                            subtitle: Text(
                              _subtitle(detail),
                              style: AppTextStyle.labelText.copyWith(
                                color:
                                    AppColor.textColor.withValues(alpha: 0.8),
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(AppColor.accentColor),
                    ),
                    onPressed: _onCancel,
                    child: Text('Ø§Ù†ØµØ±Ø§Ù', style: AppTextStyle.bodyText),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(AppColor.primaryColor),
                    ),
                    onPressed: _onIssue,
                    child: Text('ØµØ¯ÙˆØ±', style: AppTextStyle.bodyText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

### user_info_transaction.view.dart

diff --git "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-4\\user_info_transaction.view.dart" "b/lib\\src\\domain\\users\\view\\user_info_transaction.view.dart"
index ca373a9..d25f274 100644
--- "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-4\\user_info_transaction.view.dart"
+++ "b/lib\\src\\domain\\users\\view\\user_info_transaction.view.dart"
@@ -22,10 +22,12 @@ import '../../../widget/background_image_total.widget.dart';
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
@@ -39,10 +41,78 @@ class UserInfoTransactionView extends StatefulWidget {
 
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
@@ -3484,11 +3554,11 @@ class _UserInfoTransactionViewState extends State<UserInfoTransactionView> {
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
@@ -3506,11 +3576,11 @@ class _UserInfoTransactionViewState extends State<UserInfoTransactionView> {
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
@@ -4907,11 +4977,11 @@ class _UserInfoTransactionViewState extends State<UserInfoTransactionView> {
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
@@ -4935,11 +5005,11 @@ class _UserInfoTransactionViewState extends State<UserInfoTransactionView> {
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

### test/selected_factor_pdf_query_test.dart (NEW)

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> buildSelectedFactorPdfQuery({
  required int id,
  required bool showBalance,
  required List<int> inventoryDetailIds,
  bool showHaniGold = false,
}) {
  return {
    'id': id,
    'showBalance': showBalance,
    'showHaniGold': showHaniGold,
    'InventoryDetailIds': inventoryDetailIds,
  };
}

void main() {
  test('selected factor pdf query includes InventoryDetailIds', () {
    final q = buildSelectedFactorPdfQuery(
      id: 10,
      showBalance: true,
      inventoryDetailIds: [1, 2],
    );
    expect(q['id'], 10);
    expect(q['showBalance'], true);
    expect(q['showHaniGold'], false);
    expect(q['InventoryDetailIds'], [1, 2]);
  });
}
