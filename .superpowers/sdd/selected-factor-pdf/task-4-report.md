# Task 4 Report — Wire view buttons (desktop + mobile)

**Status:** DONE  
**Date:** 2026-07-13  
**Commit:** Skipped (no `.git` in workspace; NO-GIT adaptation applied)

---

## What was implemented

1. **`_onIssueInvoicePressed` helper on `_UserInfoTransactionViewState`**
   - Non-inventory types (`type` not `receive`/`payment`) keep prior behavior via `generateInvoiceForTransaction` / `generateInvoiceForTransactionWithoutBalance`
   - Inventory types: resolve `inventoryId` from `recordId ?? id`, fetch via `fetchInventoryForSelectedFactor`, show `SelectedFactorDetailDialog`, then `issueSelectedFactorPdf`
   - Snackbars use `titleText`/`messageText` with `AppColor.textColor` + centered `Text` (same pattern as controller)
   - Added `if (!mounted) return` before using `context` after the async fetch (lint-safe)

2. **Four button handlers replaced**
   - Desktop «فاکتور با مانده» → `_onIssueInvoicePressed(trans, showBalance: true)`
   - Desktop «فاکتور» → `_onIssueInvoicePressed(trans, showBalance: false)`
   - Mobile «فاکتور» → `_onIssueInvoicePressed(trans, showBalance: false)`
   - Mobile «فاکتور با مانده» → `_onIssueInvoicePressed(trans, showBalance: true)`

3. **Imports**
   - `../model/transaction_info_item.model.dart`
   - `../widgets/selected_factor_detail_dialog.widget.dart`

4. **Out of scope (honored)**
   - Did **not** modify `user_info_gold_transaction.view.dart`

---

## What was tested and results

| Check | Command | Result |
| --- | --- | --- |
| Analyze | `dart analyze lib/src/domain/users/view/user_info_transaction.view.dart` | Exit code 2 — **27 pre-existing** warnings/infos only; **no new issues** from this change (helper + four call sites clean) |

---

## Files changed

| File | Change |
| --- | --- |
| `lib/src/domain/users/view/user_info_transaction.view.dart` | Helper + four invoice handlers + imports |
| `graphify-out/` | Updated via `graphify update .` after code changes |

---

## Self-review findings

- Helper matches brief flow: inventory gate → id check → fetch → empty details snackbar → dialog → issue PDF.
- All four specified call sites updated; no leftover direct `generateInvoiceForTransaction*` on those buttons.
- Snackbar copy matches brief («شناسه فاکتور موجود نیست», «ردیفی برای صدور فاکتور یافت نشد»).
- Consumes Task 2 controller APIs and Task 3 dialog only.
- Gold transaction view untouched.

---

## Issues / concerns

1. **`dart analyze` exit code 2** — Pre-existing unused/unnecessary imports, `withOpacity` deprecations, other `use_build_context_synchronously` infos elsewhere in the file. Brief said ignore these; left untouched.
2. **Commit skipped** — Workspace has no `.git`; Step 4 intentionally omitted. Do not run `git init`.
3. **Minor deviation from brief snippet** — Added `if (!mounted) return` before `SelectedFactorDetailDialog.show` to clear the new async-gap lint on `context`. Behavior unchanged when the widget is still mounted.

---

## Note on commit

**Commit was skipped (no git).**

---

## Final-review fix

**Finding:** Double snackbar on `getOneInventory` failure — `fetchInventoryForSelectedFactor` already snacks and returns `null`; the view then treated empty details and showed «ردیفی برای صدور فاکتور یافت نشد» again.

**What changed** (`lib/src/domain/users/view/user_info_transaction.view.dart`, `_onIssueInvoicePressed`):
1. Early-return when `inventory == null` (fetch already reported the error).
2. Empty snackbar only when inventory loaded but details are empty (or all filtered out).
3. Minor: apply the same dialog filter (`id != null && isDeleted != true`) before the empty check so an all-invalid list snacks instead of opening an empty dialog.
4. Use `inventory.type` (non-null-aware) after the null guard.

**Commands run / output:**

| Check | Command | Result |
| --- | --- | --- |
| Test | `flutter test test/selected_factor_pdf_query_test.dart` | Exit 0 — `+1: All tests passed!` |
| Analyze | `dart analyze lib/src/domain/users/view/user_info_transaction.view.dart` | Exit 2 — pre-existing warnings/infos only; the new `invalid_null_aware_operator` from this fix was corrected |

**Out of scope:** Gold transaction view untouched. No commit (NO-GIT).
