import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/withdraw/controller/withdraw.controller.dart';
import 'package:hanigold_admin/src/domain/withdraw/model/today_payment_report.model.dart';
import 'package:hanigold_admin/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart';
import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';
import 'package:hanigold_admin/src/widget/hover_floating_panel.widget.dart';
import 'package:hanigold_admin/src/widget/hover_lazy_rich_tooltip.widget.dart';
import 'package:hanigold_admin/src/widget/hover_tooltip_scope.widget.dart';

const double _kTooltipWidth = 700;

class HoverTooltipTodayPaymentReportWidget extends StatefulWidget {
  final int accountId;
  final String accountName;
  final String date;
  final WithdrawController withdrawController;
  final Widget child;

  const HoverTooltipTodayPaymentReportWidget({
    super.key,
    required this.accountId,
    required this.accountName,
    required this.date,
    required this.withdrawController,
    required this.child,
  });

  @override
  State<HoverTooltipTodayPaymentReportWidget> createState() =>
      _HoverTooltipTodayPaymentReportWidgetState();
}

class _HoverTooltipTodayPaymentReportWidgetState
    extends State<HoverTooltipTodayPaymentReportWidget> {
  final GlobalKey<HoverLazyRichTooltipState<TodayPaymentReportModel>>
  _tooltipKey = GlobalKey();

  Widget _statusCloseButton() {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: IconButton(
        tooltip: 'بستن',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: () => _tooltipKey.currentState?.forceDeactivate(),
        icon: Icon(
          Icons.close_rounded,
          size: 18,
          color: AppColor.textColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HoverTooltipScopeHost(
      child: HoverLazyRichTooltip<TodayPaymentReportModel>(
        key: _tooltipKey,
        messageMaxWidth: _kTooltipWidth,
        stickyUntilDismissed: true,
        showDuration: const Duration(days: 1),
        loadData: ({forceRefresh = false}) =>
            widget.withdrawController.loadTodayPaymentReport(
              widget.accountId,
              date: widget.date,
              forceRefresh: forceRefresh,
            ),
        waitingMessage: Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            'در حال بارگذاری...',
            style: AppTextStyle.labelText.copyWith(fontSize: 12),
          ),
        ),
        messageBuilder: _buildMessage,
        child: widget.child,
      ),
    );
  }

  Widget _buildMessage(
      BuildContext context,
      AsyncSnapshot<TodayPaymentReportModel?> snapshot,
      ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return FloatingPanelStatusCard(
        width: _kTooltipWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusCloseButton(),
            const SizedBox(
              height: 80,
              child: Center(child: HaniGoldLoading()),
            ),
          ],
        ),
      );
    }

    final loadState = widget.withdrawController.todayPaymentReportStateFor(
      widget.accountId,
      date: widget.date,
    );

    if (loadState == TodayPaymentReportLoadState.error) {
      final errorMessage = widget.withdrawController.todayPaymentReportErrorFor(
        widget.accountId,
        date: widget.date,
      );
      return FloatingPanelStatusCard(
        width: _kTooltipWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusCloseButton(),
            FloatingPanelRetryRow(
              message: errorMessage ?? 'خطا در بارگذاری گزارش',
              onRetry: () =>
                  _tooltipKey.currentState?.reload(forceRefresh: true),
            ),
          ],
        ),
      );
    }

    if (loadState == TodayPaymentReportLoadState.empty ||
        snapshot.data == null) {
      return FloatingPanelStatusCard(
        width: _kTooltipWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusCloseButton(),
            Text(
              'گزارشی برای امروز موجود نیست',
              style: AppTextStyle.labelText.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return TodayPaymentReportTooltipContent(
      report: snapshot.data!,
      accountName: widget.accountName,
      accountId: widget.accountId,
      date: widget.date,
      withdrawController: widget.withdrawController,
      onRequestClose: () => _tooltipKey.currentState?.forceDeactivate(),
    );
  }
}
