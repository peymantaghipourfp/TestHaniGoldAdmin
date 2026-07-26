# Final Branch Review Package
Base: pre-Task-1 baselines
Head: current working tree
Commits: none (no-git)
Minor carry-forward: status close AlignmentDirectional.topStart vs content trailing Row RTL

## Files changed
- lib/src/widget/hover_lazy_rich_tooltip.widget.dart
- lib/src/domain/withdraw/widget/hover_tooltip_today_payment_report.widget.dart

## Diff 1: HoverLazyRichTooltip
diff --git a/.superpowers/sdd/hover_lazy_rich_tooltip.widget.baseline.dart b/lib/src/widget/hover_lazy_rich_tooltip.widget.dart
index 79e2ec8..c3c9102 100644
--- a/.superpowers/sdd/hover_lazy_rich_tooltip.widget.baseline.dart
+++ b/lib/src/widget/hover_lazy_rich_tooltip.widget.dart
@@ -20,31 +20,35 @@ class HoverLazyRichTooltip<T> extends StatefulWidget {
   final Widget Function(BuildContext context, AsyncSnapshot<T?> snapshot)
   messageBuilder;
   final Widget? waitingMessage;
   final bool preferBelow;
   final Duration showDuration;
   final double? messageMaxWidth;
 
   /// When set, this tooltip participates in [HoverTooltipScope] coordination.
   final String? nestedId;
 
+  /// When true, pointer leave does not dismiss; only [HoverLazyRichTooltipState.forceDeactivate] closes.
+  final bool stickyUntilDismissed;
+
   const HoverLazyRichTooltip({
     super.key,
     required this.child,
     required this.loadData,
     required this.messageBuilder,
     this.onHoverEnd,
     this.waitingMessage,
     this.preferBelow = false,
     this.showDuration = const Duration(seconds: 5),
     this.messageMaxWidth,
     this.nestedId,
+    this.stickyUntilDismissed = false,
   });
 
   @override
   State<HoverLazyRichTooltip<T>> createState() =>
       HoverLazyRichTooltipState<T>();
 }
 
 class HoverLazyRichTooltipState<T> extends State<HoverLazyRichTooltip<T>> {
   final GlobalKey<TooltipState> _flutterTooltipKey = GlobalKey<TooltipState>();
 
@@ -57,20 +61,21 @@ class HoverLazyRichTooltipState<T> extends State<HoverLazyRichTooltip<T>> {
   HoverTooltipScopeState? _scope;
 
   bool get _scopeRetained =>
       HoverTooltipScopeData.maybeOf(context)?.isRetained ?? false;
 
   bool get _hasActiveNested =>
       widget.nestedId == null &&
           (HoverTooltipScopeData.maybeOf(context)?.activeNestedId != null);
 
   bool get _isActive {
+    if (widget.stickyUntilDismissed && _isHovering) return true;
     if (widget.nestedId != null) {
       return _isHoveringTarget || _isHoveringMessage;
     }
     return _isHoveringTarget ||
         _isHoveringMessage ||
         _scopeRetained ||
         _hasActiveNested;
   }
 
   @override
@@ -84,27 +89,35 @@ class HoverLazyRichTooltipState<T> extends State<HoverLazyRichTooltip<T>> {
         if (mounted) _keepFlutterTooltipVisibleIfNeeded();
       });
     } else if (widget.nestedId == null &&
         _isHovering &&
         !_isHoveringTarget &&
         !_isHoveringMessage) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (!mounted) return;
         if (_scopeRetained || _hasActiveNested) return;
         if (_isHoveringTarget || _isHoveringMessage) return;
+        if (widget.stickyUntilDismissed && _isHovering) {
+          _keepFlutterTooltipVisibleIfNeeded();
+          return;
+        }
         _scheduleHide();
       });
     }
   }
 
   void _keepFlutterTooltipVisibleIfNeeded() {
-    if (!_scopeRetained && !_hasActiveNested) return;
+    if (!widget.stickyUntilDismissed &&
+        !_scopeRetained &&
+        !_hasActiveNested) {
+      return;
+    }
     _flutterTooltipKey.currentState?.ensureTooltipVisible();
   }
 
   @override
   void dispose() {
     _hideTimer?.cancel();
     _releaseScope(fromDispose: true);
     super.dispose();
   }
 
