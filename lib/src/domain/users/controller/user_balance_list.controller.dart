import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/domain/users/model/list_transaction_info_item.model.dart';
import 'package:hanigold_admin/src/domain/users/model/paginated.model.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_info_footer.model.dart';

enum PageState { loading, err, empty, list }

/// Shared contract for user-balance list screens (regular + gold).
abstract interface class UserBalanceListController {
  Rx<PageState> get state;
  RxList<ListTransactionInfoItemModel> get listTransactionInfo;
  RxList<TransactionInfoFooterModel> get listTransactionInfoFooter;
  Rxn<PaginatedModel> get paginated;
  RxnInt get sortColumnIndex;
  RxBool get sortAscending;
  RxBool get isLoading;
  RxBool get hasMore;
  TextEditingController get searchController;
  TextEditingController get nameFilterController;
  ScrollController get scrollControllerMobile;

  void onSort(int columnIndex, bool ascending);
  void isChangePage(int index);
  void clearSearch();
  void clearFilter();
  Future<void> getListTransactionInfoPager();
  Future<void> getListUserInfoTransactionExcel();
}
