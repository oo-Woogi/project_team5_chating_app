import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('폰트테스트입니다.', style: TextStyle(fontWeight: FontWeight.w100)),
            Text('폰트테스트입니다.', style: TextStyle(fontWeight: FontWeight.w200)),
            Text('폰트테스트입니다.', style: TextStyle(fontWeight: FontWeight.w300)),
            Text('폰트테스트입니다.', style: TextStyle(fontWeight: FontWeight.w400)),
            Text('폰트테스트입니다.', style: TextStyle(fontWeight: FontWeight.w500)),
            Text('폰트테스트입니다.', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('폰트테스트입니다.', style: TextStyle(fontWeight: FontWeight.w700)),
            Text('폰트테스트입니다.', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('폰트테스트입니다.', style: TextStyle(fontWeight: FontWeight.w900)),
            Text('폰트테스트입니다.', style: TextStyle(fontFamily: 'Bmjua')),
          ],
        ),
      )),
    );
  }
}
