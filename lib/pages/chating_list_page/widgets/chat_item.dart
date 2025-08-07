import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Image.asset('assets/images/icon_person_gray.png'),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dragon 지훈',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '여기 계신 분들은 쉬우셨나보네요~',
                    style: TextStyle(fontSize: 14, color: Color(0xff777777)),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 6),
                    width: double.infinity,
                    child: Text(
                      '2025-11-15 T 20:57',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff999999),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
