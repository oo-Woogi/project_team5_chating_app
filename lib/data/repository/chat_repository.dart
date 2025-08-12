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
    print('getAll: Fetched ${docs.length} chats'); // 디버깅
    return docs.map((e) => Chat.fromJson(e.data())).toList();
  }

  // ---------------------------------------------------------------------------
  // Root 컬렉션: chating_message
  // ---------------------------------------------------------------------------

  /// 메시지 1건 저장 (루트 컬렉션: chating_message)
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
        'sender': sender,
        'senderName': sender,
        'senderId': senderId,
        'address': address,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('insert: Message saved to chating_message, address=$address'); // 디버깅
      return true;
    } catch (e) {
      print('insert failed: $e');
      return false;
    }
  }

  /// 특정 roomId의 메시지 스트림 (루트 컬렉션: chating_message)
  Stream<QuerySnapshot<Map<String, dynamic>>> watchChatMessagesRoot(String roomId) {
    final firestore = FirebaseFirestore.instance;
    final stream = firestore
        .collection('chating_message')
        .where('roomId', isEqualTo: roomId)
        .orderBy('createdAt')
        .snapshots();
    stream.listen((snapshot) {
      print('watchChatMessagesRoot: roomId=$roomId, docs=${snapshot.docs.length}'); // 디버깅
    }, onError: (e) {
      print('watchChatMessagesRoot error: $e');
    });
    return stream;
  }

  /// 루트 컬렉션에 메시지 저장
  Future<void> sendChatMessageRoot({
    required String roomId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('chating_message').add({
        'roomId': roomId,
        'senderId': senderId,
        'senderName': senderName,
        'sender': senderName,
        'message': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('sendChatMessageRoot: Message sent to chating_message, roomId=$roomId'); // 디버깅
    } catch (e) {
      print('sendChatMessageRoot failed: $e');
      rethrow; // ChatingPage에서 에러 처리
    }
  }

  // ---------------------------------------------------------------------------
  // Subcollection: rooms/{roomId}/messages
  // ---------------------------------------------------------------------------

  String _pairId(String a, String b) {
    final list = [a, b]..sort();
    return '${list[0]}_${list[1]}';
  }

  /// (나, 상대) uid로 방 ID 생성/반환
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
      print('getOrCreateRoomId: Created room $roomId'); // 디버깅
    } else {
      print('getOrCreateRoomId: Room $roomId exists'); // 디버깅
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
    try {
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
      print('sendMessageToRoom: Message sent to rooms/$roomId/messages'); // 디버깅
    } catch (e) {
      print('sendMessageToRoom failed: $e');
      rethrow; // ChatingPage에서 에러 처리
    }
  }

  /// rooms/{roomId}/messages 실시간 스트림
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(String roomId) {
    final firestore = FirebaseFirestore.instance;
    final stream = firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
    stream.listen((snapshot) {
      print('watchMessages: roomId=$roomId, docs=${snapshot.docs.length}'); // 디버깅
    }, onError: (e) {
      print('watchMessages error: $e');
    });
    return stream;
  }
}