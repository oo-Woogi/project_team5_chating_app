import 'package:flutter/material.dart';

// 버튼 누르면 나오는 시트 페이지
class FriendBottomSheet extends StatelessWidget {
  const FriendBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: ListView.builder(
                controller: controller,
                itemCount: 10,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: _FriendItem(), // 리스트 아이템 위젯 분리
                ),
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
  const _FriendItem();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 친구 클릭 이벤트 처리!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      },

      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Color(0XFFF24E1E),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Image.asset('assets/images/icon_person_red.png'),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
        ),
      ),
    );
  }
}
