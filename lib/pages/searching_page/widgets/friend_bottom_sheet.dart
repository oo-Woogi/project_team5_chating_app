import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/model/user.dart';
import 'package:project_team5_chating_app/pages/searching_page/searching_veiw_model.dart';

// 버튼 누르면 나오는 시트 페이지
class FriendBottomSheet extends ConsumerWidget {
  const FriendBottomSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // :전구: userListProvider를 watch하면 AsyncValue 객체를 반환합니다.
    final userListAsyncValue = ref.watch(userListProvider);
    return DraggableScrollableSheet(
      //높이 조절
      initialChildSize: 0.75, //처음 높이
      minChildSize: 0.2, // 최소
      maxChildSize: 0.8, //최대
      expand: false,
      builder: (context, controller) {
        return Column(
          children: [
            // 스크롤 컨트롤러 같이 생긴 바
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF777777),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: SizedBox(width: 40, height: 5),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 22, bottom: 15, top: 10),
              width: double.infinity,
              child: Text(
                '근처에 있는 친구',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                textAlign: TextAlign.left,
              ),
            ),
            // 친구 목록
            Expanded(
              // :전구: 여기서 AsyncValue.when()을 사용해 상태별로 다른 위젯을 반환합니다.
              child: userListAsyncValue.when(
                data: (userList) {
                  // :전구: 데이터가 로드되면 userList 변수에 List<User>가 들어옵니다.
                  // 이 userList를 ListView.builder의 itemCount에 사용합니다.
                  return ListView.builder(
                    controller: controller,
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      // :전구: userList에서 개별 user 객체를 가져옵니다.
                      final user = userList[index];
                      // :전구: _FriendItem 위젯에 user 객체를 전달합니다.
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: _FriendItem(user: user),
                      );
                    },
                  );
                },
                loading: () {
                  // 로딩 중일 때는 로딩 인디케이터를 보여줍니다.
                  return const Center(child: CircularProgressIndicator());
                },
                error: (error, stackTrace) {
                  // 에러가 발생했을 때는 에러 메시지를 보여줍니다.
                  return Center(child: Text('에러가 발생했습니다: $error'));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// 친구 아이템 하나를 표시하는 위젯
class _FriendItem extends StatelessWidget {
  final User user;
  const _FriendItem({required this.user});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 친구 클릭 이벤트 처리
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0XFFF24E1E),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // :전구: user 객체의 데이터를 사용합니다.
              // user.image가 정확한 필드명인지 확인해 주세요.
              // Image.asset(user.image),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // :전구: user 객체의 데이터를 사용합니다.
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard-semiBold',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      user.position, // user.position이 정확한 필드명인지 확인해 주세요.
                      style: const TextStyle(
                        fontFamily: 'Pretendard-semiBold',
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
