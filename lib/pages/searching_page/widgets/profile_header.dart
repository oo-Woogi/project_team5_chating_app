import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/welcome_page/welcome_page.dart';

// 상단 프로필
class ProfileHeader extends StatelessWidget {
  final String name;
  final String aboutMe;
  final String location;
  final File? profileImage; // 변수 추가

  const ProfileHeader({
    super.key,
    required this.name,
    required this.aboutMe,
    required this.location,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF24E1E),
            backgroundImage: profileImage != null
                ? FileImage(profileImage!)
                : null,
            child: profileImage == null
                ? const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  aboutMe,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '나의 위치: $location',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
