// imports nativos do flutter
import 'package:flutter/material.dart';

// import das telas
import 'package:libras/splash/SplashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Libras',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
