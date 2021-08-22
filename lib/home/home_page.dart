// imports nativos do flutter
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:async';

// import dos core
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_images.dart';
import 'package:libras/core/app_colors.dart';

// import dos pacotes
import 'package:http/http.dart' as http;

// import das telas
import 'package:libras/home/widgets/appbar/app_bar_widget.dart';
import 'package:libras/Games/MemoryGame/MemoryGameHome.dart';

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
  double _nextLevel = 0;

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
        _nextLevel = convertNextLevel;
      });

    } else if ( response.statusCode == 401 || response.statusCode == 400 ) {

      setState(() {
        print("Usuario e/ou senha invalidos, tente novamente");
      });

    } else if ( response.statusCode == 500 ) {
      print("Nossos serviços estão temporariamente indisponoveis");
    }
  }

  // ir para o quizz
  _quizzGame() {
    print("Quizz");
  }

  // ir para o jogo da memoria
  _memoryGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          MemoryGameHome(
            token: widget.token,
          ),
      ),
    ).then(_onGoBack);
  }

  // forca o recarregamento ao voltar para essta tela
  FutureOr _onGoBack(dynamic value) {
    _getUser();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    if ( _name != null ) {
      return Scaffold(
        appBar: AppBarWidget( name: _name, photo: _photo, nextLevel: _nextLevel ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric( horizontal: 20 ),
            child: Column(
              children: [
                /*
              SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LevelButtonWidget(
                    label: "Fácil",
                  ),
                  LevelButtonWidget(
                    label: "Médio",
                  ),
                  LevelButtonWidget(
                    label: "Difícil",
                  ),
                  LevelButtonWidget(
                    label: "Fluente",
                  ),
                ],
              ),
              */

                SizedBox(
                  height: 24,
                ),

                // jogar quizz
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          child: Image.asset(
                              AppImages.blocks
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(right: 5),
                        ),
                        Text(
                          "Jogar quizz",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.levelButtonDificil,
                      padding: EdgeInsets.fromLTRB(36, 16, 36, 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      _quizzGame();
                    },
                  ),
                ),

                // jogo da memoria
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          child: Image.asset(
                              AppImages.data
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(right: 5),
                        ),
                        Text(
                          "Jogo da memória",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.levelButtonDificil,
                      padding: EdgeInsets.fromLTRB(36, 16, 36, 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      _memoryGame();
                    },
                  ),
                ),

              ],
            ),
          ),
        )
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
