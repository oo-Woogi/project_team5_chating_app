import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/repository/user_repository.dart';
import 'package:project_team5_chating_app/data/repository/chat_repository.dart';
import 'package:project_team5_chating_app/model/user.dart' as M;
import 'package:flutter/foundation.dart';

// Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Notifier (User 리스트 관리)
class SearchingViewModel extends Notifier<List<M.User>> {
  String _toStr(dynamic v) => v == null ? '' : v.toString().trim();

  @override
  List<M.User> build() {
    return [];
  }

  Future<void> loadUsers() async {
    final repo = ref.read(userRepositoryProvider);
    final users = await repo.getAll();
    state = users;
  }

  /// (나, 상대) uid로 채팅방을 결정적으로 생성/조회하고 roomId를 반환
  Future<String> getOrCreateRoomId({
    required String myUid,
    required String partnerUid,
  }) async {
    final chatRepo = ref.read(chatRepositoryProvider);
    debugPrint('[ChatLaunch] getOrCreateRoomId my=$myUid partner=$partnerUid');
    final id = await chatRepo.getOrCreateRoomId(myUid: myUid, partnerUid: partnerUid);
    debugPrint('[ChatLaunch] roomId=$id');
    return id;
  }

  /// UI에서 바로 쓰기 편하도록, partner User를 함께 돌려주는 헬퍼
  Future<ChatLaunchInfo> createChatLaunchInfo({
    required String myUid,
    required M.User partner,
  }) async {
    // --- partner UID 추출 (id 우선) ---
    final dynamic pd = partner as dynamic;
    String partnerUid = '';
    try {
      // 후보 순서: id → uid → userId → userID → uuid → key → docId → documentId
      final candidates = [
        () => pd.id,
        () => pd.uid,
        () => pd.userId,
        () => pd.userID,
        () => pd.uuid,
        () => pd.key,
        () => pd.docId,
        () => pd.documentId,
      ];
      for (final get in candidates) {
        try {
          final val = _toStr(get());
          if (val.isNotEmpty) {
            partnerUid = val;
            break;
          }
        } catch (_) { /* 다음 후보 시도 */ }
      }
    } catch (_) {
      partnerUid = '';
    }

    final String myUidStr = _toStr(myUid);
    debugPrint('[ChatLaunch] resolve uid -> myUid=$myUidStr partnerUid=$partnerUid (model=${partner.runtimeType})');

    if (myUidStr.isEmpty || partnerUid.isEmpty) {
      throw StateError('유효하지 않은 UID 입니다. (myUid=$myUidStr, partnerUid=$partnerUid)');
    }
    if (myUidStr == partnerUid) {
      throw StateError('본인과의 채팅방은 생성할 수 없습니다.');
    }

    final roomId = await getOrCreateRoomId(myUid: myUidStr, partnerUid: partnerUid);
    return ChatLaunchInfo(roomId: roomId, partner: partner);
  }

  /// 예외를 던지지 않는 안전 래퍼. 실패 시 null 반환하고 로그 남김
  Future<ChatLaunchInfo?> createChatLaunchInfoSafe({
    required String myUid,
    required M.User partner,
  }) async {
    try {
      return await createChatLaunchInfo(myUid: myUid, partner: partner);
    } catch (e, st) {
      debugPrint('[ChatLaunch] error=$e\n$st');
      return null;
    }
  }
}

// NotifierProvider
final searchingViewModelProvider =
    NotifierProvider<SearchingViewModel, List<M.User>>(
      () => SearchingViewModel(),
    );

// FutureProvider 버전 (단순 읽기)
final userListProvider = FutureProvider<List<M.User>>((ref) async {
  final repo = ref.read(userRepositoryProvider);
  return await repo.getAll();
});

/// 채팅 화면으로 이동할 때 함께 넘길 데이터
class ChatLaunchInfo {
  final String roomId;
  final M.User partner;
  const ChatLaunchInfo({required this.roomId, required this.partner});
}
