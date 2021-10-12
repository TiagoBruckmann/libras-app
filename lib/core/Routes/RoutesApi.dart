import 'package:libras/core/Routes/UrlDefault.dart';

// variavel padrão do sistema
var urlDefault = UrlDefault().url;

class RoutesAPI {

  // auth
  static final register = Uri.https("$urlDefault", "/public/api/auth/register");
  static final login = Uri.https("$urlDefault", "/public/api/auth/login");

  // users
  static final updateLevel = Uri.https("$urlDefault", "/public/api/v1/update-level");
  static final verifyLogin = Uri.https("$urlDefault", "/public/api/v1/verify");
  static final getUser = Uri.https("$urlDefault", "/public/api/v1/get-user");

  // levels
  static final getLevels = Uri.https("$urlDefault", "/public/api/v1/get-levels");

  // categories
  static final getCategories = Uri.https("$urlDefault", "/public/api/v1/get-categories");

  // memory game
  static final memoryGame = Uri.https("$urlDefault", "/public/api/v1/memory-game");

  // quizz game
  static final quizzGame = Uri.https("$urlDefault", "/public/api/v1/quizz-game");

}

// var scheduledConsult = RoutesAPI.scheduledConsult;