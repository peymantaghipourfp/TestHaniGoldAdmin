import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/withdraw/controller/withdraw.controller.dart';
import 'package:hanigold_admin/src/domain/withdraw/model/today_payment_report.model.dart';
import 'package:hanigold_admin/src/domain/withdraw/widget/today_payment_report_tooltip_content.widget.dart';
import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';
import 'package:hanigold_admin/src/widget/hover_floating_panel.widget.dart';

const double _kDialogWidth = 700;

class TodayPaymentReportDialogTrigger extends StatelessWidget {
  final int accountId;
  final String accountName;
  final String date;
  final WithdrawController withdrawController;
  final Widget child;

  const TodayPaymentReportDialogTrigger({
    super.key,
    required this.accountId,
    required this.accountName,
    required this.date,
    required this.withdrawController,
    required this.child,
  });

  Future<void> _openDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: _TodayPaymentReportDialogBody(
            accountId: accountId,
            accountName: accountName,
            date: date,
            withdrawController: withdrawController,
            onRequestClose: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: child),
        IconButton(
          tooltip: 'گزارش پرداخت‌های امروز',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => _openDialog(context),
          icon: SvgPicture.asset(
            'assets/svg/receipt.svg',
            height: 18,
            colorFilter: ColorFilter.mode(
                AppColor.secondary300Color,
                BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}

class _TodayPaymentReportDialogBody extends StatefulWidget {
  final int accountId;
  final String accountName;
  final String date;
  final WithdrawController withdrawController;
  final VoidCallback onRequestClose;

  const _TodayPaymentReportDialogBody({
    required this.accountId,
    required this.accountName,
    required this.date,
    required this.withdrawController,
    required this.onRequestClose,
  });

  @override
  State<_TodayPaymentReportDialogBody> createState() =>
      _TodayPaymentReportDialogBodyState();
}

class _TodayPaymentReportDialogBodyState
    extends State<_TodayPaymentReportDialogBody> {
  late Future<TodayPaymentReportModel?> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadReport();
  }

  Future<TodayPaymentReportModel?> _loadReport({bool forceRefresh = false}) {
    return widget.withdrawController.loadTodayPaymentReport(
      widget.accountId,
      date: widget.date,
      forceRefresh: forceRefresh,
    );
  }

  void _retry() {
    setState(() {
      _loadFuture = _loadReport(forceRefresh: true);
    });
  }

  Widget _statusCloseButton() {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: IconButton(
        tooltip: 'بستن',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: widget.onRequestClose,
        icon: Icon(
          Icons.close_rounded,
          size: 18,
          color: AppColor.textColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      AsyncSnapshot<TodayPaymentReportModel?> snapshot,
      ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return FloatingPanelStatusCard(
        width: _kDialogWidth,
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
        width: _kDialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusCloseButton(),
            FloatingPanelRetryRow(
              message: errorMessage ?? 'خطا در بارگذاری گزارش',
              onRetry: _retry,
            ),
          ],
        ),
      );
    }

    if (loadState == TodayPaymentReportLoadState.empty ||
        snapshot.data == null) {
      return FloatingPanelStatusCard(
        width: _kDialogWidth,
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
      onRequestClose: widget.onRequestClose,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TodayPaymentReportModel?>(
      future: _loadFuture,
      builder: _buildContent,
    );
  }
}
