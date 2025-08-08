import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {

  final String text; // 메시지 본문
  final DateTime time; // 보낸 시간
  final bool isMe; // 내가 보낸 메시지인지 여부
  final bool isTail; // 묶음의 마지막(꼬리)인지 여부. true면 시간 표시

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
    required this.isTail,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isTail ? 4 : 4, 
        horizontal: 10,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, // 내가 보낸 건 오른쪽 정렬, 상대는 왼쪽 정렬
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start, // 행 정렬도 동일하게
            crossAxisAlignment: CrossAxisAlignment.end, // 말풍선 하단 기준으로 맞춤
            children: [
              Flexible( // 길면 다음 줄로 감기도록
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth), // 너무 넓어지지 않게 제한
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // 내부 여백(텍스트 위아래 여백 축소)
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFFFFD8B1) // 내 메시지: 주황빛
                          : const Color(0xFFD9D9D9), // 상대 메시지: 회색
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),  // 위-왼쪽 둥글게
                        topRight: const Radius.circular(20), // 위-오른쪽 둥글게
                        bottomLeft:
                            isMe ? const Radius.circular(20) : const Radius.circular(0), // 내가 보낸 건 왼쪽 아래 둥글게
                        bottomRight:
                            isMe ? const Radius.circular(0) : const Radius.circular(20), // 상대가 보낸 건 오른쪽 아래 둥글게
                      ),
                    ),
                    child: Text(
                      text, // 실제 메시지 텍스트
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        height: 1.2, // 줄간격 살짝 조정해서 세로 여백 최소화
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isTail) // 묶음의 맨 마지막 말풍선일 때만 시간 표시
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                _formatTime(time), // "HH:mm" 형태
                textAlign: isMe ? TextAlign.right : TextAlign.left, // 내 메시지는 오른쪽 정렬, 상대는 왼쪽 정렬
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 시간을 "HH:mm" 문자열로 포맷
  String _formatTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}