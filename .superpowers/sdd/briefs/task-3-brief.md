# Task 3: Manual validation + graphify

**Files:** none new (manual)

## Step 1: Manual scenario (Windows desktop)

Run: `flutter run -d windows` (or existing running app), open withdraws list, hover a cell that shows today payment report.

Validate:
1. Hovering the wallet/receipt icons does **not** expand.
2. Clicking receipt expands withdraw detail; outer panel stays open after mouse leaves the panel.
3. Clicking wallet switches to deposit detail without closing.
4. Close button collapses detail; if pointer is outside the trigger/panel, outer tooltip dismisses shortly after.
5. Re-clicking the active icon collapses; empty sections remain non-clickable.
6. Before any expand, leaving the outer tooltip still closes it on hover (unchanged).

If you cannot interactively drive the Windows UI in this environment, run static checks instead:
- Confirm via code read that hover expand paths are gone and tap/pin/close paths exist
- Run `flutter analyze` on the three touched files from Tasks 1–2
- Document each checklist item as PASS (code-verified) / NEEDS_HUMAN_UI with what a human should click

Do not claim interactive PASS without actual UI exercise.

## Step 2: graphify

Run from project root: `graphify update .`

## Step 3: Commit graphify

**SKIPPED** — no-git mode. Do not commit.

## Report

Write to: d:\curserAi project\.superpowers\sdd\briefs\task-3-report.md
Include validation checklist results and graphify command output summary.
