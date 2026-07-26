# Review package - Task 4 (no git)
Base: after Task 3 (widgets missing date)
Head: working tree after Task 4
Commits: none (no git)

## Stat
 modify hover_tooltip_today_payment_report.widget.dart
 modify today_payment_report_tooltip_content.widget.dart
 modify hover_tooltip_withdraw_request_report.widget.dart
 modify hover_tooltip_deposit_request_report.widget.dart
 modify withdraws_list.view.dart (2 call sites + import)
 modify test/today_payment_report_tooltip_test.dart
 graphify update run

## Key evidence (grep-verified)

### List wiring
```
withdraws_list.view.dart:6156 date: formatRequestDateForApi(withdraw.requestDate),
withdraws_list.view.dart:7328 date: formatRequestDateForApi(withdraw.requestDate),
```

### Tooltip widgets
All four widgets add `required this.date` / `final String date` and pass `date: widget.date` to loadToday*/clearToday*/accessors.

### Test
_ExpandingWithdrawController.loadTodayWithdrawRequestReport includes required String date;
TodayPaymentReportTooltipContent constructions pass date: '2026-07-08'.

## Implementer validation claims
- flutter test: 9/9 passed
- dart analyze on touched paths: no errors (58 pre-existing warnings)
- graphify update: success
