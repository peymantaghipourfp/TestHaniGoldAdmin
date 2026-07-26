import 'package:hanigold_admin/src/domain/users/model/transaction_info_footer.model.dart';

class UserBalanceKpiSnapshot {
  const UserBalanceKpiSnapshot({
    required this.totalUsers,
    required this.netRial,
    required this.netGoldGrams,
    required this.netCoinCount,
  });

  final int? totalUsers;
  final double netRial;
  final double netGoldGrams;
  final double netCoinCount;
}

UserBalanceKpiSnapshot buildUserBalanceKpis({
  required int? totalCount,
  required List<TransactionInfoFooterModel> footer,
}) {
  double netFor(String unitName) =>
      footer.where((item) => item.unitName == unitName).fold(
            0.0,
            (sum, item) =>
                sum +
                (item.totalPositiveBalance ?? 0) +
                (item.totalNegativeBalance ?? 0),
          );

  return UserBalanceKpiSnapshot(
    totalUsers: totalCount,
    netRial: netFor('ریال'),
    netGoldGrams: netFor('گرم'),
    netCoinCount: netFor('عدد'),
  );
}
