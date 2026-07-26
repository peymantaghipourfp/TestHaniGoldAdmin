import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/inventory/model/inventory_detail.model.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Multi-select dialog for inventory detail rows when issuing a factor PDF.
///
/// Returns selected detail ids via [show], or null if cancelled.
class SelectedFactorDetailDialog extends StatefulWidget {
  final List<InventoryDetailModel> details;

  const SelectedFactorDetailDialog({super.key, required this.details});

  /// Returns selected detail ids, or null if cancelled.
  static Future<List<int>?> show(
      BuildContext context, {
        required List<InventoryDetailModel> details,
      }) async {
    return Get.dialog<List<int>>(
      SelectedFactorDetailDialog(details: details),
      barrierDismissible: true,
    );
  }

  @override
  State<SelectedFactorDetailDialog> createState() =>
      _SelectedFactorDetailDialogState();
}

class _SelectedFactorDetailDialogState
    extends State<SelectedFactorDetailDialog> {
  late final List<InventoryDetailModel> _visibleDetails;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _visibleDetails = widget.details
        .where((d) => d.id != null && d.isDeleted != true)
        .toList();
    // Pre-select all visible rows for convenience.
    _selectedIds.addAll(_visibleDetails.map((d) => d.id!));
  }

  bool get _allSelected =>
      _visibleDetails.isNotEmpty &&
          _selectedIds.length == _visibleDetails.length;

  bool get _noneSelected => _selectedIds.isEmpty;

  void _toggleAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds
          ..clear()
          ..addAll(_visibleDetails.map((d) => d.id!));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleOne(int id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onIssue() {
    if (_noneSelected) {
      Get.snackbar(
        'توجه',
        'لطفاً حداقل یک ردیف را انتخاب کنید',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.secondaryColor,
        colorText: AppColor.textColor,
      );
      return;
    }
    Navigator.pop(context, _selectedIds.toList());
  }

  String _displayName(InventoryDetailModel detail) {
    final name = detail.itemName ?? detail.item?.name;
    if (name == null || name.trim().isEmpty) {
      return 'نامشخص';
    }
    return name;
  }

  String _formatNumber(double? value) {
    if (value == null) return 'نامشخص';
    final asInt = value == value.roundToDouble() ? value.toInt() : value;
    return asInt.toString().seRagham(separator: ',');
  }

  String _subtitle(InventoryDetailModel detail) {
    final quantity = _formatNumber(detail.quantity);
    final weight = _formatNumber(detail.weight);
    final receipt = (detail.receiptNumber == null ||
        detail.receiptNumber!.trim().isEmpty)
        ? 'نامشخص'
        : detail.receiptNumber!;
    return 'مقدار: $quantity  |  وزن: $weight  |  رسید: $receipt';
  }

  @override
  Widget build(BuildContext context) {
    final width =
    MediaQuery.sizeOf(context).width > 700 ? 520.0 : Get.width * 0.92;
    final maxHeight = Get.height * 0.75;

    return Dialog(
      backgroundColor: AppColor.backGroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColor.secondaryColor),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.checklist, color: AppColor.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'انتخاب ردیف‌های فاکتور',
                      style: AppTextStyle.smallTitleText.copyWith(
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _onCancel,
                    icon: Icon(Icons.close, color: AppColor.textColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Container(
                height: 0.6,
                color: AppColor.textColor.withValues(alpha: 0.4),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              if (_visibleDetails.isNotEmpty)
                CheckboxListTile(
                  value: _allSelected,
                  onChanged: _toggleAll,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColor.primaryColor,
                  checkColor: AppColor.backGroundColor,
                  title: Text(
                    'انتخاب همه',
                    style: AppTextStyle.bodyTextBold,
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              Flexible(
                child: _visibleDetails.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'ردیفی برای انتخاب وجود ندارد',
                      style: AppTextStyle.bodyText.copyWith(
                        color: AppColor.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _visibleDetails.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColor.secondaryColor,
                  ),
                  itemBuilder: (context, index) {
                    final detail = _visibleDetails[index];
                    final id = detail.id!;
                    return CheckboxListTile(
                      value: _selectedIds.contains(id),
                      onChanged: (value) => _toggleOne(id, value),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColor.primaryColor,
                      checkColor: AppColor.backGroundColor,
                      title: Text(
                        _displayName(detail),
                        style: AppTextStyle.bodyTextBold,
                      ),
                      subtitle: Text(
                        _subtitle(detail),
                        style: AppTextStyle.labelText.copyWith(
                          color:
                          AppColor.textColor.withValues(alpha: 0.8),
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      WidgetStatePropertyAll(AppColor.accentColor),
                    ),
                    onPressed: _onCancel,
                    child: Text('انصراف', style: AppTextStyle.bodyText),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      WidgetStatePropertyAll(AppColor.primaryColor),
                    ),
                    onPressed: _onIssue,
                    child: Text('صدور', style: AppTextStyle.bodyText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
