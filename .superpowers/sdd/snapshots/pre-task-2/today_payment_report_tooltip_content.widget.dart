import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/withdraw/controller/withdraw.controller.dart';
import 'package:hanigold_admin/src/domain/withdraw/model/today_deposit_request_report.model.dart';
import 'package:hanigold_admin/src/domain/withdraw/model/today_payment_report.model.dart';
import 'package:hanigold_admin/src/domain/withdraw/model/today_withdraw_request_report.model.dart';
import 'package:hanigold_admin/src/domain/withdraw/util/today_payment_report_section.util.dart';
import 'package:hanigold_admin/src/domain/withdraw/widget/today_deposit_request_report_tooltip_content.widget.dart';
import 'package:hanigold_admin/src/domain/withdraw/widget/today_withdraw_request_report_tooltip_content.widget.dart';
import 'package:hanigold_admin/src/widget/hover_floating_panel.widget.dart';
import 'package:hanigold_admin/src/widget/hover_nested_panel.widget.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

const double _kTooltipWidth = 700;
const double _kSectionGap = 12;
const double _kExpandedDetailHeight = 360;
const double _kExpandedListHeight = 320;

enum _ExpandedSection { none, withdraw, deposit }

class TodayPaymentReportTooltipContent extends StatefulWidget {
  final TodayPaymentReportModel report;
  final String accountName;
  final int accountId;
  final String date;
  final WithdrawController withdrawController;

  const TodayPaymentReportTooltipContent({
    super.key,
    required this.report,
    required this.accountName,
    required this.accountId,
    required this.date,
    required this.withdrawController,
  });

  @override
  State<TodayPaymentReportTooltipContent> createState() =>
      _TodayPaymentReportTooltipContentState();
}

