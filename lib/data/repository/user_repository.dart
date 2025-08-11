import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_team5_chating_app/model/user.dart';

class UserRepository {
  UserRepository();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<User>> getAll() async {
    final collectionRef = firestore.collection('users');
    final snapshot = await collectionRef.get();

    final list = snapshot.docs.map((doc) {
      return User.fromJson(doc.data(), doc.id);
    }).toList();

    return list;
  }

  Future<String?> insert({
    required String name,
    required String aboutMe,
    required String position,
  }) async {
    try {
      final docRef = firestore.collection('users').doc();
      await docRef.set({
        'name': name,
        'aboutMe': aboutMe,
        'position': position,
      });
      return docRef.id; // 성공 시, 생성된 문서의 ID 반환
    } catch (e) {
      print('에러메시지 $e');
      return null; // 실패 시 null 반환
    }
  }
}
