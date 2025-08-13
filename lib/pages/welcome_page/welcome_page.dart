import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/core/user_global_view_model.dart';
import 'core/address_view_model.dart';
import 'core/geolocator_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_team5_chating_app/pages/searching_page/searching_page.dart';
import 'package:project_team5_chating_app/pages/welcome_page/core/address_view_model.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutMeController = TextEditingController();
  File? _image; // 선택된 이미지 파일을 저장할 변수

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
    final addressState = ref.watch(addressViewModel);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white),
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
                      fontSize: 44,
                      color: Colors.black,
                    ),
                  ),
                ),

                // 프로필
                const SizedBox(height: 35),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // 이미지 선택 시, 이미지 표시. 아니면 기본 아이콘 표시
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 138,
                          height: 138,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
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
                          width: 38,
                          height: 39,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF2421E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 58),
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
                        color: Color(0x66333333),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x66333333),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFC7C7C7), // o
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x66333333), // k
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
                  controller: _aboutMeController, // 컨트롤러 연결
                  //maxLines: 3,
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
                        color: Color(0x66333333),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x66333333),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFC7C7C7),
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

                // 주소 표시 영역
                if (addressState.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    '현재 주소: ${addressState.first}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],

                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () async {
                    print('버튼');
                    if (_formKey.currentState!.validate()) {
                      final position = await GeolocatorHelper.getPosition();
                      if (position != null) {
                        await ref
                            .read(addressViewModel.notifier)
                            .searchByLocation(
                              position.latitude,
                              position.longitude,
                            );

                        final address = ref.read(addressViewModel).first;
                        print(address);
                        final name = _nameController.text;
                        final aboutMe = _aboutMeController.text;

                        await ref
                            .read(userGlobalProvider.notifier)
                            .join(name, address, aboutMe);

                        // SearchingPage로 데이터와 함께 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchingPage(
                              name: name,
                              aboutMe: aboutMe,
                              location: address,
                              profileImage: _image, // 이미지 파일 전달
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('위치 정보를 가져올 수 없습니다.')),
                        );
                      }
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2421E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '시작하기',
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
