// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socket_chat_unread_mention_total.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketChatUnreadMentionTotalRequest
    _$SocketChatUnreadMentionTotalRequestFromJson(Map<String, dynamic> json) =>
        SocketChatUnreadMentionTotalRequest(
          channel: json['channel'] as String? ?? 'chat.unread.mentions.total',
          reqId: json['reqId'] as String,
        );

Map<String, dynamic> _$SocketChatUnreadMentionTotalRequestToJson(
        SocketChatUnreadMentionTotalRequest instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'reqId': instance.reqId,
    };

SocketChatUnreadMentionTotalModel _$SocketChatUnreadMentionTotalModelFromJson(
        Map<String, dynamic> json) =>
    SocketChatUnreadMentionTotalModel(
      channel: json['channel'] as String?,
      reqId: json['reqId'] as String?,
      sessionId: json['sessionId'] as String?,
      data: json['data'] == null
          ? null
          : UnreadMentionTotalData.fromJson(
              json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SocketChatUnreadMentionTotalModelToJson(
        SocketChatUnreadMentionTotalModel instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'reqId': instance.reqId,
      'sessionId': instance.sessionId,
      'data': instance.data,
    };

UnreadMentionTotalData _$UnreadMentionTotalDataFromJson(
        Map<String, dynamic> json) =>
    UnreadMentionTotalData(
      totalUnreadMentionCount:
          (json['totalUnreadMentionCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UnreadMentionTotalDataToJson(
        UnreadMentionTotalData instance) =>
    <String, dynamic>{
      'totalUnreadMentionCount': instance.totalUnreadMentionCount,
    };
