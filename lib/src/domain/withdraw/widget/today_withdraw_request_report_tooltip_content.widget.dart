import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/withdraw/model/today_withdraw_request_report.model.dart';
import 'package:hanigold_admin/src/widget/hover_floating_panel.widget.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

const double _kPanelWidth = 480;
const double _kListSeparator = 4;
const double _kEmbeddedListHeight = 320;

class TodayWithdrawRequestReportTooltipContent extends StatelessWidget {
  final List<TodayWithdrawRequestReportModel> reports;
  final String accountName;
  final bool embedded;
  final double listHeight;

  const TodayWithdrawRequestReportTooltipContent({
    super.key,
    required this.reports,
    required this.accountName,
    this.embedded = false,
    this.listHeight = _kEmbeddedListHeight,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = accountName.length > 36
        ? '${accountName.substring(0, 36)}...'
        : accountName;

    final totalAmount = reports.fold<double>(
      0,
          (sum, r) => sum + (r.withdrawRequestAmount ?? 0),
    );
    final avgCoverage = reports.isEmpty
        ? 0.0
        : reports.fold<double>(0, (sum, r) => sum + (r.coveragePercent ?? 0)) /
        reports.length;

    final list = TooltipScrollableList(
      maxHeight: double.infinity,
      separatorHeight: _kListSeparator,
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return _WithdrawRequestCard(report: reports[index]);
      },
    );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: 'درخواست‌های برداشت امروز',
          displayName: displayName,
          accentColor: AppColor.secondary2Color,
          icon: Icons.receipt_long_rounded,
        ),
        const SizedBox(height: 8),
        _SummaryRow(
          accentColor: AppColor.errorColor,
          items: [
            _SummaryItem(
              label: 'تعداد',
              value: '${reports.length} درخواست',
            ),
            _SummaryItem(
              label: 'مجموع',
              value: '${_formatAmount(totalAmount)} ریال',
            ),
            /*_SummaryItem(
              label: 'میانگین پوشش',
              value: '${avgCoverage.toStringAsFixed(2)}%',
            ),*/
          ],
        ),
        const SizedBox(height: 8),
        if (embedded)
          Expanded(
            child: TooltipScrollableList(
              maxHeight: double.infinity,
              separatorHeight: _kListSeparator,
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return _WithdrawRequestCard(report: reports[index]);
              },
            ),
          )
        else
          Expanded(child: list),
      ],
    );

    if (embedded) return column;
    return FloatingPanelShell(width: _kPanelWidth, child: column);
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String displayName;
  final Color accentColor;
  final IconData icon;

  const _Header({
    required this.title,
    required this.displayName,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.labelText.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                displayName,
                style: AppTextStyle.labelText.copyWith(
                  fontSize: 12,
                  color: AppColor.dividerColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});
}

class _SummaryRow extends StatelessWidget {
  final Color accentColor;
  final List<_SummaryItem> items;

  const _SummaryRow({
    required this.accentColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: AppColor.backGroundColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: items
            .map(
              (item) => Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: AppTextStyle.labelText.copyWith(fontSize: 9),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: AppTextStyle.labelText.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                  textDirection: TextDirection.rtl,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

class _WithdrawRequestCard extends StatelessWidget {
  final TodayWithdrawRequestReportModel report;

  const _WithdrawRequestCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColor.errorColor;
    final isSettled = (report.outstandingAmount ?? 0) <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: AppColor.backGroundColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatAmount(report.withdrawRequestAmount)} ریال',
                  style: AppTextStyle.labelText.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              _StatusBadge(
                label: isSettled ? 'تأمین‌شده' : 'در انتظار',
                color: isSettled ? AppColor.successColor : AppColor.dividerColor,
              ),
              if (report.requestDate != null) ...[
                const SizedBox(width: 6),
                Text(
                  report.requestDate?.toPersianDate(
                    twoDigits: true,
                    showTime: true,
                    timeSeprator: ':',
                  ) ??
                      '',
                  style: AppTextStyle.labelText.copyWith(
                    fontSize: 9,
                    color: AppColor.secondary3Color,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          _ProgressRow(
            accentColor: accentColor,
            label: 'پوشش',
            amount: report.coverageAmount,
            percent: report.coveragePercent,
          ),
          const SizedBox(height: 3),
          _ProgressRow(
            accentColor: accentColor,
            label: 'تأمین',
            amount: report.settlementAmount,
            percent: report.settlementPercent,
          ),
          if ((report.outstandingAmount ?? 0) > 0) ...[
            const SizedBox(height: 3),
            Text(
              'مانده: ${_formatAmount(report.outstandingAmount)} ریال',
              style: AppTextStyle.labelText.copyWith(
                fontSize: 11,
                color: AppColor.accentColor,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyle.labelText.copyWith(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
class _ProgressRow extends StatelessWidget {
  final Color accentColor;
  final String label;
  final double? amount;
  final double? percent;

  const _ProgressRow({
    required this.accentColor,
    required this.label,
    this.amount,
    this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final safePercent = (percent ?? 0).clamp(0, 100) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                label,
                style: AppTextStyle.labelText.copyWith(fontSize: 8),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Expanded(
              child: Text(
                '${_formatAmount(amount)} ریال',
                style: AppTextStyle.labelText.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 40,
              child: Text(
                '${(percent ?? 0).toString()}%',
                style: AppTextStyle.labelText.copyWith(
                  fontSize: 10,
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: safePercent,
            minHeight: 4,
            backgroundColor: AppColor.textColor.withValues(alpha: 0.08),
            color: accentColor,
          ),
        ),
      ],
    );
  }
}

String _formatAmount(double? value) {
  return (value ?? 0).toInt().toString().seRagham(separator: ',');
}

