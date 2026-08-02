import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/domain/inventory/controller/item_movement_report.controller.dart';
import 'package:hanigold_admin/src/domain/inventory/model/item_movement_report.model.dart';
import 'package:hanigold_admin/src/domain/inventory/model/operation.model.dart';
import 'package:hanigold_admin/src/domain/inventory/widget/item_movement_report_colors.dart';
import 'package:hanigold_admin/src/domain/product/model/item.model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:printing/printing.dart';

class ItemMovementReportView extends StatefulWidget {
  const ItemMovementReportView({super.key});

  @override
  State<ItemMovementReportView> createState() => _ItemMovementReportViewState();
}

class _ItemMovementReportViewState extends State<ItemMovementReportView> {
  final ItemMovementReportController controller =
      Get.find<ItemMovementReportController>();
  final TextEditingController _searchController = TextEditingController();

  static const _footnote =
      'این گزارش از خروجی سامانه تهیه شده است. زمان «برگشت حذف» بر اساس زمان ثبت حذف در داده‌ها نمایش داده می‌شود. '
      'موجودی هر ردیف، موجودی بلافاصله پس از همان رویداد است.';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _faNum(num? value, {int maxFractionDigits = 4}) {
    if (value == null) return '—';
    String text;
    if (value % 1 == 0) {
      text = value.toInt().toString();
    } else {
      text = value
          .toStringAsFixed(maxFractionDigits)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    return text.toPersianDigit();
  }

  String _faInt(int? value) =>
      value == null ? '—' : value.toString().toPersianDigit();

  static const _dash = '—';

  bool _isDeleted(OperationModel op) => (op.status ?? '').contains('حذف');

  bool _isInput(OperationModel op) => (op.balanceEffect ?? 0) >= 0;

  String get _unitName {
    final reportUnit = controller.report.value?.item?.unitName;
    if (reportUnit != null && reportUnit.isNotEmpty) return reportUnit;
    final selectedUnit = controller.selectedItem.value?.itemUnit?.name;
    if (selectedUnit != null && selectedUnit.isNotEmpty) return selectedUnit;
    return '';
  }

  String _withUnit(String value) {
    final unit = _unitName;
    return unit.isEmpty ? value : '$value $unit';
  }

  List<OperationModel> get _allOps {
    final days = controller.report.value?.days;
    if (days == null) return const [];
    return days.expand((d) => d.operations ?? const <OperationModel>[]).toList();
  }

  int get _activeInputCount => _allOps
      .where((op) => !_isDeleted(op) && (op.balanceEffect ?? 0) > 0)
      .length;

  int get _activeOutputCount => _allOps
      .where((op) => !_isDeleted(op) && (op.balanceEffect ?? 0) < 0)
      .length;

  String? _anomalyText(ItemMovementReportModel? report) {
    if (report == null) return null;

    final warnings = report.warnings;
    final warningCount = report.warningCount ?? 0;
    if (warningCount > 0 || (warnings != null && warnings.isNotEmpty)) {
      if (warnings != null && warnings.isNotEmpty) {
        return warnings.first.toString();
      }
      return 'یک مورد نیازمند بررسی پیدا شد';
    }

    final mismatch = _allOps.where((op) => op.hasDateMismatch == true);
    if (mismatch.isEmpty) return null;

    final op = mismatch.first;
    final detailId = (op.inventoryDetailId?.toString() ?? '').toPersianDigit();
    final day = op.operationPersianDate ?? _dash;
    final time = (op.operationTime ?? '').toPersianDigit();
    final created = _formatDateTime(op.createdOn);
    return 'عملیات شماره $detailId برای $day '
        'ساعت $time نمایش داده شده، اما زمان ایجاد فنی آن '
        '$created است. این رکورد با نوار نارنجی در جدول مشخص شده است.';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return _dash;
    final jalali = Jalali.fromDateTime(value);
    final date =
        '${jalali.year}/'
        '${jalali.month.toString().padLeft(2, '0')}/'
        '${jalali.day.toString().padLeft(2, '0')}';
    final time =
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}:'
        '${value.second.toString().padLeft(2, '0')}';
    return '${date.toPersianDigit()} ـ ${time.toPersianDigit()}';
  }

