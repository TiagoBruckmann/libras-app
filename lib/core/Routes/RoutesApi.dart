import 'package:libras/core/Routes/UrlDefault.dart';

// variavel padrão do sistema
var urlDefault = UrlDefault().url;

class RoutesAPI {

  // auth
  static final register = Uri.http("$urlDefault", "/api/auth/register");
  static final login = Uri.http("$urlDefault", "/api/auth/login");

  // users
  static final updateLevel = Uri.http("$urlDefault", "/api/v1/update-level");
  static final verifyLogin = Uri.http("$urlDefault", "/api/v1/verify");
  static final getUser = Uri.http("$urlDefault", "/api/v1/get-user");
}

// var scheduledConsult = RoutesAPI.scheduledConsult;