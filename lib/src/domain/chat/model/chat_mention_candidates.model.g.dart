// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_mention_candidates.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMentionCandidatesModel _$ChatMentionCandidatesModelFromJson(
        Map<String, dynamic> json) =>
    ChatMentionCandidatesModel(
      accountId: (json['accountId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      name: json['name'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$ChatMentionCandidatesModelToJson(
        ChatMentionCandidatesModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'userId': instance.userId,
      'name': instance.name,
      'type': instance.type,
    };
