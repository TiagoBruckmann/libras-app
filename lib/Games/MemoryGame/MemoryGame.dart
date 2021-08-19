// imports nativos do flutter
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

// import dos pacotes
import 'package:http/http.dart' as http;

// import dos modelos
import 'package:libras/core/Models/ModelCategories.dart';
import 'package:libras/core/Models/ModelLevels.dart';

// import dos core
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_colors.dart';
import 'package:libras/home/widgets/level_button/level_button_widget.dart';

class MemoryGame extends StatefulWidget {

  final String token;
  const MemoryGame({Key key, this.token}) : super(key: key);

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {

  int _levelId;
  String _levelName;

  List<ModelLevels> _listLevels = [];

  _getLevels() async {
    var getLevels = RoutesAPI.getLevels;

    var header = {
      "content-type" : "application/json",
      "Authorization": "Bearer ${widget.token}"
    };

    final response = await http.get(getLevels, headers: header);

    if ( response.statusCode == 200 ) {

      var dataReturn = convert.jsonDecode(response.body);
      for ( var item in dataReturn ) {
        ModelLevels modelLevels = ModelLevels(
            item["id"],
            item["name"]
        );
        _listLevels.add(modelLevels);
      }
      print("dataReturn => $dataReturn");

    } else if ( response.statusCode == 400 ||  response.statusCode == 401 ) {
      print("Não foi possível buscar os níveis existentes, tente novamente mais tarde");
    } else if ( response.statusCode == 500 ) {
      print("nossos serviços estão temporariamente indisponíveis");
    }
  }

  Future<List<ModelCategories>> _getCategories() async {
    var getCategories = RoutesAPI.getCategories;

    var header = {
      "content-type" : "application/json",
      "Authorization": "Bearer ${widget.token}"
    };

    final response = await http.get(getCategories, headers: header);
    List<ModelCategories> _listCategories = [];

    if ( response.statusCode == 200 ) {

      var dataReturn = convert.jsonDecode(response.body);
      print("dataReturn 2 => $dataReturn");
      for ( var item in dataReturn ) {
        ModelCategories modelCategories = ModelCategories(
            item["id"],
            item["name"]
        );
        _listCategories.add(modelCategories);
        print("_listCategories => $_listCategories");
      }

    } else if ( response.statusCode == 400 ||  response.statusCode == 401 ) {
      print("Não foi possível buscar os níveis existentes, tente novamente mais tarde");
    } else if ( response.statusCode == 500 ) {
      print("nossos serviços estão temporariamente indisponíveis");
    }
  }

  @override
  void initState() {
    super.initState();
    _getLevels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jogo da memória"),
      ),

      body: FutureBuilder<List<ModelCategories>>(
        future: _getCategories(),
        builder: (context, snapshot) {
          // verificar conexao
          if ( snapshot.connectionState == ConnectionState.waiting ) {
            print("aguenta as pontas");
            print("snapshot.data => ${snapshot.data}");
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
                ),
              ),
            );
          } else if ( snapshot.hasError ) {
            print("Deu ruim");
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
                itemCount: snapshot.data.length,
                itemBuilder: ( context, index ) {
                  ModelCategories modelCategories = snapshot.data[index];

                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 3),
                    child: Column(
                      children: [

                        ( index == 0 )
                        ? Row(
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
                        )
                        : Padding(padding: EdgeInsets.zero),

                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 5, 16, 10),
                          child: Row(
                            children: [

                              Text(
                                "${modelCategories.name}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                            ],
                          ),
                        )
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
