# Task 3 Report — Extract mobile list + thin the view

**Status:** DONE  
**Branch:** `feat/gold-tx-fit-table`  
**Commit:** `92d6c3d` — `refactor(users): extract gold transaction mobile list`

## What was implemented

### Created

| File | Responsibility |
| --- | --- |
| `lib/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_mobile_list.widget.dart` | `GoldTransactionMobileList` — empty state, cards `ListView`, infinite-scroll footer (`Obx` loading / “همه تراکنش‌ها”), type chip + type-branched detail helpers |

### Modified

| File | Change |
| --- | --- |
| `user_info_gold_transaction.view.dart` | Mobile path → `GoldTransactionMobileList(controller: controller)`; removed `_buildMobileTransactionCards` + helpers (~870 lines); cleaned unused imports (`rendering`, `services`, `shamsi_date`, `chat_dialog`, `num_display`, filter) |
| `user_info_detail_gold_transaction.controller.dart` | Removed unused desktop `ScrollController scrollController` (never attached; `scrollControllerMobile` infinite-scroll untouched) |

### Toolbar reuse

Inline mobile filter / clear-checkboxes `Row` replaced with `GoldTransactionToolbar(controller: controller)` inside `GoldTransactionMobileList` (same widget as desktop body).

### View thinned — confirmed absent

- `buildDataColumns` — gone (already removed in Task 2)
- `buildDataRows` — gone (already removed in Task 2)
- `_buildMobileTransactionCards` — removed this task

Mobile cards still show separate debit/credit/balance rows (no grouping requirement).

## Verification

| Command | Result |
| --- | --- |
| `flutter test test/gold_transaction_data_table_layout_test.dart` | **PASS** (+5) |
| `flutter analyze` on mobile list + view | **12 info** only (`withOpacity` deprecations + pre-existing view style infos); **no errors/warnings** on touched extraction |
| Chrome smoke | Skipped (no browser device / not blocking) |
| `graphify update .` | Ran; graph rebuilt (not included in this commit — Task 4 owns packaging) |

## Self-review

| Check | Result |
| --- | --- |
| Mobile UI extracted to `GoldTransactionMobileList` | Pass |
| `GoldTransactionToolbar` reused on mobile | Pass |
| View free of desktop/mobile table builders named above | Pass |
| `scrollControllerMobile` infinite-scroll preserved | Pass |
| Desktop `scrollController` removed only because unused | Pass |
| `AppColor` / `AppTextStyle` / package imports / GetX | Pass |
| Cards not grouped (debit/credit separate) | Pass (intentional) |

## Concerns / carry-forward

1. **Empty state has no toolbar:** Early-return empty UI still omits `GoldTransactionToolbar` (same as monolith). Users who filter to empty cannot clear filters from the cards panel alone — consider showing toolbar above empty next pass.
2. **`withOpacity` deprecations:** Ported as-is; not converted to `withValues` in this extraction.
3. **Commented `_showImageGallery`:** Still in the view (~190 lines of dead commented code); left untouched (out of brief scope).
4. **Controller pre-existing warnings:** `unnecessary_null_comparison` / `avoid_print` in detail gold controller unchanged.
5. **Chrome smoke:** Not run; manual mobile infinite-scroll + toolbar dialog check recommended in Task 4/QA.
