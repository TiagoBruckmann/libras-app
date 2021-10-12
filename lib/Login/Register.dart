// imports nativos do flutter
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

// import core
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_gradients.dart';
import 'package:libras/core/app_colors.dart';
import 'package:libras/core/app_images.dart';

// import dos modelos
import 'package:libras/core/Models/Users/Users.dart';

// import dos pacotes
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// import das telas
import 'package:libras/home/home_page.dart';

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  // controladores de texto
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

  // variaveis da tela
  String _token;
  bool _passwdVisible = false;
  String _mensageError = "";

  // salvamento seguro de informações
  final _storage = FlutterSecureStorage();

  // validacao dos campos
  _validateFields() {

    //Recupera dados dos campos
    String name = _controllerName.text;
    String mail = _controllerEmail.text;
    String password = _controllerSenha.text;

    if ( name.isNotEmpty ) {

      if( mail.isNotEmpty && mail.contains("@") && ( mail.contains(".com") || mail.contains(".br") ) ){

        if( password.isNotEmpty ){

          setState(() {
            _mensageError = "";
          });

          Users users = Users();
          users.name = name;
          users.mail = mail;
          users.password = password;

          _registerUser( users );

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

    } else {
      setState(() {
        _mensageError = "Preencha seu nome.";
      });
    }

  }

  // cadastrar usuario
  _registerUser( Users users ) async {

    var register = RoutesAPI.register;

    var header = {
      "content-type" : "application/json"
    };

    Map params = {
      "name": users.name,
      "mail": users.mail,
      "password": users.password,
    };

    var _body = convert.jsonEncode(params);
    final response = await http.post(register, headers: header, body: _body);
    print("response.statusCode => ${response.statusCode}");
    // Logando o usuario se o codigo HTTP for 200 e redirecionando para a tela Home;
    if( response.statusCode == 200 || response.statusCode == 204 ) {

      _login();

    } else if ( response.statusCode == 302 ) {

      setState(() {
        _mensageError = "Já existe uma conta com este endereço de e-mail.";
      });

    } else if ( response.statusCode == 401 || response.statusCode == 400 ) {

      setState(() {
        _mensageError = "Não foi possível cadastrar sua conta, tente novamente";
      });

    } else if ( response.statusCode == 500 ) {
      setState(() {
        _mensageError = "Nossos serviços estão temporariamente indisponíveis";
      });
    }

  }

  // conectar
  _login() async {

    var login = RoutesAPI.login;

    var header = {
      "content-type" : "application/json"
    };

    Map params = {
      "mail": _controllerEmail.text,
      "password": _controllerSenha.text,
    };

    var _body = convert.jsonEncode(params);
    final response = await http.post(login, headers: header, body: _body);

    if ( response.statusCode == 200 ) {

      var token = convert.jsonDecode(response.body);
      _token = token["token"];

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
        _mensageError = "Usuario e/ou senha invalidos, tente novamente.";
      });

    } else if ( response.statusCode == 500 ) {

      setState(() {
        _mensageError = "Nossos serviços estão temporariamente indisponíveis.";
      });

    }

  }

  // salvar credenciais de login
  void _saveCredentials() async {
    final String keyToken = "keyToken";
    final String token = _token;
    await _storage.write( key: keyToken, value: token );
  }

  // alterar a visibilidade da senha
  _changeVisible() {
    if ( _passwdVisible == false )
    {
      setState(() {
        _passwdVisible = true;
      });
    } else {
      setState(() {
        _passwdVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),

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
                      "Registro",
                      style: TextStyle(
                          fontSize: 25
                      ),
                    ),
                  ),
                ),

                // nome
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerName,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      hintText: "Nome",
                      labelText: "Nome",
                      filled: true,
                      fillColor: AppColors.malibu,
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          )
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
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
                      contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      hintText: "E-mail",
                      labelText: "E-mail",
                      filled: true,
                      fillColor: AppColors.malibu,
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          )
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),

                // senha
                TextField(
                  controller: _controllerSenha,
                  obscureText: ( _passwdVisible == false )
                  ? true
                  : false,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                    hintText: "Senha",
                    labelText: "Senha",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: AppColors.malibu,
                    suffixIcon: TextButton(
                      onPressed: () {
                        _changeVisible();
                      },
                      child: Icon(
                        ( _passwdVisible == false )
                        ? Icons.visibility_off
                        : Icons.visibility,
                        color: Colors.black,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
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
                          "Cadastrar",
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
