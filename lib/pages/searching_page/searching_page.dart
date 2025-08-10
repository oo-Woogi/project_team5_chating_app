import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/searching_page/widgets/friend_bottom_sheet.dart';
import 'package:project_team5_chating_app/pages/chating_page/chating_page.dart';
import 'package:project_team5_chating_app/widgets/bottom_navi.dart';
import 'widgets/chat_icon_button.dart';
import 'widgets/animated_location_image.dart';
import 'widgets/profile_header.dart';

class SearchingPage extends StatelessWidget {
  const SearchingPage({super.key});

  Future<bool> _confirmStartChat(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('채팅 시작'),
        content: const Text('채팅을 시작하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showFriendBottomSheet(BuildContext context, {required String? myName}) async {
    // 데모용 친구 목록 (roomId 포함). 실제 데이터로 교체 가능
    final friends = List.generate(5, (i) => {
          'name': '지존 상록',
          'subtitle': '좋은 아침이네요~',
          'roomId': 'room_demo_${i + 1}',
        });

    final selection = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 그랩 핸들
                Center(
                  child: Container(
                    width: 56,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const Text(
                  '근처에 있는 친구',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: friends.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (ctx, i) {
                      final f = friends[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // 항목 탭 시 선택된 roomId와 peerName을 반환
                          Navigator.of(ctx).pop({
                            'roomId': f['roomId'] as String,
                            'peerName': f['name'] as String,
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF24E1E)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFFF24E1E).withOpacity(0.12),
                                child: const Icon(Icons.person, color: Color(0xFFF24E1E), size: 36),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f['name'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      f['subtitle'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        color: Color(0xFF9E9E9E),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // 항목을 누르면 bottomSheet에서 {roomId, peerName}를 반환하고, 여기서 확인 다이얼로그 후 채팅으로 이동
    if (selection != null && selection['roomId'] != null) {
      final roomId = selection['roomId']!;
      final peerName = selection['peerName'] ?? '상대';
      final id = (myName == null || myName.isEmpty) ? 'guest' : myName;
      final ok = await _confirmStartChat(context);
      if (!ok) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatingPage(
            roomId: roomId,
            myId: id,
            myName: id,
            peerName: peerName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // WelcomePage 등에서: Navigator.pushNamed(context, '/search', arguments: {'userName': name});
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final String? userName = (routeArgs is Map) ? routeArgs['userName'] as String? : null;
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
              onPressed: () => _showFriendBottomSheet(context, myName: userName), // 시트 페이지 소환 후 선택되면 채팅으로 이동
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
