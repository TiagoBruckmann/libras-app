// import nativos do flutter
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

// import dos pacotes
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// imports core
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_gradients.dart';
import 'package:libras/core/app_colors.dart';
import 'package:libras/core/app_images.dart';

// import dos modelos
import 'package:libras/core/Models/Users/Users.dart';

// import das telas
import 'package:libras/home/home_page.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  // variaveis da tela
  TextEditingController _controllerEmail = TextEditingController(text: "tiagobruckmann@gmail.com");
  TextEditingController _controllerSenha = TextEditingController(text: "1234");
  String _mensageError = "";

  // token
  String _token = "";

  // salvamento seguro de informações
  final _storage = FlutterSecureStorage();

  // Validação pelo APP e envio para a API
  _validateFields(){

    //Recupera dados dos campos
    String mail = _controllerEmail.text;
    String password = _controllerSenha.text;

    if( mail.isNotEmpty && mail.contains("@") && mail.contains(".com") ){

      if( password.isNotEmpty ){

        setState(() {
          _mensageError = "";
        });

        Users users = Users();
        users.mail = mail;
        users.password = password;

        _userLogin( users );

      }else{
        setState(() {
          _mensageError = "Preencha a senha!";
        });
      }

    }else{
      setState(() {
        _mensageError = "Preencha um e-mail valido";
      });
    }

  }

  // Validação com a API e Login
  _userLogin( Users users ) async {

    var login = RoutesAPI.login;
    http.Response response;

    var header = {
      "content-type" : "application/json"
    };

    Map params = {
      "mail": users.mail,
      "password": users.password
    };

    var _body = convert.jsonEncode(params);
    response = await http.post(login, headers: header, body: _body);
    var token = convert.jsonDecode(response.body);
    _token = token["token"];

    // Logando o usuario se o codigo HTTP for 200 e redirecionando para a tela Home;
    if( response.statusCode == 200 ) {

      _saveCredentials();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            token: _token,
          ),
        ),
      );

    } else if ( response.statusCode == 401 || response.statusCode == 400 ) {

      setState(() {
        _mensageError = "Usuario e/ou senha invalidos, tente novamente";
      });

    } else if ( response.statusCode == 500 ) {
      _mensageError = "Nossos serviços estão temporariamente indisponoveis";
    }
  }

  // salvar credenciais de login
  void _saveCredentials() async {
    final String keyToken = "keyToken";
    final String token = _token;
    await _storage.write( key: keyToken, value: token );
  }

  _register() {
    Navigator.pushNamed(context, "/Register");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.linear,
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[

                // exibicao da logo
                Image.asset(
                  AppImages.logo,
                  width: 150,
                  height: 150,
                ),

                // autenticação
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text(
                      "Autenticação",
                      style: TextStyle(
                          fontSize: 25
                      ),
                    ),
                  ),
                ),

                // email
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "E-mail",
                      labelText: "E-mail",
                      filled: true,
                      fillColor: AppColors.malibu,
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(36, 16, 36, 16),
                    hintText: "Senha",
                    labelText: "Senha",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: AppColors.malibu,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                        ),
                        Text(
                          "Entrar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.malibu,
                      padding: EdgeInsets.fromLTRB(36, 16, 36, 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      _validateFields();
                    },
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _register,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
                        child: Text(
                          "Não possui uma conta? Cadastre-se",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      "$_mensageError",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
