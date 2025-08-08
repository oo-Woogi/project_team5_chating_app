import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/chating_page/widgets/chat_button.dart';
import 'package:project_team5_chating_app/widgets/appbar.dart';
import 'package:project_team5_chating_app/pages/chating_page/widgets/message_bubble.dart';

class ChatingPage extends StatefulWidget {
  const ChatingPage({super.key});

  @override
  State<ChatingPage> createState() => _ChatingPageState();
}

class _ChatingPageState extends State<ChatingPage> {
  final ScrollController _scrollController = ScrollController();
  final List<_Message> _messages = [];

  @override
  Widget build(BuildContext context) {
    // 앱바에서 사용할 actions
    Widget actions = IconButton(
      icon: Image.asset('assets/images/Frame.png', width: 24, height: 24),
      onPressed: () {},
    );

    final now = DateTime.now();

    return Scaffold(
      appBar: MyAppbar(title: '채팅', actions: actions),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
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
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Color(0xff777777),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // 메시지 영역
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                if (_messages.isNotEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDateHeader(now),
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xff333333),
                        ),
                      ),
                    ),
                  ),
                for (int i = 0; i < _messages.length; i++)
                  MessageBubble(
                    text: _messages[i].text,
                    time: _messages[i].time,
                    isMe: _messages[i].isMe,
                    isTail: _isTail(i),
                  ),
              ],
            ),
          ),

          // 입력창
          ChatButton(
            onSendMessage: (text) {
              final trimmed = text.trim();
              if (trimmed.isEmpty) return;
              setState(() {
                _messages.add(_Message(text: trimmed, time: DateTime.now(), isMe: true));
              });
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

// 두 객체가 같은 "분" 단위인지 비교
// 같은 분이면 시간 텍스트를 묶어 한 번만 보여줌
  bool _isSameMinute(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

// 현재 인덱스의 말풍선이 tail인지 확인
// 같은 사람 + 다른 사용자 연속해서 보낸 메시지 묶음의 마지막 부분에만 시간이 출력되도록 함
  bool _isTail(int index) {
    // 마지막 인덱스는 항상 tail처리
    if (index == _messages.length - 1) return true;
    final curr = _messages[index];
    final next = _messages[index + 1];
    // 다음 메시지와 보낸 사람이 다르면 현재 메시지가 tail
    if (curr.isMe != next.isMe) return true;
    // 다음 메시지와 분(시간)이 달라지면 묶음이 끊겨 현재 메시지가 tail 적용
    return !_isSameMinute(curr.time, next.time);
  }

  String _formatDateHeader(DateTime d) {
    const wd = ['', '월', '화', '수', '목', '금', '토', '일'];
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y.$m.$day(${wd[d.weekday]})';
  }
}

class _Message {
  final String text;
  final DateTime time;
  final bool isMe; 
  _Message({
    required this.text, 
    required this.time, 
    this.isMe = true});
}
