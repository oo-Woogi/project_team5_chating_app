// user_repository.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Firebase Auth를 import
import 'package:project_team5_chating_app/model/user.dart';
import 'package:path/path.dart' as path;

class UserRepository {
  UserRepository();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // ✨ 수정: 사용자 ID로 프로필 정보를 가져오는 함수
  Future<User?> getUserProfile(String uid) async {
    try {
      final docRef = firestore.collection('users').doc(uid);
      final doc = await docRef.get();

      if (doc.exists) {
        return User.fromJson(doc.data()!, doc.id);
      }
    } catch (e) {
      print('프로필 불러오기 에러: $e');
    }
    return null;
  }

  /// 이미지 파일 경로가 선택적으로 들어옴 (null 가능)
  // ✨ 수정: 반환형을 String? -> bool로 변경
  Future<bool> insert({
    required String name,
    required String aboutMe,
    required String position,
    File? imageFile,
  }) async {
    try {
      final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception("사용자가 로그인되지 않았습니다.");
      }

      print(
        'insert 호출됨: $name, $aboutMe, $position, 이미지 유무: ${imageFile != null}',
      );
      print('현재 로그인한 uid: $uid');

      String? imgUrl;

      if (imageFile != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
        final storageRef = storage.ref().child('profile_images/$uid/$fileName');
        await storageRef.putFile(imageFile);
        imgUrl = await storageRef.getDownloadURL();
        print('이미지 업로드 완료, URL: $imgUrl');
      }

      final docRef = firestore.collection('users').doc(uid);
      final data = {
        'name': name,
        'aboutMe': aboutMe,
        'position': position,
        if (imgUrl != null) 'imgpath': imgUrl,
      };

      print('Firestore에 저장할 데이터: $data');

      await docRef.set(data, SetOptions(merge: true));
      print('Firestore 문서 병합 저장 완료, id: $uid');

      return true;
    } catch (e, stack) {
      print('Firestore 저장 에러: $e');
      print(stack);
      return false;
    }
  }

  // getAll 함수는 기존 코드와 동일
  Future<List<User>> getAll() async {
    final collectionRef = firestore.collection('users');
    final snapshot = await collectionRef.get();

    print('📌 users 문서 개수: ${snapshot.docs.length}');
    for (var doc in snapshot.docs) {
      print('📄 문서 ID: ${doc.id}, 데이터: ${doc.data()}');
    }

    final list = snapshot.docs.map((doc) {
      return User.fromJson(doc.data(), doc.id);
    }).toList();

    return list;
  }
}
