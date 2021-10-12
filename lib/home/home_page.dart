// imports nativos do flutter
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:async';

// import dos core
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_colors.dart';

// import dos modelos
import 'package:libras/core/Models/ModelCategories.dart';

// import dos pacotes
import 'package:http/http.dart' as http;

// import das telas
import 'package:libras/home/widgets/appbar/app_bar_widget.dart';
import 'package:libras/Games/QuizGame.dart';
import 'package:libras/Info/InfoApp.dart';

class HomePage extends StatefulWidget {

  final String token;
  HomePage({ this.token });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // variaveis da tela
  String _name = "";
  String _photo = "";
  int _level = 1;
  double _nextLevel = 0;
  List<ModelCategories> _listCategories = [];

  // variaveis de informacao
  String _message;
  bool _success;

  // buscar os dados dos usuarios
  _getUser() async {
    var getUser = RoutesAPI.getUser;

    var header = {
      "content-type" : "application/json",
      "Authorization": "Bearer ${widget.token}"
    };

    final response = await http.get(getUser, headers: header);
    var userDetail = convert.jsonDecode(response.body);

    // Logando o usuario se o codigo HTTP for 200 e redirecionando para a tela Home;
    if( response.statusCode == 200 ) {

      var uiAvatar = Uri.https("ui-avatars.com", "/api/", {"name": "${userDetail["name"]}"});

      String nextLevel = userDetail["next_level"];
      double convertNextLevel;
      if ( nextLevel[0] == "-" ) {
        String rmAnyLess = nextLevel.replaceAll("-", "");
        convertNextLevel = double.parse(rmAnyLess);
      } else {
        convertNextLevel = double.parse(nextLevel);
      }

      setState(() {
        _name = userDetail["name"];
        _photo = uiAvatar.toString();
        _level = userDetail["level"];
        _nextLevel = convertNextLevel;
      });

    } else if ( response.statusCode == 401 || response.statusCode == 400 ) {

      setState(() {
        _message = "Não foi possivel concluir a chamada de informações, por favor tente novamente.";
        _success = false;
      });
      ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );

    } else if ( response.statusCode == 500 ) {

      setState(() {
        _message = "Nossos serviços estão temporariamente indisponíveis.";
        _success = false;
      });
      ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );

    }
  }

  // buscar as categorias de perguntas
  Future<List<ModelCategories>> _getCategories() async {
    
    var getCategories = RoutesAPI.getCategories;
    var header = {
      "content-type" : "application/json",
      "Authorization": "Bearer ${widget.token}"
    };

    final response = await http.get(getCategories, headers: header);

    if ( response.statusCode == 200 ) {

      var dataReturn = convert.jsonDecode(response.body);
      int totalCategories = dataReturn["total"];
      
      if ( _listCategories.length < totalCategories ) {

        for ( var item in dataReturn["data"] ) {
          ModelCategories modelCategories = ModelCategories(
              item["id"],
              item["name"],
          );
          _listCategories.add(modelCategories);
        }

        return _listCategories;
      }

    } else if ( response.statusCode == 400 ||  response.statusCode == 401 ) {

      setState(() {
        _message = "Não foi possível buscar os níveis existentes, tente novamente mais tarde.";
        _success = false;
      });
      ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );

    } else if ( response.statusCode == 500 ) {

      setState(() {
        _message = "Nossos serviços estão temporariamente indisponíveis.";
        _success = false;
      });
      ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );

    }

    return _listCategories;
  }

  // ir para as informações do app
  _goInfo() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          InfoApp(
            token: widget.token,
          ),
      ),
    );

  }

  // ir para o quizz
  _goQuizGame( ModelCategories modelCategories ) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          QuizGame(
            token: widget.token,
            categoryId: modelCategories.id,
          ),
      ),
    ).then(_onGoBack);

    setState(() {
      _listCategories.clear();
    });

  }

  // forca o recarregamento ao voltar para essta tela
  FutureOr _onGoBack(dynamic value) {
    setState(() {
      _getUser();
      _listCategories.clear();
    });
  }

  // texto informativo
  _infoMessage() {
    final snackBar = SnackBar(
      content: Text(
        "$_message",
        style: TextStyle(
            color: Colors.white
        ),
      ),
      backgroundColor: ( _success == false )
      ? Colors.red
      : Colors.green
    );
    return snackBar;
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    if ( _name != null ) {
      return Scaffold(
        appBar: AppBarWidget(
          name: _name,
          photo: _photo,
          level: _level,
          nextLevel: _nextLevel,
        ),

        body: FutureBuilder<List<ModelCategories>>(
          future: _getCategories(),
          builder: (context, snapshot) {
            // verificar conexao
            if ( snapshot.connectionState == ConnectionState.waiting ) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
                  ),
                ),
              );
            } else if ( snapshot.hasError ) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _listCategories.length,
                itemBuilder: ( context, index ) {
                  ModelCategories modelCategories = _listCategories[index];

                  return Padding(
                    padding: EdgeInsets.fromLTRB(16, 25, 16, 3),
                    child: Column(
                      children: [

                        ( index == 0 )
                        ? Column(
                          children: [

                            Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 10),
                              child: ElevatedButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 5),
                                    ),
                                    Text(
                                      "Sobre o game",
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
                                  _goInfo();
                                },
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only( bottom: 30 ),
                              child: Text(
                                "Escolha uma categoria de jogo",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),

                          ],
                        )
                        : Padding(padding: EdgeInsets.zero),

                        Row(
                          children: [

                            GestureDetector(
                              onTap: () {
                                _goQuizGame( modelCategories );
                              },
                              child: Text(
                                "${modelCategories.name}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          ],
                        ),

                      ],
                    ),
                  );
                }
              );
            }
          },
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
          ),
        ),
      );
    }

  }
}
