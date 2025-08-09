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

  Future<bool> insert({
    required String name,
    required String aboutMe,
    required String position,
  }) async {
    try {
      final docRef = firestore.collection('users').doc(); // 자동 생성 ID
      await docRef.set({
        'name': name,
        'aboutMe': aboutMe,
        'position': position,
      });
      return true;
    } catch (e) {
      print('에러메시지 $e');
      return false;
    }
  }
}
