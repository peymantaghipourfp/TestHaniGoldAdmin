# Task 2 Report: Click-to-expand + pin/unpin in payment report content

**Status:** DONE  
**Date:** 2026-07-12  
**File modified:** `lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart`  
**Commits:** none (no-git mode)

---

## Summary

Replaced hover-timer expansion with click-to-expand and scope pin/unpin so the today-payment tooltip panel stays open while inline withdraw/deposit details are expanded. Users tap metric icons to expand, tap again or use the close button to collapse; switching sections swaps content without collapsing.

---

## Steps Completed

### Step 1: Replace hover state machine with tap + pin

**Removed:**
- `_isHoveringExpanded`, `_showTimer`, `_hideTimer`
- `_onIconHoverStart`, `_onIconHoverEnd`, `_scheduleCollapse`

**Added:**
- `_hasPinnedScope`, `_scope` state fields
- `didChangeDependencies()` — caches `HoverTooltipScope.maybeOf(context)`
- `_pinOuterTooltip()` — `requestNestedActive(HoverTooltipNestedIds.todayPaymentExpanded, _collapse)` + `retain()`
- `_unpinOuterTooltip({fromDispose})` — release/clear nested id with mounted vs dispose paths
- `_onIconTap(_ExpandedSection)` — immediate expand (no delay), toggle collapse on same section, lazy-load futures
- Updated `_collapse()` — early return when already collapsed and unpinned; calls `_unpinOuterTooltip()` before cache clears

**dispose:** Removed timer cancels; calls `_unpinOuterTooltip(fromDispose: true)` then existing cache clears.

### Step 2: Wire sections + remove expanded MouseRegion auto-collapse

- `_WithdrawTodayPaymentSection` / `_PledgeTodayPaymentSection` now receive `isIconActive` and `onIconTap` (null when section empty).
- Expanded area is a plain `Column` with title row (`جزئیات درخواست برداشت` / `جزئیات تعهد پرداخت`) and `IconButton` close (`tooltip: 'بستن'`, `Icons.close_rounded`).
- Removed `MouseRegion` hover enter/exit that scheduled auto-collapse.

### Step 3: Convert `_MetricChip` to tap + active visual

- Props renamed: `onIconTap`, `isIconActive` (replacing hover start/end).
- Icon chip: `MouseRegion` (local hover affordance only) → `GestureDetector(onTap)` → `AnimatedContainer`.
- Highlight uses `isIconActive || _isIconHovered` for alpha/border — active state persists while expanded; hover is visual only.

### Step 4: Remove unused imports

- Removed `dart:async` (no timers).
- Removed `hover_nested_panel.widget.dart` (`kNestedPanelShowDelay` / `kNestedPanelHideDelay` unused).
- Added `hover_tooltip_scope.widget.dart`.
- Kept `hover_floating_panel.widget.dart` for `kHoverPanelAnimationDuration` and `FloatingPanelShell`.

### Step 5: Analyze

```
flutter analyze lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart
```

**Result:** No issues found.

### Step 6: Commit

Skipped per no-git mode.

---

## Self-Review

| Requirement | Met? | Notes |
|-------------|------|-------|
| Tap icon expands immediately | Yes | No `kNestedPanelShowDelay` |
| Tap same icon collapses | Yes | `_onIconTap` early return → `_collapse()` |
| Switch withdraw ↔ deposit without collapse | Yes | `_onIconTap` swaps section; `_pinOuterTooltip` no-ops if already pinned |
| Close button collapses | Yes | `IconButton(onPressed: _collapse)` |
| Empty sections non-interactive | Yes | `onIconTap: null` when section empty |
| Scope pin on expand | Yes | `todayPaymentExpanded` nested id + `retain()` |
| Scope unpin on collapse/dispose | Yes | `_unpinOuterTooltip` with dispose-safe paths |
| Active icon visual while expanded | Yes | `isIconActive` propagated to `_MetricChip` |
| Hover does not open/close | Yes | Local `_isIconHovered` only affects highlight |
| Cache clears on collapse | Yes | Unchanged behavior preserved |
| Task 1 files untouched | Yes | Only consumed existing APIs |
| AppColor / AppTextStyle only | Yes | No new hard-coded colors |

**Edge cases considered:**
- `_collapse` guard handles pinned-but-collapsed state after external dismiss via scope callback.
- `_pinOuterTooltip` idempotent when switching sections (already pinned).
- `dispose` uses `fromDispose: true` to avoid `setState` on unmounted scope.

**Not manually tested:** Runtime hover-tooltip interaction with parent `HoverLazyRichTooltip` idle-hide (Task 1). Recommend manual QA: expand detail, move pointer away from tooltip, verify parent stays open until close; unpin should allow parent idle hide.

---

## Concerns

None blocking. Runtime integration with parent tooltip retention depends on Task 1 `HoverLazyRichTooltip` behavior — not verified in this task (analyze-only verification).

---

## Files Changed

| File | Action |
|------|--------|
| `lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart` | Modified |
