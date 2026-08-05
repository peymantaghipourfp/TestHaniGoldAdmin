import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/toast.service.dart';
import 'package:hanigold_admin/src/config/repository/inventory.repository.dart';
import 'package:hanigold_admin/src/config/repository/item.repository.dart';
import 'package:hanigold_admin/src/domain/inventory/model/item_movement_report.model.dart';
import 'package:hanigold_admin/src/domain/inventory/model/operation.model.dart';
import 'package:hanigold_admin/src/domain/product/model/item.model.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class ItemMovementReportController extends GetxController {
  final InventoryRepository inventoryRepository = InventoryRepository();
  final ItemRepository itemRepository = ItemRepository();

  final TextEditingController dateController = TextEditingController();

  final RxList<ItemModel> itemList = <ItemModel>[].obs;
  final Rxn<ItemModel> selectedItem = Rxn<ItemModel>();
  final Rxn<ItemMovementReportModel> report = Rxn<ItemMovementReportModel>();

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString typeFilter = 'all'.obs;
  final RxString statusFilter = 'all'.obs;
  final RxList<OperationModel> visibleOperations = <OperationModel>[].obs;
  final RxString errorMessage = ''.obs;

  final List<OperationModel> _allOperations = <OperationModel>[];
  final List<_IndexedOperation> _indexedOperations = <_IndexedOperation>[];

  Worker? _searchDebounceWorker;
  Worker? _typeWorker;
  Worker? _statusWorker;

  bool _suspendFiltering = false;

  @override
  void onInit() {
    final now = Jalali.now();
    dateController.text =
    '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';

    fetchItemList();

    _searchDebounceWorker = debounce<String>(
      searchQuery,
          (_) => _applyFilters(),
      time: const Duration(milliseconds: 300),
    );

    _typeWorker = ever<String>(typeFilter, (_) => _applyFilters());
    _statusWorker = ever<String>(statusFilter, (_) => _applyFilters());

    super.onInit();
  }

  @override
  void onClose() {
    _searchDebounceWorker?.dispose();
    _typeWorker?.dispose();
    _statusWorker?.dispose();
    dateController.dispose();
    super.onClose();
  }

  static String formatGregorianApiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  static String? convertJalaliToGregorianForApi(String jalaliDateString) {
    final trimmed = jalaliDateString.trim();
    if (trimmed.isEmpty) return null;
    try {
      final parts = trimmed.split(' ');
      final datePart = parts[0];
      final dateComponents = datePart.split('/');
      if (dateComponents.length != 3) return null;

      final year = int.parse(dateComponents[0]);
      final month = int.parse(dateComponents[1]);
      final day = int.parse(dateComponents[2]);

      final jalaliDate = Jalali(year, month, day);
      final gregorianDate = jalaliDate.toDateTime();

      return formatGregorianApiDate(gregorianDate);
    } catch (_) {
      return null;
    }
  }

  void onSearchChanged(String value) {
    if (searchQuery.value == value) return;
    searchQuery.value = value;
  }

  Future<void> fetchItemList() async {
    try {
      final fetchedItemList = await itemRepository.getItemList();
      itemList.assignAll(fetchedItemList);
    } catch (e) {
      errorMessage.value = e.toString();
      ToastService().error('خطایی هنگام بارگذاری محصولات به وجود آمده است');
    }
  }

  Future<void> fetchReport() async {
    final itemId = selectedItem.value?.id;
    if (itemId == null) {
      ToastService().error('لطفا محصول را انتخاب کنید');
      return;
    }

    EasyLoading.show(status: 'لطفا منتظر بمانید');
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final gregorianDate = convertJalaliToGregorianForApi(dateController.text);
      if (gregorianDate == null) {
        report.value = null;
        _clearOperations();
        ToastService().error('تاریخ وارد شده معتبر نیست');
        return;
      }

      final result = await inventoryRepository.getItemMovementReport(
        fromDate: gregorianDate,
        toDate: gregorianDate,
        itemId: itemId,
      );

      report.value = result;

      final ops = result.days
          ?.expand((d) => d.operations ?? const <OperationModel>[])
          .toList(growable: false) ??
          const <OperationModel>[];

      _setOperations(ops);
      _applyFilters();
    } catch (e) {
      errorMessage.value = e.toString();
      report.value = null;
      _clearOperations();
      ToastService().error('خطایی هنگام دریافت گزارش به وجود آمده است');
    } finally {
      EasyLoading.dismiss();
      isLoading.value = false;
    }
  }

  void resetFilters() {
    _suspendFiltering = true;
    searchQuery.value = '';
    typeFilter.value = 'all';
    statusFilter.value = 'all';
    _suspendFiltering = false;
    _applyFilters();
  }

  void _setOperations(List<OperationModel> operations) {
    _allOperations
      ..clear()
      ..addAll(operations);

    _indexedOperations
      ..clear()
      ..addAll(operations.map(_IndexedOperation.fromOperation));
  }

  void _clearOperations() {
    _allOperations.clear();
    _indexedOperations.clear();
    visibleOperations.clear();
  }

  void _applyFilters() {
    if (_suspendFiltering) return;

    final q = searchQuery.value.trim().toLowerCase();
    final type = typeFilter.value;
    final status = statusFilter.value;

    if (q.isEmpty && type == 'all' && status == 'all') {
      visibleOperations.assignAll(_allOperations);
      return;
    }

    final List<OperationModel> result = <OperationModel>[];

    for (final item in _indexedOperations) {
      if (q.isNotEmpty && !item.searchText.contains(q)) continue;
      if (type != 'all' && item.direction != type) continue;
      if (status == 'deleted' && !item.deleted) continue;
      if (status == 'active' && item.deleted) continue;

      result.add(item.operation);
    }

    visibleOperations.assignAll(result);
  }
}

class _IndexedOperation {
  final OperationModel operation;
  final String searchText;
  final String direction; // input | output
  final bool deleted;

  const _IndexedOperation({
    required this.operation,
    required this.searchText,
    required this.direction,
    required this.deleted,
  });

  factory _IndexedOperation.fromOperation(OperationModel op) {
    final deleted = (op.status ?? '').contains('حذف');
    final direction = (op.balanceEffect ?? 0) >= 0 ? 'input' : 'output';

    final searchText = [
      op.accountName,
      op.accountCode,
      op.accountId?.toString(),
      op.inventoryDetailId?.toString(),
      op.inventoryId?.toString(),
      op.movementType,
      op.operationTime,
      op.eventTitle,
      op.createdByName,
      op.removedByName,
    ].whereType<String>().join(' ').toLowerCase();

    return _IndexedOperation(
      operation: op,
      searchText: searchText,
      direction: direction,
      deleted: deleted,
    );
  }
}