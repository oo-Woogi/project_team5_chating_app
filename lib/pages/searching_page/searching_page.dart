import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
import 'package:project_team5_chating_app/pages/searching_page/widgets/friend_bottom_sheet.dart';
import 'package:project_team5_chating_app/widgets/bottom_navi.dart';
import 'widgets/animated_location_image.dart';
import 'widgets/profile_header.dart';
import 'package:project_team5_chating_app/pages/chating_page/chating_page.dart';
import 'package:project_team5_chating_app/pages/searching_page/searching_view_model.dart'
    show ChatLaunchInfo;

class SearchingPage extends StatelessWidget {
  // final String name;
  // final String aboutMe;
  // final String location;
  // final File? profileImage; // 변수 추가

  // const SearchingPage({
  //   super.key,
  //   required this.name,
  //   required this.aboutMe,
  //   required this.location,
  //   required this.profileImage,
  // });

  Future<void> _showFriendBottomSheet(BuildContext context) async {
    try {
      debugPrint('[SearchingPage] open FriendBottomSheet');
      final info = await showModalBottomSheet<ChatLaunchInfo>(
        context: context,
        useRootNavigator: true, // 하단 탭 등 중첩 네비게이터 위에 표시
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => const FriendBottomSheet(),
      );

      if (info == null) {
        debugPrint('[SearchingPage] sheet dismissed without selection');
        return;
      }
      if (!context.mounted) return;

      debugPrint(
        '[SearchingPage] navigate -> roomId=${info.roomId}, partner=${info.partner.name}',
      );
      // 바텀시트가 완전히 닫힌 뒤에 네비게이션을 트리거
      await Future.delayed(const Duration(milliseconds: 10));
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => ChatingPage(
            roomId: info.roomId,
            partnerUid: info.partner.id,
            partnerName: info.partner.name,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('시트를 여는 중 오류: $e')),
      );
      debugPrint('[SearchingPage] open sheet error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final displayName = name.replaceAll('/search', '');
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
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                // 2. ProfileHeader에 전달받은 데이터를 넘겨줌
                child: ProfileHeader(
                  // name: displayName,
                  // aboutMe: aboutMe,
                  // location: location,
                  // profileImage: profileImage,
                ),
              ),
              // 근처 친구 찾아볼까 문구
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 34, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    '내 근처에 있는\n친구를 찾아볼까요?',
                    style: TextStyle(fontFamily: 'BMJUA', fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const AnimatedLocationImage(),
            ],
          ),
          Positioned(
            bottom: 110,
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
      bottomNavigationBar: BottomNavi(0),
    );
  }
}
