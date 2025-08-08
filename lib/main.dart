import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/repository/chat_repository.dart';
import 'package:project_team5_chating_app/firebase_options.dart';
import 'package:project_team5_chating_app/pages/welcome_page/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final repo = ChatRepository();
  await repo.insert(
    sender: '테스트 제목',
    senderId: '테스트 컨텐트',
    address: '테스트 작성자',
    message: '테스트 메시지',
    createdAt: '250808',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tokka App',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
      ),
      home: SplashPage(),
    );
  }
}
