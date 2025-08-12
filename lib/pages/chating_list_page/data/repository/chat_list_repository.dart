import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_team5_chating_app/pages/chating_list_page/data/core/chat_list_model.dart';

class ChatListRepository {
  const ChatListRepository();

  Stream<List<ChatListModel>> watchByUid(String uid) {
    final qs = FirebaseFirestore.instance
        .collection('rooms')
        .where('participants', arrayContains: uid)
        .orderBy('lastAt', descending: true);

    return qs.snapshots().map((snap) {
      return snap.docs.map((d) => ChatListModel.fromDoc(d)).toList();
    });
  }
}
