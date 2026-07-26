# Review package - Task 1 (no git)

## Commits
None (no git repository).

## Files changed
- lib/src/config/repository/inventory.repository.dart (modified)
- lib/src/config/repository/user_info_transaction.repository.dart (modified)
- test/selected_factor_pdf_query_test.dart (created)

## Diff

diff --git "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-1\\inventory.repository.dart" "b/lib\\src\\config\\repository\\inventory.repository.dart"
index 8f45591..ab8c5b1 100644
--- "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-1\\inventory.repository.dart"
+++ "b/lib\\src\\config\\repository\\inventory.repository.dart"
@@ -1081,11 +1081,25 @@ class InventoryRepository {
           options: Options(responseType: ResponseType.bytes)
       );
       return Uint8List.fromList(response.data);
     }
     catch (e, s) {
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
diff --git "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-1\\user_info_transaction.repository.dart" "b/lib\\src\\config\\repository\\user_info_transaction.repository.dart"
index 30b3100..5c6e2bb 100644
--- "a/.superpowers\\sdd\\selected-factor-pdf\\snapshots\\pre-task-1\\user_info_transaction.repository.dart"
+++ "b/lib\\src\\config\\repository\\user_info_transaction.repository.dart"
@@ -1124,11 +1124,36 @@ class UserInfoTransactionRepository{
   //
   //     };
   //
   //     var response=await userInfoTransactionDio.post('Remittance/insert',data: orderData);
   //     return RemittanceModel.fromJson(response.data);
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

### NEW FILE: test/selected_factor_pdf_query_test.dart

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
