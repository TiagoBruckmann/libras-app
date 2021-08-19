// imports nativos do flutter
import 'package:flutter/material.dart';
import 'dart:async';

// import dos pacotes
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// core
import 'package:libras/core/Models/ModelStorage.dart';
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_gradients.dart';
import 'package:libras/core/app_images.dart';

// import das telas
import 'package:libras/home/home_page.dart';
import 'package:libras/Login/Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // salvamento seguro de informações
  final _storage = FlutterSecureStorage();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Timer(Duration(seconds: 3), (){
      _verifyLogin();
    });
  }

  _verifyLogin() async {

    var verifyLogin = RoutesAPI.verifyLogin;
    final token = await _storage.read(key: "keyToken");

    var header = {
      "content-type" : "application/json",
      "Authorization": "Bearer $token"
    };

    final response = await http.get(verifyLogin, headers: header);

    // Logando o usuario se o codigo HTTP for 200 e redirecionando para a tela Home;
    if( response.statusCode == 200 || response.statusCode == 204 ) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            token: "$token",
          ),
        ),
      );

    } else {

      // Deletar token de acesso
      DeleteAll().deleteAllTokens();

      Navigator.pushReplacement(
          context, MaterialPageRoute(
          builder: (context) => Login()
      )
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.linear,
        ),
        child: Center(
          child: Image.asset(
            AppImages.logo,
          ),
        ),
      ),
    );
  }
}
