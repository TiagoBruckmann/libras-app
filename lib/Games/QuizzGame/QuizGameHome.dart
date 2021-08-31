// imports nativos do flutter
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

// import dos pacotes
import 'package:http/http.dart' as http;
import 'package:libras/Games/QuizzGame/QuizGame.dart';

// import dos modelos
import 'package:libras/core/Models/ModelCategories.dart';

// import dos core
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_colors.dart';


class QuizGameHome extends StatefulWidget {

  final String token;
  final int questionLevel;
  const QuizGameHome({ Key key, this.token, this.questionLevel }) : super(key: key);

  @override
  _QuizGameHomeState createState() => _QuizGameHomeState();
}

class _QuizGameHomeState extends State<QuizGameHome> {

  // variaveis da tela
  List<ModelCategories> _listCategories = [];

  // buscar as categorias de perguntas
  Future<ModelCategories> _getCategories() async {
    var getCategories = RoutesAPI.getCategories;

    var header = {
      "content-type" : "application/json",
      "Authorization": "Bearer ${widget.token}"
    };

    final response = await http.get(getCategories, headers: header);

    if ( response.statusCode == 200 ) {

      var dataReturn = convert.jsonDecode(response.body);
      for ( var item in dataReturn ) {
        ModelCategories modelCategories = ModelCategories(
            item["id"],
            item["name"]
        );
        _listCategories.add(modelCategories);
      }

    } else if ( response.statusCode == 400 ||  response.statusCode == 401 ) {
      print("Não foi possível buscar os níveis existentes, tente novamente mais tarde");
    } else if ( response.statusCode == 500 ) {
      print("nossos serviços estão temporariamente indisponíveis");
    }
  }

  // ir para o jogo
  _goQuizGame( ModelCategories modelCategories ) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          QuizGame(
            token: widget.token,
            categoryId: modelCategories.id,
            questionLevel: widget.questionLevel,
          ),
      ),
    );

    setState(() {
      _listCategories.clear();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz"),
      ),

      body: FutureBuilder<ModelCategories>(
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
                        ? Text("Escolha uma categoria de jogo")
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
  }
}