class _TodayPaymentReportTooltipContentState
    extends State<TodayPaymentReportTooltipContent> {
  _ExpandedSection _expandedSection = _ExpandedSection.none;
  bool _isHoveringExpanded = false;
  Timer? _showTimer;
  Timer? _hideTimer;
  Future<List<TodayWithdrawRequestReportModel>?>? _withdrawFuture;
  Future<List<TodayDepositRequestReportModel>?>? _depositFuture;

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    widget.withdrawController.clearTodayWithdrawRequestReportCache(
      widget.accountId,
      widget.date,
    );
    widget.withdrawController.clearTodayDepositRequestReportCache(
      widget.accountId,
      widget.date,
    );
    super.dispose();
  }

  void _onIconHoverStart(_ExpandedSection section) {
    _hideTimer?.cancel();
    _showTimer?.cancel();

    if (_expandedSection == section) return;

    void activate() {
      if (!mounted) return;
      setState(() {
        _expandedSection = section;
        if (section == _ExpandedSection.withdraw) {
          _withdrawFuture ??= widget.withdrawController
              .loadTodayWithdrawRequestReport(
            widget.accountId,
            date: widget.date,
          );
        } else if (section == _ExpandedSection.deposit) {
          _depositFuture ??= widget.withdrawController
              .loadTodayDepositRequestReport(
            widget.accountId,
            date: widget.date,
          );
        }
      });
    }

    if (_expandedSection != _ExpandedSection.none) {
      activate();
      return;
    }

    _showTimer = Timer(kNestedPanelShowDelay, activate);
  }

  void _onIconHoverEnd() {
    _showTimer?.cancel();
    _scheduleCollapse();
  }

  void _scheduleCollapse() {
    _hideTimer?.cancel();
    _hideTimer = Timer(kNestedPanelHideDelay, () {
      if (!mounted || _isHoveringExpanded) return;
      _collapse();
    });
  }

  void _collapse() {
    if (_expandedSection == _ExpandedSection.none) return;
    setState(() {
      _expandedSection = _ExpandedSection.none;
      _withdrawFuture = null;
      _depositFuture = null;
    });
    widget.withdrawController.clearTodayWithdrawRequestReportCache(
      widget.accountId,
      widget.date,
    );
    widget.withdrawController.clearTodayDepositRequestReportCache(
      widget.accountId,
      widget.date,
    );
  }

  void _reloadExpanded() {
    if (_expandedSection == _ExpandedSection.withdraw) {
      setState(() {
        _withdrawFuture = widget.withdrawController
            .loadTodayWithdrawRequestReport(
          widget.accountId,
          date: widget.date,
          forceRefresh: true,
        );
      });
    } else if (_expandedSection == _ExpandedSection.deposit) {
      setState(() {
        _depositFuture = widget.withdrawController
            .loadTodayDepositRequestReport(
          widget.accountId,
          date: widget.date,
          forceRefresh: true,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.accountName.length > 36
        ? '${widget.accountName.substring(0, 36)}...'
        : widget.accountName;
    final reportDatePersian = widget.report.reportDatePersian.toString();

    return FloatingPanelShell(
      width: _kTooltipWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(displayName: displayName , reportDatePersian : reportDatePersian),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth > 360;
              final withdrawSection = _WithdrawTodayPaymentSection(
                report: widget.report,
                onIconHoverStart: isWithdrawSectionEmpty(widget.report)
                    ? null
                    : () => _onIconHoverStart(_ExpandedSection.withdraw),
                onIconHoverEnd: _onIconHoverEnd,
              );
              final pledgeSection = _PledgeTodayPaymentSection(
                report: widget.report,
                onIconHoverStart: isPledgeSectionEmpty(widget.report)
                    ? null
                    : () => _onIconHoverStart(_ExpandedSection.deposit),
                onIconHoverEnd: _onIconHoverEnd,
              );

              if (useTwoColumns) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: withdrawSection),
                    const SizedBox(width: _kSectionGap),
                    Expanded(child: pledgeSection),
                  ],
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  withdrawSection,
                  const SizedBox(height: _kSectionGap),
                  pledgeSection,
                ],
              );
            },
          ),
          AnimatedSize(
            duration: kHoverPanelAnimationDuration,
            curve: Curves.easeOutCubic,
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.topCenter,
            child: _expandedSection == _ExpandedSection.none
                ? const SizedBox.shrink()
                : MouseRegion(
              onEnter: (_) {
                _isHoveringExpanded = true;
                _hideTimer?.cancel();
              },
              onExit: (_) {
                _isHoveringExpanded = false;
                _scheduleCollapse();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: AppColor.textColor.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: _kExpandedDetailHeight,
                    child: _buildExpandedDetail(),
                  ),
                ],
              ),
            ),
          ),
          if (_hasFooterMetrics(widget.report)) ...[
            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: AppColor.textColor.withValues(alpha: 0.12),
            ),
            const SizedBox(height: 10),
            _FooterMetrics(report: widget.report),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedDetail() {
    return switch (_expandedSection) {
      _ExpandedSection.withdraw => _buildWithdrawDetail(),
      _ExpandedSection.deposit => _buildDepositDetail(),
      _ExpandedSection.none => const SizedBox.shrink(),
    };
  }

  Widget _buildWithdrawDetail() {
    final future = _withdrawFuture;
    if (future == null) {
      return _InlineDetailSkeleton(accentColor: AppColor.secondary2Color);
    }

    return FutureBuilder<List<TodayWithdrawRequestReportModel>?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _InlineDetailSkeleton(accentColor: AppColor.secondary2Color);
        }

        final loadState = widget.withdrawController
            .todayWithdrawRequestReportStateFor(
          widget.accountId,
          date: widget.date,
        );

        if (loadState == TodayWithdrawRequestReportLoadState.error) {
          final errorMessage = widget.withdrawController
              .todayWithdrawRequestReportErrorFor(
            widget.accountId,
            date: widget.date,
          );
          return FloatingPanelRetryRow(
            message: errorMessage ?? 'خطا در بارگذاری گزارش',
            onRetry: _reloadExpanded,
          );
        }

        if (loadState == TodayWithdrawRequestReportLoadState.empty ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Text(
            'درخواست برداشتی برای امروز موجود نیست',
            style: AppTextStyle.labelText.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          );
        }

        return TodayWithdrawRequestReportTooltipContent(
          reports: snapshot.data!,
          accountName: widget.accountName,
          embedded: true,
          listHeight: _kExpandedListHeight,
        );
      },
    );
  }

  Widget _buildDepositDetail() {
    final future = _depositFuture;
    if (future == null) {
      return _InlineDetailSkeleton(accentColor: AppColor.primaryColor);
    }

    return FutureBuilder<List<TodayDepositRequestReportModel>?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _InlineDetailSkeleton(accentColor: AppColor.primaryColor);
        }

        final loadState = widget.withdrawController
            .todayDepositRequestReportStateFor(
          widget.accountId,
          date: widget.date,
        );

        if (loadState == TodayDepositRequestReportLoadState.error) {
          final errorMessage = widget.withdrawController
              .todayDepositRequestReportErrorFor(
            widget.accountId,
            date: widget.date,
          );
          return FloatingPanelRetryRow(
            message: errorMessage ?? 'خطا در بارگذاری گزارش',
            onRetry: _reloadExpanded,
          );
        }

        if (loadState == TodayDepositRequestReportLoadState.empty ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Text(
            'تعهدی برای امروز موجود نیست',
            style: AppTextStyle.labelText.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          );
        }

        return TodayDepositRequestReportTooltipContent(
          reports: snapshot.data!,
          accountName: widget.accountName,
          embedded: true,
          listHeight: _kExpandedListHeight,
        );
      },
    );
  }

  bool _hasFooterMetrics(TodayPaymentReportModel report) {
    return (report.activePledgeCount ?? 0) > 0 ||
        (report.finishedPledgeCount ?? 0) > 0 ||
        (report.overPaymentCount ?? 0) > 0 ||
        (report.overPaymentAmount ?? 0) > 0;
  }
}