  String _deleteTime(OperationModel op) {
    if (!_isDeleted(op) || op.modifiedOn == null) return _dash;
    final m = op.modifiedOn!;
    final time =
        '${m.hour.toString().padLeft(2, '0')}:'
        '${m.minute.toString().padLeft(2, '0')}:'
        '${m.second.toString().padLeft(2, '0')}';
    return time.toPersianDigit();
  }

  Future<void> _selectDate() async {
    try {
      final current = controller.dateController.text;
      Jalali initial = Jalali.now();
      final parts = current.split('/');
      if (parts.length == 3) {
        initial = Jalali(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }

      final Jalali? picked = await showPersianDatePicker(
        context: context,
        initialDate: initial,
        firstDate: Jalali(1400, 1, 1),
        lastDate: Jalali(1450, 12, 29),
        initialEntryMode: PersianDatePickerEntryMode.calendar,
        initialDatePickerMode: PersianDatePickerMode.day,
        locale: const Locale('fa', 'IR'),
      );

      if (picked != null) {
        controller.dateController.text =
            '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
        await controller.fetchReport();
      }
    } catch (_) {}
  }

  Future<void> _printReport() async {
    final report = controller.report.value;
    final ops = controller.visibleOperations.toList();
    final fontData =
        await rootBundle.load('assets/fonts/IRANSansX-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final title = report?.item?.name ?? 'گزارش گردش انبار';
    final dateLabel = report?.fromPersianDate ?? controller.dateController.text;
    final unit = _unitName;

    await Printing.layoutPdf(
      name: 'item_movement_report.pdf',
      onLayout: (format) async {
        final pdf = pw.Document();
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.landscape,
            textDirection: pw.TextDirection.rtl,
            theme: pw.ThemeData.withFont(base: ttf, fontFallback: [ttf]),
            build: (context) {
              return [
                pw.Text(
                  'گزارش قابل فهم گردش انبار',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  [
                    if (dateLabel.isNotEmpty) dateLabel,
                    if (unit.isNotEmpty) 'واحد: $unit',
                  ].join('  |  '),
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 12),
                pw.TableHelper.fromTextArray(
                  headers: const [
                    'ساعت',
                    'حساب',
                    'نوع رویداد',
                    'وضعیت',
                    'تعداد',
                    'اثر هنگام ثبت',
                    'موجودی پس از ثبت',
                    'ساعت حذف',
                    'موجودی پس از حذف',
                    'توضیح',
                  ],
                  data: ops
                      .map(
                        (op) => [
                          op.operationTime ?? _dash,
                          op.accountName ?? _dash,
                          op.movementType ?? _dash,
                          op.status ?? _dash,
                          _faNum(op.quantity),
                          _effectLabel(op.balanceEffect),
                          _faNum(op.balanceAfterOperation),
                          _deleteTime(op),
                          _dash,
                          _dash,
                        ],
                      )
                      .toList(),
                  headerStyle: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 7),
                  cellAlignment: pw.Alignment.centerRight,
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                ),
                if (ops.isEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(16),
                    child: pw.Text(
                      'موردی مطابق فیلتر انتخاب‌شده پیدا نشد.',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
              ];
            },
          ),
        );
        return pdf.save();
      },
    );
  }

  String _effectLabel(double? effect) {
    if (effect == null) return _dash;
    final sign = effect > 0 ? '+' : '';
    return '$sign${_faNum(effect)}';
  }

  void _resetFilters() {
    _searchController.clear();
    controller.resetFilters();
  }

  InputDecoration _controlDecoration({String? hint, String? label}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      hintStyle: const TextStyle(
        color: ItemMovementReportColors.muted,
        fontSize: 13,
      ),
      labelStyle: const TextStyle(
        color: ItemMovementReportColors.muted,
        fontSize: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFD7D0C1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFD7D0C1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: ItemMovementReportColors.gold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ItemMovementReportColors.canvas,
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.9, -1),
              radius: 1.2,
              colors: [
                Color(0x1FB48622),
                ItemMovementReportColors.canvas,
              ],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1480),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 56),
                children: [
                  _buildHero(),
                  const SizedBox(height: 18),
                  Obx(() => _buildSummary()),
                  Obx(() {
                    final text = _anomalyText(controller.report.value);
                    if (text == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _buildNotice(text),
                    );
                  }),
                  _buildGuide(),
                  const SizedBox(height: 18),
                  _buildPanel(),
                  const SizedBox(height: 15),
                  const Text(
                    _footnote,
                    style: TextStyle(
                      color: ItemMovementReportColors.muted,
                      fontSize: 12.5,
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            ItemMovementReportColors.heroStart,
            ItemMovementReportColors.heroEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x173D3016),
            blurRadius: 42,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -90,
            bottom: -140,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x29CDA037),
                  width: 42,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'گزارش قابل فهم گردش انبار',
                style: TextStyle(
                  color: Color(0xFFE9C86F),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Obx(() {
                final name = controller.report.value?.item?.name ??
                    controller.selectedItem.value?.name ??
                    'انتخاب محصول';
                return Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                );
              }),
              const SizedBox(height: 14),
              Obx(() {
                final date = controller.report.value?.fromPersianDate ??
                    controller.dateController.text;
                final unit = _unitName;
                return Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    Text(
                      date.toPersianDigit(),
                      style: const TextStyle(
                        color: Color(0xFFD3DADC),
                        fontSize: 14.5,
                      ),
                    ),
                    if (unit.isNotEmpty)
                      Text(
                        'واحد: $unit',
                        style: const TextStyle(
                          color: Color(0xFFD3DADC),
                          fontSize: 14.5,
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 720;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: narrow ? constraints.maxWidth : 280,
                        child: Obx(
                          () => DropdownButtonFormField<ItemModel>(
                            value: controller.selectedItem.value,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1A2328),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: _controlDecoration(
                              hint: 'انتخاب محصول',
                            ).copyWith(
                              fillColor: Colors.white.withValues(alpha: 0.08),
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2BD5F),
                                ),
                              ),
                            ),
                            items: controller.itemList
                                .map(
                                  (item) => DropdownMenuItem<ItemModel>(
                                    value: item,
                                    child: Text(
                                      item.name ?? '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (item) {
                              controller.selectedItem.value = item;
                              controller.fetchReport();
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: narrow ? constraints.maxWidth : 180,
                        child: TextField(
                          controller: controller.dateController,
                          readOnly: true,
                          onTap: _selectDate,
                          style: const TextStyle(color: Colors.white),
                          decoration: _controlDecoration(
                            hint: 'تاریخ',
                          ).copyWith(
                            fillColor: Colors.white.withValues(alpha: 0.08),
                            prefixIcon: Icon(
                              Icons.calendar_month,
                              color: Colors.white.withValues(alpha: 0.75),
                              size: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2BD5F),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _heroButton(
                    label: 'چاپ یا ذخیره PDF',
                    primary: true,
                    onPressed: _printReport,
                  ),
                  _heroButton(
                    label: 'نمایش همه رویدادها',
                    onPressed: _resetFilters,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroButton({
    required String label,
    required VoidCallback onPressed,
    bool primary = false,
  }) {
    return Material(
      color: primary
          ? const Color(0xFFE2BD5F)
          : Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primary
                  ? const Color(0xFFE2BD5F)
                  : Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: primary ? const Color(0xFF1B1B16) : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final report = controller.report.value;
    final opening = report?.openingBalance;
    final inputQty = report?.inputQuantity;
    final outputQty = report?.outputQuantity;
    final deletedCount = report?.deletedOperationCount;
    final deletedQty = report?.deletedQuantity;
    final closing = report?.closingBalance;
    final net = (opening != null && closing != null) ? closing - opening : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns;
        if (width > 1050) {
          columns = 5;
        } else if (width > 720) {
          columns = 3;
        } else {
          columns = 2;
        }
        final gap = 12.0;
        final itemWidth = (width - gap * (columns - 1)) / columns;

        final cards = [
          _SummaryCardData(
            label: 'موجودی ابتدای روز',
            value: _withUnit(_faNum(opening)),
            note: 'پیش از اولین عملیات این گزارش',
          ),
          _SummaryCardData(
            label: 'ورودی واقعی',
            value: _withUnit(_faNum(inputQty)),
            note: '${_faInt(_activeInputCount)} عملیات فعال',
            valueColor: ItemMovementReportColors.green,
            kind: _SummaryKind.input,
          ),
          _SummaryCardData(
            label: 'خروجی واقعی',
            value: _withUnit(_faNum(outputQty)),
            note: '${_faInt(_activeOutputCount)} عملیات فعال',
            valueColor: ItemMovementReportColors.red,
            kind: _SummaryKind.output,
          ),
          _SummaryCardData(
            label: 'عملیات حذف‌شده',
            value: '${_faInt(deletedCount)} عملیات',
            note:
                'مجموع گردش حذف‌شده: ${_withUnit(_faNum(deletedQty?.toDouble()))}',
            valueColor: ItemMovementReportColors.orange,
            kind: _SummaryKind.deleted,
          ),
          _SummaryCardData(
            label: 'موجودی پایان روز',
            value: _withUnit(_faNum(closing)),
            note: net == null
                ? _dash
                : 'تغییر خالص روز: ${net > 0 ? '+' : ''}${_withUnit(_faNum(net))}',
            kind: _SummaryKind.finalCard,
          ),
        ];

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < cards.length; i++)
              SizedBox(
                width: columns == 2 && i == cards.length - 1
                    ? width
                    : itemWidth,
                child: _buildSummaryCard(cards[i]),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(_SummaryCardData data) {
    final isFinal = data.kind == _SummaryKind.finalCard;
    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isFinal
            ? const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  ItemMovementReportColors.finalCardStart,
                  ItemMovementReportColors.finalCardEnd,
                ],
              )
            : null,
        color: isFinal
            ? null
            : ItemMovementReportColors.paper.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFinal ? Colors.transparent : ItemMovementReportColors.line,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D3D3016),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: TextStyle(
              color: isFinal
                  ? const Color(0xFFF5E7C1)
                  : ItemMovementReportColors.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: TextStyle(
              color: isFinal
                  ? Colors.white
                  : (data.valueColor ?? ItemMovementReportColors.ink),
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.note,
            style: TextStyle(
              color: isFinal
                  ? const Color(0xFFF5E7C1)
                  : ItemMovementReportColors.muted,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: ItemMovementReportColors.orangeSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDC696)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: ItemMovementReportColors.orange,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'یک مورد نیازمند بررسی پیدا شد',
                  style: TextStyle(
                    color: Color(0xFF6F3D0B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF6F3D0B),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuide() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1050 ? 2 : 1;
        final gap = 12.0;
        final itemWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / 2;
        final items = [
          (
            ItemMovementReportColors.green,
            'فعال:',
            ' عملیات واقعی که اثر آن در موجودی پایان روز باقی مانده است.',
          ),
          (
            ItemMovementReportColors.red,
            'حذف‌شده:',
            ' ساعت ثبت و ساعت حذف در یک ردیف آمده و موجودی هر دو لحظه نمایش داده شده است.',
          ),
        ];
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                  decoration: BoxDecoration(
                    color:
                        ItemMovementReportColors.paper.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ItemMovementReportColors.line),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 7),
                        decoration: BoxDecoration(
                          color: item.$1,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              color: ItemMovementReportColors.muted,
                              fontSize: 13.5,
                              height: 1.55,
                            ),
                            children: [
                              TextSpan(
                                text: item.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: ItemMovementReportColors.ink,
                                ),
                              ),
                              TextSpan(text: item.$3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPanel() {
    return Container(
      decoration: BoxDecoration(
        color: ItemMovementReportColors.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ItemMovementReportColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x173D3016),
            blurRadius: 42,
            offset: Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ریز گردش روز',
                        style: TextStyle(
                          color: ItemMovementReportColors.ink,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'هر عملیات فقط یک ردیف دارد؛ ساعت و نتیجه حذف نیز در همان ردیف نمایش داده می‌شود.',
                        style: TextStyle(
                          color: ItemMovementReportColors.muted,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final visible = controller.visibleOperations.length;
                  final total = _allOps.length;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8EDCE),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${_faInt(visible)} عملیات از ${_faInt(total)}',
                      style: const TextStyle(
                        color: ItemMovementReportColors.goldDark,
                        fontSize: 12.5,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, color: ItemMovementReportColors.line),
          _buildFilters(),
          const Divider(height: 1, color: ItemMovementReportColors.line),
          Obx(() {
            final ops = controller.visibleOperations.toList();
            if (ops.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(36),
                child: Text(
                  'موردی مطابق فیلتر انتخاب‌شده پیدا نشد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ItemMovementReportColors.muted,
                    fontSize: 14,
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1250),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFF7F3EB),
                  ),
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 120,
                  headingTextStyle: const TextStyle(
                    color: Color(0xFF596167),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  columns: const [
                    DataColumn(label: Text('ساعت')),
                    DataColumn(label: Text('حساب')),
                    DataColumn(label: Text('نوع رویداد')),
                    DataColumn(label: Text('وضعیت')),
                    DataColumn(label: Text('تعداد')),
                    DataColumn(label: Text('اثر هنگام ثبت')),
                    DataColumn(label: Text('موجودی پس از ثبت')),
                    DataColumn(label: Text('ساعت حذف')),
                    DataColumn(label: Text('موجودی پس از حذف')),
                    DataColumn(label: Text('توضیح')),
                    DataColumn(label: Text('اطلاعات فنی')),
                  ],
                  rows: [
                    for (final op in ops) _buildDataRow(op),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: const Color(0xFFFAF7F0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 720;
          if (narrow) {
            return Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 10),
                _buildTypeFilter(),
                const SizedBox(height: 10),
                _buildStatusFilter(),
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 3, child: _buildSearchField()),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: _buildTypeFilter()),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: _buildStatusFilter()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => controller.searchQuery.value = value,
      decoration: _controlDecoration(
        hint: 'جست‌وجوی نام حساب، توضیح یا شناسه…',
      ),
      style: const TextStyle(
        color: ItemMovementReportColors.ink,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.typeFilter.value,
        decoration: _controlDecoration(),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('همه ورود و خروج‌ها')),
          DropdownMenuItem(value: 'input', child: Text('فقط ورودی‌ها')),
          DropdownMenuItem(value: 'output', child: Text('فقط خروجی‌ها')),
        ],
        onChanged: (value) {
          if (value != null) controller.typeFilter.value = value;
        },
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.statusFilter.value,
        decoration: _controlDecoration(),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('همه وضعیت‌ها')),
          DropdownMenuItem(value: 'active', child: Text('فقط فعال')),
          DropdownMenuItem(value: 'deleted', child: Text('فقط حذف‌شده')),
        ],
        onChanged: (value) {
          if (value != null) controller.statusFilter.value = value;
        },
      ),
    );
  }

  DataRow _buildDataRow(OperationModel op) {
    final deleted = _isDeleted(op);
    final input = _isInput(op);
    final anomaly = op.hasDateMismatch == true;
    final effect = op.balanceEffect ?? 0;

    return DataRow(
      color: WidgetStateProperty.resolveWith((states) {
        if (deleted) {
          return ItemMovementReportColors.redSoft.withValues(alpha: 0.52);
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFFFFFCF5);
        }
        return null;
      }),
      cells: [
        DataCell(
          Container(
            decoration: anomaly
                ? const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFFD37A1E), width: 4),
                    ),
                  )
                : null,
            padding: anomaly ? const EdgeInsets.only(right: 6) : EdgeInsets.zero,
            child: Text(
              op.operationTime ?? _dash,
              style: const TextStyle(
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                op.accountName ?? _dash,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                'کد حساب: ${op.accountCode ?? _dash}',
                style: const TextStyle(
                  color: ItemMovementReportColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          _badge(
            op.movementType ?? _dash,
            color: input
                ? const Color(0xFF0F614B)
                : const Color(0xFF96312B),
            background: input
                ? ItemMovementReportColors.greenSoft
                : ItemMovementReportColors.redSoft,
          ),
        ),
        DataCell(
          _badge(
            op.status ?? _dash,
            color: deleted
                ? const Color(0xFF96312B)
                : const Color(0xFF0F614B),
            background: deleted
                ? ItemMovementReportColors.redSoft
                : ItemMovementReportColors.greenSoft,
          ),
        ),
        DataCell(
          Text(
            _faNum(op.quantity),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        DataCell(
          Text(
            _effectLabel(effect),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: effect >= 0
                  ? ItemMovementReportColors.green
                  : ItemMovementReportColors.red,
            ),
          ),
        ),
        DataCell(
          Container(
            constraints: const BoxConstraints(minWidth: 64),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: ItemMovementReportColors.blueSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              _faNum(op.balanceAfterOperation),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF21373E),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        DataCell(
          deleted && _deleteTime(op) != _dash
              ? Text(
                  _deleteTime(op),
                  style: const TextStyle(
                    color: ItemMovementReportColors.red,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : Text(
                  _dash,
                  style: const TextStyle(color: Color(0xFF9AA0A4)),
                ),
        ),
        const DataCell(
          Text(
            '—',
            style: TextStyle(color: Color(0xFF9AA0A4)),
          ),
        ),
        const DataCell(
          Text(
            '—',
            style: TextStyle(color: Color(0xFF515960)),
          ),
        ),
        DataCell(_buildTechnical(op)),
      ],
    );
  }

  Widget _badge(String text, {required Color color, required Color background}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTechnical(OperationModel op) {
    return TextButton(
      onPressed: () => _showTechnicalDetails(op),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'نمایش جزئیات',
        style: TextStyle(
          color: ItemMovementReportColors.blue,
          fontSize: 13,
        ),
      ),
    );
  }

  Future<void> _showTechnicalDetails(OperationModel op) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'اطلاعات فنی',
            style: TextStyle(
              color: ItemMovementReportColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _techLine('شناسه ردیف', op.inventoryDetailId?.toString()),
                _techLine('شناسه سند', op.inventoryId?.toString()),
                _techLine('شناسه حساب', op.accountId?.toString()),
                _techLine('شناسه کیف پول', op.walletId?.toString()),
                _techLine('زمان ایجاد', _formatDateTime(op.createdOn)),
                _techLine('زمان آخرین تغییر', _formatDateTime(op.modifiedOn)),
                _techLine('ایجادکننده', op.createdBy?.toString()),
                _techLine('ویرایش‌کننده', op.modifiedBy?.toString()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'بستن',
                style: TextStyle(color: ItemMovementReportColors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _techLine(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            color: Color(0xFF545D62),
            fontSize: 11.5,
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: (value == null || value.isEmpty) ? _dash : value,
              style: const TextStyle(
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SummaryKind { normal, input, output, deleted, finalCard }

class _SummaryCardData {
  final String label;
  final String value;
  final String note;
  final Color? valueColor;
  final _SummaryKind kind;

  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.note,
    this.valueColor,
    this.kind = _SummaryKind.normal,
  });
}
