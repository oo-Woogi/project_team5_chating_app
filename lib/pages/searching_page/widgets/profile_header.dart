import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/welcome_page/welcome_page.dart';

// 상단 프로필
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // 누르면 웰컴으로 이동
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WelcomePage()),
        );
      },
      child: Row(
        children: [
          Image.asset('assets/images/icon_person_red.png'),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'zl존 상록',
                  style: TextStyle(
                    fontFamily: 'Pretendard-semiBold',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '좋은 아침이네요~',
                  style: TextStyle(
                    fontFamily: 'Pretendard-semiBold',
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
