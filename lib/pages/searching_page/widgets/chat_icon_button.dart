import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/chating_list_page/chating_list_page.dart';

class ChatIconButton extends StatefulWidget {
  const ChatIconButton({super.key});

  @override
  State<ChatIconButton> createState() => _ChatIconButtonState();
}

class _ChatIconButtonState extends State<ChatIconButton> {
  bool isClicked = false;

  void _onTap() {
    setState(() => isClicked = true);
    Timer(
      const Duration(milliseconds: 100),
      () {
        setState(() => isClicked = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatingListPage()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Image.asset(
        isClicked
            ? 'assets/images/icon_chat_on.png'
            : 'assets/images/icon_chat.png',
        width: 50,
        height: 50,
      ),
    );
  }
}
