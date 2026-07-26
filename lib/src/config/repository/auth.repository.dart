

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hanigold_admin/src/config/repository/url/base_url.dart';
import 'package:hanigold_admin/src/config/secure_session_storage.dart';
import 'package:hanigold_admin/src/domain/auth/model/user_login.model.dart';

import '../logger/app_logger.dart';
import '../network/dio_Interceptor.dart';
import '../network/error/network.error.dart';
import '../network/error_handler.dart';

class AuthRepository{
  Dio authDio=Dio();
  Dio authDioWithInterceptor = Dio();

  AuthRepository(){
    authDio.options.baseUrl=BaseUrl.baseUrl;
    authDioWithInterceptor.options.baseUrl = BaseUrl.baseUrl;
    authDioWithInterceptor.interceptors.add(DioInterceptor());
  }
  Future<UserLoginModel> login(String mobile,String password)async{
    try{
      Map<String , dynamic> options={
        "password" : password,
        "user": {
          "MobileNumber" : mobile
        }
      };
      final response=await authDio.post('Login/LoginAdmin',data: options,options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),);

      AppLogger.d("responseLogin:::: $response");
      UserLoginModel userLoginModel = UserLoginModel.fromJson(response.data);

      /// اگر داخل body نبود → از header بخوان
      String? token = userLoginModel.token;
      String? sessionId = userLoginModel.sessionId;

      final headerToken = response.headers.value('Authorization');
      final headerSession = response.headers.value('x-session-id');

      if ((token == null || token.isEmpty) && headerToken != null) {
        token = headerToken.startsWith('Bearer ')
            ? headerToken.substring(7)
            : headerToken;
      }

      if ((sessionId == null || sessionId.isEmpty) &&
          headerSession != null) {
        sessionId = headerSession;
      }

      userLoginModel.token = token;
      userLoginModel.sessionId = sessionId;

      final session = SecureSessionStorage.instance;
      if (token != null) await session.write('token', token);
      if (sessionId != null) await session.write('x-session-id', sessionId);

      return userLoginModel;
    }
    catch(e,s){
      AppLogger.e('login failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }

  Future<dynamic> forgetPasswordMobile(String mobile)async{
    try{
      Map<String , dynamic> options={
        "user": {
          "MobileNumber" : mobile
        }
      };
      final response=await authDio.post('Login/mobileVerificationForgetPassword',data: options);
      return jsonEncode(response.data);
    }
    catch(e,s){
      AppLogger.e('forgetPasswordMobile failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }
  Future<Map<String , dynamic>> forgetPasswordVerify(String mobile,String code)async{
    try{
      Map<String , dynamic> options={
        "VerificationCode" : code,
        "user": {
          "MobileNumber" : mobile
        }
      };
      final response=await authDio.post('Login/checkVerificationForgetPassword',data: options);
      return response.data;
      //return UserLoginModel.fromJson(response.data);
    }
    catch(e,s){
      AppLogger.e('forgetPasswordVerify failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }


  Future<Map<String , dynamic>> changePassword(String mobile,String password,String oldPassword,int id)async{
    try{
      Map<String , dynamic> options={
        "password" : password,
        "RetypePassword" : password,
        "OldPassword" : oldPassword,
        "user": {
          "MobileNumber" : mobile,
          "id" : id
        }
      };
      final response = await authDioWithInterceptor.post('Login/changePassword', data: options);
      return response.data;
    }
    catch(e,s){
      AppLogger.e('changePassword failed', e, s);
      throw ErrorException(ErrorHandler.handle(e));
    }
  }


}