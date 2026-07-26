import 'package:flutter_test/flutter_test.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_info_footer.model.dart';
import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_helper.dart';

TransactionInfoFooterModel _footer({
  String? unitName,
  double? totalPositiveBalance,
  double? totalNegativeBalance,
  String? itemName,
}) {
  return TransactionInfoFooterModel(
    rowNum: 1,
    itemId: 1,
    itemName: itemName ?? 'item',
    unitName: unitName ?? 'ریال',
    itemGroupName: '',
    totalPositiveBalance: totalPositiveBalance,
    totalPositiveValue: 0,
    totalNegativeBalance: totalNegativeBalance,
    totalNegativeValue: 0,
  );
}

void main() {
  group('buildUserBalanceKpis', () {
    test('empty footer yields zero nets and passes through totalCount', () {
      final snapshot = buildUserBalanceKpis(
        totalCount: 42,
        footer: const [],
      );

      expect(snapshot.totalUsers, 42);
      expect(snapshot.netRial, 0);
      expect(snapshot.netGoldGrams, 0);
      expect(snapshot.netCoinCount, 0);
    });

    test('null totalCount yields null totalUsers', () {
      final snapshot = buildUserBalanceKpis(
        totalCount: null,
        footer: const [],
      );

      expect(snapshot.totalUsers, isNull);
    });

    test('sums rial net balances by unitName', () {
      final snapshot = buildUserBalanceKpis(
        totalCount: 1,
        footer: [
          _footer(
              unitName: 'ریال',
              totalPositiveBalance: 100,
              totalNegativeBalance: -20),
          _footer(
              unitName: 'ریال',
              totalPositiveBalance: 50,
              totalNegativeBalance: -10),
          _footer(
              unitName: 'گرم',
              totalPositiveBalance: 5,
              totalNegativeBalance: -1),
        ],
      );

      expect(snapshot.netRial, 120);
    });

    test('sums gold gram net balances by unitName', () {
      final snapshot = buildUserBalanceKpis(
        totalCount: 1,
        footer: [
          _footer(
              unitName: 'گرم',
              totalPositiveBalance: 3.5,
              totalNegativeBalance: -1.5),
          _footer(
              unitName: 'گرم',
              totalPositiveBalance: 2,
              totalNegativeBalance: 0),
        ],
      );

      expect(snapshot.netGoldGrams, 4);
    });

    test('sums coin count net balances by unitName', () {
      final snapshot = buildUserBalanceKpis(
        totalCount: 1,
        footer: [
          _footer(
            unitName: 'عدد',
            itemName: 'سکه تمام',
            totalPositiveBalance: 10,
            totalNegativeBalance: -3,
          ),
          _footer(
            unitName: 'عدد',
            itemName: 'نیم سکه',
            totalPositiveBalance: 4,
            totalNegativeBalance: -1,
          ),
        ],
      );

      expect(snapshot.netCoinCount, 10);
    });

    test('treats null balances as zero', () {
      final snapshot = buildUserBalanceKpis(
        totalCount: 1,
        footer: [
          _footer(unitName: 'ریال'),
        ],
      );

      expect(snapshot.netRial, 0);
    });
  });
}
