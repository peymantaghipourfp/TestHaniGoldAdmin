# Final Branch Review Package (no-git)
Plan: pin_expand_tooltips
Minor findings rollup: Task1 none; Task2 parent-tooltip runtime unverified; Task3 NEEDS_HUMAN_UI for interactive Windows smoke.

## Diff 1: hover_tooltip_scope.widget.dart
```
diff --git "a/d:\\curserAi project\\.superpowers\\sdd\\snapshots\\pre-task-1\\hover_tooltip_scope.widget.dart" "b/d:\\curserAi project\\lib\\src\\widget\\hover_tooltip_scope.widget.dart"
index f6bdb9a..5a98277 100644
--- "a/d:\\curserAi project\\.superpowers\\sdd\\snapshots\\pre-task-1\\hover_tooltip_scope.widget.dart"	
+++ "b/d:\\curserAi project\\lib\\src\\widget\\hover_tooltip_scope.widget.dart"	
@@ -129,4 +129,5 @@ class HoverTooltipScopeHost extends StatelessWidget {
 abstract final class HoverTooltipNestedIds {
   static const withdraw = 'withdraw-request-report';
   static const deposit = 'deposit-request-report';
+  static const todayPaymentExpanded = 'today-payment-expanded';
 }

```

## Diff 2: hover_lazy_rich_tooltip.widget.dart
```
diff --git "a/d:\\curserAi project\\.superpowers\\sdd\\snapshots\\pre-task-1\\hover_lazy_rich_tooltip.widget.dart" "b/d:\\curserAi project\\lib\\src\\widget\\hover_lazy_rich_tooltip.widget.dart"
index df2e372..856d2b6 100644
--- "a/d:\\curserAi project\\.superpowers\\sdd\\snapshots\\pre-task-1\\hover_lazy_rich_tooltip.widget.dart"	
+++ "b/d:\\curserAi project\\lib\\src\\widget\\hover_lazy_rich_tooltip.widget.dart"	
@@ -83,6 +83,16 @@ class HoverLazyRichTooltipState<T> extends State<HoverLazyRichTooltip<T>> {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) _keepFlutterTooltipVisibleIfNeeded();
       });
+    } else if (widget.nestedId == null &&
+        _isHovering &&
+        !_isHoveringTarget &&
+        !_isHoveringMessage) {
+      WidgetsBinding.instance.addPostFrameCallback((_) {
+        if (!mounted) return;
+        if (_scopeRetained || _hasActiveNested) return;
+        if (_isHoveringTarget || _isHoveringMessage) return;
+        _scheduleHide();
+      });
     }
   }
 

```

