import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/network/api_base_helper.dart';

class UserAuthenticationRepository{
  late ApiBaseHelper _apiBaseHelper;

  UserAuthenticationRepository(){
    _apiBaseHelper = ApiBaseHelper();
  }

  Future<ParseResponse> registerUser(String username,String password) async{
    final user = ParseUser.createUser(username,password);
    return await user.signUp(allowWithoutEmail: true);
  }

  Future<ParseResponse> loginUser(String username,String password) async{
    final user = ParseUser(username, password,null);
    return await user.login();
  }

  Future<ParseResponse> logoutUser() async{
    final user = ParseUser.createUser();
    return await user.logout();
  }
}