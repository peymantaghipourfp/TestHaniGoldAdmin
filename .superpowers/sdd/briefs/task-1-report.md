# Task 1 Report: Disable nested tooltip hover inside the panel

**Status:** DONE_WITH_CONCERNS  
**Date:** 2026-07-12  
**Source brief:** `.superpowers/sdd/briefs/task-1-brief.md`  
**Source plan:** `docs/superpowers/plans/2026-07-12-fix-icon-hover-closes-tooltip.md`

---

## Summary

Wrapped `FloatingPanelShell` in `TooltipVisibility(visible: false)` inside `TodayPaymentReportTooltipContent.build` so nested `IconButton` tooltips no longer steal exclusive hover and dismiss the parent `HoverLazyRichTooltip` panel. Click handlers for pin/close were left untouched. UI smoke validation was not run in this session (documented as smoke-unverified-human).

---

## Step 1 — Expected behavior

| Action | Expected |
| --- | --- |
| Hover pin / close | Outer panel stays open |
| Click close | Panel closes via `forceDeactivate` / `_dismissEntireTooltip` |
| Click pin (when expanded) | Pin toggles; panel stays open |

---

## Step 2 — Failure mode confirmation

Confirmed three nested `IconButton` `tooltip:` declarations inside the payment-report panel tree:

| Location | Tooltip string | Role |
| --- | --- | --- |
| Expanded detail close (~line 271 / after edit still present) | `'بستن'` | Collapse/dismiss expanded detail row close |
| `_Header` pin IconButton | `isPinned ? 'برداشتن سنجاق' : 'سنجاق'` | Pin / unpin outer tooltip |
| `_Header` close IconButton | `'بستن'` | Full panel dismiss |

These nest under `FloatingPanelShell` → `_Header` / expanded `Row`. Flutter `Tooltip` on hover takes exclusive hover, which matches the reported parent-panel dismiss path for `HoverLazyRichTooltip`.

**Unchanged (context only, as specified):**

- `lib/src/widget/hover_lazy_rich_tooltip.widget.dart`
- `lib/src/domain/withdraw/widget/hover_tooltip_today_payment_report.widget.dart`

---

## Step 3 — Fix applied

**File modified:** `lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart`

`build` now returns:

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

- `TooltipVisibility` is provided by `package:flutter/material.dart` (already imported).
- No changes to `_dismissEntireTooltip`, `_onIconTap`, pin retain/release, or `onRequestClose`.
- The three `tooltip:` arguments were **kept** (fallback Step 5 not applied).

---

## Step 4 — Validation

| Check | Result |
| --- | --- |
| Code wrap matches brief | Yes |
| Click handlers untouched | Yes (verified by diff scope: only TooltipVisibility wrapper around existing return) |
| UI hover/click matrix | **smoke-unverified-human** — full Flutter UI not run in this subagent session |

---

## Step 5 — Fallback

Not applied. Prefer TooltipVisibility-only per brief; could not prove TooltipVisibility fails without UI run. If human smoke still sees panel close on icon hover, remove the three `tooltip:` args as optional fallback.

---

## Step 6 — Analyze + graphify

```text
flutter analyze lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart
→ No issues found! (ran in ~7.1s)

graphify update .
→ Rebuilt: 8517 nodes, 15772 edges, 500 communities; graph.json and GRAPH_REPORT.md updated
```

---

## Step 7 — Commit

SKIPPED (no-git workspace / dispatch forbids git write).

---

## Acceptance checklist

- [x] Panel wrapped in `TooltipVisibility(visible: false)`
- [x] Click handlers untouched
- [x] `flutter analyze` clean on touched file
- [x] `graphify update .` run
- [x] Report written to this file
- [ ] Human UI smoke of hover/click matrix (pending)

---

## Self-review

1. **Minimal scope:** Only the outer return wrapper in one widget file; no hover-infra refactor.
2. **Coverage:** Wrapper surrounds entire `FloatingPanelShell`, so all three nested IconButton tooltips are under `TooltipVisibility(visible: false)`.
3. **Risk residual:** Without running the app, cannot confirm exclusive-hover is fully suppressed on desktop Windows/web. Residual concern only; code matches plan intent.
4. **No unrelated edits:** Pin/close `onPressed` / callbacks unchanged; `tooltip:` strings retained.

---

## Concerns

- Smoke validation deferred to human: hover pin/close must keep panel open; click close / pin must still work.
- If TooltipVisibility proves insufficient at runtime, apply Step 5 (strip three `tooltip:` args) without further structural changes.
