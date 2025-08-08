import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/chating_page/widgets/chat_button.dart';
import 'package:project_team5_chating_app/widgets/appbar.dart';

class ChatingPage extends StatelessWidget {
  const ChatingPage({super.key});

  @override
  Widget build(BuildContext context) {

    //앱바에서 사용할 actions
    Widget actions = IconButton(
          icon: Image.asset('assets/images/Frame.png', width: 24, height: 24),
          onPressed: () {},
    );
    
    return Scaffold(
      appBar: MyAppbar(title: '채팅', actions: actions),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '채팅방 이용 시 개인 정보 및 금융 정보 보호에 유의해주시기 바랍니다. \n광고, 스팸 사기 등의 메시지를 받은 경우 신고해 주세요.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400, // 글씨체 Pretendart Regular 적용
                  fontSize: 13,
                  color: Color(0xff777777),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '2025.08.06(수)',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Color(0xff333333),
                ),
              ),
            ),
          ),
          const Spacer(),
          ChatButton(
            onSendMessage: (text) {
              print('전송된 메시지: $text');
            },
          ),
        ],
      ),
    );
  }
}

