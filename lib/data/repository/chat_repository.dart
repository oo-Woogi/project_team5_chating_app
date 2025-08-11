import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/model/chat.dart';

/// 리포지토리 DI
final chatRepositoryProvider = Provider<ChatRepository>((ref) => const ChatRepository());

/// Firestore 채팅 리포지토리
class ChatRepository {
  const ChatRepository();

  /// 기존 "chat" 컬렉션 전체 조회 (사용 중이면 유지)
  Future<List<Chat>> getAll() async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('chat');
    final snapshot = await collectionRef.get();
    final docs = snapshot.docs;
    return docs.map((e) => Chat.fromJson(e.data())).toList();
  }

  // ---------------------------------------------------------------------------
  // Root 컬렉션: chating_message  (요구사항: 메시지를 루트 컬렉션에 저장)
  // ---------------------------------------------------------------------------

  /// 메시지 1건 저장 (루트 컬렉션: chating_message)
  /// createdAt은 항상 서버시간으로 저장. (호출부에서 어떤 값을 넘겨도 무시)
  Future<bool> insert({
    required String sender,
    required String senderId,
    required String address,
    required String message,
    Object? createdAt, // 호환성 유지를 위해 남겨두지만 사용하지 않음
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('chating_message').doc();

      await docRef.set({
        'sender': sender,           // 표시용 이름
        'senderName': sender,       // 호환 키
        'senderId': senderId,       // 발신자 UID
        'address': address,         // 방/주소 식별자 또는 메타
        'message': message,         // 본문
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('insert() 실패: $e');
      return false;
    }
  }

  /// 특정 roomId의 메시지 스트림 (루트 컬렉션: chating_message)
  /// roomId 필터가 필요한 경우, 저장 시 map에 roomId 필드를 함께 넣으세요.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchChatMessagesRoot(String roomId) {
    final firestore = FirebaseFirestore.instance;
    return firestore
        .collection('chating_message')
        .where('roomId', isEqualTo: roomId)
        .orderBy('createdAt')
        .snapshots();
  }

  /// 루트 컬렉션에 메시지를 저장할 때 roomId를 함께 기록하고 싶을 때 사용
  Future<void> sendChatMessageRoot({
    required String roomId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('chating_message').add({
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'sender': senderName,
      'message': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // Subcollection: rooms/{roomId}/messages (필요 시 사용)
  // ---------------------------------------------------------------------------

  String _pairId(String a, String b) {
    final list = [a, b]..sort();
    return '${list[0]}_${list[1]}';
  }

  /// (나, 상대) uid로 방 ID를 결정적으로 생성하고, 없으면 생성 후 반환
  Future<String> getOrCreateRoomId({
    required String myUid,
    required String partnerUid,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final roomId = _pairId(myUid, partnerUid);
    final roomRef = firestore.collection('rooms').doc(roomId);
    final snap = await roomRef.get();
    if (!snap.exists) {
      await roomRef.set({
        'participants': [myUid, partnerUid],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastAt': FieldValue.serverTimestamp(),
      });
    }
    return roomId;
  }

  /// rooms/{roomId}/messages에 메시지 전송
  Future<void> sendMessageToRoom({
    required String roomId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final msgCol = firestore.collection('rooms').doc(roomId).collection('messages');

    await msgCol.add({
      'senderId': senderId,
      'senderName': senderName,
      'sender': senderName,
      'message': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await firestore.collection('rooms').doc(roomId).update({
      'lastMessage': text,
      'lastAt': FieldValue.serverTimestamp(),
    });
  }

  /// rooms/{roomId}/messages 실시간 스트림
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(String roomId) {
    final firestore = FirebaseFirestore.instance;
    return firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }
}
