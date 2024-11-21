import 'dart:async';
import 'dart:io';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/network/api_response.dart';
import 'package:quick_task/repository/user_authetication_repository.dart';
import 'package:quick_task/utils/app_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpBloc {
  late UserAuthenticationRepository _userAuthenticationRepository;

  StreamController<ApiResponse<ParseResponse>>? _signUpController;

  SignUpBloc() {
    _userAuthenticationRepository = UserAuthenticationRepository();

    _signUpController =
        StreamController<ApiResponse<ParseResponse>>.broadcast();
  }

  Stream<ApiResponse<ParseResponse>>? getSignupResponse(){
    return _signUpController?.stream as Stream<ApiResponse<ParseResponse>>;
  }

  signUpUser(String username,String password) async{
    _signUpController?.sink.add(ApiResponse.loading(AppString.loaderMessage));
    try{
      final response = await _userAuthenticationRepository.registerUser(username, password);
      if(response.success) {
        // Save login state in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', username);
        _signUpController?.sink.add(ApiResponse.success(response));
      }else{
        if(response.error?.code==-1){
          _signUpController?.sink.add(
              ApiResponse.error(AppString.noInternetMsg));
        }else {
          _signUpController?.sink.add(
              ApiResponse.error(response.error?.message));
        }
      }
    }on SocketException{
      _signUpController?.sink.add(ApiResponse.error(AppString.noInternetMsg));
    }catch(e){
      _signUpController?.sink.add(ApiResponse.error(AppString.somethingWentWrongMsg));
    }
  }

  dispose(){
    _signUpController?.close();
  }
}
