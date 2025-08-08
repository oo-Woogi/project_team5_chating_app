import 'package:flutter/material.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? actions;
  const MyAppbar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        color: Colors.black,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600, // 글씨체 Pretendart SemiBold 적용
          color: Colors.black,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: actions == null ? null : [actions!],
    );
  }
}
