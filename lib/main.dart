import 'package:flutter/material.dart';


import 'package:project_team5_chating_app/pages/welcome_page/splash_page.dart';
import 'package:project_team5_chating_app/pages/welcome_page/welcome_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tokka App',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashPage(),
    );
  }
}
