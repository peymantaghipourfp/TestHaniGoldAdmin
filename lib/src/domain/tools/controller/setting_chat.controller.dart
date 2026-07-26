import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/toast.service.dart';
import 'package:hanigold_admin/src/config/repository/setting_chat.repository.dart';
import 'package:hanigold_admin/src/domain/account/model/account.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/topic.model.dart';
import 'package:hanigold_admin/src/domain/tools/controller/setting_chat.logic.dart';
import 'package:hanigold_admin/src/domain/tools/model/admin_chat_topic.model.dart';

enum SettingChatPageState { loading, list, empty, error }

class SettingChatController extends GetxController {
  final SettingChatRepository _repository = SettingChatRepository();
  final TextEditingController accountSearchController = TextEditingController();

  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final RxList<AdminChatTopicModel> assignedTopics = <AdminChatTopicModel>[].obs;
  final RxList<TopicModel> allTopics = <TopicModel>[].obs;

  final Rx<SettingChatPageState> accountsState =
      SettingChatPageState.loading.obs;
  final Rx<SettingChatPageState> assignedTopicsState =
      SettingChatPageState.loading.obs;

  final RxBool isLoadingAllTopics = false.obs;
  final RxBool isAssigning = false.obs;
  final RxInt deletingTopicId = (-1).obs;

  final Rxn<AccountModel> selectedAccount = Rxn<AccountModel>();
  final Rxn<int> resolvedUserId = Rxn<int>();
  final Rxn<TopicModel> topicToAssign = Rxn<TopicModel>();
  final RxString accountSearchQuery = ''.obs;
  final RxString accountsError = ''.obs;
  final RxString assignedTopicsError = ''.obs;

  List<AccountModel> get filteredAccounts =>
      filterSettingChatAccounts(accounts, accountSearchQuery.value);

  List<TopicModel> get availableTopicsToAssign =>
      availableSettingChatTopics(allTopics, assignedTopics);

  @override
  void onInit() {
    super.onInit();
    accountSearchController.addListener(_onAccountSearchChanged);
    fetchAccounts();
    //fetchAllTopics();
  }

  @override
  void onClose() {
    accountSearchController.removeListener(_onAccountSearchChanged);
    accountSearchController.dispose();
    super.onClose();
  }

  void _onAccountSearchChanged() {
    accountSearchQuery.value = accountSearchController.text;
  }

  Future<void> fetchAccounts() async {
    accountsState.value = SettingChatPageState.loading;
    accountsError.value = '';
    try {
      final result = await _repository.getAccountListAdmin('');
      accounts.assignAll(result);
      accountsState.value =
      result.isEmpty ? SettingChatPageState.empty : SettingChatPageState.list;
    } catch (e) {
      accountsError.value = e.toString();
      accountsState.value = SettingChatPageState.error;
      ToastService().error('خطا در دریافت لیست کاربران');
    }
  }

  /*Future<void> fetchAllTopics() async {
    isLoadingAllTopics.value = true;
    try {
      final result = await _repository.getTopics();
      allTopics.assignAll(result);
    } catch (e) {
      ToastService().error('خطا در دریافت موضوعات');
    } finally {
      isLoadingAllTopics.value = false;
    }
  }*/


  Future<void> fetchMissingTopics(String accountId) async {
    isLoadingAllTopics.value = true;
    allTopics.clear();
    try {
      final result =
      await _repository.getMissingAdminChatTopic(accountId: accountId);
      allTopics.assignAll(missingAdminChatTopicsAsTopicModels(result));
    } catch (e) {
      ToastService().error('خطا در دریافت موضوعات اختصاص نیافته');
    } finally {
      isLoadingAllTopics.value = false;
    }
  }


  Future<void> selectAccount(AccountModel account) async {
    if (account.id == null) {
      ToastService().error('شناسه حساب نامعتبر است');
      return;
    }
    selectedAccount.value = account;
    topicToAssign.value = null;
    resolvedUserId.value = null;
    //await fetchAssignedTopics(account.id!.toString());
    allTopics.clear();
    final accountId = account.id!.toString();
    await fetchAssignedTopics(accountId);
    await fetchMissingTopics(accountId);
    await _resolveUserIdForSelectedAccount(account);
  }

