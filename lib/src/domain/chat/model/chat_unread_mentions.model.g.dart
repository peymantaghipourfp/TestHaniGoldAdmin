// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_unread_mentions.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatUnreadMentionsModel _$ChatUnreadMentionsModelFromJson(
        Map<String, dynamic> json) =>
    ChatUnreadMentionsModel(
      messageGuid: json['messageGuid'] as String?,
      seq: (json['seq'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChatUnreadMentionsModelToJson(
        ChatUnreadMentionsModel instance) =>
    <String, dynamic>{
      'messageGuid': instance.messageGuid,
      'seq': instance.seq,
    };
