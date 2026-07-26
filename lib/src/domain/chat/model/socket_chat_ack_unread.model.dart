import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'socket_envelope_normalize.dart';
part 'socket_chat_ack_unread.model.g.dart';

SocketChatAckUnreadModel socketChatAckUnreadModelFromJson(String str) => SocketChatAckUnreadModel.fromJson(json.decode(str));

String socketChatAckUnreadModelToJson(SocketChatAckUnreadModel data) => json.encode(data.toJson());
///  "channel": "ack",
@JsonSerializable()
class SocketChatAckUnreadModel {
  @JsonKey(name: "channel")
  final String? channel;
  @JsonKey(name: "reqId")
  final String? reqId;
  @JsonKey(name: "sessionId")
  final String? sessionId;
  @JsonKey(name: "data")
  final int? data;

  SocketChatAckUnreadModel({
    required this.channel,
    required this.reqId,
    required this.sessionId,
    required this.data,
  });

  factory SocketChatAckUnreadModel.fromJson(Map<String, dynamic> json) =>
      _$SocketChatAckUnreadModelFromJson(normalizeSocketEnvelopeJson(json));

  Map<String, dynamic> toJson() => _$SocketChatAckUnreadModelToJson(this);
}