import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/repository/user_repository.dart';
import 'package:project_team5_chating_app/model/user.dart';

// Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Notifier (User 리스트 관리)
class SearchingViewModel extends Notifier<List<User>> {
  @override
  List<User> build() {
    return [];
  }

  Future<void> loadUsers() async {
    final repo = ref.read(userRepositoryProvider);
    final users = await repo.getAll();
    state = users;
  }
}

// NotifierProvider
final searchingViewModelProvider =
    NotifierProvider<SearchingViewModel, List<User>>(
      () => SearchingViewModel(),
    );

// FutureProvider 버전 (단순 읽기)
final userListProvider = FutureProvider<List<User>>((ref) async {
  final repo = ref.read(userRepositoryProvider);
  return await repo.getAll();
});
