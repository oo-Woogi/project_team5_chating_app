import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/chating_list_page/chating_list_page.dart';
import 'package:project_team5_chating_app/pages/searching_page/searching_page.dart';
import 'package:project_team5_chating_app/pages/welcome_page/welcome_page.dart';

class BottomNavi extends StatelessWidget {
  final int currentIndex;
  BottomNavi(this.currentIndex);

  void naviOnTap(BuildContext context, int index) {
    if (index == currentIndex) return; // 이미 선택된 페이지면 무시

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = WelcomePage();
        break;
      case 1:
        targetPage = ChatingListPage();
        break;
      case 2:
        targetPage = SearchingPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => targetPage,
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(70),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          bottomNaviItem(context, 0, '홈', 'home'),
          bottomNaviItem(context, 1, '채팅', 'chat'),
          bottomNaviItem(context, 2, '프로필', 'user'),
        ],
      ),
    );
  }

  GestureDetector bottomNaviItem(BuildContext context, int index, String label, String img) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () {
        return naviOnTap(context, index);
      },
      child: SizedBox(
        width: 70,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(isSelected? 'assets/images/icon_${img}_on.png' : 'assets/images/icon_${img}.png'),
            SizedBox(height: 4,),
            Text(label, style: TextStyle(color: isSelected ? Color(0xffF24E1E) : Color(0xff999999), fontSize: 12),),
          ],
        ),
      ),
    );
  }
}

  
