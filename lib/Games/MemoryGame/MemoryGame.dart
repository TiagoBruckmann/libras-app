// imports nativos do flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;

// import dos pacotes
import 'package:http/http.dart' as http;

// import dos modelos
import 'package:libras/core/Models/ModelQuestions.dart';

// import dos core
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_colors.dart';
import 'package:libras/core/app_images.dart';

class MemoryGame extends StatefulWidget {

  final String token;
  final int categoryId;
  const MemoryGame({Key key, this.token, this.categoryId}) : super(key: key);

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {

  // variaveis da tela
  bool _showAwnser = false;

  // listagem das perguntas
  List<ModelQuestions> _listQuestions = [];

  // buscar as categorias de perguntas
  Future<ModelQuestions> _getQuestions() async {
    var memoryGame = RoutesAPI.memoryGame;

    var header = {
      "content-type" : "application/json",
      "Authorization": "Bearer ${widget.token}"
    };

    Map params = {
      "category_id": widget.categoryId,
    };
    var _body = convert.jsonEncode(params);

    final response = await http.post(memoryGame, headers: header, body: _body);
    List<ModelQuestions> _questions = [];
    print("response => ${response.statusCode}");

    if ( response.statusCode == 200 ) {

      var dataReturn = convert.jsonDecode(response.body);
      for ( var item in dataReturn ) {
        ModelQuestions modelQuestions = ModelQuestions(
            item["id"],
            item["awnser"],
            item["banner"]
        );
        _listQuestions.add(modelQuestions);
      }

      print("_listQuestions => ${_listQuestions.length}");

    } else if ( response.statusCode == 400 ||  response.statusCode == 401 ) {
      print("Não foi possível buscar os níveis existentes, tente novamente mais tarde");
    } else if ( response.statusCode == 500 ) {
      print("nossos serviços estão temporariamente indisponíveis");
    }
  }

  @override
  void initState() {
    super.initState();
    _getQuestions();
  }

  @override
  Widget build(BuildContext context) {
    // função para bloquear o giro da tela
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text("Jogo da memória"),
      ),

      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 25, 16, 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Expanded(
                child: GridView.count(
                  mainAxisSpacing: 16,
                  crossAxisCount: 3,
                  children: [
                    for ( int i = 0; i <_listQuestions.length; i++)
                      Image.asset(
                        AppImages.cardsBack,
                        width: 80,
                        height: 80,
                      )
                  ],
                )
            ),
            /*
            GestureDetector(
              onTap: () {
                _showAwnser = true;
              },
              child: Text(
                "${modelQuestions.awnser}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
             */

          ],
        ),
      )
    );
  }
}
