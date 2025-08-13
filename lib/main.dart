import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_team5_chating_app/data/core/user_global_view_model.dart';
import 'package:project_team5_chating_app/data/repository/user_repository.dart';
import 'package:project_team5_chating_app/pages/searching_page/searching_page.dart';
import 'package:project_team5_chating_app/pages/welcome_page/splash_page.dart';
import 'package:project_team5_chating_app/pages/welcome_page/welcome_page.dart';
import 'package:project_team5_chating_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
    print('익명 로그인 완료: ${auth.currentUser?.uid}');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepository = UserRepository();

    return MaterialApp(
      title: 'Chating App',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            final uid = snapshot.data!.uid;

            return FutureBuilder(
              future: userRepository.getUserProfile(uid),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (profileSnapshot.hasData && profileSnapshot.data != null) {
                  // 프로필 있으면 바로 검색 페이지
                  ref.read(userGlobalProvider.notifier).loadUserProfile(uid);
                  return SearchingPage();
                } else {
                  // 프로필 없으면 웰컴페이지로 이동
                  return SplashPage();
                }
              },
            );
          }

          // 유저 데이터 없으면 웰컴페이지 (보통 로그아웃 상태)
          return SplashPage();
        },
      ),
    );
  }
}
