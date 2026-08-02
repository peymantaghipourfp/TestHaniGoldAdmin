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
  final List<ItemModel> itemList = <ItemModel>[].obs;
  final Rxn<ItemModel> selectedItem = Rxn<ItemModel>();
  final Rxn<ItemMovementReportModel> report = Rxn<ItemMovementReportModel>();
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final typeFilter = 'all'.obs;
  final statusFilter = 'all'.obs;
  final visibleOperations = <OperationModel>[].obs;
  final errorMessage = ''.obs;

  final List<OperationModel> _allOperations = [];

  @override
  void onInit() {
    final now = Jalali.now();
    dateController.text =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    fetchItemList();
    ever(searchQuery, (_) => _applyFilters());
    ever(typeFilter, (_) => _applyFilters());
    ever(statusFilter, (_) => _applyFilters());
    super.onInit();
  }

  @override
  void onClose() {
    dateController.dispose();
    super.onClose();
  }

  static String formatGregorianApiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static bool operationMatchesFilters({
    required OperationModel op,
    required String query,
    required String typeFilter,
    required String statusFilter,
  }) {
    final deleted = (op.status ?? '').contains('حذف');
    final direction = (op.balanceEffect ?? 0) >= 0 ? 'input' : 'output';
    final haystack = [
      op.accountName,
      op.accountCode,
      op.accountId,
      op.inventoryDetailId,
      op.inventoryId,
      op.movementType,
      op.operationTime,
    ].join(' ').toLowerCase();
    final q = query.trim().toLowerCase();
    final matchesSearch = q.isEmpty || haystack.contains(q);
    final matchesType = typeFilter == 'all' || direction == typeFilter;
    final matchesStatus = statusFilter == 'all' ||
        (statusFilter == 'deleted' ? deleted : !deleted);
    return matchesSearch && matchesType && matchesStatus;
  }

  String convertJalaliToGregorianForApi(String jalaliDateString) {
    try {
      final parts = jalaliDateString.split(' ');
      final datePart = parts[0];

      final dateComponents = datePart.split('/');
      final year = int.parse(dateComponents[0]);
      final month = int.parse(dateComponents[1]);
      final day = int.parse(dateComponents[2]);

      final jalaliDate = Jalali(year, month, day);
      final gregorianDate = jalaliDate.toDateTime();

      return formatGregorianApiDate(gregorianDate);
    } catch (e) {
      return formatGregorianApiDate(DateTime.now());
    }
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
      final result = await inventoryRepository.getItemMovementReport(
        fromDate: gregorianDate,
        toDate: gregorianDate,
        itemId: itemId,
      );
      report.value = result;
      _allOperations
        ..clear()
        ..addAll(
          result.days?.expand((d) => d.operations ?? const <OperationModel>[]) ??
              const <OperationModel>[],
        );
      _applyFilters();
    } catch (e) {
      errorMessage.value = e.toString();
      ToastService().error('خطایی هنگام دریافت گزارش به وجود آمده است');
    } finally {
      EasyLoading.dismiss();
      isLoading.value = false;
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    typeFilter.value = 'all';
    statusFilter.value = 'all';
    _applyFilters();
  }

  void _applyFilters() {
    visibleOperations.assignAll(
      _allOperations.where(
        (op) => operationMatchesFilters(
          op: op,
          query: searchQuery.value,
          typeFilter: typeFilter.value,
          statusFilter: statusFilter.value,
        ),
      ),
    );
  }
}