  Future<void> _resolveUserIdForSelectedAccount(AccountModel account) async {
    resolvedUserId.value = resolveSettingChatUserId(
      account,
      assignedTopics: assignedTopics,
    );
    if (resolvedUserId.value != null || account.id == null) {
      return;
    }

    try {
      final detail =
      await _repository.getAccountOne(accountId: account.id!);
      resolvedUserId.value = resolveSettingChatUserId(
        detail,
        assignedTopics: assignedTopics,
      );
    } catch (_) {
      // Fall through to User/getWrapper lookup.
    }

    if (resolvedUserId.value != null) {
      return;
    }

    resolvedUserId.value = await _repository.getUserIdForAccount(
      accountId: account.id!.toString(),
    );
  }

  Future<void> fetchAssignedTopics(String accountId) async {
    assignedTopicsState.value = SettingChatPageState.loading;
    assignedTopicsError.value = '';
    assignedTopics.clear();
    try {
      final result =
      await _repository.getAdminChatTopic(accountId: accountId);
      assignedTopics.assignAll(result);
      assignedTopicsState.value = result.isEmpty
          ? SettingChatPageState.empty
          : SettingChatPageState.list;
      final account = selectedAccount.value;
      if (account != null) {
        final userId = resolveSettingChatUserId(
          account,
          assignedTopics: assignedTopics,
          cachedUserId: resolvedUserId.value,
        );
        if (userId != null) {
          resolvedUserId.value = userId;
        }
      }
    } catch (e) {
      assignedTopicsError.value = e.toString();
      assignedTopicsState.value = SettingChatPageState.error;
      ToastService().error('خطا در دریافت موضوعات کاربر');
    }
  }

  Future<void> assignSelectedTopic() async {
    final account = selectedAccount.value;
    final topic = topicToAssign.value;
    if (account == null) {
      ToastService().error('ابتدا یک کاربر انتخاب کنید');
      return;
    }
    if (topic?.topicId == null) {
      ToastService().error('لطفاً یک موضوع انتخاب کنید');
      return;
    }

    var userId = resolvedUserId.value ??
        resolveSettingChatUserId(
          account,
          assignedTopics: assignedTopics,
        );
    if (userId == null) {
      await _resolveUserIdForSelectedAccount(account);
      userId = resolvedUserId.value;
    }
    if (userId == null) {
      ToastService().error('شناسه کاربر برای این حساب یافت نشد');
      return;
    }

    isAssigning.value = true;
    try {
      await _repository.insertAdminChatTopic(
        topicId: topic!.topicId!,
        userId: userId,
      );
      ToastService().success('موضوع با موفقیت اختصاص داده شد');
      topicToAssign.value = null;
      //await fetchAssignedTopics(account.id!.toString());
      final accountId = account.id!.toString();
      await fetchAssignedTopics(accountId);
      await fetchMissingTopics(accountId);
    } catch (e) {
      ToastService().error('خطا در اختصاص موضوع');
    } finally {
      isAssigning.value = false;
    }
  }

  Future<void> removeAssignedTopic(AdminChatTopicModel topic) async {
    final adminChatTopicId = topic.id;
    final accountId = selectedAccount.value?.id;
    if (adminChatTopicId == null || accountId == null) {
      ToastService().error('اطلاعات موضوع نامعتبر است');
      return;
    }

    deletingTopicId.value = adminChatTopicId;
    try {
      await _repository.deleteAdminChatTopic(adminChatTopicId: adminChatTopicId);
      ToastService().success('موضوع با موفقیت حذف شد');
      //await fetchAssignedTopics(accountId.toString());
      final accountIdStr = accountId.toString();
      await fetchAssignedTopics(accountIdStr);
      await fetchMissingTopics(accountIdStr);
    } catch (e) {
      ToastService().error('خطا در حذف موضوع');
    } finally {
      deletingTopicId.value = -1;
    }
  }
}