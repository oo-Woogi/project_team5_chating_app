import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 간지나는 이미지를 위해 StatefulWidget으로 변경
class SearchingPage extends StatefulWidget {
  const SearchingPage({super.key});

  @override
  State<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage>
    with SingleTickerProviderStateMixin {
  //

  // 애니메이션 컨트롤러 추가
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true); // 위아래 반복

    _animation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  //

  // 컨트롤러 정리
  @override
  void dispose() {
    _controller.dispose(); // 메모리의 누수를 방지하기위해 사용된다고 함
    super.dispose();
  }
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),

      /// 앱바 부분
      appBar: AppBar(
        title: Text(
          '홈',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.bubble_left_bubble_right),
            onPressed: () {
              //페이지 이동 추가!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            },
          ),
          SizedBox(width: 10),
        ],
      ),

      //
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  /// 프로필 부분
                  children: [
                    Image.asset('assets/images/icon_person_red.png'),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '좋은 아침이네요~',
                            style: TextStyle(
                              fontFamily: 'Pretendard-semiBold',
                              color: Color(0xFF777777),
                            ),
                          ),
                          Text(
                            'zl존 상록',
                            style: TextStyle(
                              fontFamily: 'Pretendard-semiBold',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  //
                ),
              ),

              /// 근처에 있는 친구를 찾아볼까 문구
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    '내 근처에 있는\n친구를 찾아볼까요?',
                    style: TextStyle(fontFamily: 'BMJUA', fontSize: 32),
                  ),
                ),
              ),
              //
              SizedBox(height: 20),

              /// Location 이미지 - 애니메이션 추가
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_animation.value - 10), // 이미지 위치 조절
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/img_main.png',
                  width: 240,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
              //
            ],
          ),

          /// 근처 친구 찾기 버튼
          Positioned(
            bottom: 140,
            left: 32,
            right: 32,
            child: ElevatedButton(
              onPressed: () {
                // 버튼 동작
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // 높이 제어
                  backgroundColor: Colors.white,
                  builder: (context) {
                    //드래그해서 시트를 위아래로 스크롤 할 수 있는 위젯
                    return DraggableScrollableSheet(
                      initialChildSize: 0.75, // 처음 높이
                      minChildSize: 0.2, // 최소 축소
                      maxChildSize: 0.75, // 최대 크기
                      expand: false, // true면 전체영역 차지, false는 드래그한 만큼 시트 확장
                      builder: (context, ScrollController) {
                        ///시트 안쪽
                        return Column(
                          children: [
                            //상단바 추가하기!!!!!!!!!!!!
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Container(
                                //상단 바 막대
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Color(0xFF777777),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Expanded(
                              //친구 목록을 리스트 뷰로 나열
                              child: ListView.builder(
                                controller: ScrollController,
                                // 임시 친구 5명 설정
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    // 친구 목록 수정하기!!!!!!!!!!!!!!!!!!!!
                                    title: Text('근처에 있는 친구'),
                                    //
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0XFFF24E1E),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Text(
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
    );
  }
}
