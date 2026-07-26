82ead62 feat(users): add 7-column grouped data table
 .../user_balance_data_table.widget.dart            | 225 +++++++++++++++++++++
 .../user_balance_desktop_body.widget.dart          |  41 ++++
 2 files changed, 266 insertions(+)
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_data_table.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_data_table.widget.dart
new file mode 100644
index 0000000..24e640e
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_data_table.widget.dart
@@ -0,0 +1,225 @@
+import 'package:flutter/material.dart';
+import 'package:get/get.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_coin_cell.widget.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_currency_cell.widget.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_gold_cell.widget.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_grouped_header.widget.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_rial_cell.widget.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_total_cell.widget.dart';
+
+/// Seven-column grouped [DataTable] for the desktop user-balance list.
+class UserBalanceDataTable extends StatelessWidget {
+  const UserBalanceDataTable({
+    super.key,
+    required this.controller,
+  });
+
+  final UserInfoTransactionController controller;
+
+  @override
+  Widget build(BuildContext context) {
+    return Obx(() {
+      return DataTable(
+        columns: _buildColumns(context),
+        sortColumnIndex: _visualSortColumnIndex(controller.sortColumnIndex.value),
+        sortAscending: controller.sortAscending.value,
+        border: TableBorder.symmetric(
+          inside: BorderSide(color: AppColor.textColor, width: 0.3),
+          outside: BorderSide(color: AppColor.textColor, width: 0.3),
+          borderRadius: BorderRadius.circular(8),
+        ),
+        dividerThickness: 0.3,
+        rows: _buildRows(context),
+        dataRowMaxHeight: double.infinity,
+        headingRowColor:
+            WidgetStatePropertyAll(AppColor.buttonColor.withAlpha(40)),
+        headingRowHeight: 56,
+        columnSpacing: 16,
+        horizontalMargin: 5,
+      );
+    });
+  }
+
+  List<DataColumn> _buildColumns(BuildContext context) {
+    return [
+      DataColumn(
+        label: ConstrainedBox(
+          constraints: const BoxConstraints(maxWidth: 80),
+          child: Text('╪▒╪»█î┘ü', style: AppTextStyle.labelText),
+        ),
+        headingRowAlignment: MainAxisAlignment.center,
+      ),
+      DataColumn(
+        label: ConstrainedBox(
+          constraints: const BoxConstraints(maxWidth: 100),
+          child: Text(
+            '┘å╪º┘à',
+            style: AppTextStyle.labelText.copyWith(fontSize: 11),
+          ),
+        ),
+        headingRowAlignment: MainAxisAlignment.center,
+      ),
+      DataColumn(
+        label: UserBalanceGroupedHeader(
+          label: '┘à╪º┘å╪»┘ç ╪▒█î╪º┘ä█î',
+          creditSortIndex: 2,
+          debitSortIndex: 3,
+          controller: controller,
+        ),
+        headingRowAlignment: MainAxisAlignment.center,
+      ),
+      DataColumn(
+        label: UserBalanceGroupedHeader(
+          label: '┘à╪º┘å╪»┘ç ╪╖┘ä╪º',
+          creditSortIndex: 4,
+          debitSortIndex: 5,
+          controller: controller,
+        ),
+        headingRowAlignment: MainAxisAlignment.center,
+      ),
+      DataColumn(
+        label: UserBalanceGroupedHeader(
+          label: '┘à╪º┘å╪»┘ç ╪│┌⌐┘ç',
+          creditSortIndex: 6,
+          debitSortIndex: 7,
+          controller: controller,
+        ),
+        headingRowAlignment: MainAxisAlignment.center,
+      ),
+      DataColumn(
+        label: UserBalanceGroupedHeader(
+          label: '┘à╪º┘å╪»┘ç ╪º╪▒╪▓',
+          creditSortIndex: 8,
+          debitSortIndex: 9,
+          controller: controller,
+          sortEnabled: false,
+          swapPolarityColors: true,
+        ),
+        headingRowAlignment: MainAxisAlignment.center,
+      ),
+      DataColumn(
+        label: UserBalanceGroupedHeader(
+          label: '╪¬╪▒╪º╪▓ ┌⌐┘ä',
+          creditSortIndex: 10,
+          debitSortIndex: 11,
+          controller: controller,
+        ),
+        headingRowAlignment: MainAxisAlignment.center,
+      ),
+    ];
+  }
+
+  List<DataRow> _buildRows(BuildContext context) {
+    return controller.listTransactionInfo.asMap().entries.map((entry) {
+      final index = entry.key;
+      final trans = entry.value;
+      final rowColor = index.isEven
+          ? AppColor.backGroundColor
+          : AppColor.secondaryColor.withAlpha(100);
+
+      return DataRow(
+        color: WidgetStateProperty.all(rowColor),
+        cells: [
+          DataCell(
+            Center(
+              child: Text(
+                '${trans.rowNum}',
+                style: AppTextStyle.bodyText,
+              ),
+            ),
+          ),
+          DataCell(
+            Center(
+              child: GestureDetector(
+                onTap: () {
+                  Get.toNamed(
+                    '/userInfoTransaction',
+                    parameters: {
+                      'accountId': trans.accountId.toString(),
+                    },
+                  );
+                },
+                child: Text(
+                  '${trans.accountName} ',
+                  style: AppTextStyle.bodyText.copyWith(
+                    color: AppColor.textColor,
+                    fontSize: 11,
+                    decoration: TextDecoration.underline,
+                    decorationColor: AppColor.textColor,
+                    decorationThickness: 3,
+                  ),
+                ),
+              ),
+            ),
+          ),
+          DataCell(_assetCell(
+            credit: UserBalanceRialCell.creditSection(
+              context: context,
+              trans: trans,
+            ),
+            debit: UserBalanceRialCell.debitSection(
+              context: context,
+              trans: trans,
+            ),
+          )),
+          DataCell(_assetCell(
+            credit: UserBalanceGoldCell.creditSection(
+              context: context,
+              trans: trans,
+            ),
+            debit: UserBalanceGoldCell.debitSection(
+              context: context,
+              trans: trans,
+            ),
+          )),
+          DataCell(_assetCell(
+            credit: UserBalanceCoinCell.creditSection(trans: trans),
+            debit: UserBalanceCoinCell.debitSection(trans: trans),
+          )),
+          DataCell(_assetCell(
+            credit: UserBalanceCurrencyCell.creditSection(trans: trans),
+            debit: UserBalanceCurrencyCell.debitSection(trans: trans),
+          )),
+          DataCell(_assetCell(
+            credit: UserBalanceTotalCell.creditSection(trans: trans),
+            debit: UserBalanceTotalCell.debitSection(trans: trans),
+          )),
+        ],
+      );
+    }).toList();
+  }
+
+  static Widget _assetCell({
+    required Widget credit,
+    required Widget debit,
+  }) {
+    return Center(
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.center,
+        children: [
+          credit,
+          const SizedBox(height: 4),
+          debit,
+        ],
+      ),
+    );
+  }
+
+  /// Maps controller sort indices (2ΓÇô11) to visual column indices (2ΓÇô6).
+  static int? _visualSortColumnIndex(int? controllerIndex) {
+    if (controllerIndex == null) {
+      return null;
+    }
+    return switch (controllerIndex) {
+      2 || 3 => 2,
+      4 || 5 => 3,
+      6 || 7 => 4,
+      8 || 9 => 5,
+      10 || 11 => 6,
+      _ => null,
+    };
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_desktop_body.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_desktop_body.widget.dart
new file mode 100644
index 0000000..818e892
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_desktop_body.widget.dart
@@ -0,0 +1,41 @@
+import 'package:flutter/material.dart';
+import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_data_table.widget.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_grid.widget.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_toolbar.widget.dart';
+
+/// Desktop content stack: KPI cards ΓåÆ toolbar ΓåÆ grouped table ΓåÆ optional footer.
+class UserBalanceDesktopBody extends StatelessWidget {
+  const UserBalanceDesktopBody({
+    super.key,
+    required this.controller,
+    this.footer,
+  });
+
+  final UserInfoTransactionController controller;
+  final Widget? footer;
+
+  @override
+  Widget build(BuildContext context) {
+    return Container(
+      margin: const EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 30),
+      padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 40),
+      decoration: UserBalancePageChrome.panelDecoration(),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.stretch,
+        children: [
+          UserBalanceStatsGrid(controller: controller),
+          const SizedBox(height: 12),
+          UserBalanceToolbar(controller: controller, isDesktop: true),
+          const SizedBox(height: 12),
+          UserBalanceDataTable(controller: controller),
+          if (footer != null) ...[
+            const SizedBox(height: 12),
+            footer!,
+          ],
+        ],
+      ),
+    );
+  }
+}
