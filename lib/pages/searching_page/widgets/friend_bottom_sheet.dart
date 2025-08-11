import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/core/user_global_view_model.dart';
import 'package:project_team5_chating_app/model/user.dart';
import 'package:project_team5_chating_app/pages/searching_page/searching_view_model.dart';
import 'package:project_team5_chating_app/pages/chating_page/chating_page.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// 버튼 누르면 나오는 시트 페이지
class FriendBottomSheet extends ConsumerWidget {
  const FriendBottomSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // :전구: userListProvider를 watch하면 AsyncValue 객체를 반환합니다.
    final myId = ref.watch(userGlobalProvider.select((state) => state.userId));
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
                  final myIdStr = (myId ?? '').toString().trim();
                  final filteredList = userList.where((u) => u.id.toString().trim() != myIdStr).toList();
                  return ListView.builder(
                    controller: controller,
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      // :전구: userList에서 개별 user 객체를 가져옵니다.
                      final user = filteredList[index];
                      // :전구: _FriendItem 위젯에 user 객체를 전달합니다.
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: _FriendItem(user: user, myId: myId),
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
class _FriendItem extends ConsumerWidget {
  final User user;
  final String? myId;
  const _FriendItem({required this.user, required this.myId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () async {
          // Firebase Auth uid 우선 확보 (Rules와 일치)
          String myUid = (myId ?? '').trim();
          try {
            final auth = fb_auth.FirebaseAuth.instance;
            var authUid = auth.currentUser?.uid;
            if (authUid == null || authUid.isEmpty) {
              await auth.signInAnonymously();
              authUid = auth.currentUser?.uid;
            }
            if (authUid != null && authUid.isNotEmpty) {
              myUid = authUid;
            }
          } catch (_) {}
          debugPrint('[FriendItem] tap myUid=$myUid partner=${user.id}/${user.name}');
          if (myUid.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('로그인 상태를 확인할 수 없어요. 다시 시도해 주세요.')),
            );
            return;
          }

          try {
            // 방 생성/조회 (예외를 잡아서 사용자에게 원인 표시)
            final vm = ref.read(searchingViewModelProvider.notifier);
            final info = await vm.createChatLaunchInfo(myUid: myUid, partner: user);

            if (!context.mounted) return;
            debugPrint('[FriendItem] selected -> pop with ChatLaunchInfo');
            Navigator.of(context, rootNavigator: true).pop(info);
          } catch (e, st) {
            debugPrint('[FriendItem] onTap error: $e\n$st');
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('채팅방 생성 실패: ${e is fb_auth.FirebaseAuthException ? e.code : e}')),
            );
          }
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
                user.imgpath?.isNotEmpty == true
                    ? ClipOval(
                        child: Image.network(
                          user.imgpath!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, size: 40),
                      ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        user.position,
                        style: const TextStyle(
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
      ),
    );
  }
}
