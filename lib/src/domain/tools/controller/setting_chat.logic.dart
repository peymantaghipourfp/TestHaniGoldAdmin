import 'package:hanigold_admin/src/domain/account/model/account.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/topic.model.dart';
import 'package:hanigold_admin/src/domain/tools/model/admin_chat_topic.model.dart';

int? parseSettingChatDynamicId(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

int? userIdFromAccountUserIds(AccountModel account) {
  final userIds = account.userIds;
  if (userIds == null || userIds.isEmpty) {
    return null;
  }
  return parseSettingChatDynamicId(userIds.first);
}

int? userIdFromAssignedTopics(List<AdminChatTopicModel> assignedTopics) {
  for (final topic in assignedTopics) {
    if (topic.userId != null) {
      return topic.userId;
    }
  }
  return null;
}

int? resolveSettingChatUserId(
    AccountModel account, {
      List<AdminChatTopicModel> assignedTopics = const [],
      int? cachedUserId,
    }) {
  if (cachedUserId != null) {
    return cachedUserId;
  }
  return userIdFromAccountUserIds(account) ??
      userIdFromAssignedTopics(assignedTopics);
}

List<AccountModel> filterSettingChatAccounts(
    List<AccountModel> accounts,
    String query,
    ) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return accounts;
  }
  return accounts.where((account) {
    final name = (account.name ?? '').toLowerCase();
    final code = (account.code ?? '').toLowerCase();
    return name.contains(normalized) || code.contains(normalized);
  }).toList();
}

List<TopicModel> availableSettingChatTopics(
    List<TopicModel> allTopics,
    List<AdminChatTopicModel> assignedTopics,
    ) {
  final assignedIds =
  assignedTopics.map((item) => item.topicId).whereType<int>().toSet();
  return allTopics
      .where(
        (topic) =>
    topic.topicId != null && !assignedIds.contains(topic.topicId),
  )
      .toList();
}

TopicModel topicModelFromMissingAdminChat(AdminChatTopicModel item) {
  return TopicModel(
    topicId: item.topicId,
    code: item.topicCode,
    title: item.topicTitle,
    sortOrder: null,
  );
}

List<TopicModel> missingAdminChatTopicsAsTopicModels(
    List<AdminChatTopicModel> items,
    ) {
  return items
      .where((item) => item.topicId != null)
      .map(topicModelFromMissingAdminChat)
      .toList();
}
