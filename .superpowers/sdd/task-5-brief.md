### Task 5: 7-column data table + desktop body

**Files:** `user_balance_data_table.widget.dart`, `user_balance_desktop_body.widget.dart`

- [ ] **Step 1:** `UserBalanceDataTable` — 7 `DataColumn`s, `dataRowMaxHeight: double.infinity`, zebra rows, `sortColumnIndex`/`sortAscending` from controller
- [ ] **Step 2:** Each `DataRow` has 7 `DataCell`s; asset cells = `Column(crossAxisAlignment: center, children: [creditSection, SizedBox(4), debitSection])`
- [ ] **Step 3:** `UserBalanceDesktopBody` — vertical `Column`: `StatsGrid` → `Toolbar` → `DataTable` (NO horizontal `SingleChildScrollView`) → `Footer` placeholder or skip footer until Task 6
- [ ] **Step 4:** Commit `feat(users): add 7-column grouped data table`

**Validate:** Column count == 7; NO outer horizontal scroll; sort indices 2–11 via grouped headers.

**Use widgets from Tasks 1-4.** Footer widget comes in Task 6 — desktop body can omit footer or accept optional footer slot.

**Do NOT thin main view yet (Task 6).**
