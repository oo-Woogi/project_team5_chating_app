import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListModel {
  final String id;                // rooms 문서 id (roomId)
  final DateTime createdAt;
  final DateTime lastAt;
  final String lastMessage;
  final List<String> participants; // uid 리스트

  ChatListModel({
    required this.id,
    required this.createdAt,
    required this.lastAt,
    required this.lastMessage,
    required this.participants,
  });

  factory ChatListModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final json = doc.data();

    DateTime _toDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is double) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
      if (v is String) {
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final parts = (json['participants'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    return ChatListModel(
      id: doc.id,
      createdAt: _toDate(json['createdAt']),
      lastAt: _toDate(json['lastAt']),
      lastMessage: (json['lastMessage'] ?? '').toString(),
      participants: parts,
    );
  }

  Map<String, dynamic> toJson() => {
        'createdAt': Timestamp.fromDate(createdAt),
        'lastAt': Timestamp.fromDate(lastAt),
        'lastMessage': lastMessage,
        'participants': participants,
      };
}
