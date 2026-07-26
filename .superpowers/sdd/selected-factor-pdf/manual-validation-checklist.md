# Manual Validation Checklist — Selected Factor PDF

**Status:** PENDING_HUMAN  
**Feature:** Selected Factor PDF (Tasks 1–4)  
**Date prepared:** 2026-07-13  
**Workspace:** `D:\curserAi project`

Automated UI/PDF E2E is not available in this repo’s sparse test suite. Complete the steps below on a local run (Windows desktop preferred).

---

## Prerequisites

- [ ] App builds and runs (`flutter run -d windows` or equivalent)
- [ ] Logged in with an account that can open user transaction detail
- [ ] Test data available: at least one `receive` or `payment` transaction with **multiple** inventory details
- [ ] At least one non-inventory transaction row for regression check

---

## Checklist

### 1. Inventory row — open detail picker

- [ ] Open user transaction detail for a user that has `receive` / `payment` inventory rows
- [ ] Locate a row with multiple inventory details
- [ ] Confirm invoice action buttons are visible («فاکتور با مانده» / «فاکتور»)

### 2. «فاکتور با مانده» → PDF with balance

- [ ] Click **«فاکتور با مانده»**
- [ ] Dialog lists inventory details for that factor
- [ ] Select **≥1** detail row(s)
- [ ] Click **صدور** (or equivalent confirm)
- [ ] PDF downloads / shares successfully
- [ ] Network request includes `showBalance=true` and `InventoryDetailIds` (DevTools / proxy / logs)

### 3. «فاکتور» → PDF without balance

- [ ] Click **«فاکتور»** on the same (or another) inventory row
- [ ] Dialog lists details → select ≥1 → صدور
- [ ] PDF downloads / shares successfully
- [ ] Network request includes `showBalance=false` and `InventoryDetailIds`

### 4. Cancel / empty selection

- [ ] Open dialog via either button → **Cancel / dismiss** → no PDF API call
- [ ] Open dialog → select **none** → confirm → no PDF call (or empty-selection snackbar shown)

### 5. Non-inventory row — legacy path

- [ ] On a non-`receive` / non-`payment` row, click «فاکتور» / «فاکتور با مانده»
- [ ] Confirm **old client invoice** path still runs (no selected-factor detail dialog)

### 6. Desktop + mobile (if applicable)

- [ ] Repeat steps 2–3 on **desktop** layout
- [ ] Repeat steps 2–3 on **mobile** / narrow layout (both invoice buttons)

---

## Sign-off

| Field | Value |
| --- | --- |
| Tester | _PENDING_HUMAN_ |
| Date tested | _PENDING_HUMAN_ |
| Result | _PENDING_HUMAN_ (PASS / FAIL) |
| Notes | |

**Overall:** PENDING_HUMAN — automated test/analyze passed; human UI/PDF verification not yet performed.
