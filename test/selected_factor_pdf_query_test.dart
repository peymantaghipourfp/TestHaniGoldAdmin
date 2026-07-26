import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> buildSelectedFactorPdfQuery({
  required int id,
  required bool showBalance,
  required List<int> inventoryDetailIds,
  bool showHaniGold = false,
}) {
  return {
    // API DTO InventoryFactorPdfSelectionRequest.id is System.String
    'id': id.toString(),
    'showBalance': showBalance,
    'showHaniGold': showHaniGold,
    'InventoryDetailIds': inventoryDetailIds,
  };
}

void main() {
  test('selected factor pdf body sends id as string and InventoryDetailIds', () {
    final q = buildSelectedFactorPdfQuery(
      id: 10,
      showBalance: true,
      inventoryDetailIds: [1, 2],
    );
    expect(q['id'], '10');
    expect(q['showBalance'], true);
    expect(q['showHaniGold'], false);
    expect(q['InventoryDetailIds'], [1, 2]);
  });
}