@@ -204,37 +217,45 @@ class HoverLazyRichTooltipState<T> extends State<HoverLazyRichTooltip<T>> {
   void _onTargetEnter(PointerEnterEvent _) {
     _isHoveringTarget = true;
     _activate();
   }
 
   void _onTargetExit(PointerExitEvent _) {
     _isHoveringTarget = false;
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (!mounted) return;
       if (_isHoveringTarget || _isHoveringMessage) return;
+      if (widget.stickyUntilDismissed && _isHovering) {
+        _keepFlutterTooltipVisibleIfNeeded();
+        return;
+      }
       _scheduleHide();
     });
   }
 
   void _onMessageEnter(PointerEnterEvent _) {
     _isHoveringMessage = true;
     _cancelHide();
     if (!_isHovering) {
       _activate();
     }
   }
 
   void _onMessageExit(PointerExitEvent _) {
     _isHoveringMessage = false;
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (!mounted) return;
       if (_isHoveringMessage || _isHoveringTarget) return;
+      if (widget.stickyUntilDismissed && _isHovering) {
+        _keepFlutterTooltipVisibleIfNeeded();
+        return;
+      }
       if (_scopeRetained || _hasActiveNested) {
         _keepFlutterTooltipVisibleIfNeeded();
         return;
       }
       _scheduleHide();
     });
   }
 
   @override
   Widget build(BuildContext context) {

## Diff 2: HoverTooltipTodayPaymentReportWidget
diff --git a/.superpowers/sdd/hover_tooltip_today_payment_report.widget.baseline.dart b/lib/src/domain/withdraw/widget/hover_tooltip_today_payment_report.widget.dart
index a84b7ac..c396d98 100644
--- a/.superpowers/sdd/hover_tooltip_today_payment_report.widget.baseline.dart
+++ b/lib/src/domain/withdraw/widget/hover_tooltip_today_payment_report.widget.dart
@@ -1,11 +1,12 @@
 import 'package:flutter/material.dart';
+import 'package:hanigold_admin/src/config/const/app_color.dart';
 import 'package:hanigold_admin/src/config/const/app_text_style.dart';
 import 'package:hanigold_admin/src/domain/withdraw/controller/withdraw.controller.dart';
 import 'package:hanigold_admin/src/domain/withdraw/model/today_payment_report.model.dart';
 import 'package:hanigold_admin/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart';
 import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';
 import 'package:hanigold_admin/src/widget/hover_floating_panel.widget.dart';
 import 'package:hanigold_admin/src/widget/hover_lazy_rich_tooltip.widget.dart';
 import 'package:hanigold_admin/src/widget/hover_tooltip_scope.widget.dart';
 
 const double _kTooltipWidth = 700;
@@ -29,26 +30,46 @@ class HoverTooltipTodayPaymentReportWidget extends StatefulWidget {
   @override
   State<HoverTooltipTodayPaymentReportWidget> createState() =>
       _HoverTooltipTodayPaymentReportWidgetState();
 }
 
 class _HoverTooltipTodayPaymentReportWidgetState
     extends State<HoverTooltipTodayPaymentReportWidget> {
   final GlobalKey<HoverLazyRichTooltipState<TodayPaymentReportModel>>
   _tooltipKey = GlobalKey();
 
+  Widget _statusCloseButton() {
+    return Align(
+      alignment: AlignmentDirectional.topStart,
+      child: IconButton(
+        tooltip: '╪¿╪│╪¬┘å',
+        visualDensity: VisualDensity.compact,
+        padding: EdgeInsets.zero,
+        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
+        onPressed: () => _tooltipKey.currentState?.forceDeactivate(),
+        icon: Icon(
+          Icons.close_rounded,
+          size: 18,
+          color: AppColor.textColor.withValues(alpha: 0.7),
+        ),
+      ),
+    );
+  }
+
   @override
   Widget build(BuildContext context) {
     return HoverTooltipScopeHost(
       child: HoverLazyRichTooltip<TodayPaymentReportModel>(
         key: _tooltipKey,
         messageMaxWidth: _kTooltipWidth,
+        stickyUntilDismissed: true,
+        showDuration: const Duration(days: 1),
         loadData: ({forceRefresh = false}) =>
             widget.withdrawController.loadTodayPaymentReport(
               widget.accountId,
               date: widget.date,
               forceRefresh: forceRefresh,
             ),
         waitingMessage: Container(
           padding: const EdgeInsets.all(8),
           child: Text(
             '╪»╪▒ ╪¡╪º┘ä ╪¿╪º╪▒┌»╪░╪º╪▒█î...',
@@ -61,55 +82,73 @@ class _HoverTooltipTodayPaymentReportWidgetState
     );
   }
 
   Widget _buildMessage(
       BuildContext context,
       AsyncSnapshot<TodayPaymentReportModel?> snapshot,
       ) {
     if (snapshot.connectionState == ConnectionState.waiting) {
       return FloatingPanelStatusCard(
         width: _kTooltipWidth,
-        child: const SizedBox(
-          height: 80,
-          child: Center(child: HaniGoldLoading()),
+        child: Column(
+          mainAxisSize: MainAxisSize.min,
+          children: [
+            _statusCloseButton(),
+            const SizedBox(
+              height: 80,
+              child: Center(child: HaniGoldLoading()),
+            ),
+          ],
         ),
       );
     }
 
     final loadState = widget.withdrawController.todayPaymentReportStateFor(
       widget.accountId,
       date: widget.date,
     );
 
     if (loadState == TodayPaymentReportLoadState.error) {
       final errorMessage = widget.withdrawController.todayPaymentReportErrorFor(
         widget.accountId,
         date: widget.date,
       );
       return FloatingPanelStatusCard(
         width: _kTooltipWidth,
-        child: FloatingPanelRetryRow(
-          message: errorMessage ?? '╪«╪╖╪º ╪»╪▒ ╪¿╪º╪▒┌»╪░╪º╪▒█î ┌»╪▓╪º╪▒╪┤',
-          onRetry: () =>
-              _tooltipKey.currentState?.reload(forceRefresh: true),
+        child: Column(
+          mainAxisSize: MainAxisSize.min,
+          children: [
+            _statusCloseButton(),
+            FloatingPanelRetryRow(
+              message: errorMessage ?? '╪«╪╖╪º ╪»╪▒ ╪¿╪º╪▒┌»╪░╪º╪▒█î ┌»╪▓╪º╪▒╪┤',
+              onRetry: () =>
+                  _tooltipKey.currentState?.reload(forceRefresh: true),
+            ),
+          ],
         ),
       );
     }
 
     if (loadState == TodayPaymentReportLoadState.empty ||
         snapshot.data == null) {
       return FloatingPanelStatusCard(
         width: _kTooltipWidth,
-        child: Text(
-          '┌»╪▓╪º╪▒╪┤█î ╪¿╪▒╪º█î ╪º┘à╪▒┘ê╪▓ ┘à┘ê╪¼┘ê╪» ┘å█î╪│╪¬',
-          style: AppTextStyle.labelText.copyWith(fontSize: 12),
-          textAlign: TextAlign.center,
+        child: Column(
+          mainAxisSize: MainAxisSize.min,
+          children: [
+            _statusCloseButton(),
+            Text(
+              '┌»╪▓╪º╪▒╪┤█î ╪¿╪▒╪º█î ╪º┘à╪▒┘ê╪▓ ┘à┘ê╪¼┘ê╪» ┘å█î╪│╪¬',
+              style: AppTextStyle.labelText.copyWith(fontSize: 12),
+              textAlign: TextAlign.center,
+            ),
+          ],
         ),
       );
     }
 
     return TodayPaymentReportTooltipContent(
       report: snapshot.data!,
       accountName: widget.accountName,
       accountId: widget.accountId,
       date: widget.date,
       withdrawController: widget.withdrawController,