class _InlineDetailSkeleton extends StatelessWidget {
  final Color accentColor;

  const _InlineDetailSkeleton({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 14,
          width: 160,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String displayName;
  final String reportDatePersian;

  const _Header({required this.displayName,required this.reportDatePersian });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'گزارش پرداخت‌های  ',
              style: AppTextStyle.labelText.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              reportDatePersian,
              style: AppTextStyle.labelText.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.successColor
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          displayName,
          style: AppTextStyle.labelText.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.dividerColor,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

class _WithdrawTodayPaymentSection extends StatelessWidget {
  final TodayPaymentReportModel report;
  final VoidCallback? onIconHoverStart;
  final VoidCallback? onIconHoverEnd;

  const _WithdrawTodayPaymentSection({
    required this.report,
    this.onIconHoverStart,
    this.onIconHoverEnd,
  });

  static const _title = 'درخواست برداشت امروز';
  static const _emptyMessage = 'اطلاعاتی برای درخواست برداشت امروز موجود نیست';

  @override
  Widget build(BuildContext context) {
    final isEmpty = isWithdrawSectionEmpty(report);
    return _SectionCardShell(
      accentColor: AppColor.errorColor,
      title: _title,
      heroAmount: isEmpty ? null : report.withdrawRequestAmount,
      percent: isEmpty ? null : report.withdrawCoveragePercent,
      body: isEmpty
          ? const _SectionEmptyBody(message: _emptyMessage)
          : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProgressRow(
            accentColor: AppColor.errorColor,
            label: 'تعهد ثبت‌شده',
            amount: report.withdrawCoverageAmount,
            percent: report.withdrawCoveragePercent,
          ),
          const SizedBox(height: 8),
          _ProgressRow(
            accentColor: AppColor.errorColor,
            label: 'تأمین واقعی',
            amount: report.withdrawSettlementAmount,
            percent: report.withdrawSettlementPercent,
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: AppColor.textColor.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 10),
          _MetricChip(
            accentColor: AppColor.errorColor,
            icon: Icons.receipt_long_rounded,
            label: 'تعداد',
            value: '${report.withdrawRequestCount ?? 0} درخواست',
            onIconHoverStart: onIconHoverStart,
            onIconHoverEnd: onIconHoverEnd,
          ),
        ],
      ),
    );
  }
}

class _PledgeTodayPaymentSection extends StatelessWidget {
  final TodayPaymentReportModel report;
  final VoidCallback? onIconHoverStart;
  final VoidCallback? onIconHoverEnd;

  const _PledgeTodayPaymentSection({
    required this.report,
    this.onIconHoverStart,
    this.onIconHoverEnd,
  });

  static const _title = 'تعهد پرداخت امروز';
  static const _emptyMessage = 'اطلاعاتی برای تعهد پرداخت امروز موجود نیست';

  double? _remainingPercent(double? progressPercent) {
    if (progressPercent == null) return null;
    return (100 - progressPercent).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = isPledgeSectionEmpty(report);
    return _SectionCardShell(
      accentColor: AppColor.primaryColor,
      title: _title,
      heroAmount: isEmpty ? null : report.pledgeAmount,
      percent: isEmpty ? null : report.pledgeProgressPercent,
      body: isEmpty
          ? const _SectionEmptyBody(message: _emptyMessage)
          : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProgressRow(
            accentColor: AppColor.primaryColor,
            label: 'پرداخت‌شده',
            amount: report.transferAmount,
            percent: report.pledgeProgressPercent,
          ),
          const SizedBox(height: 8),
          _ProgressRow(
            accentColor: AppColor.primaryColor,
            label: 'مانده تعهدات',
            amount: report.outstandingAmount,
            percent: _remainingPercent(report.pledgeProgressPercent),
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: AppColor.textColor.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 10),
          _MetricChip(
            accentColor: AppColor.primaryColor,
            icon: Icons.account_balance_wallet,
            label: 'تعداد',
            value: '${report.pledgeCount ?? 0} تعهد',
            onIconHoverStart: onIconHoverStart,
            onIconHoverEnd: onIconHoverEnd,
          ),
        ],
      ),
    );
  }
}

class _SectionCardShell extends StatelessWidget {
  final Color accentColor;
  final String title;
  final double? heroAmount;
  final double? percent;
  final Widget body;

