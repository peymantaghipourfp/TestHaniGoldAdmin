import 'package:flutter_test/flutter_test.dart';
import 'package:hanigold_admin/src/domain/inventory/controller/item_movement_report.controller.dart';
import 'package:hanigold_admin/src/domain/inventory/model/operation.model.dart';

OperationModel _op({
  String? accountName,
  String? status,
  double? balanceEffect,
  String? movementType,
}) =>
    OperationModel(
      inventoryDetailId: 1,
      inventoryId: 1,
      accountId: 1,
      accountCode: '100',
      accountName: accountName ?? 'حساب تست',
      operationDate: DateTime(2026, 5, 21),
      operationPersianDate: '1405/02/31',
      operationTime: '11:45:29',
      type: 1,
      movementType: movementType ?? 'ورودی انبار',
      status: status ?? 'فعال',
      quantity: 1,
      balanceEffect: balanceEffect ?? 1,
      balanceAfterOperation: 10,
      walletId: null,
      receiptNumber: null,
      createdOn: DateTime(2026, 5, 21, 11, 45),
      modifiedOn: DateTime(2026, 5, 21, 11, 45),
      createdBy: 1,
      modifiedBy: 1,
      isPriorPeriodOperation: false,
      hasDateMismatch: false,
    );

void main() {
  test('formatGregorianApiDate zero-pads month and day', () {
    expect(
      ItemMovementReportController.formatGregorianApiDate(DateTime(2026, 5, 21)),
      '2026-05-21',
    );
  });

  test('convertJalaliToGregorianForApi parses valid Jalali date', () {
    expect(
      ItemMovementReportController.convertJalaliToGregorianForApi('1405/02/31'),
      '2026-05-21',
    );
  });

  test('convertJalaliToGregorianForApi returns null for empty or invalid', () {
    expect(
      ItemMovementReportController.convertJalaliToGregorianForApi(''),
      isNull,
    );
    expect(
      ItemMovementReportController.convertJalaliToGregorianForApi('not-a-date'),
      isNull,
    );
    expect(
      ItemMovementReportController.convertJalaliToGregorianForApi('1405/13/01'),
      isNull,
    );
  });

  test('filter matches account name search and input type', () {
    final op = _op(accountName: 'خانم شریفی', balanceEffect: 2);
    expect(
      ItemMovementReportController.operationMatchesFilters(
        op: op,
        query: 'شریفی',
        typeFilter: 'input',
        statusFilter: 'all',
      ),
      isTrue,
    );
  });

  test('filter excludes deleted when statusFilter is active', () {
    final op = _op(status: 'حذف‌شده', balanceEffect: -1);
    expect(
      ItemMovementReportController.operationMatchesFilters(
        op: op,
        query: '',
        typeFilter: 'all',
        statusFilter: 'active',
      ),
      isFalse,
    );
  });
}
