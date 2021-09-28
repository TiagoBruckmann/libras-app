// imports nativos do flutter
import 'package:flutter/material.dart';

class InfoApp extends StatefulWidget {

  final String token;
  const InfoApp({ Key key, this.token }) : super(key: key);

  @override
  _InfoAppState createState() => _InfoAppState();
}

class _InfoAppState extends State<InfoApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sobre o app"),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          children: [

            ListTile(
              title: Text(
                "Game desenvolvido com o intuito de aprender e ensinar libras.",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only( top: 20 ),
                child: Text(
                  "Game desenvolvido utilizando a linguagem de programação e framework Dart e Flutter respectivamente.\n\n"
                  "Seu funcionamento ocorre através da seleção de uma categoria de perguntas, sendo redirecionado para "
                  "uma sequência de 4 perguntas onde quando uma resposta for incorreta, a mesma será removida e sua nota "
                  "será decrementada a cada erro.\n\n"
                  "Cada pergunta é gerada de forma totalmente aleatória e após passar alguns níveis a dificuldade das perguntas aumenta, "
                  "sendo também selecionada de forma aleatória.\n\n",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
