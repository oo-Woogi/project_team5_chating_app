import 'package:flutter/material.dart';

class ChatingPage extends StatelessWidget {
  const ChatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '채팅',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600, // 글씨체 Pretendart SemiBold 적용
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon : Image.asset(
              'assets/images/Frame.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('채팅 페이지 본문 영역'),
      ),
    );
  }
}