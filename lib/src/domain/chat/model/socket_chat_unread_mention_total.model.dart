import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'socket_envelope_normalize.dart';
part 'socket_chat_unread_mention_total.model.g.dart';

SocketChatUnreadMentionTotalModel socketChatUnreadMentionTotalModelFromJson(String str) =>
    SocketChatUnreadMentionTotalModel.fromJson(json.decode(str));

String socketChatUnreadMentionTotalModelToJson(SocketChatUnreadMentionTotalModel data) =>
    json.encode(data.toJson());

/// Outbound request: `{ "channel": "chat.unread.mentions.total", "reqId": "..." }` (no `data`).
@JsonSerializable(includeIfNull: false)
class SocketChatUnreadMentionTotalRequest {
  @JsonKey(name: 'channel')
  final String channel;
  @JsonKey(name: 'reqId')
  final String reqId;

  const SocketChatUnreadMentionTotalRequest({
    this.channel = 'chat.unread.mentions.total',
    required this.reqId,
  });

  factory SocketChatUnreadMentionTotalRequest.fromJson(Map<String, dynamic> json) =>
      _$SocketChatUnreadMentionTotalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SocketChatUnreadMentionTotalRequestToJson(this);
}

/// Inbound ack response to [SocketChatUnreadMentionTotalRequest]:
/// `{ "channel": "ack", "reqId": "...", "data": { "totalUnreadMentionCount" } }`
@JsonSerializable()
class SocketChatUnreadMentionTotalModel {
  @JsonKey(name: 'channel')
  final String? channel;
  @JsonKey(name: 'reqId')
  final String? reqId;
  @JsonKey(name: 'sessionId')
  final String? sessionId;
  @JsonKey(name: 'data')
  final UnreadMentionTotalData? data;

  SocketChatUnreadMentionTotalModel({
    required this.channel,
    required this.reqId,
    required this.sessionId,
    required this.data,
  });

  factory SocketChatUnreadMentionTotalModel.fromJson(Map<String, dynamic> json) =>
      _$SocketChatUnreadMentionTotalModelFromJson(normalizeSocketEnvelopeJson(json));

  Map<String, dynamic> toJson() => _$SocketChatUnreadMentionTotalModelToJson(this);
}

@JsonSerializable()
class UnreadMentionTotalData {
  @JsonKey(name: 'totalUnreadMentionCount')
  final int? totalUnreadMentionCount;

  UnreadMentionTotalData({
    required this.totalUnreadMentionCount,
  });

  factory UnreadMentionTotalData.fromJson(Map<String, dynamic> json) =>
      _$UnreadMentionTotalDataFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadMentionTotalDataToJson(this);
}
