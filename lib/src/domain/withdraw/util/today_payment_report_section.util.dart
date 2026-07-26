import 'package:hanigold_admin/src/domain/withdraw/model/today_payment_report.model.dart';

bool isWithdrawSectionEmpty(TodayPaymentReportModel report) {
  return (report.withdrawRequestCount ?? 0) == 0 &&
      (report.withdrawRequestAmount ?? 0) == 0;
}

bool isPledgeSectionEmpty(TodayPaymentReportModel report) {
  return (report.pledgeCount ?? 0) == 0 && (report.pledgeAmount ?? 0) == 0;
}