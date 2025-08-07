import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'welcome_page.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 160,
            left: -30,
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFFF7E8E1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -50,
            child: Container(
              width: 230,
              height: 230,
              decoration: const BoxDecoration(
                color: Color(0xFFF7E8E1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: const BoxDecoration(
                color: Color(0xFFF7E8E1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 450,
            right: -100,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFFF7E8E1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 200),
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '동네 친구들과 함께하는',
                  style: TextStyle(fontFamily: 'BMJUA', fontSize: 23),
                ),
                Text(
                  '소소한 일상!',
                  style: TextStyle(fontFamily: 'BMJUA', fontSize: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
