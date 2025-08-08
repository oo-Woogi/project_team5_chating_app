import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/searching_page/widgets/friend_bottom_sheet.dart';
import 'package:project_team5_chating_app/widgets/bottom_navi.dart';
import 'widgets/chat_icon_button.dart';
import 'widgets/animated_location_image.dart';
import 'widgets/profile_header.dart';

class SearchingPage extends StatelessWidget {
  const SearchingPage({super.key});

  void _showFriendBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => const FriendBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 아이콘 제거
        title: const Text(
          '홈',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: const [
          ChatIconButton(),
          SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: const [
              Padding(
                padding: EdgeInsets.all(32),
                child: ProfileHeader(),
              ),
              // 근처 친구 찾아볼까 문구
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 34),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    '내 근처에 있는\n친구를 찾아볼까요?',
                    style: TextStyle(fontFamily: 'BMJUA', fontSize: 32),
                  ),
                ),
              ),
              SizedBox(height: 20),
              AnimatedLocationImage(),
            ],
          ),
          Positioned(
            bottom: 140,
            left: 32,
            right: 32,

            child: ElevatedButton(
              onPressed: () => _showFriendBottomSheet(context), // 시트 페이지 소환술
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFFF24E1E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text(
                '근처 친구 찾기',
                style: TextStyle(
                  fontFamily: 'BMJUA',
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavi(2),
    );
  }
}
