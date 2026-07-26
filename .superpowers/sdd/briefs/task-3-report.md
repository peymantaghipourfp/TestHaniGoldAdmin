# Task 3 Report: Manual validation + graphify

**Date:** 2026-07-12  
**Mode:** Static-check fallback (interactive Windows UI not available in agent environment)  
**Commits:** none (no-git mode)

---

## Environment

- **Interactive UI:** Not attempted — no `flutter run -d windows` session available for agent-driven hover/click validation.
- **Static checks:** Code review of Tasks 1–2 files + `flutter analyze` on the three touched files.

---

## flutter analyze

```
Analyzing 3 items...
No issues found! (ran in 1.5s)
```

**Files analyzed:**
- `lib/src/widget/hover_tooltip_scope.widget.dart`
- `lib/src/widget/hover_lazy_rich_tooltip.widget.dart`
- `lib/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart`

---

## Validation checklist

| # | Scenario | Result | Evidence |
|---|----------|--------|----------|
| 1 | Hovering wallet/receipt icons does **not** expand | **PASS (code-verified)** | `_MetricChip` `MouseRegion` only toggles `_isIconHovered` for highlight; no expand on enter. Expansion is exclusively via `GestureDetector.onTap` → `_onIconTap`. |
| 1 | *(human confirmation)* | **NEEDS_HUMAN_UI** | Hover receipt/wallet icons in withdraw list today-payment tooltip; detail panel must not open until click. |
| 2 | Click receipt → withdraw detail expands; outer panel stays open after mouse leaves | **PASS (code-verified)** | `_onIconTap(withdraw)` sets `_expandedSection`, calls `_pinOuterTooltip()` → `scope.retain()` + `requestNestedActive(todayPaymentExpanded)`. Parent `HoverLazyRichTooltip` keeps `_isActive` via `_scopeRetained` / `_hasActiveNested`; `_onMessageExit` calls `_keepFlutterTooltipVisibleIfNeeded()` when retained. |
| 2 | *(human confirmation)* | **NEEDS_HUMAN_UI** | Click receipt icon, move mouse off panel; outer tooltip should remain visible with expanded withdraw detail. |
| 3 | Click wallet → deposit detail without closing outer panel | **PASS (code-verified)** | `_onIconTap(deposit)` switches `_expandedSection` in `setState`; `_pinOuterTooltip` is idempotent when already pinned (`_hasPinnedScope` guard). |
| 3 | *(human confirmation)* | **NEEDS_HUMAN_UI** | With withdraw detail open, click wallet icon; should switch to deposit detail without dismissing outer tooltip. |
| 4 | Close collapses detail; pointer outside trigger/panel dismisses outer tooltip shortly after | **PASS (code-verified)** | Close `IconButton` and `_collapse()` call `_unpinOuterTooltip()`; parent uses `_scheduleHide()` with `kHoverTooltipHideDelay` (120 ms) when no retention/nested active. |
| 4 | *(human confirmation)* | **NEEDS_HUMAN_UI** | Close detail, move pointer away from trigger and panel; outer tooltip should dismiss ~120 ms later. |
| 5 | Re-click active icon collapses; empty sections non-clickable | **PASS (code-verified)** | `_onIconTap`: if `section == _expandedSection` → `_collapse()`. Empty sections pass `onIconTap: null` via `isWithdrawSectionEmpty` / `isPledgeSectionEmpty`; cursor stays `basic`. |
| 5 | *(human confirmation)* | **NEEDS_HUMAN_UI** | Re-click active icon to collapse; verify empty-section rows have no click cursor and no tap response. |
| 6 | Before expand, leaving outer tooltip still closes on hover (unchanged) | **PASS (code-verified)** | When `_hasPinnedScope` is false, parent `HoverLazyRichTooltip` `_deactivateIfIdle` / `_onTargetExit` / `_onMessageExit` paths schedule hide without retention bypass. |
| 6 | *(human confirmation)* | **NEEDS_HUMAN_UI** | Open tooltip without clicking icons; move mouse away; tooltip should close as before. |

---

## Code paths verified (pin-on-expand)

| Mechanism | Location |
|-----------|----------|
| Scope retention API | `HoverTooltipScopeState.retain()` / `release()` / `requestNestedActive()` |
| Nested id for expanded panel | `HoverTooltipNestedIds.todayPaymentExpanded` |
| Pin on icon tap | `_pinOuterTooltip()` in `today_payment_report_tooltip_content.widget.dart` |
| Unpin on collapse / dispose | `_unpinOuterTooltip()` |
| Parent stays open while pinned | `_scopeRetained`, `_hasActiveNested` in `hover_lazy_rich_tooltip.widget.dart` |
| Hover-expand removed | No `onEnter` → expand wiring; icons use tap-only `_onIconTap` |

---

## graphify update

**Command:** `graphify update .` (from project root)

**Output summary:**
```
Re-extracting code files in . (no LLM needed)...
  AST extraction: 711/711 files (100%)
[graphify watch] Skipped graph.html: Graph has 8500 nodes - too large for HTML viz (limit: 5000).
[graphify watch] Rebuilt: 8500 nodes, 15756 edges, 497 communities
[graphify watch] graph.json and GRAPH_REPORT.md updated in graphify-out
Code graph updated.
```

**Result:** Success (exit code 0). `graphify-out/graph.json` and `graphify-out/GRAPH_REPORT.md` updated. HTML viz skipped due to node count (8500 > 5000 limit) — expected, non-blocking.

---

## Overall status

**DONE_WITH_CONCERNS**

- Static analysis and code review support all six scenarios; no analyzer issues.
- All interactive behaviors marked **NEEDS_HUMAN_UI** — agent could not drive Windows desktop UI.
- graphify update completed successfully.

---

## Recommended human smoke test (Windows)

1. `flutter run -d windows`
2. Navigate to withdraws list; hover a cell with today payment report tooltip.
3. Run through checklist items 1–6 above.
4. Report any mismatch between observed behavior and code-verified expectations.
