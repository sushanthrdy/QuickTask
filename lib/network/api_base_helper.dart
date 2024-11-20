

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ApiBaseHelper{
  final String _keyApplicationId = '__REPLACE_APP_ID___';
  final String _keyClientKey = '__REPLACE_CLIENT_KEY___';
  final String _baseUrl = "https://parseapi.back4app.com";

  void initializeApi() async{
    await Parse().initialize(_keyApplicationId, _baseUrl,clientKey: _keyClientKey,debug: true);
  }


}