import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/core/user_global_view_model.dart';
import 'core/address_view_model.dart';
import 'core/geolocator_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_team5_chating_app/pages/searching_page/searching_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutMeController = TextEditingController();
  File? _image;

  Future<void> _prefillFromExistingProfile() async {
    try {
      // 1) 우선 전역 상태(userGlobalProvider)에서 가져오기
      dynamic stateOrUser = ref.read(userGlobalProvider);
      if (stateOrUser is AsyncValue) {
        stateOrUser = stateOrUser.value;
      }
      final String? fullName =
          (stateOrUser?.name ?? stateOrUser?.nickname ?? stateOrUser?.fullName) as String?;
      final String? aboutMe =
          (stateOrUser?.aboutMe ?? stateOrUser?.intro ?? stateOrUser?.bio) as String?;

      if ((fullName ?? '').isNotEmpty && _nameController.text.isEmpty) {
        _nameController.text = fullName!;
      }
      if ((aboutMe ?? '').isNotEmpty && _aboutMeController.text.isEmpty) {
        _aboutMeController.text = aboutMe!;
      }
    } catch (_) {
      // 무시 (아래 Firestore fallback 시도)
    }

    // 2) 전역 상태에 값이 없으면 Firestore에서 직접 로드 (profiles → users 순서)
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      if (user == null) return;

      Future<bool> _applyFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) async {
        if (!doc.exists) return false;
        final data = doc.data()!;
        final String? nameFromDb =
            (data['name'] ?? data['nickname'] ?? data['fullName']) as String?;
        final String? aboutFromDb =
            (data['aboutMe'] ?? data['intro'] ?? data['bio']) as String?;
        if ((nameFromDb ?? '').isNotEmpty && _nameController.text.isEmpty) {
          _nameController.text = nameFromDb!;
        }
        if ((aboutFromDb ?? '').isNotEmpty && _aboutMeController.text.isEmpty) {
          _aboutMeController.text = aboutFromDb!;
        }
        return (nameFromDb != null && nameFromDb.isNotEmpty) ||
               (aboutFromDb != null && aboutFromDb.isNotEmpty);
      }

      final profilesDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();
      final ok = await _applyFromDoc(profilesDoc);
      if (ok) return;

      final usersDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      await _applyFromDoc(usersDoc);
    } catch (_) {
      // 로드 실패는 조용히 무시 (UI는 빈칸 유지)
    }
  }

  @override
  void initState() {
    super.initState();
    _prefillFromExistingProfile();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod 규칙: ref.listen은 build 안에서 사용
    ref.listen(userGlobalProvider, (previous, next) {
      try {
        dynamic stateOrUser = next;
        if (stateOrUser is AsyncValue) {
          stateOrUser = stateOrUser.value;
        }
        final String? fullName =
            (stateOrUser?.name ?? stateOrUser?.nickname ?? stateOrUser?.fullName) as String?;
        final String? aboutMe =
            (stateOrUser?.aboutMe ?? stateOrUser?.intro ?? stateOrUser?.bio) as String?;

        if ((fullName ?? '').isNotEmpty && _nameController.text != fullName) {
          _nameController.text = fullName!;
        }
        if ((aboutMe ?? '').isNotEmpty && _aboutMeController.text != aboutMe) {
          _aboutMeController.text = aboutMe!;
        }
      } catch (_) {
        // 타입 차이 등은 무시
      }
    });

    final addressState = ref.watch(addressViewModel);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SearchingPage()),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'BMJUA',
                      fontSize: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            shape: BoxShape.circle,
                            image: _image != null
                                ? DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _image == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 80,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF24E1E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  'Full Name',
                  style: TextStyle(color: Color(0xFFA7A7A7), fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '이름을 입력해주세요',
                    filled: false,
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFE5E5E5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFE5E5E5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFE5E5E5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x66333333),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'About me',
                  style: TextStyle(color: Color(0xFFA7A7A7), fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _aboutMeController,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '자기소개를 작성해주세요.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '자기소개를 작성해주세요',
                    filled: false,
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFE5E5E5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFE5E5E5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFE5E5E5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x66333333),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
                if (addressState.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    '현재 주소: ${addressState.first}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final position = await GeolocatorHelper.getPosition();
                      if (position != null) {
                        await ref.read(addressViewModel.notifier).searchByLocation(
                          position.latitude,
                          position.longitude,
                        );

                        final address = ref.read(addressViewModel).first;
                        final name = _nameController.text;
                        final aboutMe = _aboutMeController.text;

                        final success = await ref.read(userGlobalProvider.notifier).join(
                          name,
                          address,
                          aboutMe,
                          _image,
                        );

                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SearchingPage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('프로필 저장에 실패했습니다.')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('위치 정보를 가져올 수 없습니다.')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF24E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '수정하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
