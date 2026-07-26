import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'socket_envelope_normalize.dart';
part 'socket_chat_unread_total.model.g.dart';

SocketChatUnreadTotalModel socketChatUnreadTotalModelFromJson(String str) =>
    SocketChatUnreadTotalModel.fromJson(json.decode(str));

String socketChatUnreadTotalModelToJson(SocketChatUnreadTotalModel data) =>
    json.encode(data.toJson());

/// Outbound request: `{ "channel": "chat.admin.unread.total", "reqId": "..." }` (no `data`).
@JsonSerializable(includeIfNull: false)
class SocketChatUnreadTotalRequest {
  @JsonKey(name: 'channel')
  final String channel;
  @JsonKey(name: 'reqId')
  final String reqId;

  const SocketChatUnreadTotalRequest({
    this.channel = 'chat.admin.unread.total',
    required this.reqId,
  });

  factory SocketChatUnreadTotalRequest.fromJson(Map<String, dynamic> json) =>
      _$SocketChatUnreadTotalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SocketChatUnreadTotalRequestToJson(this);
}

/// Inbound ack response to [SocketChatUnreadTotalRequest]:
/// `{ "channel": "ack", "reqId": "...", "data": { "totalUnreadMessageCount", "on" } }`
@JsonSerializable()
class SocketChatUnreadTotalModel {
  @JsonKey(name: 'channel')
  final String? channel;
  @JsonKey(name: 'reqId')
  final String? reqId;
  @JsonKey(name: 'sessionId')
  final String? sessionId;
  @JsonKey(name: 'data')
  final UnreadTotalData? data;

  SocketChatUnreadTotalModel({
    required this.channel,
    required this.reqId,
    required this.sessionId,
    required this.data,
  });

  factory SocketChatUnreadTotalModel.fromJson(Map<String, dynamic> json) =>
      _$SocketChatUnreadTotalModelFromJson(normalizeSocketEnvelopeJson(json));

  Map<String, dynamic> toJson() => _$SocketChatUnreadTotalModelToJson(this);
}

@JsonSerializable()
class UnreadTotalData {
  @JsonKey(name: 'totalUnreadMessageCount')
  final int? totalUnreadMessageCount;
  @JsonKey(name: 'on')
  final DateTime? on;

  UnreadTotalData({
    required this.totalUnreadMessageCount,
    required this.on,
  });

  factory UnreadTotalData.fromJson(Map<String, dynamic> json) =>
      _$UnreadTotalDataFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadTotalDataToJson(this);
}
