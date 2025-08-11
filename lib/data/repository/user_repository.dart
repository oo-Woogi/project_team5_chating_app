import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project_team5_chating_app/model/user.dart';

class UserRepository {
  UserRepository();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<List<User>> getAll() async {
    final collectionRef = firestore.collection('users');
    final snapshot = await collectionRef.get();

    final list = snapshot.docs.map((doc) {
      return User.fromJson(doc.data(), doc.id);
    }).toList();

    return list;
  }

  /// 이미지 파일 경로가 선택적으로 들어옴 (null 가능)
  Future<String?> insert({
    required String name,
    required String aboutMe,
    required String position,
    File? imageFile,
  }) async {
    try {
      print(
        'insert 호출됨: $name, $aboutMe, $position, 이미지 유무: ${imageFile != null}',
      );

      String? imgUrl;

      if (imageFile != null) {
        final storageRef = storage.ref().child(
          'profile_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}',
        );
        await storageRef.putFile(imageFile);
        imgUrl = await storageRef.getDownloadURL();
        print('이미지 업로드 완료, URL: $imgUrl');
      }

      final docRef = firestore.collection('users').doc();
      final data = {
        'name': name,
        'aboutMe': aboutMe,
        'position': position,
        if (imgUrl != null) 'imgpath': imgUrl,
      };

      await docRef.set(data);
      print('Firestore 문서 저장 완료, id: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      print('Firestore 저장 에러: $e');
      return null;
    }
  }
}