  const _SectionCardShell({
    required this.accentColor,
    required this.title,
    this.heroAmount,
    this.percent,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.backGroundColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (heroAmount != null && percent != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: AppTextStyle.labelText.copyWith(
                          fontSize: 13,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatAmount(heroAmount)} ریال',
                        style: AppTextStyle.labelText.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _SectionPercentRing(
                  percent: percent,
                  accentColor: accentColor,
                ),
              ],
            )
          else
            Text(
              title,
              style: AppTextStyle.labelText.copyWith(
                fontSize: 13,
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }
}

class _SectionPercentRing extends StatelessWidget {
  final double? percent;
  final Color accentColor;

  const _SectionPercentRing({
    required this.percent,
    required this.accentColor,
  });

  static const double _size = 52;
  static const double _strokeWidth = 4;

  @override
  Widget build(BuildContext context) {
    final safePercent = ((percent ?? 0).clamp(0, 100)) / 100;
    final label = '${(percent ?? 0).toString()}%';

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: _size,
            height: _size,
            child: CircularProgressIndicator(
              value: safePercent,
              strokeWidth: _strokeWidth,
              backgroundColor: accentColor.withValues(alpha: 0.15),
              color:(percent ?? 0) > 100 ? AppColor.accentColor : accentColor,
            ),
          ),
          Text(
            label,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 11,
              color:(percent ?? 0) > 100 ? AppColor.accentColor : accentColor,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}

class _SectionEmptyBody extends StatelessWidget {
  final String message;

  const _SectionEmptyBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: AppTextStyle.labelText.copyWith(
          fontSize: 11,
          color: AppColor.dividerColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MetricChip extends StatefulWidget {
  final Color accentColor;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onIconHoverStart;
  final VoidCallback? onIconHoverEnd;

  const _MetricChip({
    required this.accentColor,
    required this.icon,
    required this.label,
    required this.value,
    this.onIconHoverStart,
    this.onIconHoverEnd,
  });

  @override
  State<_MetricChip> createState() => _MetricChipState();
}

class _MetricChipState extends State<_MetricChip> {
  bool _isIconHovered = false;

  @override
  Widget build(BuildContext context) {
    final iconChip = MouseRegion(
      onEnter: (_) {
        setState(() => _isIconHovered = true);
        widget.onIconHoverStart?.call();
      },
      onExit: (_) {
        setState(() => _isIconHovered = false);
        widget.onIconHoverEnd?.call();
      },
      cursor: widget.onIconHoverStart != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: kHoverPanelAnimationDuration,
        curve: Curves.easeOutCubic,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: widget.accentColor.withValues(
            alpha: _isIconHovered ? 0.28 : 0.15,
          ),
          borderRadius: BorderRadius.circular(8),
          border: _isIconHovered
              ? Border.all(
            color: widget.accentColor.withValues(alpha: 0.5),
          )
              : null,
        ),
        child: Icon(
          widget.icon,
          size: 14,
          color: widget.accentColor,
        ),
      ),
    );

    return Row(
      children: [
        iconChip,
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.label,
            style: AppTextStyle.labelText.copyWith(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Flexible(
          child: Text(
            widget.value,
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              color: widget.accentColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: AppTextStyle.labelText.copyWith(fontSize: 10),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Flexible(
              child: Text(
                '${_formatAmount(amount)} ریال',
                style: AppTextStyle.labelText.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${(percent ?? 0).toString()}%',
              style: AppTextStyle.labelText.copyWith(
                  fontSize: 13,
                  color: (percent ?? 0) > 100 ? AppColor.accentColor : accentColor,
                  fontWeight: FontWeight.bold
              ),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: safePercent,
            minHeight: 5,
            backgroundColor: AppColor.textColor.withValues(alpha: 0.08),
            color: accentColor,
          ),
        ),
      ],
    );
  }
}

class _FooterMetrics extends StatelessWidget {
  final TodayPaymentReportModel report;

  const _FooterMetrics({required this.report});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        if ((report.activePledgeCount ?? 0) > 0 ||
            (report.finishedPledgeCount ?? 0) > 0)
          Text(
            'تعهدات باز: ${report.activePledgeCount ?? 0}  |  تکمیل‌شده: ${report.finishedPledgeCount ?? 0}',
            style: AppTextStyle.labelText.copyWith(fontSize: 11,fontWeight: FontWeight.bold),
          ),
        if ((report.overPaymentCount ?? 0) > 0 ||
            (report.overPaymentAmount ?? 0) > 0)
          Text(
            'اضافه‌واریزی: ${report.overPaymentCount ?? 0} مورد _ ${_formatAmount(report.overPaymentAmount)} ریال',
            style: AppTextStyle.labelText.copyWith(
                fontSize: 11,
                color: AppColor.dividerColor,
                fontWeight: FontWeight.bold
            ),
            textDirection: TextDirection.rtl,
          ),
      ],
    );
  }
}

String _formatAmount(double? value) {
  return (value ?? 0).toInt().toString().seRagham(separator: ',');
}
