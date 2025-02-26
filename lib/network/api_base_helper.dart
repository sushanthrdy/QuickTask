

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/utils/env.dart';

class ApiBaseHelper{

  void initializeApi() async{
    await Parse().initialize(Env.keyApplicationId, Env.baseUrl,clientKey: Env.keyClientKey,debug: true);
  }


}