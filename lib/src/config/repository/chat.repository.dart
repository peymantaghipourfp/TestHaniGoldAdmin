import 'package:dio/dio.dart';
import 'package:hanigold_admin/src/config/network/error/network.error.dart';
import 'package:hanigold_admin/src/config/repository/url/base_url.dart';
import 'package:hanigold_admin/src/domain/chat/model/account_admin.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat_account.model.dart';
import 'package:hanigold_admin/src/domain/chat/model/chat_mention_candidates.model.dart';

import '../../domain/chat/model/chat_message.model.dart';
import '../../domain/chat/model/chat_unread_mentions.model.dart';
import '../../domain/chat/model/topic.model.dart';
import '../logger/app_logger.dart';
import '../network/dio_Interceptor.dart';
import '../network/error_handler.dart';

class ChatRepository {
  Dio chatDio = Dio();

  ChatRepository() {
    chatDio.options.baseUrl = BaseUrl.baseUrl;
    chatDio.interceptors.add(DioInterceptor());
  }

  // Get account chat list
  Future<List<ChatAccountModel>> getChatAccountList({
    int startIndex = 1,
    int toIndex = 20,
    String? searchText,
  }) async {
    try {
      final trimmed = searchText?.trim();
      final Map<String, dynamic> chat = {
        "orderBy": "AccountLast.LastMessageOn",
        "orderByType": "desc",
        "StartIndex": startIndex,
        "ToIndex": toIndex,
        if (trimmed != null && trimmed.isNotEmpty)
          "predicate": [
            {
              "innerCondition": 1,
              "outerCondition": 0,
              "filters": [
                {
                  "fieldName": "SearchText",
                  "filterValue": trimmed,
                  "filterType": 0,
                  "refTable": "Chat"
                }
              ]
            }
          ],
      };

      final Map<String, dynamic> options = {
        "options": {"chat": chat}
      };

      final response = await chatDio.post('Chat/getChatAccount', data: options);

      if (response.statusCode == 200) {
        /*List<dynamic> data = response.data;
        return data.map((chatAccount) => ChatAccountModel.fromJson(chatAccount)).toList();*/
        final dynamic body = response.data;
        if (body == null) return <ChatAccountModel>[];
        if (body is! List) return <ChatAccountModel>[];
        return body
            .map((chatAccount) => ChatAccountModel.fromJson(chatAccount))
            .toList();
      } else {
        throw ErrorException('خطا در دریافت لیست چت ‌اکانت ها');
      }
    } catch (e,s) {
      AppLogger.e('getChatAccountList failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  // Get chat list
  Future<List<ChatModel>> getChatList(
      String accountId, {
        int startIndex = 1,
        int toIndex = 20,
        int? chatStatus,
        String? topicCode,
        String? searchText,
      }) async {
    try {
      final trimmedTopic = topicCode?.trim();
      final trimmedSearch = searchText?.trim();
      final List<Map<String, dynamic>> filters = [
        {
          "fieldName": "accountId",
          "filterValue": accountId,
          "filterType": 5,
          "RefTable": "ChatSession"
        },
        if (chatStatus != null)
          {
            "fieldName": "status",
            "filterValue": chatStatus.toString(),
            "filterType": 5,
            "RefTable": "ChatSession"
          },
        if (trimmedTopic != null && trimmedTopic.isNotEmpty)
          {
            "fieldName": "topicCode",
            "filterValue": trimmedTopic,
            "filterType": 4,
            "RefTable": "ChatSession"
          },
        if (trimmedSearch != null && trimmedSearch.isNotEmpty)
          {
            "fieldName": "SearchText",
            "filterValue": trimmedSearch,
            "filterType": 0,
            "RefTable": "Chat"
          },
      ];

      Map<String, dynamic> options = {
        "options" : { "chat" :{
          "Predicate": [
            {
              "innerCondition": 0,
              "outerCondition": 0,
              "filters": filters
            }
          ],
          "orderBy": "ChatSession.LastActivity",
          "orderByType": "desc",
          "StartIndex": startIndex,
          "ToIndex": toIndex
        }}
      };
      final response = await chatDio.post('Chat/getChat', data: options);
      if (response.statusCode == 200) {
        final dynamic body = response.data;
        if (body == null) return <ChatModel>[];
        if (body is! List) return <ChatModel>[];
        return body.map((chat) => ChatModel.fromJson(chat)).toList();
      } else {
        throw ErrorException('خطا در دریافت لیست چت‌ها');
      }
    } catch (e,s) {
      AppLogger.e('getChatList failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  // Get chat messages
  Future<List<ChatMessageModel>> getChatMessages(
      String chatId, {
        int startIndex = 1,
        int toIndex = 20,
        String? textSearch,
      }) async {
    try {
      final trimmedSearch = textSearch?.trim();
      final List<Map<String, dynamic>> filters = [
        {
          "fieldName": "ChatId",
          "filterValue": chatId,
          "filterType": 4,
          "RefTable": "ChatMessage"
        },
        if (trimmedSearch != null && trimmedSearch.isNotEmpty)
          {
            "fieldName": "Text",
            "filterValue": trimmedSearch,
            "filterType": 0,
            "RefTable": "ChatMessage"
          },
      ];
      Map<String, dynamic> options = {"options" :
      { "chat": {
        "Predicate": [
          {
            "innerCondition": 1,
            "outerCondition": 0,
            "filters": filters
          }
        ],
        "orderBy": "ChatMessage.Seq",
        "orderByType": "desc",
        "StartIndex": startIndex,
        "ToIndex": toIndex
      }
      }
      };

      final response = await chatDio.post('Chat/getChatMessagesByChatId', data: options);

      if (response.statusCode == 200) {
        final dynamic body = response.data;
        if (body == null) return <ChatMessageModel>[];
        if (body is! List) return <ChatMessageModel>[];
        return body.map((message) => ChatMessageModel.fromJson(message)).toList();
      } else {
        throw ErrorException('خطا در دریافت پیام‌ها');
      }
    } catch (e,s) {
      AppLogger.e('getChatMessages failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));

    }
  }

  Future<List<AccountAdminModel>> getAccountAdminList(String topicCode)async{
    try{
      Map<String,dynamic> option={
        "topicCode": topicCode,
      };
      final response=await chatDio.get('Chat/topicAdmins',queryParameters: option);
      if(response.statusCode==200){
        final raw = response.data;
        if (raw is List<dynamic>) {
          return raw
              .map((e) => AccountAdminModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (raw is Map<String, dynamic>) {
          return [AccountAdminModel.fromJson(raw)];
        }
        return <AccountAdminModel>[];
      }else{
        throw ErrorException('خطا');
      }
    }
    catch (e, s) {
      AppLogger.e('getAccountAdminList failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  // Get topics for a account
  Future<List<TopicModel>> getTopics() async {
    try {
      final response = await chatDio.get('Chat/getTopic');

      if (response.statusCode == 200) {
        final dynamic body = response.data;
        if (body == null) return <TopicModel>[];
        if (body is! List) return <TopicModel>[];
        return body.map((topic) => TopicModel.fromJson(topic)).toList();
      } else {
        throw ErrorException('خطا در دریافت موضوعات');
      }
    } catch (e,s) {
      AppLogger.e('getTopics failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  Future<List<ChatMentionCandidatesModel>> chatMentionCandidates(
      String chatId) async {
    try {
      final Map<String, dynamic> option = {
        'chatId': chatId,
      };
      final response = await chatDio.get(
        'chat/mentionCandidates',
        queryParameters: option,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        if (raw is List) {
          return raw
              .map((e) =>
              ChatMentionCandidatesModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (raw is Map<String, dynamic> && raw['items'] is List) {
          return (raw['items'] as List)
              .map((e) =>
              ChatMentionCandidatesModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <ChatMentionCandidatesModel>[];
      } else {
        throw ErrorException('خطا در دریافت لیست منشن');
      }
    } catch (e, s) {
      AppLogger.e('chatMentionCandidates failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }
  Future<List<ChatUnreadMentionsModel>> getUnreadMention(String chatId) async {
    try {
      final Map<String, dynamic> option = {
        'chatId': chatId,
      };
      final response = await chatDio.get(
        'Chat/getUnreadMentionsByChatId',
        queryParameters: option,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        if (raw is List) {
          return raw
              .map((e) => ChatUnreadMentionsModel.fromJson(
            e as Map<String, dynamic>,
          ))
              .toList();
        }
        if (raw is Map<String, dynamic> && raw['items'] is List) {
          return (raw['items'] as List)
              .map((e) => ChatUnreadMentionsModel.fromJson(
            e as Map<String, dynamic>,
          ))
              .toList();
        }
        return <ChatUnreadMentionsModel>[];
      } else {
        throw ErrorException('خطا در دریافت منشن‌های خوانده‌نشده');
      }
    } catch (e, s) {
      AppLogger.e('getUnreadMention failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  Future<bool> updateSeen(String id) async {
    try {
      final response = await chatDio.put('Message/updateSeen?id=$id');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw ErrorException('خطا در آپدیت');
      }
    } catch (e,s) {
      AppLogger.e('updateSeen failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }
}
