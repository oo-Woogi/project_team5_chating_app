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
  final String? address;        // (선택) 위치/동네
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
      // 첫 화면
      initialRoute: '/splash',

      // 간단 라우트 테이블
      routes: {
        '/splash': (_) => SplashPage(),

        // 웰컴(프로필 입력 후 “친구 찾기”로 이동)
        '/search': (ctx) => const SearchingPage(),

        // 채팅 목록
        '/chatList': (_) => ChatingListPage(),

        // 채팅방
        '/chat': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;

          // 1) 정상 경로: ChatPageArgs가 오면 바로 채팅방 진입
          if (args is ChatPageArgs) {
            return ChatingPage(
              roomId: args.roomId,
              myId: args.myId,
              myName: args.myName,
            );
          }

          // 2) 레거시/임시: Map으로 전달된 경우도 지원
          if (args is Map) {
            final roomId = (args['roomId'] as String?) ?? 'room_demo';
            final myName = (args['myName'] as String?) ?? 'guest';
            final myId = (args['myId'] as String?) ?? myName;
            return ChatingPage(
              roomId: roomId,
              myId: myId,
              myName: myName,
            );
          }

          // 3) 인자가 없으면 반드시 "상대찾기"부터 거치게 함
          return const SearchingPage();
        },
      },
    );
  }
}