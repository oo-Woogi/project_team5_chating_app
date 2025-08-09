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