## Diff 3: today_payment_report_tooltip_content.widget.dart
```
diff --git "a/d:\\curserAi project\\.superpowers\\sdd\\snapshots\\pre-task-2\\today_payment_report_tooltip_content.widget.dart" "b/d:\\curserAi project\\lib\\src\\domain\\withdraw\\widget\\today_payment_report_tooltip_content.widget.dart"
index 9710b60..c8bf4de 100644
--- "a/d:\\curserAi project\\.superpowers\\sdd\\snapshots\\pre-task-2\\today_payment_report_tooltip_content.widget.dart"	
+++ "b/d:\\curserAi project\\lib\\src\\domain\\withdraw\\widget\\today_payment_report_tooltip_content.widget.dart"	
@@ -1,5 +1,3 @@
-import 'dart:async';
-
 import 'package:flutter/material.dart';
 import 'package:hanigold_admin/src/config/const/app_color.dart';
 import 'package:hanigold_admin/src/config/const/app_text_style.dart';
@@ -11,7 +9,7 @@ import 'package:hanigold_admin/src/domain/withdraw/util/today_payment_report_sec
 import 'package:hanigold_admin/src/domain/withdraw/widget/today_deposit_request_report_tooltip_content.widget.dart';
 import 'package:hanigold_admin/src/domain/withdraw/widget/today_withdraw_request_report_tooltip_content.widget.dart';
 import 'package:hanigold_admin/src/widget/hover_floating_panel.widget.dart';
-import 'package:hanigold_admin/src/widget/hover_nested_panel.widget.dart';
+import 'package:hanigold_admin/src/widget/hover_tooltip_scope.widget.dart';
 import 'package:persian_number_utility/persian_number_utility.dart';
 
 const double _kTooltipWidth = 700;
@@ -45,16 +43,20 @@ class TodayPaymentReportTooltipContent extends StatefulWidget {
 class _TodayPaymentReportTooltipContentState
     extends State<TodayPaymentReportTooltipContent> {
   _ExpandedSection _expandedSection = _ExpandedSection.none;
-  bool _isHoveringExpanded = false;
-  Timer? _showTimer;
-  Timer? _hideTimer;
+  bool _hasPinnedScope = false;
+  HoverTooltipScopeState? _scope;
   Future<List<TodayWithdrawRequestReportModel>?>? _withdrawFuture;
   Future<List<TodayDepositRequestReportModel>?>? _depositFuture;
 
+  @override
+  void didChangeDependencies() {
+    super.didChangeDependencies();
+    _scope = HoverTooltipScope.maybeOf(context);
+  }
+
   @override
   void dispose() {
-    _showTimer?.cancel();
-    _hideTimer?.cancel();
+    _unpinOuterTooltip(fromDispose: true);
     widget.withdrawController.clearTodayWithdrawRequestReportCache(
       widget.accountId,
       widget.date,
@@ -66,60 +68,66 @@ class _TodayPaymentReportTooltipContentState
     super.dispose();
   }
 
-  void _onIconHoverStart(_ExpandedSection section) {
-    _hideTimer?.cancel();
-    _showTimer?.cancel();
-
-    if (_expandedSection == section) return;
-
-    void activate() {
-      if (!mounted) return;
-      setState(() {
-        _expandedSection = section;
-        if (section == _ExpandedSection.withdraw) {
-          _withdrawFuture ??= widget.withdrawController
-              .loadTodayWithdrawRequestReport(
-            widget.accountId,
-            date: widget.date,
-          );
-        } else if (section == _ExpandedSection.deposit) {
-          _depositFuture ??= widget.withdrawController
-              .loadTodayDepositRequestReport(
-            widget.accountId,
-            date: widget.date,
-          );
-        }
-      });
-    }
+  void _pinOuterTooltip() {
+    final scope = _scope;
+    if (scope == null || _hasPinnedScope) return;
+    _hasPinnedScope = true;
+    scope.requestNestedActive(
+      HoverTooltipNestedIds.todayPaymentExpanded,
+      _collapse,
+    );
+    scope.retain();
+  }
 
-    if (_expandedSection != _ExpandedSection.none) {
-      activate();
+  void _unpinOuterTooltip({bool fromDispose = false}) {
+    if (!_hasPinnedScope) return;
+    final scope = _scope;
+    _hasPinnedScope = false;
+    if (scope == null) return;
+    if (fromDispose) {
+      scope.releaseFromDispose();
+      scope.clearNestedActiveFromDispose(
+        HoverTooltipNestedIds.todayPaymentExpanded,
+      );
       return;
     }
-
-    _showTimer = Timer(kNestedPanelShowDelay, activate);
-  }
-
-  void _onIconHoverEnd() {
-    _showTimer?.cancel();
-    _scheduleCollapse();
+    if (scope.mounted) {
+      scope.release();
+      scope.clearNestedActive(HoverTooltipNestedIds.todayPaymentExpanded);
+    } else {
+      scope.releaseFromDispose();
+      scope.clearNestedActiveFromDispose(
+        HoverTooltipNestedIds.todayPaymentExpanded,
+      );
+    }
   }
 
-  void _scheduleCollapse() {
-    _hideTimer?.cancel();
-    _hideTimer = Timer(kNestedPanelHideDelay, () {
-      if (!mounted || _isHoveringExpanded) return;
+  void _onIconTap(_ExpandedSection section) {
+    if (_expandedSection == section) {
       _collapse();
+      return;
+    }
+    setState(() {
+      _expandedSection = section;
+      if (section == _ExpandedSection.withdraw) {
+        _withdrawFuture ??= widget.withdrawController
+            .loadTodayWithdrawRequestReport(widget.accountId, date: widget.date);
+      } else if (section == _ExpandedSection.deposit) {
+        _depositFuture ??= widget.withdrawController
+            .loadTodayDepositRequestReport(widget.accountId, date: widget.date);
+      }
     });
+    _pinOuterTooltip();
   }
 
   void _collapse() {
-    if (_expandedSection == _ExpandedSection.none) return;
+    if (_expandedSection == _ExpandedSection.none && !_hasPinnedScope) return;
     setState(() {
       _expandedSection = _ExpandedSection.none;
       _withdrawFuture = null;
       _depositFuture = null;
     });
+    _unpinOuterTooltip();
     widget.withdrawController.clearTodayWithdrawRequestReportCache(
       widget.accountId,
       widget.date,
@@ -172,17 +180,17 @@ class _TodayPaymentReportTooltipContentState
               final useTwoColumns = constraints.maxWidth > 360;
               final withdrawSection = _WithdrawTodayPaymentSection(
                 report: widget.report,
-                onIconHoverStart: isWithdrawSectionEmpty(widget.report)
+                isIconActive: _expandedSection == _ExpandedSection.withdraw,
+                onIconTap: isWithdrawSectionEmpty(widget.report)
                     ? null
-                    : () => _onIconHoverStart(_ExpandedSection.withdraw),
-                onIconHoverEnd: _onIconHoverEnd,
+                    : () => _onIconTap(_ExpandedSection.withdraw),
               );
               final pledgeSection = _PledgeTodayPaymentSection(
                 report: widget.report,
-                onIconHoverStart: isPledgeSectionEmpty(widget.report)
+                isIconActive: _expandedSection == _ExpandedSection.deposit,
+                onIconTap: isPledgeSectionEmpty(widget.report)
                     ? null
-                    : () => _onIconHoverStart(_ExpandedSection.deposit),
-                onIconHoverEnd: _onIconHoverEnd,
+                    : () => _onIconTap(_ExpandedSection.deposit),
               );
 
               if (useTwoColumns) {
@@ -212,32 +220,53 @@ class _TodayPaymentReportTooltipContentState
             alignment: Alignment.topCenter,
             child: _expandedSection == _ExpandedSection.none
                 ? const SizedBox.shrink()
-                : MouseRegion(
-              onEnter: (_) {
-                _isHoveringExpanded = true;
-                _hideTimer?.cancel();
-              },
-              onExit: (_) {
-                _isHoveringExpanded = false;
-                _scheduleCollapse();
-              },
-              child: Column(
-                mainAxisSize: MainAxisSize.min,
-                crossAxisAlignment: CrossAxisAlignment.stretch,
-                children: [
-                  const SizedBox(height: 12),
-                  Divider(
-                    height: 1,
-                    color: AppColor.textColor.withValues(alpha: 0.12),
-                  ),
-                  const SizedBox(height: 10),
-                  SizedBox(
-                    height: _kExpandedDetailHeight,
-                    child: _buildExpandedDetail(),
+                : Column(
+                    mainAxisSize: MainAxisSize.min,
+                    crossAxisAlignment: CrossAxisAlignment.stretch,
+                    children: [
+                      const SizedBox(height: 12),
+                      Divider(
+                        height: 1,
+                        color: AppColor.textColor.withValues(alpha: 0.12),
+                      ),
+                      const SizedBox(height: 8),
+                      Row(
+                        children: [
+                          Expanded(
+                            child: Text(
+                              _expandedSection == _ExpandedSection.withdraw
+                                  ? '╪¼╪▓╪ª█î╪º╪¬ ╪»╪▒╪«┘ê╪º╪│╪¬ ╪¿╪▒╪»╪º╪┤╪¬'
+                                  : '╪¼╪▓╪ª█î╪º╪¬ ╪¬╪╣┘ç╪» ┘╛╪▒╪»╪º╪«╪¬',
+                              style: AppTextStyle.labelText.copyWith(
+                                fontSize: 12,
+                                fontWeight: FontWeight.w600,
+                              ),
+                            ),
+                          ),
+                          IconButton(
+                            tooltip: '╪¿╪│╪¬┘å',
+                            visualDensity: VisualDensity.compact,
+                            padding: EdgeInsets.zero,
+                            constraints: const BoxConstraints(
+                              minWidth: 32,
+                              minHeight: 32,
+                            ),
+                            onPressed: _collapse,
+                            icon: Icon(
+                              Icons.close_rounded,
+                              size: 18,
+                              color: AppColor.textColor.withValues(alpha: 0.7),
+                            ),
+                          ),
+                        ],
+                      ),
+                      const SizedBox(height: 8),
+                      SizedBox(
+                        height: _kExpandedDetailHeight,
+                        child: _buildExpandedDetail(),
+                      ),
+                    ],
                   ),
-                ],
-              ),
-            ),
           ),
           if (_hasFooterMetrics(widget.report)) ...[
             const SizedBox(height: 14),
@@ -462,13 +491,13 @@ class _Header extends StatelessWidget {
 
 class _WithdrawTodayPaymentSection extends StatelessWidget {
   final TodayPaymentReportModel report;
-  final VoidCallback? onIconHoverStart;
-  final VoidCallback? onIconHoverEnd;
+  final bool isIconActive;
+  final VoidCallback? onIconTap;
 
   const _WithdrawTodayPaymentSection({
     required this.report,
-    this.onIconHoverStart,
-    this.onIconHoverEnd,
+    this.isIconActive = false,
+    this.onIconTap,
   });
 
   static const _title = '╪»╪▒╪«┘ê╪º╪│╪¬ ╪¿╪▒╪»╪º╪┤╪¬ ╪º┘à╪▒┘ê╪▓';
@@ -512,8 +541,8 @@ class _WithdrawTodayPaymentSection extends StatelessWidget {
             icon: Icons.receipt_long_rounded,
             label: '╪¬╪╣╪»╪º╪»',
             value: '${report.withdrawRequestCount ?? 0} ╪»╪▒╪«┘ê╪º╪│╪¬',
-            onIconHoverStart: onIconHoverStart,
-            onIconHoverEnd: onIconHoverEnd,
+            isIconActive: isIconActive,
+            onIconTap: onIconTap,
           ),
         ],
       ),
@@ -523,13 +552,13 @@ class _WithdrawTodayPaymentSection extends StatelessWidget {
 
 class _PledgeTodayPaymentSection extends StatelessWidget {
   final TodayPaymentReportModel report;
-  final VoidCallback? onIconHoverStart;
-  final VoidCallback? onIconHoverEnd;
+  final bool isIconActive;
+  final VoidCallback? onIconTap;
 
   const _PledgeTodayPaymentSection({
     required this.report,
-    this.onIconHoverStart,
-    this.onIconHoverEnd,
+    this.isIconActive = false,
+    this.onIconTap,
   });
 
   static const _title = '╪¬╪╣┘ç╪» ┘╛╪▒╪»╪º╪«╪¬ ╪º┘à╪▒┘ê╪▓';
@@ -578,8 +607,8 @@ class _PledgeTodayPaymentSection extends StatelessWidget {
             icon: Icons.account_balance_wallet,
             label: '╪¬╪╣╪»╪º╪»',
             value: '${report.pledgeCount ?? 0} ╪¬╪╣┘ç╪»',
-            onIconHoverStart: onIconHoverStart,
-            onIconHoverEnd: onIconHoverEnd,
+            isIconActive: isIconActive,
+            onIconTap: onIconTap,
           ),
         ],
       ),
@@ -750,16 +779,16 @@ class _MetricChip extends StatefulWidget {
   final IconData icon;
   final String label;
   final String value;
-  final VoidCallback? onIconHoverStart;
-  final VoidCallback? onIconHoverEnd;
+  final bool isIconActive;
+  final VoidCallback? onIconTap;
 
   const _MetricChip({
     required this.accentColor,
     required this.icon,
     required this.label,
     required this.value,
-    this.onIconHoverStart,
-    this.onIconHoverEnd,
+    this.isIconActive = false,
+    this.onIconTap,
   });
 
   @override
@@ -771,38 +800,36 @@ class _MetricChipState extends State<_MetricChip> {
 
   @override
   Widget build(BuildContext context) {
+    final isHighlighted = widget.isIconActive || _isIconHovered;
     final iconChip = MouseRegion(
-      onEnter: (_) {
-        setState(() => _isIconHovered = true);
-        widget.onIconHoverStart?.call();
-      },
-      onExit: (_) {
-        setState(() => _isIconHovered = false);
-        widget.onIconHoverEnd?.call();
-      },
-      cursor: widget.onIconHoverStart != null
+      onEnter: (_) => setState(() => _isIconHovered = true),
+      onExit: (_) => setState(() => _isIconHovered = false),
+      cursor: widget.onIconTap != null
           ? SystemMouseCursors.click
           : SystemMouseCursors.basic,
-      child: AnimatedContainer(
-        duration: kHoverPanelAnimationDuration,
-        curve: Curves.easeOutCubic,
-        width: 28,
-        height: 28,
-        decoration: BoxDecoration(
-          color: widget.accentColor.withValues(
-            alpha: _isIconHovered ? 0.28 : 0.15,
+      child: GestureDetector(
+        onTap: widget.onIconTap,
+        child: AnimatedContainer(
+          duration: kHoverPanelAnimationDuration,
+          curve: Curves.easeOutCubic,
+          width: 28,
+          height: 28,
+          decoration: BoxDecoration(
+            color: widget.accentColor.withValues(
+              alpha: isHighlighted ? 0.28 : 0.15,
+            ),
+            borderRadius: BorderRadius.circular(8),
+            border: isHighlighted
+                ? Border.all(
+                    color: widget.accentColor.withValues(alpha: 0.5),
+                  )
+                : null,
+          ),
+          child: Icon(
+            widget.icon,
+            size: 14,
+            color: widget.accentColor,
           ),
-          borderRadius: BorderRadius.circular(8),
-          border: _isIconHovered
-              ? Border.all(
-            color: widget.accentColor.withValues(alpha: 0.5),
-          )
-              : null,
-        ),
-        child: Icon(
-          widget.icon,
-          size: 14,
-          color: widget.accentColor,
         ),
       ),
     );

```
