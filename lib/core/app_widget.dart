// import pacotes nativos flutter
import 'package:flutter/material.dart';
import 'package:libras/challenge/challange_page.dart';

// import das telas
import 'package:libras/home/home_page.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DevQuiz",
      home: HomePage(),
    );
  }
}
