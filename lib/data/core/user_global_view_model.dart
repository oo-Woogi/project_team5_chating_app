import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  UserGlobalViewModel() : super(UserGlobalState.initial());

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
  return UserGlobalViewModel();
});
