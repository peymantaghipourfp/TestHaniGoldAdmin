3310575 feat(users): extract grouped balance cells with installment breakdown
 .../user_balance_coin_cell.widget.dart             | 216 +++++++++
 .../user_balance_currency_cell.widget.dart         | 120 +++++
 .../user_balance_gold_cell.widget.dart             | 499 ++++++++++++++++++++
 .../user_balance_grouped_header.widget.dart        |  79 ++++
 .../user_balance_rial_cell.widget.dart             | 509 +++++++++++++++++++++
 .../user_balance_total_cell.widget.dart            | 275 +++++++++++
 6 files changed, 1698 insertions(+)
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_coin_cell.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_coin_cell.widget.dart
new file mode 100644
index 0000000..8102382
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_coin_cell.widget.dart
@@ -0,0 +1,216 @@
+import 'package:flutter/material.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
+import 'package:hanigold_admin/src/utils/num_display.dart';
+
+/// Coin balance cell (╪¿╪│╪¬╪º┘å┌⌐╪º╪▒ / ╪¿╪»┘ç┌⌐╪º╪▒).
+class UserBalanceCoinCell {
+  UserBalanceCoinCell._();
+
+  static Widget creditSection({
+    required ListTransactionInfoItemModel trans,
+  }) {
+    return Column(
+      mainAxisAlignment: MainAxisAlignment.center,
+      children: [
+        trans.coinBalanceBes == 0
+            ? SizedBox()
+            : Column(
+                children: [
+                  Row(
+                    children: [
+                      Text(
+                        ' ╪¬┘à╪º┘à ╪│┌⌐┘ç ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      Text(
+                        trans.coinBalanceBes?.toDisplayString() ?? '',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 11,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                        textDirection: TextDirection.ltr,
+                      ),
+                      Text(
+                        ' ╪╣╪»╪» ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                  Row(
+                    children: [
+                      Text(
+                        ' ┘å█î┘à ╪│┌⌐┘ç ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      Text(
+                        trans.halfCoinBalanceBes?.toDisplayString() ?? '',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 11,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                        textDirection: TextDirection.ltr,
+                      ),
+                      Text(
+                        ' ╪╣╪»╪» ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                  Row(
+                    children: [
+                      Text(
+                        ' ╪▒╪¿╪╣ ╪│┌⌐┘ç ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      Text(
+                        trans.quarterCoinBalanceBes?.toDisplayString() ?? '',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 11,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                        textDirection: TextDirection.ltr,
+                      ),
+                      Text(
+                        ' ╪╣╪»╪» ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                ],
+              ),
+      ],
+    );
+  }
+
+  static Widget debitSection({
+    required ListTransactionInfoItemModel trans,
+  }) {
+    return Column(
+      mainAxisAlignment: MainAxisAlignment.center,
+      children: [
+        trans.coinBalanceBed == 0
+            ? SizedBox()
+            : Column(
+                children: [
+                  Row(
+                    children: [
+                      Text(
+                        ' ╪¬┘à╪º┘à ╪│┌⌐┘ç ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      Text(
+                        '-${trans.coinBalanceBed?.abs().toDisplayString()}',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 11,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                        textDirection: TextDirection.ltr,
+                      ),
+                      Text(
+                        ' ╪╣╪»╪» ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                  Row(
+                    children: [
+                      Text(
+                        ' ┘å█î┘à ╪│┌⌐┘ç ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      Text(
+                        '-${trans.halfCoinBalanceBed?.abs().toDisplayString()}',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 11,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                        textDirection: TextDirection.ltr,
+                      ),
+                      Text(
+                        ' ╪╣╪»╪» ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                  Row(
+                    children: [
+                      Text(
+                        ' ╪▒╪¿╪╣ ╪│┌⌐┘ç ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      Text(
+                        '-${trans.quarterCoinBalanceBed?.abs().toDisplayString()}',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 11,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                        textDirection: TextDirection.ltr,
+                      ),
+                      Text(
+                        ' ╪╣╪»╪» ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                ],
+              ),
+      ],
+    );
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_currency_cell.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_currency_cell.widget.dart
new file mode 100644
index 0000000..f22882e
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_currency_cell.widget.dart
@@ -0,0 +1,120 @@
+import 'package:flutter/material.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
+import 'package:hanigold_admin/src/utils/num_display.dart';
+
+/// Foreign-currency balance cell (╪¿╪│╪¬╪º┘å┌⌐╪º╪▒ / ╪¿╪»┘ç┌⌐╪º╪▒) from [balances].
+class UserBalanceCurrencyCell {
+  UserBalanceCurrencyCell._();
+
+  static Widget creditSection({
+    required ListTransactionInfoItemModel trans,
+  }) {
+    return Column(
+      mainAxisAlignment: MainAxisAlignment.center,
+      children: [
+        trans.balances!.isEmpty
+            ? SizedBox()
+            : Column(
+                children: trans.balances!
+                    .map(
+                      (e) => Container(
+                        child: e.unitName == '╪»┘ä╪º╪▒' && e.balance! > 0
+                            ? Row(
+                                children: [
+                                  Text(
+                                    ' ${e.itemName} ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.primaryColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                  Text(
+                                    e.balance?.toDisplayString() ?? '',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 10,
+                                      color: AppColor.primaryColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                    textDirection: TextDirection.ltr,
+                                  ),
+                                  Text(
+                                    ' ${e.unitName} ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.primaryColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                ],
+                              )
+                            : Row(
+                                children: [
+                                  SizedBox(width: 120),
+                                ],
+                              ),
+                      ),
+                    )
+                    .toList(),
+              ),
+      ],
+    );
+  }
+
+  static Widget debitSection({
+    required ListTransactionInfoItemModel trans,
+  }) {
+    return Column(
+      mainAxisAlignment: MainAxisAlignment.center,
+      children: [
+        trans.balances!.isEmpty
+            ? SizedBox()
+            : Column(
+                children: trans.balances!
+                    .map(
+                      (e) => Container(
+                        child: e.unitName == '╪»┘ä╪º╪▒' && e.balance! < 0
+                            ? Row(
+                                children: [
+                                  Text(
+                                    ' ${e.itemName} ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.accentColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                  Text(
+                                    e.balance?.toDisplayString() ?? '',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 10,
+                                      color: AppColor.accentColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                    textDirection: TextDirection.ltr,
+                                  ),
+                                  Text(
+                                    ' ${e.unitName} ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.accentColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                ],
+                              )
+                            : Row(
+                                children: [
+                                  SizedBox(width: 120),
+                                ],
+                              ),
+                      ),
+                    )
+                    .toList(),
+              ),
+      ],
+    );
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_gold_cell.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_gold_cell.widget.dart
new file mode 100644
index 0000000..81fad49
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_gold_cell.widget.dart
@@ -0,0 +1,499 @@
+import 'package:flutter/material.dart';
+import 'package:flutter_svg/svg.dart';
+import 'package:get/get.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
+
+/// Gold balance cell (╪¿╪│╪¬╪º┘å┌⌐╪º╪▒ / ╪¿╪»┘ç┌⌐╪º╪▒) with installment breakdown.
+class UserBalanceGoldCell {
+  UserBalanceGoldCell._();
+
+  static Widget creditSection({
+    required BuildContext context,
+    required ListTransactionInfoItemModel trans,
+  }) {
+    return (trans.goldBalanceBes ?? 0) > 0
+        ? Row(
+            mainAxisAlignment: MainAxisAlignment.center,
+            children: [
+              trans.goldBalanceBes == 0
+                  ? SizedBox()
+                  : Column(
+                      mainAxisAlignment: MainAxisAlignment.center,
+                      children: [
+                        Row(
+                          children: [
+                            SizedBox(
+                              child: Row(
+                                children: [
+                                  Text(
+                                    '╪ó╪¿╪┤╪»┘ç ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.primaryColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                  Text(
+                                    trans.goldBalanceBes!.toStringAsFixed(3),
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 11,
+                                      color: AppColor.primaryColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                    textDirection: TextDirection.ltr,
+                                  ),
+                                  Text(
+                                    ' ┌»╪▒┘à ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.primaryColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                ],
+                              ),
+                            ),
+                            GestureDetector(
+                              onTap: () {
+                                Get.defaultDialog(
+                                  confirm: Column(
+                                    children: trans.balances!
+                                        .map(
+                                          (e) => e.unitName == '┌»╪▒┘à'
+                                              ? Row(
+                                                  mainAxisAlignment:
+                                                      MainAxisAlignment
+                                                          .spaceBetween,
+                                                  children: [
+                                                    Text(
+                                                      e.itemName ?? '',
+                                                      style: AppTextStyle
+                                                          .labelText
+                                                          .copyWith(
+                                                        fontSize: 12,
+                                                        color: AppColor
+                                                            .backGroundColor,
+                                                      ),
+                                                    ),
+                                                    Text(
+                                                      '${e.balance ?? 0} ┌»╪▒┘à ',
+                                                      style: AppTextStyle
+                                                          .labelText
+                                                          .copyWith(
+                                                        fontSize: 12,
+                                                        color: AppColor
+                                                            .backGroundColor,
+                                                      ),
+                                                    ),
+                                                  ],
+                                                )
+                                              : SizedBox(),
+                                        )
+                                        .toList(),
+                                  ),
+                                  middleText: '┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪╖┘ä╪º█î ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                                  middleTextStyle: context
+                                      .textTheme.bodyMedium!
+                                      .copyWith(
+                                    color: AppColor.backGroundColor,
+                                    fontSize: 13,
+                                  ),
+                                  title: '╪¼╪▓█î█î╪º╪¬',
+                                  titleStyle: context.textTheme.titleSmall!
+                                      .copyWith(
+                                    color: AppColor.backGroundColor,
+                                    fontSize: 14,
+                                  ),
+                                  backgroundColor: AppColor.textColor,
+                                  radius: 7,
+                                  contentPadding: EdgeInsets.symmetric(
+                                    horizontal: 20,
+                                    vertical: 20,
+                                  ),
+                                );
+                              },
+                              child: SvgPicture.asset(
+                                'assets/svg/list.svg',
+                                height: 16,
+                                colorFilter: ColorFilter.mode(
+                                  AppColor.textColor,
+                                  BlendMode.srcIn,
+                                ),
+                              ),
+                            ),
+                          ],
+                        ),
+                        SizedBox(height: 5),
+                        (trans.afterGoldBalance ?? 0) > 0
+                            ? Divider(
+                                height: 0.5,
+                                color: AppColor.dividerColor,
+                              )
+                            : SizedBox.shrink(),
+                        SizedBox(height: 5),
+                        (trans.afterGoldBalance ?? 0) > 0
+                            ? Column(
+                                children: trans.balances!
+                                    .map(
+                                      (e) => e.unitName == '┌»╪▒┘à'
+                                          ? Row(
+                                              mainAxisAlignment:
+                                                  MainAxisAlignment
+                                                      .spaceBetween,
+                                              children: [
+                                                (e.balance ?? 0) > 0
+                                                    ? Row(
+                                                        children: [
+                                                          Text(
+                                                            e.itemName ?? '',
+                                                            style: AppTextStyle
+                                                                .labelText
+                                                                .copyWith(
+                                                              fontSize: 10,
+                                                              color: AppColor
+                                                                  .primaryColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                          ),
+                                                          Text(
+                                                            '${e.balance ?? 0}',
+                                                            style: AppTextStyle
+                                                                .labelText
+                                                                .copyWith(
+                                                              fontSize: 12,
+                                                              color: AppColor
+                                                                  .primaryColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                          ),
+                                                          Text(
+                                                            ' ┌»╪▒┘à ',
+                                                            style: AppTextStyle
+                                                                .bodyText
+                                                                .copyWith(
+                                                              fontSize: 10,
+                                                              color: AppColor
+                                                                  .primaryColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                          ),
+                                                        ],
+                                                      )
+                                                    : (e.balance ?? 0) < 0
+                                                        ? Row(
+                                                            children: [
+                                                              Text(
+                                                                e.itemName ??
+                                                                    '',
+                                                                style: AppTextStyle
+                                                                    .labelText
+                                                                    .copyWith(
+                                                                  fontSize: 10,
+                                                                  color: AppColor
+                                                                      .accentColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                              ),
+                                                              Text(
+                                                                '-${e.balance?.abs() ?? 0}',
+                                                                style: AppTextStyle
+                                                                    .labelText
+                                                                    .copyWith(
+                                                                  fontSize: 12,
+                                                                  color: AppColor
+                                                                      .accentColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                                textDirection:
+                                                                    TextDirection
+                                                                        .ltr,
+                                                              ),
+                                                              Text(
+                                                                ' ┌»╪▒┘à ',
+                                                                style: AppTextStyle
+                                                                    .bodyText
+                                                                    .copyWith(
+                                                                  fontSize: 10,
+                                                                  color: AppColor
+                                                                      .accentColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                                textDirection:
+                                                                    TextDirection
+                                                                        .ltr,
+                                                              ),
+                                                            ],
+                                                          )
+                                                        : SizedBox.shrink(),
+                                              ],
+                                            )
+                                          : SizedBox(),
+                                    )
+                                    .toList(),
+                              )
+                            : SizedBox.shrink(),
+                      ],
+                    ),
+            ],
+          )
+        : SizedBox.shrink();
+  }
+
+  static Widget debitSection({
+    required BuildContext context,
+    required ListTransactionInfoItemModel trans,
+  }) {
+    return (trans.goldBalanceBed ?? 0) < 0
+        ? Row(
+            mainAxisAlignment: MainAxisAlignment.center,
+            children: [
+              trans.goldBalanceBed == 0
+                  ? SizedBox()
+                  : Column(
+                      mainAxisAlignment: MainAxisAlignment.center,
+                      children: [
+                        Row(
+                          children: [
+                            SizedBox(
+                              child: Row(
+                                children: [
+                                  Text(
+                                    '╪ó╪¿╪┤╪»┘ç ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.accentColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                  Text(
+                                    '-${trans.goldBalanceBed?.abs().toStringAsFixed(3) ?? ''}',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 11,
+                                      color: AppColor.accentColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                    textDirection: TextDirection.ltr,
+                                  ),
+                                  Text(
+                                    ' ┌»╪▒┘à ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.accentColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                ],
+                              ),
+                            ),
+                            GestureDetector(
+                              onTap: () {
+                                Get.defaultDialog(
+                                  confirm: Column(
+                                    children: trans.balances!
+                                        .map(
+                                          (e) => e.unitName == '┌»╪▒┘à'
+                                              ? Row(
+                                                  mainAxisAlignment:
+                                                      MainAxisAlignment
+                                                          .spaceBetween,
+                                                  children: [
+                                                    Text(
+                                                      e.itemName ?? '',
+                                                      style: AppTextStyle
+                                                          .labelText
+                                                          .copyWith(
+                                                        fontSize: 12,
+                                                        color: AppColor
+                                                            .backGroundColor,
+                                                      ),
+                                                    ),
+                                                    Text(
+                                                      '${e.balance ?? 0} ┌»╪▒┘à',
+                                                      style: AppTextStyle
+                                                          .labelText
+                                                          .copyWith(
+                                                        fontSize: 12,
+                                                        color: AppColor
+                                                            .backGroundColor,
+                                                      ),
+                                                    ),
+                                                  ],
+                                                )
+                                              : SizedBox(),
+                                        )
+                                        .toList(),
+                                  ),
+                                  middleText: '┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪╖┘ä╪º█î ╪¿╪»┘ç┌⌐╪º╪▒',
+                                  middleTextStyle: context
+                                      .textTheme.bodyMedium!
+                                      .copyWith(
+                                    color: AppColor.backGroundColor,
+                                    fontSize: 13,
+                                  ),
+                                  title: '╪¼╪▓█î█î╪º╪¬',
+                                  titleStyle: context.textTheme.titleSmall!
+                                      .copyWith(
+                                    color: AppColor.backGroundColor,
+                                    fontSize: 14,
+                                  ),
+                                  backgroundColor: AppColor.textColor,
+                                  radius: 7,
+                                  contentPadding: EdgeInsets.symmetric(
+                                    horizontal: 20,
+                                    vertical: 20,
+                                  ),
+                                );
+                              },
+                              child: SvgPicture.asset(
+                                'assets/svg/list.svg',
+                                height: 16,
+                                colorFilter: ColorFilter.mode(
+                                  AppColor.textColor,
+                                  BlendMode.srcIn,
+                                ),
+                              ),
+                            ),
+                          ],
+                        ),
+                        SizedBox(height: 5),
+                        (trans.afterGoldBalance ?? 0) < 0
+                            ? Divider(
+                                height: 0.5,
+                                color: AppColor.dividerColor,
+                              )
+                            : SizedBox.shrink(),
+                        SizedBox(height: 5),
+                        (trans.afterGoldBalance ?? 0) < 0
+                            ? Column(
+                                children: trans.balances!
+                                    .map(
+                                      (e) => e.unitName == '┌»╪▒┘à'
+                                          ? Row(
+                                              mainAxisAlignment:
+                                                  MainAxisAlignment
+                                                      .spaceBetween,
+                                              children: [
+                                                (e.balance ?? 0) > 0
+                                                    ? Row(
+                                                        children: [
+                                                          Text(
+                                                            e.itemName ?? '',
+                                                            style: AppTextStyle
+                                                                .labelText
+                                                                .copyWith(
+                                                              fontSize: 10,
+                                                              color: AppColor
+                                                                  .primaryColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                          ),
+                                                          Text(
+                                                            '${e.balance ?? 0}',
+                                                            style: AppTextStyle
+                                                                .labelText
+                                                                .copyWith(
+                                                              fontSize: 12,
+                                                              color: AppColor
+                                                                  .primaryColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                          ),
+                                                          Text(
+                                                            ' ┌»╪▒┘à ',
+                                                            style: AppTextStyle
+                                                                .bodyText
+                                                                .copyWith(
+                                                              fontSize: 10,
+                                                              color: AppColor
+                                                                  .primaryColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                          ),
+                                                        ],
+                                                      )
+                                                    : (e.balance ?? 0) < 0
+                                                        ? Row(
+                                                            children: [
+                                                              Text(
+                                                                e.itemName ??
+                                                                    '',
+                                                                style: AppTextStyle
+                                                                    .labelText
+                                                                    .copyWith(
+                                                                  fontSize: 10,
+                                                                  color: AppColor
+                                                                      .accentColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                              ),
+                                                              Text(
+                                                                '-${e.balance?.abs() ?? 0}',
+                                                                style: AppTextStyle
+                                                                    .labelText
+                                                                    .copyWith(
+                                                                  fontSize: 12,
+                                                                  color: AppColor
+                                                                      .accentColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                                textDirection:
+                                                                    TextDirection
+                                                                        .ltr,
+                                                              ),
+                                                              Text(
+                                                                ' ┌»╪▒┘à ',
+                                                                style: AppTextStyle
+                                                                    .bodyText
+                                                                    .copyWith(
+                                                                  fontSize: 10,
+                                                                  color: AppColor
+                                                                      .accentColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                                textDirection:
+                                                                    TextDirection
+                                                                        .ltr,
+                                                              ),
+                                                            ],
+                                                          )
+                                                        : SizedBox.shrink(),
+                                              ],
+                                            )
+                                          : SizedBox(),
+                                    )
+                                    .toList(),
+                              )
+                            : SizedBox.shrink(),
+                      ],
+                    ),
+            ],
+          )
+        : SizedBox.shrink();
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_grouped_header.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_grouped_header.widget.dart
new file mode 100644
index 0000000..75286f0
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_grouped_header.widget.dart
@@ -0,0 +1,79 @@
+import 'package:flutter/material.dart';
+import 'package:get/get.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/controller/user_info_transaction.controller.dart';
+import 'package:hanigold_admin/src/domain/users/widgets/list_user_info_transaction/user_balance_polarity_chip.widget.dart';
+
+/// Grouped column header: asset label + ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒/╪¿╪»┘ç┌⌐╪º╪▒ sort chips.
+class UserBalanceGroupedHeader extends StatelessWidget {
+  const UserBalanceGroupedHeader({
+    super.key,
+    required this.label,
+    required this.creditSortIndex,
+    required this.debitSortIndex,
+    required this.controller,
+    this.sortEnabled = true,
+    this.swapPolarityColors = false,
+  });
+
+  final String label;
+  final int creditSortIndex;
+  final int debitSortIndex;
+  final UserInfoTransactionController controller;
+  final bool sortEnabled;
+
+  /// Currency headers swap ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒/╪¿╪»┘ç┌⌐╪º╪▒ colors (monolith parity).
+  final bool swapPolarityColors;
+
+  @override
+  Widget build(BuildContext context) {
+    return Obx(() {
+      final activeIndex = controller.sortColumnIndex.value;
+      final ascending = controller.sortAscending.value;
+
+      final creditIsCredit = !swapPolarityColors;
+      final debitIsCredit = swapPolarityColors;
+
+      return Column(
+        mainAxisSize: MainAxisSize.min,
+        children: [
+          Text(
+            label,
+            style: AppTextStyle.labelText.copyWith(fontSize: 11),
+          ),
+          const SizedBox(height: 4),
+          Row(
+            mainAxisSize: MainAxisSize.min,
+            children: [
+              UserBalancePolarityChip(
+                label: '╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                isCredit: creditIsCredit,
+                isActive: activeIndex == creditSortIndex,
+                onTap: sortEnabled
+                    ? () => _onChipTap(creditSortIndex, ascending, activeIndex)
+                    : null,
+              ),
+              const SizedBox(width: 4),
+              UserBalancePolarityChip(
+                label: '╪¿╪»┘ç┌⌐╪º╪▒',
+                isCredit: debitIsCredit,
+                isActive: activeIndex == debitSortIndex,
+                onTap: sortEnabled
+                    ? () => _onChipTap(debitSortIndex, ascending, activeIndex)
+                    : null,
+              ),
+            ],
+          ),
+        ],
+      );
+    });
+  }
+
+  void _onChipTap(int columnIndex, bool ascending, int? activeIndex) {
+    if (activeIndex == columnIndex) {
+      controller.onSort(columnIndex, !ascending);
+    } else {
+      controller.onSort(columnIndex, true);
+    }
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_rial_cell.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_rial_cell.widget.dart
new file mode 100644
index 0000000..0d411fe
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_rial_cell.widget.dart
@@ -0,0 +1,509 @@
+import 'package:flutter/material.dart';
+import 'package:flutter_svg/svg.dart';
+import 'package:get/get.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
+import 'package:persian_number_utility/persian_number_utility.dart';
+
+/// Rial balance cell (╪¿╪│╪¬╪º┘å┌⌐╪º╪▒ / ╪¿╪»┘ç┌⌐╪º╪▒) with installment breakdown.
+class UserBalanceRialCell {
+  UserBalanceRialCell._();
+
+  static Widget creditSection({
+    required BuildContext context,
+    required ListTransactionInfoItemModel trans,
+  }) {
+    return (trans.cashBalanceBes ?? 0) > 0
+        ? Row(
+            mainAxisAlignment: MainAxisAlignment.center,
+            children: [
+              trans.cashBalanceBes == 0
+                  ? SizedBox()
+                  : Column(
+                      mainAxisAlignment: MainAxisAlignment.center,
+                      children: [
+                        Row(
+                          children: [
+                            SizedBox(
+                              child: Row(
+                                children: [
+                                  Text(
+                                    '┘ê╪¼┘ç ┘å┘é╪» ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.primaryColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                  Text(
+                                    trans.cashBalanceBes!
+                                        .toStringAsFixed(0)
+                                        .seRagham(),
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 12,
+                                      color: AppColor.primaryColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                    textDirection: TextDirection.ltr,
+                                  ),
+                                  Text(
+                                    ' ╪▒█î╪º┘ä ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.primaryColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                ],
+                              ),
+                            ),
+                            GestureDetector(
+                              onTap: () {
+                                Get.defaultDialog(
+                                  confirm: Column(
+                                    children: trans.balances!
+                                        .map(
+                                          (e) => e.unitName == '╪▒█î╪º┘ä'
+                                              ? Row(
+                                                  mainAxisAlignment:
+                                                      MainAxisAlignment
+                                                          .spaceBetween,
+                                                  children: [
+                                                    Text(
+                                                      e.itemName ?? '',
+                                                      style: AppTextStyle
+                                                          .labelText
+                                                          .copyWith(
+                                                        fontSize: 12,
+                                                        color: AppColor
+                                                            .backGroundColor,
+                                                      ),
+                                                    ),
+                                                    Text(
+                                                      '${e.balance?.toStringAsFixed(0).seRagham() ?? 0} ╪▒█î╪º┘ä ',
+                                                      style: AppTextStyle
+                                                          .labelText
+                                                          .copyWith(
+                                                        fontSize: 12,
+                                                        color: AppColor
+                                                            .backGroundColor,
+                                                      ),
+                                                      textDirection:
+                                                          TextDirection.ltr,
+                                                    ),
+                                                  ],
+                                                )
+                                              : SizedBox(),
+                                        )
+                                        .toList(),
+                                  ),
+                                  middleText: '┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪▒█î╪º┘ä ╪¿╪│╪¬╪º┘å┌⌐╪º╪▒',
+                                  middleTextStyle: context
+                                      .textTheme.bodyMedium!
+                                      .copyWith(
+                                    color: AppColor.backGroundColor,
+                                    fontSize: 13,
+                                  ),
+                                  title: '╪¼╪▓█î█î╪º╪¬',
+                                  titleStyle: context.textTheme.titleSmall!
+                                      .copyWith(
+                                    color: AppColor.backGroundColor,
+                                    fontSize: 14,
+                                  ),
+                                  backgroundColor: AppColor.textColor,
+                                  radius: 7,
+                                  contentPadding: EdgeInsets.symmetric(
+                                    horizontal: 20,
+                                    vertical: 20,
+                                  ),
+                                );
+                              },
+                              child: SvgPicture.asset(
+                                'assets/svg/list.svg',
+                                height: 16,
+                                colorFilter: ColorFilter.mode(
+                                  AppColor.textColor,
+                                  BlendMode.srcIn,
+                                ),
+                              ),
+                            ),
+                          ],
+                        ),
+                        SizedBox(height: 5),
+                        (trans.afterCashBalance ?? 0) > 0
+                            ? Divider(
+                                height: 0.5,
+                                color: AppColor.dividerColor,
+                              )
+                            : SizedBox.shrink(),
+                        SizedBox(height: 5),
+                        (trans.afterCashBalance ?? 0) > 0
+                            ? Column(
+                                children: trans.balances!
+                                    .map(
+                                      (e) => e.unitName == '╪▒█î╪º┘ä'
+                                          ? Row(
+                                              mainAxisAlignment:
+                                                  MainAxisAlignment
+                                                      .spaceBetween,
+                                              children: [
+                                                (e.balance ?? 0) > 0
+                                                    ? Row(
+                                                        children: [
+                                                          Text(
+                                                            e.itemName ?? '',
+                                                            style: AppTextStyle
+                                                                .labelText
+                                                                .copyWith(
+                                                              fontSize: 10,
+                                                              color: AppColor
+                                                                  .primaryColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                          ),
+                                                          Text(
+                                                            '${e.balance?.toStringAsFixed(0).seRagham() ?? 0}',
+                                                            style: AppTextStyle
+                                                                .labelText
+                                                                .copyWith(
+                                                              fontSize: 12,
+                                                              color: AppColor
+                                                                  .primaryColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                            textDirection:
+                                                                TextDirection
+                                                                    .ltr,
+                                                          ),
+                                                          Text(
+                                                            ' ╪▒█î╪º┘ä ',
+                                                            style: AppTextStyle
+                                                                .bodyText
+                                                                .copyWith(
+                                                              fontSize: 9,
+                                                              color: AppColor
+                                                                  .primaryColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                            textDirection:
+                                                                TextDirection
+                                                                    .ltr,
+                                                          ),
+                                                        ],
+                                                      )
+                                                    : (e.balance ?? 0) < 0
+                                                        ? Row(
+                                                            children: [
+                                                              Text(
+                                                                e.itemName ??
+                                                                    '',
+                                                                style: AppTextStyle
+                                                                    .labelText
+                                                                    .copyWith(
+                                                                  fontSize: 10,
+                                                                  color: AppColor
+                                                                      .accentColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                              ),
+                                                              Text(
+                                                                '-${e.balance?.abs().toStringAsFixed(0).seRagham() ?? 0}',
+                                                                style: AppTextStyle
+                                                                    .labelText
+                                                                    .copyWith(
+                                                                  fontSize: 12,
+                                                                  color: AppColor
+                                                                      .accentColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                                textDirection:
+                                                                    TextDirection
+                                                                        .ltr,
+                                                              ),
+                                                              Text(
+                                                                ' ╪▒█î╪º┘ä ',
+                                                                style: AppTextStyle
+                                                                    .bodyText
+                                                                    .copyWith(
+                                                                  fontSize: 10,
+                                                                  color: AppColor
+                                                                      .accentColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                              ),
+                                                            ],
+                                                          )
+                                                        : SizedBox.shrink(),
+                                              ],
+                                            )
+                                          : SizedBox(),
+                                    )
+                                    .toList(),
+                              )
+                            : SizedBox.shrink(),
+                      ],
+                    ),
+            ],
+          )
+        : SizedBox.shrink();
+  }
+
+  static Widget debitSection({
+    required BuildContext context,
+    required ListTransactionInfoItemModel trans,
+  }) {
+    return (trans.cashBalanceBed ?? 0) < 0
+        ? Column(
+            mainAxisAlignment: MainAxisAlignment.center,
+            children: [
+              trans.cashBalanceBed == 0
+                  ? SizedBox()
+                  : Column(
+                      mainAxisAlignment: MainAxisAlignment.center,
+                      children: [
+                        Row(
+                          children: [
+                            SizedBox(
+                              child: Row(
+                                children: [
+                                  Text(
+                                    '┘ê╪¼┘ç ┘å┘é╪» ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.accentColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                  Text(
+                                    '-${trans.cashBalanceBed?.abs().toStringAsFixed(0).seRagham() ?? ''}',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 12,
+                                      color: AppColor.accentColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                    textDirection: TextDirection.ltr,
+                                  ),
+                                  Text(
+                                    ' ╪▒█î╪º┘ä ',
+                                    style: AppTextStyle.bodyText.copyWith(
+                                      fontSize: 9,
+                                      color: AppColor.accentColor,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                ],
+                              ),
+                            ),
+                            GestureDetector(
+                              onTap: () {
+                                Get.defaultDialog(
+                                  confirm: Column(
+                                    children: trans.balances!
+                                        .map(
+                                          (e) => e.unitName == '╪▒█î╪º┘ä'
+                                              ? Row(
+                                                  mainAxisAlignment:
+                                                      MainAxisAlignment
+                                                          .spaceBetween,
+                                                  children: [
+                                                    Text(
+                                                      e.itemName ?? '',
+                                                      style: AppTextStyle
+                                                          .labelText
+                                                          .copyWith(
+                                                        fontSize: 12,
+                                                        color: AppColor
+                                                            .backGroundColor,
+                                                      ),
+                                                    ),
+                                                    Text(
+                                                      '-${e.balance?.abs().toStringAsFixed(0).seRagham() ?? 0} ╪▒█î╪º┘ä ',
+                                                      style: AppTextStyle
+                                                          .labelText
+                                                          .copyWith(
+                                                        fontSize: 12,
+                                                        color: AppColor
+                                                            .backGroundColor,
+                                                      ),
+                                                      textDirection:
+                                                          TextDirection.ltr,
+                                                    ),
+                                                  ],
+                                                )
+                                              : SizedBox(),
+                                        )
+                                        .toList(),
+                                  ),
+                                  middleText: '┘ä█î╪│╪¬ ┘à╪º┘å╪»┘ç ╪▒█î╪º┘ä ╪¿╪»┘ç┌⌐╪º╪▒',
+                                  middleTextStyle: context
+                                      .textTheme.bodyMedium!
+                                      .copyWith(
+                                    color: AppColor.backGroundColor,
+                                    fontSize: 13,
+                                  ),
+                                  title: '╪¼╪▓█î█î╪º╪¬',
+                                  titleStyle: context.textTheme.titleSmall!
+                                      .copyWith(
+                                    color: AppColor.backGroundColor,
+                                    fontSize: 14,
+                                  ),
+                                  backgroundColor: AppColor.textColor,
+                                  radius: 7,
+                                  contentPadding: EdgeInsets.symmetric(
+                                    horizontal: 20,
+                                    vertical: 20,
+                                  ),
+                                );
+                              },
+                              child: SvgPicture.asset(
+                                'assets/svg/list.svg',
+                                height: 16,
+                                colorFilter: ColorFilter.mode(
+                                  AppColor.textColor,
+                                  BlendMode.srcIn,
+                                ),
+                              ),
+                            ),
+                          ],
+                        ),
+                        SizedBox(height: 5),
+                        (trans.afterCashBalance ?? 0) < 0
+                            ? Divider(
+                                height: 0.5,
+                                color: AppColor.dividerColor,
+                              )
+                            : SizedBox.shrink(),
+                        SizedBox(height: 5),
+                        (trans.afterCashBalance ?? 0) < 0
+                            ? Column(
+                                children: trans.balances!
+                                    .map(
+                                      (e) => e.unitName == '╪▒█î╪º┘ä'
+                                          ? Row(
+                                              children: [
+                                                (e.balance ?? 0) < 0
+                                                    ? Row(
+                                                        children: [
+                                                          Text(
+                                                            e.itemName ?? '',
+                                                            style: AppTextStyle
+                                                                .labelText
+                                                                .copyWith(
+                                                              fontSize: 10,
+                                                              color: AppColor
+                                                                  .accentColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                          ),
+                                                          Text(
+                                                            '-${e.balance?.abs().toStringAsFixed(0).seRagham() ?? 0}',
+                                                            style: AppTextStyle
+                                                                .labelText
+                                                                .copyWith(
+                                                              fontSize: 12,
+                                                              color: AppColor
+                                                                  .accentColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                            textDirection:
+                                                                TextDirection
+                                                                    .ltr,
+                                                          ),
+                                                          Text(
+                                                            ' ╪▒█î╪º┘ä ',
+                                                            style: AppTextStyle
+                                                                .bodyText
+                                                                .copyWith(
+                                                              fontSize: 10,
+                                                              color: AppColor
+                                                                  .accentColor,
+                                                              fontWeight:
+                                                                  FontWeight
+                                                                      .bold,
+                                                            ),
+                                                          ),
+                                                        ],
+                                                      )
+                                                    : (e.balance ?? 0) > 0
+                                                        ? Row(
+                                                            children: [
+                                                              Text(
+                                                                e.itemName ??
+                                                                    '',
+                                                                style: AppTextStyle
+                                                                    .labelText
+                                                                    .copyWith(
+                                                                  fontSize: 10,
+                                                                  color: AppColor
+                                                                      .primaryColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                              ),
+                                                              Text(
+                                                                '${e.balance?.toStringAsFixed(0).seRagham() ?? 0}',
+                                                                style: AppTextStyle
+                                                                    .labelText
+                                                                    .copyWith(
+                                                                  fontSize: 12,
+                                                                  color: AppColor
+                                                                      .primaryColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                                textDirection:
+                                                                    TextDirection
+                                                                        .ltr,
+                                                              ),
+                                                              Text(
+                                                                ' ╪▒█î╪º┘ä ',
+                                                                style: AppTextStyle
+                                                                    .bodyText
+                                                                    .copyWith(
+                                                                  fontSize: 9,
+                                                                  color: AppColor
+                                                                      .primaryColor,
+                                                                  fontWeight:
+                                                                      FontWeight
+                                                                          .bold,
+                                                                ),
+                                                                textDirection:
+                                                                    TextDirection
+                                                                        .ltr,
+                                                              ),
+                                                            ],
+                                                          )
+                                                        : SizedBox.shrink(),
+                                              ],
+                                            )
+                                          : SizedBox(),
+                                    )
+                                    .toList(),
+                              )
+                            : SizedBox.shrink(),
+                      ],
+                    ),
+            ],
+          )
+        : SizedBox.shrink();
+  }
+}
diff --git a/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_total_cell.widget.dart b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_total_cell.widget.dart
new file mode 100644
index 0000000..182eec3
--- /dev/null
+++ b/lib/src/domain/users/widgets/list_user_info_transaction/user_balance_total_cell.widget.dart
@@ -0,0 +1,275 @@
+import 'package:flutter/material.dart';
+import 'package:flutter_svg/svg.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
+import 'package:hanigold_admin/src/config/const/app_text_style.dart';
+import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
+import 'package:persian_number_utility/persian_number_utility.dart';
+
+/// Total balance cell (╪¬╪▒╪º╪▓ ┌⌐┘ä ╪¿╪│ / ╪¿╪») with scales icon.
+class UserBalanceTotalCell {
+  UserBalanceTotalCell._();
+
+  static Widget creditSection({
+    required ListTransactionInfoItemModel trans,
+  }) {
+    return Column(
+      mainAxisAlignment: MainAxisAlignment.center,
+      children: [
+        (trans.currencyValueBes ?? 0) > 0
+            ? Column(
+                children: [
+                  SizedBox(height: 5),
+                  Row(
+                    children: [
+                      SvgPicture.asset(
+                        'assets/svg/scales.svg',
+                        height: 15,
+                        colorFilter: ColorFilter.mode(
+                          AppColor.primaryColor,
+                          BlendMode.srcIn,
+                        ),
+                      ),
+                      SizedBox(width: 5),
+                      Text(
+                        trans.currencyValueBes
+                                ?.toStringAsFixed(0)
+                                .seRagham() ??
+                            '',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 10,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      Text(
+                        ' ╪▒█î╪º┘ä ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 8,
+                          color: AppColor.primaryColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      SizedBox(width: 5),
+                    ],
+                  ),
+                  Container(
+                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
+                    height: 0.5,
+                    color: AppColor.textColor,
+                  ),
+                  Row(
+                    children: [
+                      Text(
+                        ' ┘à╪╣╪º╪»┘ä ╪ó╪¿╪┤╪»┘ç : ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.textColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      (trans.goldValue ?? 0) < 0
+                          ? Text(
+                              '-${trans.goldValue?.abs().toStringAsFixed(3) ?? ''} ',
+                              style: AppTextStyle.bodyText.copyWith(
+                                fontSize: 9,
+                                color: AppColor.accentColor,
+                                fontWeight: FontWeight.bold,
+                              ),
+                              textDirection: TextDirection.ltr,
+                            )
+                          : Text(
+                              ' ${trans.goldValue?.toStringAsFixed(3) ?? ''} ',
+                              style: AppTextStyle.bodyText.copyWith(
+                                fontSize: 9,
+                                color: AppColor.primaryColor,
+                                fontWeight: FontWeight.bold,
+                              ),
+                            ),
+                      Text(
+                        ' ┌»╪▒┘à ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 8,
+                          color: AppColor.textColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                  SizedBox(height: 5),
+                  Row(
+                    children: [
+                      Text(
+                        ' ┘à╪╣╪º╪»┘ä ╪│┌⌐┘ç : ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.textColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      (trans.coinValue ?? 0) < 0
+                          ? Text(
+                              '-${trans.coinValue?.abs().toStringAsFixed(3) ?? ''} ',
+                              style: AppTextStyle.bodyText.copyWith(
+                                fontSize: 9,
+                                color: AppColor.accentColor,
+                                fontWeight: FontWeight.bold,
+                              ),
+                              textDirection: TextDirection.ltr,
+                            )
+                          : Text(
+                              ' ${trans.coinValue?.toStringAsFixed(3) ?? ''} ',
+                              style: AppTextStyle.bodyText.copyWith(
+                                fontSize: 9,
+                                color: AppColor.primaryColor,
+                                fontWeight: FontWeight.bold,
+                              ),
+                            ),
+                      Text(
+                        ' ╪╣╪»╪» ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 8,
+                          color: AppColor.textColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                  SizedBox(height: 5),
+                ],
+              )
+            : SizedBox.shrink(),
+      ],
+    );
+  }
+
+  static Widget debitSection({
+    required ListTransactionInfoItemModel trans,
+  }) {
+    return Column(
+      mainAxisAlignment: MainAxisAlignment.center,
+      children: [
+        (trans.currencyValueBed ?? 0) < 0
+            ? Column(
+                children: [
+                  SizedBox(height: 5),
+                  Row(
+                    children: [
+                      SvgPicture.asset(
+                        'assets/svg/scales.svg',
+                        height: 15,
+                        colorFilter: ColorFilter.mode(
+                          AppColor.accentColor,
+                          BlendMode.srcIn,
+                        ),
+                      ),
+                      SizedBox(width: 5),
+                      Text(
+                        '-${trans.currencyValueBed?.abs().toStringAsFixed(0).seRagham() ?? ''}',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 10,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                        textDirection: TextDirection.ltr,
+                      ),
+                      Text(
+                        ' ╪▒█î╪º┘ä ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 8,
+                          color: AppColor.accentColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      SizedBox(width: 5),
+                    ],
+                  ),
+                  Container(
+                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
+                    height: 0.5,
+                    color: AppColor.textColor,
+                  ),
+                  Row(
+                    children: [
+                      Text(
+                        ' ┘à╪╣╪º╪»┘ä ╪ó╪¿╪┤╪»┘ç : ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.textColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      (trans.goldValue ?? 0) < 0
+                          ? Text(
+                              '-${trans.goldValue?.abs().toStringAsFixed(3) ?? ''} ',
+                              style: AppTextStyle.bodyText.copyWith(
+                                fontSize: 9,
+                                color: AppColor.accentColor,
+                                fontWeight: FontWeight.bold,
+                              ),
+                              textDirection: TextDirection.ltr,
+                            )
+                          : Text(
+                              ' ${trans.goldValue?.toStringAsFixed(3) ?? ''} ',
+                              style: AppTextStyle.bodyText.copyWith(
+                                fontSize: 9,
+                                color: AppColor.primaryColor,
+                                fontWeight: FontWeight.bold,
+                              ),
+                            ),
+                      Text(
+                        ' ┌»╪▒┘à ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 8,
+                          color: AppColor.textColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                  SizedBox(height: 5),
+                  Row(
+                    children: [
+                      Text(
+                        ' ┘à╪╣╪º╪»┘ä ╪│┌⌐┘ç : ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 9,
+                          color: AppColor.textColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      (trans.coinValue ?? 0) < 0
+                          ? Text(
+                              '-${trans.coinValue?.abs().toStringAsFixed(3) ?? ''} ',
+                              style: AppTextStyle.bodyText.copyWith(
+                                fontSize: 9,
+                                color: AppColor.accentColor,
+                                fontWeight: FontWeight.bold,
+                              ),
+                              textDirection: TextDirection.ltr,
+                            )
+                          : Text(
+                              ' ${trans.coinValue?.toStringAsFixed(3) ?? ''} ',
+                              style: AppTextStyle.bodyText.copyWith(
+                                fontSize: 9,
+                                color: AppColor.primaryColor,
+                                fontWeight: FontWeight.bold,
+                              ),
+                            ),
+                      Text(
+                        ' ╪╣╪»╪» ',
+                        style: AppTextStyle.bodyText.copyWith(
+                          fontSize: 8,
+                          color: AppColor.textColor,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                    ],
+                  ),
+                  SizedBox(height: 5),
+                ],
+              )
+            : SizedBox.shrink(),
+      ],
+    );
+  }
+}
