import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/core/user_global_view_model.dart';
import 'package:project_team5_chating_app/model/user.dart';
import 'package:project_team5_chating_app/pages/welcome_page/profile_edit_page.dart';
import 'package:project_team5_chating_app/pages/welcome_page/welcome_page.dart';

// 상단 프로필
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userGlobalProvider);

    // 데이터가 없으면 안내 문구 표시
    if (userState.userId.isEmpty) {
      // userState.userId로 상태 확인
      return const Text('프로필을 다시 설정해주세요.');
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileEditPage()),
        );
      },
      child: Row(
        children: [
          // ✨ 변경: 이미지 파일 대신 이미지 URL 사용
          ClipOval(
            child: userState.imgUrl != null
                ? Image.network(
                    userState.imgUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/icon_person_red.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/icon_person_red.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  userState.userName.isNotEmpty ? userState.userName : '이름 없음',
                  style: const TextStyle(
                    fontFamily: 'Pretendard-semiBold',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  userState.aboutMe.isNotEmpty ? userState.aboutMe : '한마디 없음',
                  style: const TextStyle(
                    fontFamily: 'Pretendard-semiBold',
                    fontSize: 14,
                    color: Color(0xFF777777),
                  ),
                ),
                Text(
                  userState.address.isNotEmpty ? userState.address : '주소 없음',
                  style: const TextStyle(
                    fontFamily: 'Pretendard-semiBold',
                    fontSize: 12,
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
