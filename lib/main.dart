import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_team5_chating_app/firebase_options.dart';

import 'package:project_team5_chating_app/pages/welcome_page/splash_page.dart';
import 'package:project_team5_chating_app/pages/searching_page/searching_page.dart';
import 'package:project_team5_chating_app/pages/chating_page/chating_page.dart';
import 'package:project_team5_chating_app/pages/chating_list_page/chating_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _logAppStart();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _logAppStart() async {
  try {
    await FirebaseFirestore.instance.collection('chating_message').add({
      'event': '앱을 접속했습니다.',
      'StartAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    debugPrint('Failed to log app_start: $e');
  }
}

/// 화면 간 전달할 값들
class ProfileArgs {
  final String userName;        // 웰컴에서 입력한 이름
  final String? address;        // 위치/동네
  const ProfileArgs({required this.userName, this.address});
}

class ChatPageArgs {
  final String roomId;
  final String myId;
  final String myName;
  const ChatPageArgs({
    required this.roomId,
    required this.myId,
    required this.myName,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tokka App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
      ),
      home : ChatingPage(
        roomId: null,
        myId: 'guest_id',
        myName: 'guest_name',
      )
    );
  }
}