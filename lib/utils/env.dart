
import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'KEY_APPLICATION_ID',obfuscate: true)
  static final String keyApplicationId = _Env.keyApplicationId;

  @EnviedField(varName: 'KEY_CLIENT_KEY',obfuscate: true)
  static final String keyClientKey = _Env.keyClientKey;

  @EnviedField(varName: 'BASE_URL',obfuscate: true)
  static final String baseUrl = _Env.baseUrl;
}