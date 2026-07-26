# Task 1 Brief: Disable nested tooltip hover inside the panel

**Source plan:** docs/superpowers/plans/2026-07-12-fix-icon-hover-closes-tooltip.md

**Goal:** Keep the today-payment hover panel open when the cursor moves over pin/close icons; dismiss/collapse only on click.

## Global Constraints

- Follow existing GetX / hover-panel patterns; no new state-management library.
- Minimum necessary change; do not refactor unrelated hover infrastructure.
- RTL / Persian UI preserved; pin/close click handlers unchanged.
- Do not hand-edit `*.g.dart` or bump dependencies.
- After code edits: `graphify update .`
- **No git commits** (no-git workspace). Do not run git commit --trailer "Co-authored-by: Cursor <cursoragent@cursor.com>" / git add.
- Persist plan already done at docs/superpowers/plans/2026-07-12-fix-icon-hover-closes-tooltip.md

## Root cause

Nested Flutter Tooltips on pin/close IconButtons steal exclusive hover and immediately dismiss the parent HoverLazyRichTooltip panel. Wrap the payment-report panel in TooltipVisibility(visible: false) so icons only act on click.

## Files

- Modify: `lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart` (`build` return ~177–306)
- Unchanged (context only): `lib/src/widget/hover_lazy_rich_tooltip.widget.dart`, `lib/src/domain/withdraw/widget/hover_tooltip_today_payment_report.widget.dart`
- Optional fallback in same file: remove the three `tooltip:` strings if TooltipVisibility alone is insufficient

## Steps

### Step 1: Document expected behavior (in report)

| Action | Expected |
| --- | --- |
| Hover pin / close | Outer panel stays open |
| Click close | Panel closes via `forceDeactivate` |
| Click pin (when expanded) | Pin toggles; panel stays open |

### Step 2: Confirm failure mode in code

In `_TodayPaymentReportTooltipContentState.build`, three IconButtons declare nested `tooltip:` (e.g. `'بستن'`, pin strings). Confirm they match exclusive-hover dismiss path.

### Step 3: Apply minimal fix

Wrap the existing `FloatingPanelShell` return in `TooltipVisibility(visible: false)`:

```dart
return TooltipVisibility(
  visible: false,
  child: FloatingPanelShell(
    width: _kTooltipWidth,
    child: Column(
      // ... existing children unchanged ...
    ),
  ),
);
```

Do not change `_dismissEntireTooltip`, `_onIconTap`, pin retain/release, or `onRequestClose`.

### Step 4: Validate

If you can run the app, validate hover/click matrix. If you cannot run UI, document that in the report as smoke-unverified-human and still complete code + analyze.

### Step 5: Fallback only if Step 4 fails

If panel still closes on icon hover after TooltipVisibility, remove the three `tooltip:` arguments from IconButtons. Re-validate.

### Step 6: Analyze + graphify

```bash
flutter analyze lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart
graphify update .
```

### Step 7: Commit — SKIP (no-git / user did not ask)

## Acceptance

- Panel wrapped in TooltipVisibility(visible: false)
- Click handlers untouched
- flutter analyze clean on touched file
- graphify update run
- Report written to report file path given in dispatch
