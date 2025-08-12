import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:project_team5_chating_app/model/user.dart';

class UserGlobalState {
  final String userId;
  final String userName;
  final String address;
  final String aboutMe;
  final String? imgUrl;

  UserGlobalState({
    required this.userId,
    required this.userName,
    required this.address,
    required this.aboutMe,
    this.imgUrl,
  });

  UserGlobalState copyWith({
    String? userId,
    String? userName,
    String? address,
    String? aboutMe,
    String? imgUrl,
  }) {
    return UserGlobalState(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      address: address ?? this.address,
      aboutMe: aboutMe ?? this.aboutMe,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }

  factory UserGlobalState.initial() {
    return UserGlobalState(
      userId: '',
      userName: '',
      address: '',
      aboutMe: '',
      imgUrl: null,
    );
  }
}

class UserGlobalViewModel extends StateNotifier<UserGlobalState> {
  final UserRepository _userRepository;
  UserGlobalViewModel(this._userRepository) : super(UserGlobalState.initial());

  Future<void> loadUserProfile(String uid) async {
    print('loadUserProfile 호출됨: uid=$uid');
    final userProfile = await _userRepository.getUserProfile(uid);
    if (userProfile != null) {
      print('프로필 데이터 불러옴: name=${userProfile.name}, address=${userProfile.position}');
      state = state.copyWith(
        userId: uid,
        userName: userProfile.name,
        address: userProfile.position,
        aboutMe: userProfile.aboutMe,
        imgUrl: userProfile.imgpath,
      );
    } else {
      print('프로필 데이터가 Firestore에 없음');
    }
  }

  Future<bool> join(
    String userName,
    String address,
    String aboutMe, [
    File? imageFile,
  ]) async {
    final result = await _userRepository.insert(
      name: userName,
      aboutMe: aboutMe,
      position: address,
      imageFile: imageFile,
    );
    if (result) {
      final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        state = state.copyWith(
          userId: uid,
          userName: userName,
          address: address,
          aboutMe: aboutMe,
        );
        final userProfile = await _userRepository.getUserProfile(uid);
        state = state.copyWith(imgUrl: userProfile?.imgpath);
        return true;
      }
    }
    return false;
  }
}

final userGlobalProvider =
    StateNotifierProvider<UserGlobalViewModel, UserGlobalState>((ref) {
  final repo = UserRepository();
  return UserGlobalViewModel(repo);
});
