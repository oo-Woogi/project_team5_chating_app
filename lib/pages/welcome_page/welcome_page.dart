import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/core/user_global_view_model.dart';
import 'package:project_team5_chating_app/pages/searching_page/searching_page.dart';
import 'package:project_team5_chating_app/data/repository/user_repository.dart';
import 'core/address_view_model.dart';
import 'core/geolocator_helper.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutmeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _aboutmeController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    try {
      final position = await GeolocatorHelper.getPosition();
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치를 가져올 수 없습니다.')),
        );
        return;
      }

      final addressList = await ref
          .read(addressViewModel.notifier)
          .searchByLocation(position.latitude, position.longitude);

      if (addressList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주소를 찾을 수 없습니다.')),
        );
        return;
      }

      final repo = UserRepository();
      final success = await repo.insert(
        name: _nameController.text.trim(),
        aboutMe: _aboutmeController.text.trim(),
        position: addressList.first,
      );

      if (success) {
        //user globak view model에 현재 사용자 전달
        final userGlobalNotifier = ref.read(userGlobalProvider.notifier);
        userGlobalNotifier.setUserId('고유ID'); // 실제 ID 있으면 교체
        userGlobalNotifier.setUserName(_nameController.text.trim());
        userGlobalNotifier.setAddress(addressList.first);
        userGlobalNotifier.setAboutMe(_aboutmeController.text);

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchingPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장 실패. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      debugPrint('데이터 저장 중 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
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
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E0E0),
                            shape: BoxShape.circle,
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
                    validator: (value) =>
                        value == null || value.isEmpty ? '이름을 입력해주세요.' : null,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'About me',
                    style: TextStyle(color: Color(0xFFA7A7A7), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _aboutmeController,
                    maxLines: 3,
                    validator: (value) =>
                        value == null || value.isEmpty ? '자기소개를 작성해주세요.' : null,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _saveUserData();
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
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      filled: false,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE5E5E5), width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0x66333333), width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }
}
