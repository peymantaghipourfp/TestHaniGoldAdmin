import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_report_gold.model.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_coin_cell.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_datetime_cell.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_description_cell.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_gold_cell.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_grouped_header.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_half_quarter_cell.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_invoice_cell.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_qty_cell.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_rial_cell.widget.dart';

/// Fourteen-column fit-width gold ledger [DataTable] (no horizontal scroll).
class GoldTransactionDataTable extends StatelessWidget {
  const GoldTransactionDataTable({
    super.key,
    required this.controller,
  });

  final UserInfoDetailGoldTransactionController controller;

  /// Visual column index of تاریخ/ساعت (sole sortable column).
  static const int dateSortVisualIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Touch observables synchronously so GetX registers them (LayoutBuilder
      // callback is deferred and would otherwise trigger improper-use errors).
      final rows = controller.transactionInfoGoldList.toList();
      final sortIndex = controller.sortIndex.value;
      final sortAscending = controller.sort.value;

      return LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth.isFinite &&
                  constraints.maxWidth > 0
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width - 40;
          final widths = _columnWidths(available);

          return DataTable(
            key: const Key('gold_transaction_data_table'),
            columns: _buildColumns(context, widths),
            sortColumnIndex:
                sortIndex == dateSortVisualIndex ? dateSortVisualIndex : null,
            sortAscending: sortAscending,
            border: TableBorder.symmetric(
              inside: BorderSide(color: AppColor.textColor, width: 0.3),
              outside: BorderSide(color: AppColor.textColor, width: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            dividerThickness: 0.3,
            rows: _buildRows(context, widths, rows),
            dataRowMaxHeight: double.infinity,
            headingRowColor:
                WidgetStatePropertyAll(AppColor.buttonColor.withAlpha(40)),
            headingRowHeight: 72,
            columnSpacing: 8,
            horizontalMargin: 4,
          );
        },
      );
    });
  }

  /// Width budgets: fixed meta + شرح share + 8 balance-related columns.
  static List<double> _columnWidths(double available) {
    const spacing = 8.0 * 13; // between 14 columns
    const margin = 4.0 * 2;
    final usable = (available - spacing - margin).clamp(400.0, double.infinity);

    const row = 52.0;
    const invoice = 64.0;
    const datetime = 72.0;
    const ops = 56.0;
    const qty = 52.0;
    final desc = (usable * 0.16).clamp(72.0, 160.0);
    final fixed = row + invoice + datetime + ops + qty + desc;
    final rest = (usable - fixed).clamp(320.0, double.infinity);
    // 4 grouped get more than 4 مانده; floor keeps chips readable.
    final grouped = (rest / 8 * 1.15).clamp(88.0, double.infinity);
    final running = (rest / 8 * 0.85).clamp(64.0, double.infinity);

    return [
      row,
      invoice,
      datetime,
      ops,
      desc,
      qty,
      grouped, // طلا
      running, // مانده طلایی
      grouped, // تمام‌سکه
      running, // مانده تمام‌سکه
      grouped, // نیم‌ربع
      running, // مانده نیم‌ربع
      grouped, // ریال
      running, // مانده ریالی
    ];
  }

  List<DataColumn> _buildColumns(BuildContext context, List<double> widths) {
    TextStyle labelStyle =
        AppTextStyle.labelText.copyWith(fontSize: 11);
    TextStyle runningStyle = AppTextStyle.labelText.copyWith(
      fontSize: 11,
      color: AppColor.dividerColor,
      fontWeight: FontWeight.bold,
    );

    Widget headerLabel(String text, double maxWidth, {TextStyle? style}) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Text(
          text,
          style: style ?? labelStyle,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      );
    }

    return [
      DataColumn(
        label: headerLabel('ردیف', widths[0]),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: headerLabel('فاکتور', widths[1]),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        onSort: (columnIndex, ascending) {
          controller.setSort(columnIndex, ascending);
          controller.onSortColum(columnIndex, ascending);
        },
        label: headerLabel('تاریخ/ساعت', widths[2]),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: headerLabel('عملیات', widths[3]),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: headerLabel('شرح', widths[4]),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: headerLabel('وزن یا تعداد', widths[5]),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widths[6]),
          child: const GoldTransactionGroupedHeader(label: 'طلا'),
        ),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: headerLabel('مانده طلایی', widths[7], style: runningStyle),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widths[8]),
          child: const GoldTransactionGroupedHeader(label: 'تمام‌سکه'),
        ),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: headerLabel('مانده تمام‌سکه', widths[9], style: runningStyle),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widths[10]),
          child: const GoldTransactionGroupedHeader(label: 'نیم‌ربع'),
        ),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: headerLabel('مانده نیم‌ربع', widths[11], style: runningStyle),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widths[12]),
          child: const GoldTransactionGroupedHeader(label: 'ریال'),
        ),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: headerLabel('مانده ریالی', widths[13], style: runningStyle),
        headingRowAlignment: MainAxisAlignment.center,
      ),
    ];
  }

  List<DataRow> _buildRows(
    BuildContext context,
    List<double> widths,
    List<TransactionReportGoldModel> rows,
  ) {
    return rows.asMap().entries.map((entry) {
      final index = entry.key;
      final trans = entry.value;
      final rowColor = index.isEven
          ? AppColor.backGroundColor
          : AppColor.secondaryColor.withAlpha(100);

      return DataRow(
        color: trans.checked == true
            ? WidgetStateProperty.all(AppColor.appBarColor.withAlpha(150))
            : WidgetStateProperty.all(rowColor),
        cells: [
          DataCell(_budget(widths[0], _rowCell(trans))),
          DataCell(
            _budget(
              widths[1],
              GoldTransactionInvoiceCell(
                controller: controller,
                trans: trans,
              ),
            ),
          ),
          DataCell(
            _budget(widths[2], GoldTransactionDateTimeCell(trans: trans)),
          ),
          DataCell(_budget(widths[3], _operationCell(trans))),
          DataCell(
            GoldTransactionDescriptionCell(
              trans: trans,
              maxWidth: widths[4],
            ),
          ),
          DataCell(_budget(widths[5], GoldTransactionQtyCell(trans: trans))),
          DataCell(
            _budget(
              widths[6],
              _assetCell(
                credit: GoldTransactionGoldCell.creditSection(trans: trans),
                debit: GoldTransactionGoldCell.debitSection(trans: trans),
              ),
            ),
          ),
          DataCell(
            _budget(
              widths[7],
              Center(
                child: GoldTransactionGoldCell.balanceSection(trans: trans),
              ),
            ),
          ),
          DataCell(
            _budget(
              widths[8],
              _assetCell(
                credit: GoldTransactionCoinCell.creditSection(trans: trans),
                debit: GoldTransactionCoinCell.debitSection(trans: trans),
              ),
            ),
          ),
          DataCell(
            _budget(
              widths[9],
              Center(
                child: GoldTransactionCoinCell.balanceSection(trans: trans),
              ),
            ),
          ),
          DataCell(
            _budget(
              widths[10],
              _assetCell(
                credit: GoldTransactionHalfQuarterCell.creditSection(
                  trans: trans,
                ),
                debit:
                    GoldTransactionHalfQuarterCell.debitSection(trans: trans),
              ),
            ),
          ),
          DataCell(
            _budget(
              widths[11],
              Center(
                child: GoldTransactionHalfQuarterCell.balanceSection(
                  trans: trans,
                ),
              ),
            ),
          ),
          DataCell(
            _budget(
              widths[12],
              _assetCell(
                credit: GoldTransactionRialCell.creditSection(trans: trans),
                debit: GoldTransactionRialCell.debitSection(trans: trans),
              ),
            ),
          ),
          DataCell(
            _budget(
              widths[13],
              Center(
                child: GoldTransactionRialCell.balanceSection(trans: trans),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  /// Caps cell intrinsic width so columns honor [_columnWidths] budgets.
  static Widget _budget(double maxWidth, Widget child) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ClipRect(child: child),
    );
  }

  Widget _rowCell(TransactionReportGoldModel trans) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Row(
          children: [
            Checkbox(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: trans.checked ?? false,
              onChanged: (value) async {
                if (value != null) {
                  await controller.updateGoldChecked(trans.id ?? 0, value);
                }
              },
            ),
            const SizedBox(width: 2),
            Flexible(
              child: SelectableText(
                '${trans.rowNum ?? 0}',
                maxLines: 1,
                style: AppTextStyle.bodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _operationCell(TransactionReportGoldModel trans) {
    final label = switch (trans.type) {
      'issue' => ' حواله دریافتی ',
      'receive' => ' دریافت ',
      'payment' => ' پرداخت ',
      'sell' => ' فروش ',
      'buy' => ' خرید ',
      'deposit' => ' واریز ',
      'withdraw' => ' برداشت ',
      'reciept' => ' حواله پرداختی ',
      'initial' => ' اول دوره ',
      _ => '',
    };
    return Center(
      child: Text(
        label,
        softWrap: false,
        maxLines: 1,
        style: AppTextStyle.bodyText.copyWith(
          color: AppColor.textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  static Widget _assetCell({
    required Widget credit,
    required Widget debit,
  }) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          credit,
          const SizedBox(height: 4),
          debit,
        ],
      ),
    );
  }
}
