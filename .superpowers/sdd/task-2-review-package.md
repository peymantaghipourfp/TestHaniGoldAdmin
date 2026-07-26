2c5574c feat(users): add KPI grid and page states
 .../user_balance_empty_state.widget.dart           |  64 ++++++++
 .../user_balance_error_state.widget.dart           |  23 +++
 .../user_balance_loading_state.widget.dart         |  14 ++
 .../user_balance_stats_grid.widget.dart            | 161 +++++++++++++++++++++
 4 files changed, 262 insertions(+)
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_empty_state.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_empty_state.widget.dart
new file mode 100644
index 0000000..4165d64
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_empty_state.widget.dart
@@ -0,0 +1,64 @@
+import 'package:flutter/material.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
+
+/// Empty-list state for the user-balance page.
+class UserBalanceEmptyState extends StatelessWidget {
+  const UserBalanceEmptyState({
+    super.key,
+    required this.onRetry,
+  });
+
+  final VoidCallback onRetry;
+
+  @override
+  Widget build(BuildContext context) {
+    return Center(
+      child: Container(
+        margin: const EdgeInsets.symmetric(horizontal: 24),
+        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
+        decoration: UserBalancePageChrome.panelDecoration(
+          color: AppColor.appBarColor,
+        ),
+        child: Column(
+          mainAxisSize: MainAxisSize.min,
+          children: [
+            Icon(
+              Icons.inbox_outlined,
+              size: 56,
+              color: AppColor.textColor.withAlpha(140),
+            ),
+            const SizedBox(height: 16),
+            Text(
+              '┘à╪º┘å╪»┘çΓÇî╪º█î █î╪º┘ü╪¬ ┘å╪┤╪»',
+              style: AppTextStyle.mediumBodyText.copyWith(
+                fontWeight: FontWeight.bold,
+              ),
+              textAlign: TextAlign.center,
+            ),
+            const SizedBox(height: 10),
+            Text(
+              '╪¿╪▒╪º█î ╪º█î┘å ╪¼╪│╪¬╪¼┘ê █î╪º ┘ü█î┘ä╪¬╪▒ ╪º╪╖┘ä╪º╪╣╪º╪¬█î ┘ê╪¼┘ê╪» ┘å╪»╪º╪▒╪».',
+              style: AppTextStyle.bodyText,
+              textAlign: TextAlign.center,
+            ),
+            const SizedBox(height: 20),
+            TextButton(
+              onPressed: onRetry,
+              style: TextButton.styleFrom(
+                foregroundColor: AppColor.secondary3Color,
+              ),
+              child: Text(
+                '╪¬┘ä╪º╪┤ ┘à╪¼╪»╪»',
+                style: AppTextStyle.mediumBodyText.copyWith(
+                  color: AppColor.secondary3Color,
+                ),
+              ),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_error_state.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_error_state.widget.dart
new file mode 100644
index 0000000..1769a2e
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_error_state.widget.dart
@@ -0,0 +1,23 @@
+import 'package:flutter/material.dart';
+import 'package:hanigold_admin/src/widget/err_page.dart';
+
+/// Error state wrapper for the user-balance list.
+class UserBalanceErrorState extends StatelessWidget {
+  const UserBalanceErrorState({
+    super.key,
+    required this.onRetry,
+  });
+
+  final VoidCallback onRetry;
+
+  @override
+  Widget build(BuildContext context) {
+    return Center(
+      child: ErrPage(
+        callback: onRetry,
+        title: '╪«╪╖╪º ╪»╪▒ ┘ä█î╪│╪¬ ┌⌐╪º╪▒╪¿╪▒╪º┘å',
+        des: '╪¿╪▒╪º█î ╪»╪▒█î╪º┘ü╪¬ ┘ä█î╪│╪¬ ┌⌐╪º╪▒╪¿╪▒╪º┘å ┘à╪¼╪»╪»╪º ╪¬┘ä╪º╪┤ ┌⌐┘å█î╪»',
+      ),
+    );
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_loading_state.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_loading_state.widget.dart
new file mode 100644
index 0000000..7d18ee9
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_loading_state.widget.dart
@@ -0,0 +1,14 @@
+import 'package:flutter/material.dart';
+import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';
+
+/// Full-page loading state for the user-balance list.
+class UserBalanceLoadingState extends StatelessWidget {
+  const UserBalanceLoadingState({super.key});
+
+  @override
+  Widget build(BuildContext context) {
+    return const Center(
+      child: HaniGoldLoading.large(),
+    );
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_grid.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_grid.widget.dart
new file mode 100644
index 0000000..aac15c1
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_grid.widget.dart
@@ -0,0 +1,161 @@
+import 'package:flutter/material.dart';
+import 'package:get/get.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_page_chrome.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_stats_helper.dart';
+import 'package:persian_number_utility/persian_number_utility.dart';
+
+/// KPI summary row for the user-balance list (users, rial, gold, coin).
+class UserBalanceStatsGrid extends StatelessWidget {
+  const UserBalanceStatsGrid({
+    super.key,
+    required this.controller,
+  });
+
+  final UserInfoTransactionController controller;
+
+  @override
+  Widget build(BuildContext context) {
+    return Obx(() {
+      final snapshot = buildUserBalanceKpis(
+        totalCount: controller.paginated.value?.totalCount,
+        footer: controller.listTransactionInfoFooter,
+      );
+
+      final cards = <_KpiCardData>[
+        _KpiCardData(
+          label: '╪¬╪╣╪»╪º╪» ┌⌐┘ä ┌⌐╪º╪▒╪¿╪▒╪º┘å',
+          value: _formatUserCount(snapshot.totalUsers),
+          valueColor: AppColor.textColor,
+        ),
+        _KpiCardData(
+          label: '┘à╪¼┘à┘ê╪╣ ┘à╪º┘å╪»┘ç ╪▒█î╪º┘ä█î',
+          value: _formatRial(snapshot.netRial),
+          valueColor: _balanceColor(snapshot.netRial),
+        ),
+        _KpiCardData(
+          label: '┘à╪¼┘à┘ê╪╣ ╪╖┘ä╪º (┌»╪▒┘à)',
+          value: _formatGold(snapshot.netGoldGrams),
+          valueColor: _balanceColor(snapshot.netGoldGrams),
+        ),
+        _KpiCardData(
+          label: '╪¬╪╣╪»╪º╪» ╪│┌⌐┘ç',
+          value: _formatCoin(snapshot.netCoinCount),
+          valueColor: _balanceColor(snapshot.netCoinCount),
+        ),
+      ];
+
+      return LayoutBuilder(
+        builder: (context, constraints) {
+          final maxWidth = constraints.maxWidth;
+          final columns = !maxWidth.isFinite || maxWidth <= 0
+              ? 1
+              : maxWidth >= 900
+                  ? 4
+                  : maxWidth >= 480
+                      ? 2
+                      : 1;
+          const spacing = 12.0;
+          final cardWidth = maxWidth.isFinite && maxWidth > 0
+              ? (maxWidth - (columns - 1) * spacing) / columns
+              : null;
+
+          return Wrap(
+            spacing: spacing,
+            runSpacing: spacing,
+            children: [
+              for (final card in cards)
+                SizedBox(
+                  width: cardWidth,
+                  child: _KpiCard(data: card),
+                ),
+            ],
+          );
+        },
+      );
+    });
+  }
+
+  static String _formatUserCount(int? count) {
+    if (count == null) {
+      return 'ΓÇö';
+    }
+    return count.toString().seRagham();
+  }
+
+  static String _formatRial(double value) {
+    return value.toStringAsFixed(0).seRagham();
+  }
+
+  static String _formatGold(double value) {
+    return value.toStringAsFixed(3);
+  }
+
+  static String _formatCoin(double value) {
+    if (value == value.roundToDouble()) {
+      return value.toInt().toString().seRagham();
+    }
+    return value.toStringAsFixed(3);
+  }
+
+  static Color _balanceColor(double value) {
+    if (value > 0) {
+      return AppColor.primaryColor;
+    }
+    if (value < 0) {
+      return AppColor.accentColor;
+    }
+    return AppColor.textColor;
+  }
+}
+
+class _KpiCardData {
+  const _KpiCardData({
+    required this.label,
+    required this.value,
+    required this.valueColor,
+  });
+
+  final String label;
+  final String value;
+  final Color valueColor;
+}
+
+class _KpiCard extends StatelessWidget {
+  const _KpiCard({required this.data});
+
+  final _KpiCardData data;
+
+  @override
+  Widget build(BuildContext context) {
+    return Container(
+      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
+      decoration: UserBalancePageChrome.panelDecoration(
+        color: AppColor.appBarColor,
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Text(
+            data.label,
+            style: AppTextStyle.labelText.copyWith(
+              fontSize: 11,
+              color: AppColor.textColor.withAlpha(180),
+            ),
+          ),
+          const SizedBox(height: 8),
+          Text(
+            data.value,
+            style: AppTextStyle.mediumBodyText.copyWith(
+              fontSize: 16,
+              fontWeight: FontWeight.bold,
+              color: data.valueColor,
+            ),
+          ),
+        ],
+      ),
+    );
+  }
+}
