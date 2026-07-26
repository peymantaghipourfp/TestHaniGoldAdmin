### Task 1: Repository — `getOneInventory` + `getSelectedFactorPdf`

**Files:**
- Modify: `lib/src/config/repository/inventory.repository.dart` (after `getFactorPdf` block ~1073)
- Modify: `lib/src/config/repository/user_info_transaction.repository.dart` (before closing `}` ~1134)
- Test: `test/selected_factor_pdf_query_test.dart`

**Interfaces:**
- Consumes: existing Dio clients, `InventoryModel`, `ErrorException` / `ErrorHandler` / `AppLogger`
- Produces:
  - `Future<InventoryModel> getOneInventory({required int id})`
  - `Future<Uint8List> getSelectedFactorPdf({required int id, required bool showBalance, required List<int> inventoryDetailIds, bool showHaniGold = false})`

- [ ] **Step 1: Write failing test for query payload shape**

```dart
// test/selected_factor_pdf_query_test.dart
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
```

- [ ] **Step 2: Run test**

Run: `flutter test test/selected_factor_pdf_query_test.dart`
Expected: PASS (pure helper; if file missing, FAIL then add file)

- [ ] **Step 3: Add `getOneInventory` to InventoryRepository**

```dart
Future<InventoryModel> getOneInventory({required int id}) async {
  try {
    Map<String, dynamic> inventoryData = {'id': id};
    var response = await inventoryDio.get(
      'Inventory/getOne',
      queryParameters: inventoryData,
    );
    return InventoryModel.fromJson(response.data);
  } catch (e, s) {
    AppLogger.e('getOneInventory failed', e, s);
    throw ErrorException(ErrorHandler.handle(e));
  }
}
```

- [ ] **Step 4: Add `getSelectedFactorPdf` to UserInfoTransactionRepository**

Use the same query map as the test helper (inline or shared). Call `userInfoTransactionDio.get('Inventory/getSelectedFactorPdf', queryParameters: option, options: Options(responseType: ResponseType.bytes))` and return `Uint8List.fromList(response.data)`. Log/throw like `getGoldPdf`.

- [ ] **Step 5: Analyze repositories**

Run: `dart analyze lib/src/config/repository/inventory.repository.dart lib/src/config/repository/user_info_transaction.repository.dart`
Expected: no issues

- [ ] **Step 6: Commit**

```bash
git add lib/src/config/repository/inventory.repository.dart lib/src/config/repository/user_info_transaction.repository.dart test/selected_factor_pdf_query_test.dart
git commit -m "feat: add getOneInventory and getSelectedFactorPdf APIs"
```

**NO-GIT ADAPTATION:** Workspace has no `.git`. Skip Step 6 commit. Still implement Steps 1–5 fully.
