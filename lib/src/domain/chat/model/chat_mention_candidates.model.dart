import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'chat_mention_candidates.model.g.dart';

List<ChatMentionCandidatesModel> chatMentionCandidatesModelFromJson(String str) => List<ChatMentionCandidatesModel>.from(json.decode(str).map((x) => ChatMentionCandidatesModel.fromJson(x)));

String chatMentionCandidatesModelToJson(List<ChatMentionCandidatesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable()
class ChatMentionCandidatesModel {
  @JsonKey(name: "accountId")
  final int? accountId;
  @JsonKey(name: "userId")
  final int? userId;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "type")
  final String? type;

  ChatMentionCandidatesModel({
    required this.accountId,
    required this.userId,
    required this.name,
    required this.type,
  });

  factory ChatMentionCandidatesModel.fromJson(Map<String, dynamic> json) => _$ChatMentionCandidatesModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMentionCandidatesModelToJson(this);
}