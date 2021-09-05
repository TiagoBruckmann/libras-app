// imports nativos do flutter
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

// import dos pacotes
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

// import dos core
import 'package:libras/core/Models/ModelQuestions.dart';
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_colors.dart';

class QuizGame extends StatefulWidget {

  final String token;
  final int categoryId;
  const QuizGame({ Key key, this.token, this.categoryId }) : super(key: key);

  @override
  _QuizGameState createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {

  // variaveis da tela
  String _title;
  String _questionBanner;
  int _awnserId;
  List<ModelQuestions> _listAwnsers = [];
  double _qtyLevel;
  int _questionLevel = 1;
  int _rightAwnser = 0;

  // variaveis para a mensagem
  String _message;
  bool _success;

  // variaveis para rodar o video
  FlickManager _flickManager;

  // buscar perguntas
  _getQuestions() async {
    var quizzGame = RoutesAPI.quizzGame;

    var header = {
      "content-type" : "application/json",
      "Authorization": "Bearer ${widget.token}"
    };

    Map params = {
      "category_id": widget.categoryId,
    };
    var _body = convert.jsonEncode(params);

    final response = await http.post(quizzGame, headers: header, body: _body);

    if ( response.statusCode == 200 ) {

      var dataReturn = convert.jsonDecode(response.body);

      setState(() {
        _title = dataReturn["question"]["title"];
        _questionBanner = dataReturn["question"]["banner"];
        _awnserId = dataReturn["question"]["awnser_id"];
        _questionLevel = dataReturn["question_level"];
      });

      // lista de respostas
      for ( var item in dataReturn["awnsers"] ) {
        ModelQuestions modelQuestions = ModelQuestions(
          item["id"],
          item["awnser"]
        );

        _listAwnsers.add(modelQuestions);
      }

      // resposta certa
      ModelQuestions modelQuestions = ModelQuestions(
          dataReturn["right"]["id"],
          dataReturn["right"]["awnser"]
      );

      _listAwnsers.add( modelQuestions );

      // randomizar as respostas
      _listAwnsers.shuffle();

      setState(() {
        _flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.network(
            "$_questionBanner",
          ),
        );
      });

    } else if ( response.statusCode == 400 ||  response.statusCode == 401 ) {
      print("Não foi possível buscar as perguntas, tente novamente mais tarde");
    } else if ( response.statusCode == 500 ) {
      print("nossos serviços estão temporariamente indisponíveis");
    }
  }

  _validateAwnser( var awnser ) {

    if ( awnser.id != _awnserId ) {
      // remove a resposta errada
      setState(() {
        _listAwnsers.removeWhere((element) => element.id == awnser.id);
      });

    } else {

      if ( _questionLevel == 1 ) {

        if ( _listAwnsers.length == 4 ) {
          _qtyLevel = 5.0;
        } else if ( _listAwnsers.length == 3 ) {
          _qtyLevel = 5 * 0.8;
        } else if ( _listAwnsers.length == 2 ) {
          _qtyLevel = 5 * 0.4;
        } else {
          _qtyLevel = 5 * 0.2;
        }

      } else if ( _questionLevel == 2 ) {

        if ( _listAwnsers.length == 4 ) {
          _qtyLevel = 7.0;
        } else if ( _listAwnsers.length == 3 ) {
          _qtyLevel = 7 * 0.8;
        } else if ( _listAwnsers.length == 2 ) {
          _qtyLevel = 7 * 0.4;
        } else {
          _qtyLevel = 7 * 0.2;
        }

      } else if ( _questionLevel == 3 ) {

        if ( _listAwnsers.length == 4 ) {
          _qtyLevel = 9.0;
        } else if ( _listAwnsers.length == 3 ) {
          _qtyLevel = 9 * 0.8;
        } else if ( _listAwnsers.length == 2 ) {
          _qtyLevel = 9 * 0.4;
        } else {
          _qtyLevel = 9 * 0.2;
        }

      } else {

        if ( _listAwnsers.length == 4 ) {
          _qtyLevel = 11.0;
        } else if ( _listAwnsers.length == 3 ) {
          _qtyLevel = 11 * 0.8;
        } else if ( _listAwnsers.length == 2 ) {
          _qtyLevel = 11 * 0.4;
        } else {
          _qtyLevel = 11 * 0.2;
        }

      }
      _updateLevel();
      setState(() {
        _getQuestions();
        _listAwnsers.clear();
      });
    }
  }

  _updateLevel() async {
    var updateLevel = RoutesAPI.updateLevel;

    var header = {
      "content-type" : "application/json",
      "Authorization": "Bearer ${widget.token}"
    };

    Map params = {
      "qty_level": _qtyLevel,
    };
    var _body = convert.jsonEncode(params);

    final response = await http.post(updateLevel, headers: header, body: _body);

    if ( response.statusCode == 200 || response.statusCode == 204 ) {

      _rightAwnser++;
      print("_rightAwnser => $_rightAwnser");
      if ( _rightAwnser < 4 ) {
        setState(() {
          _message = "Parabéns, resposta correta uma nova pergunta foi gerada.";
          _success = true;
        });
        ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );
      } else {
        setState(() {
          _message = "Parabéns, desafio concluído.";
          _success = true;
        });
        ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );
        Navigator.pop(context);

      }

    } else if ( response.statusCode == 401 || response.statusCode == 400 ) {

      print("Não foi possivel concluir a chamada de informações, por favor tente novamente.");

    } else if ( response.statusCode == 500 ) {

      print("Nossos serviços estão temporariamente indisponoveis.");

    }

  }

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
    _getQuestions();
  }

  @override
  void dispose() {
    super.dispose();
    _flickManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quizz"),
      ),

      body: ( _questionBanner != null )
        ? VisibilityDetector(
        key:ObjectKey( _flickManager ),
        onVisibilityChanged: ( visibility ) {
          if ( visibility.visibleFraction == 0 && this.mounted ) {
            _flickManager.flickControlManager.autoPause();
          } else if ( visibility.visibleFraction == 1 ) {
            _flickManager.flickControlManager.autoResume();
          }
        },
        child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 5),
            child: Column(
              children: [

                // pergunta
                Padding(
                  padding: EdgeInsets.only( bottom: 20 ),
                  child: Text(
                    "$_title",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // video
                FlickVideoPlayer(
                  flickManager: _flickManager,
                  flickVideoWithControls: FlickVideoWithControls(
                    controls: FlickPortraitControls(),
                    textStyle: TextStyle(
                      fontSize: 8,
                    ),
                  ),
                  flickVideoWithControlsFullscreen: FlickVideoWithControls(
                    controls: FlickLandscapeControls(),
                  ),
                ),

                for ( int i = 0; i < _listAwnsers.length; i++ )
                  Padding(
                    padding: EdgeInsets.only( top: 16, bottom: 16 ),
                    child: ElevatedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${_listAwnsers[i].awnser}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.malibu,
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        _validateAwnser( _listAwnsers[i] );
                      },
                    ),
                  ),

              ],
            )
        ),
      )
      : Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
        ),
      ),
    );
  }
}
