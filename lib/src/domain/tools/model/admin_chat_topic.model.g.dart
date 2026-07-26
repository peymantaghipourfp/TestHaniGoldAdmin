// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_chat_topic.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminChatTopicModel _$AdminChatTopicModelFromJson(Map<String, dynamic> json) =>
    AdminChatTopicModel(
      topicId: (json['topicId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      topicCode: json['topicCode'] as String?,
      topicTitle: json['topicTitle'] as String?,
      userName: json['userName'] as String?,
      accountId: (json['accountId'] as num?)?.toInt(),
      accountName: json['accountName'] as String?,
      rowNum: (json['rowNum'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      attribute: json['attribute'] as String?,
      recId: json['recId'] as String?,
      infos: json['infos'] as List<dynamic>?,
    );

Map<String, dynamic> _$AdminChatTopicModelToJson(
        AdminChatTopicModel instance) =>
    <String, dynamic>{
      'topicId': instance.topicId,
      'userId': instance.userId,
      'topicCode': instance.topicCode,
      'topicTitle': instance.topicTitle,
      'userName': instance.userName,
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'rowNum': instance.rowNum,
      'id': instance.id,
      'attribute': instance.attribute,
      'recId': instance.recId,
      'infos': instance.infos,
    };
