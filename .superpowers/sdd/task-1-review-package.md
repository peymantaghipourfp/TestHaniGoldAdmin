68d3104 feat(users): add user-balance chrome, polarity chip, KPI helper
 .../user_balance_page_chrome.dart                  |  31 ++++++
 .../user_balance_polarity_chip.widget.dart         |  56 ++++++++++
 .../user_balance_stats_helper.dart                 |  36 +++++++
 .../users/user_balance_stats_helper_test.dart      | 120 +++++++++++++++++++++
 4 files changed, 243 insertions(+)
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart
new file mode 100644
index 0000000..fdccfb1
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart
@@ -0,0 +1,31 @@
+import 'package:flutter/material.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+
+/// Shared panel / toolbar decorations for the user-balance transaction list.
+class UserBalancePageChrome {
+  UserBalancePageChrome._();
+
+  static const double radiusLg = 16;
+  static const double radiusMd = 12;
+  static const Color slateBorder = Color(0xFF64748B);
+
+  static BoxDecoration panelDecoration({Color? color}) => BoxDecoration(
+        color: (color ?? AppColor.backGroundColor1).withAlpha(150),
+        borderRadius: BorderRadius.circular(radiusLg),
+        border: Border.all(color: slateBorder.withAlpha(120)),
+        boxShadow: [
+          BoxShadow(
+            color: Colors.black.withAlpha(40),
+            blurRadius: 24,
+            offset: const Offset(0, 8),
+          ),
+        ],
+      );
+
+  /// Soft toolbar strip ΓÇö matches order/withdraw `appBarColor.withAlpha(30)` panels.
+  static BoxDecoration toolbarDecoration({Color? color}) => BoxDecoration(
+        color: (color ?? AppColor.appBarColor).withAlpha(30),
+        borderRadius: BorderRadius.circular(radiusMd),
+        border: Border.all(color: slateBorder.withAlpha(120)),
+      );
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_polarity_chip.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_polarity_chip.widget.dart
new file mode 100644
index 0000000..923ee78
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_polarity_chip.widget.dart
@@ -0,0 +1,56 @@
+import 'package:flutter/material.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+
+/// Balance polarity chip (╪¿╪│╪¬╪º┘å┌⌐╪º╪▒ / ╪¿╪»┘ç┌⌐╪º╪▒) using the ChatStatusChip recipe.
+class UserBalancePolarityChip extends StatelessWidget {
+  const UserBalancePolarityChip({
+    super.key,
+    required this.label,
+    required this.isCredit,
+    this.isActive = false,
+    this.onTap,
+  });
+
+  final String label;
+  final bool isCredit;
+  final bool isActive;
+  final VoidCallback? onTap;
+
+  @override
+  Widget build(BuildContext context) {
+    final color = isCredit ? AppColor.primaryColor : AppColor.accentColor;
+    final chip = Container(
+      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
+      decoration: BoxDecoration(
+        color: color.withAlpha(isActive ? 56 : 36),
+        borderRadius: BorderRadius.circular(8),
+        border: Border.all(color: color.withAlpha(isActive ? 200 : 100)),
+      ),
+      child: Text(
+        label,
+        style: AppTextStyle.bodyText.copyWith(
+          fontSize: 10,
+          color: color,
+          fontWeight: FontWeight.w600,
+        ),
+      ),
+    );
+
+    if (onTap == null) {
+      return chip;
+    }
+
+    return Material(
+      color: Colors.transparent,
+      child: InkWell(
+        onTap: onTap,
+        borderRadius: BorderRadius.circular(8),
+        child: ConstrainedBox(
+          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
+          child: Center(child: chip),
+        ),
+      ),
+    );
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_helper.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_helper.dart
new file mode 100644
index 0000000..2dd0531
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_helper.dart
@@ -0,0 +1,36 @@
+import 'package:hanigold_admin/src/domain/users/model/transaction_info_footer.model.dart';
+
+class UserBalanceKpiSnapshot {
+  const UserBalanceKpiSnapshot({
+    required this.totalUsers,
+    required this.netRial,
+    required this.netGoldGrams,
+    required this.netCoinCount,
+  });
+
+  final int? totalUsers;
+  final double netRial;
+  final double netGoldGrams;
+  final double netCoinCount;
+}
+
+UserBalanceKpiSnapshot buildUserBalanceKpis({
+  required int? totalCount,
+  required List<TransactionInfoFooterModel> footer,
+}) {
+  double netFor(String unitName) =>
+      footer.where((item) => item.unitName == unitName).fold(
+            0.0,
+            (sum, item) =>
+                sum +
+                (item.totalPositiveBalance ?? 0) +
+                (item.totalNegativeBalance ?? 0),
+          );
+
+  return UserBalanceKpiSnapshot(
+    totalUsers: totalCount,
+    netRial: netFor('╪▒█î╪º┘ä'),
+    netGoldGrams: netFor('┌»╪▒┘à'),
+    netCoinCount: netFor('╪╣╪»╪»'),
+  );
+}
diff --git a/test/domain/users/user_balance_stats_helper_test.dart b/test/domain/users/user_balance_stats_helper_test.dart
new file mode 100644
index 0000000..85c3e99
--- /dev/null
+++ b/test/domain/users/user_balance_stats_helper_test.dart
@@ -0,0 +1,120 @@
+import 'package:flutter_test/flutter_test.dart';
+import 'package:hanigold_admin/src/domain/users/model/transaction_info_footer.model.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_helper.dart';
+
+TransactionInfoFooterModel _footer({
+  String? unitName,
+  double? totalPositiveBalance,
+  double? totalNegativeBalance,
+  String? itemName,
+}) {
+  return TransactionInfoFooterModel(
+    rowNum: 1,
+    itemId: 1,
+    itemName: itemName ?? 'item',
+    unitName: unitName ?? '╪▒█î╪º┘ä',
+    itemGroupName: '',
+    totalPositiveBalance: totalPositiveBalance,
+    totalPositiveValue: 0,
+    totalNegativeBalance: totalNegativeBalance,
+    totalNegativeValue: 0,
+  );
+}
+
+void main() {
+  group('buildUserBalanceKpis', () {
+    test('empty footer yields zero nets and passes through totalCount', () {
+      final snapshot = buildUserBalanceKpis(
+        totalCount: 42,
+        footer: const [],
+      );
+
+      expect(snapshot.totalUsers, 42);
+      expect(snapshot.netRial, 0);
+      expect(snapshot.netGoldGrams, 0);
+      expect(snapshot.netCoinCount, 0);
+    });
+
+    test('null totalCount yields null totalUsers', () {
+      final snapshot = buildUserBalanceKpis(
+        totalCount: null,
+        footer: const [],
+      );
+
+      expect(snapshot.totalUsers, isNull);
+    });
+
+    test('sums rial net balances by unitName', () {
+      final snapshot = buildUserBalanceKpis(
+        totalCount: 1,
+        footer: [
+          _footer(
+              unitName: '╪▒█î╪º┘ä',
+              totalPositiveBalance: 100,
+              totalNegativeBalance: -20),
+          _footer(
+              unitName: '╪▒█î╪º┘ä',
+              totalPositiveBalance: 50,
+              totalNegativeBalance: -10),
+          _footer(
+              unitName: '┌»╪▒┘à',
+              totalPositiveBalance: 5,
+              totalNegativeBalance: -1),
+        ],
+      );
+
+      expect(snapshot.netRial, 120);
+    });
+
+    test('sums gold gram net balances by unitName', () {
+      final snapshot = buildUserBalanceKpis(
+        totalCount: 1,
+        footer: [
+          _footer(
+              unitName: '┌»╪▒┘à',
+              totalPositiveBalance: 3.5,
+              totalNegativeBalance: -1.5),
+          _footer(
+              unitName: '┌»╪▒┘à',
+              totalPositiveBalance: 2,
+              totalNegativeBalance: 0),
+        ],
+      );
+
+      expect(snapshot.netGoldGrams, 4);
+    });
+
+    test('sums coin count net balances by unitName', () {
+      final snapshot = buildUserBalanceKpis(
+        totalCount: 1,
+        footer: [
+          _footer(
+            unitName: '╪╣╪»╪»',
+            itemName: '╪│┌⌐┘ç ╪¬┘à╪º┘à',
+            totalPositiveBalance: 10,
+            totalNegativeBalance: -3,
+          ),
+          _footer(
+            unitName: '╪╣╪»╪»',
+            itemName: '┘å█î┘à ╪│┌⌐┘ç',
+            totalPositiveBalance: 4,
+            totalNegativeBalance: -1,
+          ),
+        ],
+      );
+
+      expect(snapshot.netCoinCount, 10);
+    });
+
+    test('treats null balances as zero', () {
+      final snapshot = buildUserBalanceKpis(
+        totalCount: 1,
+        footer: [
+          _footer(unitName: '╪▒█î╪º┘ä'),
+        ],
+      );
+
+      expect(snapshot.netRial, 0);
+    });
+  });
+}
