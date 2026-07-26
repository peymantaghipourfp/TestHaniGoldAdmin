# Task 2: Click-to-expand + pin/unpin in payment report content

**Files:**
- Modify: `lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart`

**Interfaces:**
- Consumes: `HoverTooltipScope.maybeOf`, `HoverTooltipNestedIds.todayPaymentExpanded`, existing `loadTodayWithdrawRequestReport` / `loadTodayDepositRequestReport`
- Produces: `_onIconTap(_ExpandedSection)`, `_collapse()` releases scope; expanded UI stays until explicit close

**Prerequisite (already done in Task 1):** `HoverTooltipNestedIds.todayPaymentExpanded = 'today-payment-expanded'` exists; parent `HoverLazyRichTooltip` schedules idle hide when pin releases.

## Step 1: Replace hover state machine with tap + pin

Remove `_isHoveringExpanded`, `_showTimer`, `_hideTimer`, `_onIconHoverStart`, `_onIconHoverEnd`, `_scheduleCollapse`.

Add scope pin helpers and tap handler (immediate expand, no `kNestedPanelShowDelay`):

```dart
bool _hasPinnedScope = false;
HoverTooltipScopeState? _scope;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _scope = HoverTooltipScope.maybeOf(context);
}

void _pinOuterTooltip() {
  final scope = _scope;
  if (scope == null || _hasPinnedScope) return;
  _hasPinnedScope = true;
  scope.requestNestedActive(
    HoverTooltipNestedIds.todayPaymentExpanded,
    _collapse,
  );
  scope.retain();
}

void _unpinOuterTooltip({bool fromDispose = false}) {
  if (!_hasPinnedScope) return;
  final scope = _scope;
  _hasPinnedScope = false;
  if (scope == null) return;
  if (fromDispose) {
    scope.releaseFromDispose();
    scope.clearNestedActiveFromDispose(
      HoverTooltipNestedIds.todayPaymentExpanded,
    );
    return;
  }
  if (scope.mounted) {
    scope.release();
    scope.clearNestedActive(HoverTooltipNestedIds.todayPaymentExpanded);
  } else {
    scope.releaseFromDispose();
    scope.clearNestedActiveFromDispose(
      HoverTooltipNestedIds.todayPaymentExpanded,
    );
  }
}

void _onIconTap(_ExpandedSection section) {
  if (_expandedSection == section) {
    _collapse();
    return;
  }
  setState(() {
    _expandedSection = section;
    if (section == _ExpandedSection.withdraw) {
      _withdrawFuture ??= widget.withdrawController
          .loadTodayWithdrawRequestReport(widget.accountId, date: widget.date);
    } else if (section == _ExpandedSection.deposit) {
      _depositFuture ??= widget.withdrawController
          .loadTodayDepositRequestReport(widget.accountId, date: widget.date);
    }
  });
  _pinOuterTooltip();
}

void _collapse() {
  if (_expandedSection == _ExpandedSection.none && !_hasPinnedScope) return;
  setState(() {
    _expandedSection = _ExpandedSection.none;
    _withdrawFuture = null;
    _depositFuture = null;
  });
  _unpinOuterTooltip();
  // existing cache clears stay as today
  widget.withdrawController.clearTodayWithdrawRequestReportCache(
    widget.accountId,
    widget.date,
  );
  widget.withdrawController.clearTodayDepositRequestReportCache(
    widget.accountId,
    widget.date,
  );
}
```

Update `dispose` to cancel nothing timer-related; call `_unpinOuterTooltip(fromDispose: true)` then existing cache clears.

## Step 2: Wire sections + remove expanded MouseRegion auto-collapse

Pass `onIconTap` / `isIconActive` instead of hover callbacks:

```dart
final withdrawSection = _WithdrawTodayPaymentSection(
  report: widget.report,
  isIconActive: _expandedSection == _ExpandedSection.withdraw,
  onIconTap: isWithdrawSectionEmpty(widget.report)
      ? null
      : () => _onIconTap(_ExpandedSection.withdraw),
);
// pledge analog with _ExpandedSection.deposit
```

Replace the expanded `MouseRegion(onEnter/onExit → scheduleCollapse)` with a plain `Column` plus a close row:

```dart
child: _expandedSection == _ExpandedSection.none
    ? const SizedBox.shrink()
    : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColor.textColor.withValues(alpha: 0.12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _expandedSection == _ExpandedSection.withdraw
                      ? 'جزئیات درخواست برداشت'
                      : 'جزئیات تعهد پرداخت',
                  style: AppTextStyle.labelText.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'بستن',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: _collapse,
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
```

## Step 3: Convert `_MetricChip` to tap + active visual

Rename props to `onIconTap` and `isIconActive`. Remove `onIconHoverStart` / `onIconHoverEnd` and the hover enter/exit that called them. Keep a light local hover highlight for affordance only (optional), but **do not** open/close expansion from hover.

Wrap the icon chip:

```dart
final iconChip = MouseRegion(
  cursor: widget.onIconTap != null
      ? SystemMouseCursors.click
      : SystemMouseCursors.basic,
  child: GestureDetector(
    onTap: widget.onIconTap,
    child: AnimatedContainer(
      // use isIconActive OR local hover for alpha/border
      ...
    ),
  ),
);
```

Propagate prop renames through `_WithdrawTodayPaymentSection` and `_PledgeTodayPaymentSection`.

## Step 4: Remove unused imports

Drop `dart:async` if no timers remain. Keep `hover_nested_panel` import only if still needed for constants; if `kNestedPanelShowDelay` / hide delay unused, remove that import. Keep `kHoverPanelAnimationDuration` from `hover_floating_panel.widget.dart`.

## Step 5: Analyze

Run: `flutter analyze lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart`

Expected: clean (or only pre-existing warnings unrelated to this change).

## Step 6: Commit

**SKIPPED** — no-git mode. Do not commit.

## Locked UX assumptions

- Empty sections keep icons non-interactive (`onIconTap == null`), same as today.
- Switching withdraw ↔ deposit while open does **not** collapse; it swaps content and reuses one scope nested id.
- Close control is an `Icons.close_rounded` button in the expanded detail chrome (above the detail body).
- Visual “active” state on the icon while that section is expanded (border/background), not hover-to-open.

## Global Constraints (binding)

- Do not change repository/API contracts or cache key behavior beyond existing `_collapse` cache clears.
- Match existing RTL Persian UI; use `AppColor` / `AppTextStyle` only (no hard-coded colors).
- Prefer package imports; keep private widgets private (`_MetricChip`, etc.).
- YAGNI: no new state-management library; no refactor of unrelated hover tooltips.
- Do not run `graphify update .` in this task (Task 3 owns it).
