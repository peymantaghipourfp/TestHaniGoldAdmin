import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import 'chat_message.model.dart';
import 'socket_envelope_normalize.dart';

part 'socket_chat_admin_send.model.g.dart';

ReplyMessage? _forwardMessageFromAdminSendJson(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    return ReplyMessage.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

Map<String, dynamic>? forwardMessageToAdminSendJson(ReplyMessage? message) {
  if (message == null) return null;
  final json = message.toJson();
  final out = <String, dynamic>{};
  void put(String camel, String pascal) {
    final value = json[camel];
    if (value != null) out[pascal] = value;
  }

  put('chatId', 'ChatId');
  put('messageGuid', 'MessageGuid');
  put('seq', 'Seq');
  put('senderType', 'SenderType');
  put('senderAccountId', 'SenderAccountId');
  put('senderUserId', 'SenderUserId');
  put('messageType', 'MessageType');
  put('text', 'Text');
  put('replyToMessageGuid', 'ReplyToMessageGuid');
  put('filesJson', 'FilesJson');
  put('createdOnUtc', 'CreatedOnUtc');
  put('isDeleted', 'IsDeleted');
  put('senderAccountName', 'SenderAccountName');
  return out.isEmpty ? null : out;
}

Object? _forwardMessageToAdminSendJson(ReplyMessage? value) =>
    forwardMessageToAdminSendJson(value);


SocketChatAdminSendModel socketChatAdminSendModelFromJson(String str) => SocketChatAdminSendModel.fromJson(json.decode(str));

String socketChatAdminSendModelToJson(SocketChatAdminSendModel data) => json.encode(data.toJson());
/// "channel": "chat.admin.send",
@JsonSerializable()
class SocketChatAdminSendModel {
  @JsonKey(name: "channel")
  final String? channel;
  @JsonKey(name: "reqId")
  final String? reqId;
  @JsonKey(name: "sessionId")
  final String? sessionId;
  @JsonKey(name: "data")
  final Data? data;

  SocketChatAdminSendModel({
    required this.channel,
    required this.reqId,
    required this.sessionId,
    required this.data,
  });

  factory SocketChatAdminSendModel.fromJson(Map<String, dynamic> json) =>
      _$SocketChatAdminSendModelFromJson(normalizeSocketEnvelopeJson(json));

  Map<String, dynamic> toJson() => _$SocketChatAdminSendModelToJson(this);
}

@JsonSerializable()
class Data {
  @JsonKey(name: "CustomerAccountId")
  final int? customerAccountId;
  @JsonKey(name: "TopicCode")
  final String? topicCode;
  @JsonKey(name: "TopicKey")
  final String? topicKey;
  @JsonKey(name: "Text")
  final String? text;
  @JsonKey(name: "DataJson")
  final String? dataJson;
  @JsonKey(name: "FilesJson")
  final String? filesJson;
  @JsonKey(name: "ReplyToMessageGuid")
  final String? replyToMessageGuid;
  @JsonKey(name: "ForwardFromMessageGuid")
  final String? forwardFromMessageGuid;
  @JsonKey(name: "ForwardFromSenderName")
  final String? forwardFromSenderName;
  @JsonKey(
    name: "ForwardMessage",
    fromJson: _forwardMessageFromAdminSendJson,
    toJson: _forwardMessageToAdminSendJson,
  )
  final ReplyMessage? forwardMessage;
  @JsonKey(name: "ReferenceType")
  final String? referenceType;
  @JsonKey(name: "ReferenceId")
  final int? referenceId;
  @JsonKey(
    name: "Mentions",
    fromJson: normalizeMessageMentionsJson,
    toJson: messageMentionsToJson,
  )
  final List<MessageMention>? mentions;

  Data({
    required this.customerAccountId,
    required this.topicCode,
    required this.topicKey,
    required this.text,
    required this.dataJson,
    required this.filesJson,
    required this.replyToMessageGuid,
    required this.forwardFromMessageGuid,
    required this.forwardFromSenderName,
    required this.forwardMessage,
    required this.referenceType,
    required this.referenceId,
    this.mentions,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class FilesJson {
  @JsonKey(name: "recordId")
  final String? recordId;

  @JsonKey(name: "fileType")
  final String? fileType;

  FilesJson({
    required this.recordId,
    required this.fileType,
  });

  factory FilesJson.fromJson(Map<String, dynamic> json) =>
      _$FilesJsonFromJson(json);

  Map<String, dynamic> toJson() => _$FilesJsonToJson(this);
}