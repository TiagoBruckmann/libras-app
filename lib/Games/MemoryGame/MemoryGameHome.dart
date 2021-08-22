// imports nativos do flutter
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

// import dos pacotes
import 'package:http/http.dart' as http;

// import dos modelos
import 'package:libras/core/Models/ModelCategories.dart';

// import dos core
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_colors.dart';

// import das telas
import 'package:libras/Games/MemoryGame/MemoryGame.dart';

class MemoryGameHome extends StatefulWidget {

  final String token;
  const MemoryGameHome({Key key, this.token}) : super(key: key);

  @override
  _MemoryGameHomeState createState() => _MemoryGameHomeState();
}

class _MemoryGameHomeState extends State<MemoryGameHome> {

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
  _goMemoryGame( ModelCategories modelCategories ) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          MemoryGame(
            token: widget.token,
            categoryId: modelCategories.id,
          ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jogo da memória"),
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

                        Row(
                          children: [

                            GestureDetector(
                              onTap: () {
                                _goMemoryGame( modelCategories );
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
