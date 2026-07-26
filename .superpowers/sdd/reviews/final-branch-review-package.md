# Review Package - Task 1 (no-git working tree)

**Base:** pre-task (FloatingPanelShell as direct return)
**Head:** post-task (TooltipVisibility wrap)
**Changed file:** lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart

## Commit list
(none — no-git workspace)

## Stat summary
 today_payment_report_tooltip_content.widget.dart | ~+3/-1 (TooltipVisibility wrap around FloatingPanelShell)

## Conceptual diff

```diff
@@@ build return
-    return FloatingPanelShell(
+    return TooltipVisibility(
+      visible: false,
+      child: FloatingPanelShell(
         width: _kTooltipWidth,
         child: Column(
           ...
         ),
-    );
+      ),
+    );
```

## Post-change build() region (lines ~170–310)

  @override
  Widget build(BuildContext context) {
    final displayName = widget.accountName.length > 36
        ? '${widget.accountName.substring(0, 36)}...'
        : widget.accountName;
    final reportDatePersian = widget.report.reportDatePersian.toString();

    return TooltipVisibility(
      visible: false,
      child: FloatingPanelShell(
        width: _kTooltipWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              displayName: displayName,
              reportDatePersian: reportDatePersian,
              showPin: _expandedSection != _ExpandedSection.none,
              isPinned: _hasPinnedScope,
              onTogglePin: _expandedSection == _ExpandedSection.none
                  ? null
                  : () {
                      if (_hasPinnedScope) {
                        _unpinOuterTooltip();
                        setState(() {});
                      } else {
                        _pinOuterTooltip();
                        setState(() {});
                      }
                    },
              onClose: _dismissEntireTooltip,
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth > 360;
                final withdrawSection = _WithdrawTodayPaymentSection(
                  report: widget.report,
                  isIconActive: _expandedSection == _ExpandedSection.withdraw,
                  onIconTap: isWithdrawSectionEmpty(widget.report)
                      ? null
                      : () => _onIconTap(_ExpandedSection.withdraw),
                );
                final pledgeSection = _PledgeTodayPaymentSection(
                  report: widget.report,
                  isIconActive: _expandedSection == _ExpandedSection.deposit,
                  onIconTap: isPledgeSectionEmpty(widget.report)
                      ? null
                      : () => _onIconTap(_ExpandedSection.deposit),
                );

                if (useTwoColumns) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: withdrawSection),
                      const SizedBox(width: _kSectionGap),
                      Expanded(child: pledgeSection),
                    ],
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    withdrawSection,
                    const SizedBox(height: _kSectionGap),
                    pledgeSection,
                  ],
                );
              },
            ),
            AnimatedSize(
              duration: kHoverPanelAnimationDuration,
              curve: Curves.easeOutCubic,
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.topCenter,
              child: _expandedSection == _ExpandedSection.none
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: AppColor.textColor.withValues(alpha: 0.12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _expandedSection == _ExpandedSection.withdraw
                                    ? 'Ø¬Ø²Ø¦ÛŒØ§Øª Ø¯Ø±Ø®ÙˆØ§Ø³Øª Ø¨Ø±Ø¯Ø§Ø´Øª'
                                    : 'Ø¬Ø²Ø¦ÛŒØ§Øª ØªØ¹Ù‡Ø¯ Ù¾Ø±Ø¯Ø§Ø®Øª',
                                style: AppTextStyle.labelText.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Ø¨Ø³ØªÙ†',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              onPressed: _dismissEntireTooltip,
                              icon: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AppColor.textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: _kExpandedDetailHeight,
                          child: _buildExpandedDetail(),
                        ),
                      ],
                    ),
            ),
            if (_hasFooterMetrics(widget.report)) ...[
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: AppColor.textColor.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 10),
              _FooterMetrics(report: widget.report),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetail() {
    return switch (_expandedSection) {
      _ExpandedSection.withdraw => _buildWithdrawDetail(),

## Confirmed still present: tooltip: on IconButtons
Search hits for tooltip: in this file remain (fallback NOT applied).


## Minor findings from Task 1 (for final triage)
- Review-package mojibake only (not live code)
- Human UI smoke still pending

