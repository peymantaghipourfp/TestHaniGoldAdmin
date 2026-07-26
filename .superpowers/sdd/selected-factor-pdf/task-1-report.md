# Task 1 Report — Repository: `getOneInventory` + `getSelectedFactorPdf`

**Status:** DONE_WITH_CONCERNS  
**Date:** 2026-07-13  
**Commit:** Skipped (no `.git` in workspace; NO-GIT adaptation applied)

---

## What was implemented

1. **`InventoryRepository.getOneInventory`**
   - Placed after `getFactorPdf` (before class closing `}`).
   - `GET Inventory/getOne` with `queryParameters: {'id': id}`.
   - Returns `InventoryModel.fromJson(response.data)`.
   - Error handling matches existing pattern: `AppLogger.e` + `ErrorException(ErrorHandler.handle(e))`.

2. **`UserInfoTransactionRepository.getSelectedFactorPdf`**
   - Placed at end of class (before closing `}`).
   - `GET Inventory/getSelectedFactorPdf` with bytes response type.
   - Query map (inlined, same shape as test helper):
     - `id`, `showBalance`, `showHaniGold`, `InventoryDetailIds`
   - Returns `Uint8List.fromList(response.data)`.
   - Error handling matches `getGoldPdf` / `getFactorPdf` style.

3. **Query-shape unit test**
   - `test/selected_factor_pdf_query_test.dart` with `buildSelectedFactorPdfQuery` helper living only in the test file (per brief; not shared into lib).

---

## What was tested and results

| Check | Command | Result |
| --- | --- | --- |
| Query test (RED) | `flutter test test/selected_factor_pdf_query_test.dart` (before file existed) | **FAIL** — file does not exist |
| Query test (GREEN) | `flutter test test/selected_factor_pdf_query_test.dart` (after adding file) | **PASS** — `+1: All tests passed!` |
| Analyze | `dart analyze lib/src/config/repository/inventory.repository.dart lib/src/config/repository/user_info_transaction.repository.dart` | Exit code 2 — **5 pre-existing** warnings/infos only; **none** in new methods |

---

## TDD Evidence (RED then GREEN)

1. **RED:** Ran `flutter test test/selected_factor_pdf_query_test.dart` before creating the file → `Failed to load ... Does not exist.`
2. **GREEN:** Added the test file with the helper verbatim from the brief → `All tests passed!`
3. Repository methods were then added to match the verified query shape and existing Dio/bytes patterns (`getFactorPdf`, `getGoldPdf`).

---

## Files changed

| File | Change |
| --- | --- |
| `lib/src/config/repository/inventory.repository.dart` | Added `getOneInventory` |
| `lib/src/config/repository/user_info_transaction.repository.dart` | Added `getSelectedFactorPdf` |
| `test/selected_factor_pdf_query_test.dart` | **New** — query payload shape test + helper |
| `graphify-out/` | Updated via `graphify update .` after code changes |

---

## Self-review findings

- Method signatures match the brief exactly (named params, `showHaniGold` default `false`).
- Placement matches brief: `getOneInventory` after `getFactorPdf`; `getSelectedFactorPdf` at end of `UserInfoTransactionRepository`.
- Query key casing `InventoryDetailIds` preserved (critical for API contract); covered by unit test.
- Bytes PDF path uses `Options(responseType: ResponseType.bytes)` and `Uint8List.fromList` like siblings.
- No shared lib extracted for the query helper (brief said test-only helper is fine).
- No new analyze issues introduced by the added methods.
- Imports already present (`InventoryModel`, `Uint8List` / `dart:typed_data`, `ErrorException`, `ErrorHandler`, `AppLogger`, `Options`).

---

## Issues / concerns

1. **`dart analyze` exit code 2** — Expected “no issues” in the brief, but the two repository files already have unrelated warnings/infos (e.g. `unnecessary_null_comparison` at UIT repo L147; `unnecessary_null_in_if_null_operators` in inventory L954/L1019). **Not introduced by this task**; left untouched to avoid scope creep.
2. **Query helper duplication** — Test helper and repository inline the same map. Acceptable per brief; later tasks may want a shared helper if drift becomes a risk.
3. **Commit skipped** — Workspace has no `.git`; Step 6 intentionally omitted. Do not run `git init`.

---

## Note on commit

**Commit was skipped (no git).**
