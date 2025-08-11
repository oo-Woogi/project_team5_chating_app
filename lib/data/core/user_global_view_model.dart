import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/repository/user_repository.dart';

class UserGlobalState {
  final String userId;
  final String userName;
  final String address;
  final String aboutMe;

  UserGlobalState({
    required this.userId,
    required this.userName,
    required this.address,
    required this.aboutMe,
  });

  UserGlobalState copyWith({
    String? userId,
    String? userName,
    String? address,
    String? aboutMe,
  }) {
    return UserGlobalState(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      address: address ?? this.address,
      aboutMe: aboutMe ?? this.aboutMe,
    );
  }

  factory UserGlobalState.initial() {
    return UserGlobalState(userId: '', userName: '', address: '', aboutMe: '');
  }
}

class UserGlobalViewModel extends StateNotifier<UserGlobalState> {
  final UserRepository _userRepository;

  UserGlobalViewModel(this._userRepository) : super(UserGlobalState.initial());

  Future<bool> join(String userName, String address, String aboutMe, [File? imageFile]) async {
    final userId = await _userRepository.insert(
      name: userName,
      aboutMe: aboutMe,
      position: address,
      imageFile: imageFile
    );

    if (userId != null) {
      // ID가 null이 아니면 성공
      state = state.copyWith(
        userId: userId, // 생성된 userId로 상태 업데이트
        userName: userName,
        address: address,
        aboutMe: aboutMe,
        
      );
      return true;
    } else {
      return false;
    }
  }

  void setUserId(String id) {
    state = state.copyWith(userId: id);
  }

  void setUserName(String name) {
    state = state.copyWith(userName: name);
  }

  void setAddress(String address) {
    state = state.copyWith(address: address);
  }

  void setAboutMe(String aboutMe) {
    state = state.copyWith(aboutMe: aboutMe);
  }
}

final userGlobalProvider =
    StateNotifierProvider<UserGlobalViewModel, UserGlobalState>((ref) {
      final repo = UserRepository();
      return UserGlobalViewModel(repo);
    });
