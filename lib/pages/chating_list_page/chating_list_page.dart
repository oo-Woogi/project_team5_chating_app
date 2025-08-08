import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/chating_list_page/widgets/chat_item.dart';
import 'package:project_team5_chating_app/widgets/appbar.dart';
import 'package:project_team5_chating_app/widgets/bottom_navi.dart';

class ChatingListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Color(0xfff3f3f3),
      appBar: MyAppbar(title: '채팅목록'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(height: 16),
          itemCount: 10,
          itemBuilder: (context, index) {
            return ChatItem();
          },
        ),
      ),
      bottomNavigationBar: BottomNavi(1),
    );
  }
}
