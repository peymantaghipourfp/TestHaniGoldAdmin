import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'admin_chat_topic.model.g.dart';

List<AdminChatTopicModel> adminChatTopicModelFromJson(String str) => List<AdminChatTopicModel>.from(json.decode(str).map((x) => AdminChatTopicModel.fromJson(x)));

String adminChatTopicModelToJson(List<AdminChatTopicModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable()
class AdminChatTopicModel {
  @JsonKey(name: "topicId")
  final int? topicId;
  @JsonKey(name: "userId")
  final int? userId;
  @JsonKey(name: "topicCode")
  final String? topicCode;
  @JsonKey(name: "topicTitle")
  final String? topicTitle;
  @JsonKey(name: "userName")
  final String? userName;
  @JsonKey(name: "accountId")
  final int? accountId;
  @JsonKey(name: "accountName")
  final String? accountName;
  @JsonKey(name: "rowNum")
  final int? rowNum;
  @JsonKey(name: "id")
  final int? id;
  @JsonKey(name: "attribute")
  final String? attribute;
  @JsonKey(name: "recId")
  final String? recId;
  @JsonKey(name: "infos")
  final List<dynamic>? infos;

  AdminChatTopicModel({
    required this.topicId,
    required this.userId,
    required this.topicCode,
    required this.topicTitle,
    required this.userName,
    required this.accountId,
    required this.accountName,
    required this.rowNum,
    required this.id,
    required this.attribute,
    required this.recId,
    required this.infos,
  });

  factory AdminChatTopicModel.fromJson(Map<String, dynamic> json) => _$AdminChatTopicModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdminChatTopicModelToJson(this);
}