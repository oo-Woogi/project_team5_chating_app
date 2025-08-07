import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/chating_page/chating_page.dart';
import 'package:project_team5_chating_app/pages/welcome_page/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
      ),
      home: ChatingPage(), // ChatingPage 구상 중이여서 home에 설정 추후 WelcomePage로 변경 예정
    );
  }
}
