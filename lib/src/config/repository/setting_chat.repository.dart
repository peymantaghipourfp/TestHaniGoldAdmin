

import 'package:dio/dio.dart';
import 'package:hanigold_admin/src/config/repository/url/base_url.dart';
import 'package:hanigold_admin/src/domain/tools/model/admin_chat_topic.model.dart';

import '../../domain/account/model/account.model.dart';
import '../../domain/users/model/list_user_account.model.dart';
import '../logger/app_logger.dart';
import '../network/dio_Interceptor.dart';
import '../network/error/network.error.dart';
import '../network/error_handler.dart';

class SettingChatRepository{
  Dio settingChatDio=Dio();

  SettingChatRepository(){
    settingChatDio.options.baseUrl=BaseUrl.baseUrl;
    settingChatDio.interceptors.add(DioInterceptor());
  }

  Future<List<AdminChatTopicModel>> getAdminChatTopic({
    required String accountId,
  }) async {
    try {
      Map<String , dynamic> options=
      {
        "options" : { "adminChatTopic" :{
          "Predicate": [
            {
              "innerCondition": 1,
              "outerCondition": 0,
              "filters": [
                {
                  "fieldName": "id",
                  "filterValue": accountId,
                  "filterType": 5,
                  "RefTable": "Account"
                }
              ]
            }
          ],

          "orderBy": "adminChatTopic.Id",
          "orderByType": "desc",
          "StartIndex": 1,
          "ToIndex": 500
        }}
      };
      final response = await settingChatDio.post('adminChatTopic/get', data: options);

      if (response.statusCode == 200) {
        final dynamic body = response.data;
        if (body == null) return <AdminChatTopicModel>[];
        if (body is! List) return <AdminChatTopicModel>[];
        return body.map((chatTopic) => AdminChatTopicModel.fromJson(chatTopic)).toList();
      } else {
        throw ErrorException('خطا در دریافت تاپیک های ادمین');
      }
    }catch (e, s) {
      AppLogger.e('adminChatTopic failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  Future<List<AdminChatTopicModel>> getMissingAdminChatTopic({
    required String accountId,
  }) async {
    try {
      Map<String , dynamic> options=
      {
        "options" : { "adminChatTopic" :{
          "Predicate": [
            {
              "innerCondition": 1,
              "outerCondition": 0,
              "filters": [
                {
                  "fieldName": "id",
                  "filterValue": accountId,
                  "filterType": 5,
                  "RefTable": "Account"
                }
              ]
            }
          ],

          "orderBy": "ChatTopic.SortOrder",
          "orderByType": "desc",
          "StartIndex": 1,
          "ToIndex": 500
        }}
      };
      final response = await settingChatDio.post('adminChatTopic/getMissingAdminChatTopic', data: options);

      if (response.statusCode == 200) {
        final dynamic body = response.data;
        if (body == null) return <AdminChatTopicModel>[];
        if (body is! List) return <AdminChatTopicModel>[];
        return body.map((chatTopic) => AdminChatTopicModel.fromJson(chatTopic)).toList();
      } else {
        throw ErrorException('خطا در دریافت تاپیک های اختصاص نیافته به ادمین');
      }
    }catch (e, s) {
      AppLogger.e('getMissingAdminChatTopic failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  Future<Map<String, dynamic>> insertAdminChatTopic({
    required int topicId,
    required int userId,
  })async{
    try{
      Map<String, dynamic> adminChatTopicData = {
        "topicId": topicId,
        "userId": userId
      };

      var response=await settingChatDio.post('adminChatTopic/insert',data: adminChatTopicData);
      return response.data;
    }
    catch (e, s) {
      AppLogger.e('insertAdminChatTopic failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  Future<List< dynamic>> deleteAdminChatTopic({
    required int adminChatTopicId,
  })async{
    try{
      Map<String,dynamic> adminChatTopicData={
        "id": adminChatTopicId,
      };

      var response=await settingChatDio.delete('adminChatTopic/delete',data: adminChatTopicData);
      if (response.data is List) {
        return response.data;
      } else {
        return [response.data];
      }
    }
    catch (e, s) {
      AppLogger.e('deleteAdminChatTopic failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  Future<List<AccountModel>> getAccountListAdmin(String status)async{
    try{
      Map<String , dynamic> options={
        "options" : {
          "account" :{
            "Predicate": [
              {
                "innerCondition": 0,
                "outerCondition": 0,
                "filters": [
                  {
                    "fieldName": "accountGroupId",
                    "filterValue": "4",
                    "filterType": 5,
                    "RefTable": "Account"
                  },
                  if(status!="")
                    {
                      "fieldName": "Status",
                      "filterValue": status,
                      "filterType": 4,
                      "RefTable": "Account"
                    }
                ]
              }
            ],
            "orderBy": "Account.StartDate",
            "orderByType": "desc",
            "StartIndex": 1,
            "ToIndex": 100000
          }
        }
      };
      final response=await settingChatDio.post('Account/get',data: options);
      if(response.statusCode==200){
        List<dynamic> data=response.data;
        return data.map((account)=>AccountModel.fromJson(account)).toList();
      }else{
        throw ErrorException('خطا');
      }
    }
    catch (e, s) {
      AppLogger.e('getAccountListAdmin failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  /*Future<List<TopicModel>> getTopics() async {
    try {
      final response = await settingChatDio.get('Chat/getTopic');

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
  }*/

  Future<AccountModel> getAccountOne({
    required int accountId,
  }) async {
    try {
      final response = await settingChatDio.get(
        'Account/getOne',
        queryParameters: {'id': accountId},
      );
      return AccountModel.fromJson(response.data);
    } catch (e, s) {
      AppLogger.e('getAccountOne failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  Future<int?> getUserIdForAccount({
    required String accountId,
  }) async {
    try {
      final Map<String, dynamic> options = {
        'options': {
          'user': {
            'Predicate': [
              {
                'innerCondition': 0,
                'outerCondition': 0,
                'filters': [
                  {
                    'fieldName': 'id',
                    'filterValue': accountId,
                    'filterType': 5,
                    'RefTable': 'Account',
                  },
                ],
              },
            ],
            'orderBy': 'users.Id',
            'orderByType': 'desc',
            'StartIndex': 1,
            'ToIndex': 5,
          },
        },
      };
      final response =
      await settingChatDio.post('User/getWrapper', data: options);
      if (response.statusCode != 200 || response.data == null) {
        return null;
      }
      final users = ListUserAccountModel.fromJson(response.data).users;
      if (users == null || users.isEmpty) {
        return null;
      }
      return users.first.id;
    } catch (e, s) {
      AppLogger.e('getUserIdForAccount failed', e, s);
      return null;
    }
  }

}