
import 'dart:async';
import 'dart:io';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/network/api_response.dart';
import 'package:quick_task/repository/user_authetication_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_string.dart';

class LoginBloc{
  late UserAuthenticationRepository _userAuthenticationRepository;

  late StreamController<ApiResponse<ParseResponse>>? _loginController;

  LoginBloc(){
    _userAuthenticationRepository = UserAuthenticationRepository();
    _loginController = StreamController<ApiResponse<ParseResponse>>.broadcast();
  }

  Stream<ApiResponse<ParseResponse>>? getLoginResponse(){
    return _loginController?.stream as Stream<ApiResponse<ParseResponse>>;
  }

  loginUser(String username,String password) async{
    _loginController?.sink.add(ApiResponse.loading(AppString.loaderMessage));
    try{
      final response = await _userAuthenticationRepository.loginUser(username, password);
      if(response.success) {
        // Save login state in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', username);
        _loginController?.sink.add(ApiResponse.success(response));
      }else{
        if(response.error?.code==-1){
          _loginController?.sink.add(
              ApiResponse.error(AppString.noInternetMsg));
        }else {
          _loginController?.sink.add(
              ApiResponse.error(response.error?.message));
        }
      }
    }on SocketException{
      _loginController?.sink.add(ApiResponse.error(AppString.noInternetMsg));
    }catch(e){
      _loginController?.sink.add(ApiResponse.error(AppString.somethingWentWrongMsg));
    }
  }

  logoutUser() async{
    _loginController?.sink.add(ApiResponse.loading(AppString.loaderMessage));
    try{
      final response = await _userAuthenticationRepository.logoutUser();
      if(response.success) {
        // Save login state in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        _loginController?.sink.add(ApiResponse.success(response));
      }else{
        _loginController?.sink.add(ApiResponse.error(response.error?.message));
      }
    }on SocketException{
      _loginController?.sink.add(ApiResponse.error(AppString.noInternetMsg));
    }catch(e){
      _loginController?.sink.add(ApiResponse.error(AppString.somethingWentWrongMsg));
    }
  }

  dispose(){
    _loginController?.close();
  }
}