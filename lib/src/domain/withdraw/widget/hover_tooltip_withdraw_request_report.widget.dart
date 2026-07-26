import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/withdraw/controller/withdraw.controller.dart';
import 'package:hanigold_admin/src/domain/withdraw/model/today_withdraw_request_report.model.dart';
import 'package:hanigold_admin/src/domain/withdraw/widget/today_withdraw_request_report_tooltip_content.widget.dart';
import 'package:hanigold_admin/src/widget/hover_floating_panel.widget.dart';
import 'package:hanigold_admin/src/widget/hover_nested_panel.widget.dart';
import 'package:hanigold_admin/src/widget/hover_tooltip_scope.widget.dart';

const double _kPanelWidth = 480;

class HoverTooltipWithdrawRequestReportWidget extends StatefulWidget {
  final int accountId;
  final String accountName;
  final String date;
  final WithdrawController withdrawController;
  final Widget child;

  const HoverTooltipWithdrawRequestReportWidget({
    super.key,
    required this.accountId,
    required this.accountName,
    required this.date,
    required this.withdrawController,
    required this.child,
  });

  @override
  State<HoverTooltipWithdrawRequestReportWidget> createState() =>
      _HoverTooltipWithdrawRequestReportWidgetState();
}

class _HoverTooltipWithdrawRequestReportWidgetState
    extends State<HoverTooltipWithdrawRequestReportWidget> {
  final GlobalKey<HoverNestedPanelState<List<TodayWithdrawRequestReportModel>>>
  _panelKey = GlobalKey();

  @override
  void dispose() {
    widget.withdrawController.clearTodayWithdrawRequestReportCache(
      widget.accountId,
      widget.date,
    );
    super.dispose();
  }

  void _onHide() {
    widget.withdrawController.clearTodayWithdrawRequestReportCache(
      widget.accountId,
      widget.date,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HoverNestedPanel<List<TodayWithdrawRequestReportModel>>(
      key: _panelKey,
      nestedId: HoverTooltipNestedIds.withdraw,
      panelWidth: _kPanelWidth,
      onHide: _onHide,
      loadData: ({forceRefresh = false}) =>
          widget.withdrawController.loadTodayWithdrawRequestReport(
            widget.accountId,
            date: widget.date,
            forceRefresh: forceRefresh,
          ),
      panelBuilder: _buildPanel,
      child: widget.child,
    );
  }

  Widget _buildPanel(
      BuildContext context,
      AsyncSnapshot<List<TodayWithdrawRequestReportModel>?> snapshot,
      ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return TooltipSkeletonList(
        width: _kPanelWidth,
        accentColor: AppColor.secondary2Color,
      );
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
      return FloatingPanelStatusCard(
        width: _kPanelWidth,
        child: FloatingPanelRetryRow(
          message: errorMessage ?? 'خطا در بارگذاری گزارش',
          onRetry: () => _panelKey.currentState?.reload(forceRefresh: true),
        ),
      );
    }

    if (loadState == TodayWithdrawRequestReportLoadState.empty ||
        snapshot.data == null ||
        snapshot.data!.isEmpty) {
      return FloatingPanelStatusCard(
        width: _kPanelWidth,
        child: Text(
          'درخواست برداشتی برای امروز موجود نیست',
          style: AppTextStyle.labelText.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }

    return TodayWithdrawRequestReportTooltipContent(
      reports: snapshot.data!,
      accountName: widget.accountName,
    );
  }
}
