// imports nativos do flutter
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:async';

// import dos pacotes
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

// import dos core
import 'package:libras/core/Models/ModelQuestions.dart';
import 'package:libras/core/Routes/RoutesApi.dart';
import 'package:libras/core/app_images.dart';
import 'package:libras/core/app_colors.dart';

// import das telas
import 'package:libras/home/home_page.dart';

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

  // tempo permitido por requisição
  Timer _timer;

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
      setState(() {
        _message = "Não foi possível buscar as perguntas, tente novamente mais tarde.";
        _success = true;
      });
      ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );
    } else if ( response.statusCode == 500 ) {
      setState(() {
        _message = "Nossos serviços estão temporariamente indisponoveis.";
        _success = true;
      });
      ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );
    }
  }

  // validacao da resposta e calculo de pontos
  _validateAwnser( var awnser ) {

    if ( awnser.id != _awnserId ) {
      // remove a resposta errada
      setState(() {
        _listAwnsers.removeWhere((element) => element.id == awnser.id);
        _message = "Resposta incorreta, tente novamente.";
        _success = false;
      });
      _awnserCorrectly();
      _timer = Timer(Duration(seconds: 1), () {
        Navigator.pop(context);
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

  // atualizar o nivel do usuário
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
      if ( _rightAwnser < 4 ) {
        setState(() {
          _message = "Parabéns, resposta correta uma nova pergunta foi gerada.";
          _success = true;
        });
        // ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );
        _awnserCorrectly();
        _timer = Timer(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _message = "Parabéns, desafio concluído.";
          _success = true;
        });
        _awnserCorrectly();

        _timer = Timer(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                token: widget.token,
              ),
            ),
          );
        });

      }

    } else if ( response.statusCode == 401 || response.statusCode == 400 ) {

      setState(() {
        _message = "Não foi possivel concluir a chamada de informações, por favor tente novamente.";
        _success = true;
      });
      ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );

    } else if ( response.statusCode == 500 ) {

      setState(() {
        _message = "Nossos serviços estão temporariamente indisponoveis.";
        _success = true;
      });
      ScaffoldMessenger.of(context).showSnackBar( _infoMessage() );

    }

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

  // resposta certa / errada
  _awnserCorrectly() {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contex) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, 150, 16, 0),
          child: Center(
            child: Column(
              children: [
                AlertDialog(
                  title: Text(
                    "$_message",
                    textAlign: TextAlign.center,
                  ),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // exibicao da resposta
                      Image.asset(
                        ( _success == true )
                        ? AppImages.check
                        : AppImages.error,
                        width: 150,
                        height: 150,
                      ),

                    ],
                  ),

                  contentPadding: EdgeInsets.all(16),


                ),
              ],
            ),
          ),
        );
      }
    );

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
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quizz ($_rightAwnser/4)"),
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
