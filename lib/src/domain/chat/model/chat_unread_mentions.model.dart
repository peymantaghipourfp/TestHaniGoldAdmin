import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'chat_unread_mentions.model.g.dart';

List<ChatUnreadMentionsModel> chatUnreadMentionsModelFromJson(String str) => List<ChatUnreadMentionsModel>.from(json.decode(str).map((x) => ChatUnreadMentionsModel.fromJson(x)));

String chatUnreadMentionsModelToJson(List<ChatUnreadMentionsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable()
class ChatUnreadMentionsModel {
  @JsonKey(name: "messageGuid")
  final String? messageGuid;
  @JsonKey(name: "seq")
  final int? seq;

  ChatUnreadMentionsModel({
    required this.messageGuid,
    required this.seq,
  });

  factory ChatUnreadMentionsModel.fromJson(Map<String, dynamic> json) => _$ChatUnreadMentionsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatUnreadMentionsModelToJson(this);
}