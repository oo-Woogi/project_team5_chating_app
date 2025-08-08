import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_team5_chating_app/model/chat.dart';

class ChatRepository {
  const ChatRepository();
  Future<List<Chat>> getAll() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final collectionRef = firestore.collection('chat');
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
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final collectionRef = firestore.collection('chat');

      final docRef = collectionRef.doc();

      // 생성할 데이터 만들기!
      final map = {
        'sender': sender,
        'senderId': senderId,
        'address': address,
        'message': message,
        'createdAt': createdAt,
      };
      // 저장!
      await docRef.set(map);
      return true;
    } catch (e) {
      print('에러메시지 $e');
      return false;
    }
  }
}
