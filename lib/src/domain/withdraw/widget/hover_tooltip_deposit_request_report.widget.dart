import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/withdraw/controller/withdraw.controller.dart';
import 'package:hanigold_admin/src/domain/withdraw/model/today_deposit_request_report.model.dart';
import 'package:hanigold_admin/src/domain/withdraw/widget/today_deposit_request_report_tooltip_content.widget.dart';
import 'package:hanigold_admin/src/widget/hover_floating_panel.widget.dart';
import 'package:hanigold_admin/src/widget/hover_nested_panel.widget.dart';
import 'package:hanigold_admin/src/widget/hover_tooltip_scope.widget.dart';

const double _kPanelWidth = 480;

class HoverTooltipDepositRequestReportWidget extends StatefulWidget {
  final int accountId;
  final String accountName;
  final String date;
  final WithdrawController withdrawController;
  final Widget child;

  const HoverTooltipDepositRequestReportWidget({
    super.key,
    required this.accountId,
    required this.accountName,
    required this.date,
    required this.withdrawController,
    required this.child,
  });

  @override
  State<HoverTooltipDepositRequestReportWidget> createState() =>
      _HoverTooltipDepositRequestReportWidgetState();
}

class _HoverTooltipDepositRequestReportWidgetState
    extends State<HoverTooltipDepositRequestReportWidget> {
  final GlobalKey<HoverNestedPanelState<List<TodayDepositRequestReportModel>>>
  _panelKey = GlobalKey();

  @override
  void dispose() {
    widget.withdrawController.clearTodayDepositRequestReportCache(
      widget.accountId,
      widget.date,
    );
    super.dispose();
  }

  void _onHide() {
    widget.withdrawController.clearTodayDepositRequestReportCache(
      widget.accountId,
      widget.date,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HoverNestedPanel<List<TodayDepositRequestReportModel>>(
      key: _panelKey,
      nestedId: HoverTooltipNestedIds.deposit,
      panelWidth: _kPanelWidth,
      onHide: _onHide,
      loadData: ({forceRefresh = false}) =>
          widget.withdrawController.loadTodayDepositRequestReport(
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
      AsyncSnapshot<List<TodayDepositRequestReportModel>?> snapshot,
      ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return TooltipSkeletonList(
        width: _kPanelWidth,
        accentColor: AppColor.primaryColor,
      );
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
      return FloatingPanelStatusCard(
        width: _kPanelWidth,
        child: FloatingPanelRetryRow(
          message: errorMessage ?? 'خطا در بارگذاری گزارش',
          onRetry: () => _panelKey.currentState?.reload(forceRefresh: true),
        ),
      );
    }

    if (loadState == TodayDepositRequestReportLoadState.empty ||
        snapshot.data == null ||
        snapshot.data!.isEmpty) {
      return FloatingPanelStatusCard(
        width: _kPanelWidth,
        child: Text(
          'تعهدی برای امروز موجود نیست',
          style: AppTextStyle.labelText.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }

    return TodayDepositRequestReportTooltipContent(
      reports: snapshot.data!,
      accountName: widget.accountName,
    );
  }
}
