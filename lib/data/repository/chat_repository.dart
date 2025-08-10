import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_team5_chating_app/model/chat.dart';

class ChatRepository {
  const ChatRepository();
  Future<List<Chat>> getAll() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final collectionRef = firestore.collection('chating_message');
    final snapshot = await collectionRef.get();
    final documentSnaphots = snapshot.docs;

    final iterable = documentSnaphots.map((e) {
      final map = e.data();
      return Chat.fromJson(map);
    });

    final list = iterable.toList();
    return list;
  }

  // 1. insert 구현하기
  Future<bool> insert({
    required String sender,
    required String senderId,
    required String address,
    required String message,
    required String createdAt,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final collectionRef = firestore.collection('chating_message');

      final docRef = collectionRef.doc();

      // 생성할 데이터 만들기!
      final map = {
        'sender': sender,
        'senderId': senderId,
        'address': address,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(), // 정렬/일관성을 위해서 서버 타임스탬프 사용
      };
      // 저장!
      await docRef.set(map);
      return true;
    } catch (e) {
      print('에러메시지 $e');
      return false;
    }
  }
  // 2. watchByAddress: 특정 address의 메시지 실시간 스트림
  Stream<List<Chat>> watchByAddress(String address, {int limit = 100}) {
    final firestore = FirebaseFirestore.instance;
    final q = firestore
        .collection('chating_message')
        .where('address', isEqualTo: address)
        .orderBy('createdAt', descending: false)
        .limit(limit);

    return q.snapshots().map((snap) {
      return snap.docs.map((doc) {
        // fromJson과 호환 위해 가변 맵으로 복사하고 Timestamp를 문자열로 변환(필요 시)
        final src = doc.data();
        final data = Map<String, dynamic>.from(src);
        final ca = data['createdAt'];
        if (ca is Timestamp) {
          data['createdAt'] = ca.toDate().toIso8601String();
        }
        return Chat.fromJson(data);
      }).toList();
    });
  }
}
