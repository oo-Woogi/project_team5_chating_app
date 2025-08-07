import 'package:flutter/material.dart';

class ChatButton extends StatefulWidget {
  final ValueChanged<String> onSendMessage;

  const ChatButton({
    Key? key, required this.onSendMessage
    }) : super(key: key);

    @override
  _ChatButtonState createState() => _ChatButtonState();
}

class _ChatButtonState extends State<ChatButton> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        Container(
          height: 100 + bottomInset,
          color: const Color(0xFFD9D9D9),
        ),
        SafeArea(
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(20),
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    // 채팅방 입력창
                    controller: _controller,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: '대화 내용을 입력하세요.',
                      hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 13, // 폰트 크기 16 > 13으로 변경 why? => 텍스트 박스 크기에 맞추기 위함
                        color: Color(0xff777777),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                      suffixIcon: IconButton(
                        icon: Image.asset('assets/images/send.png', width: 24, height: 24),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}