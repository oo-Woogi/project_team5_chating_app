// lib/pages/chating_list_page/data/core/room_tiles_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/core/user_global_view_model.dart';

class RoomTile {
  final String id;                 // roomId (문서 id)
  final DateTime createdAt;
  final DateTime lastAt;
  final String lastMessage;
  final List<String> participants; // uid 리스트
  final String peerUid;            // 1:1 기준 상대 uid (없으면 '')
  final String peerName;           // 상대 이름 (없으면 '알 수 없음')
  final String? peerPhoto;         // 상대 사진 URL (없으면 null)

  RoomTile({
    required this.id,
    required this.createdAt,
    required this.lastAt,
    required this.lastMessage,
    required this.participants,
    required this.peerUid,
    required this.peerName,
    required this.peerPhoto,
  });
}

final roomTilesProvider =
    StreamProvider.autoDispose<List<RoomTile>>((ref) {
  final myUid = ref.watch(userGlobalProvider).userId;
  if (myUid.isEmpty) {
    return const Stream.empty();
  }

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

  final qs = FirebaseFirestore.instance
      .collection('rooms')
      .where('participants', arrayContains: myUid)
      .orderBy('lastAt', descending: true);

  // 스냅샷 → (사용자 정보 whereIn으로 묶어 조회) → RoomTile 리스트
  return qs.snapshots().asyncMap((snap) async {
    final docs = snap.docs;

    // participants에서 내 uid 제외 → 상대 uid 수집
    final peers = <String>{};
    final roomsRaw = <Map<String, dynamic>>[];
    for (final d in docs) {
      final data = d.data();
      final parts = (data['participants'] as List? ?? [])
          .map((e) => e.toString())
          .toList();
      roomsRaw.add({
        'id': d.id,
        'createdAt': _toDate(data['createdAt']),
        'lastAt': _toDate(data['lastAt']),
        'lastMessage': (data['lastMessage'] ?? '').toString(),
        'participants': parts,
      });
      for (final p in parts) {
        if (p != myUid) peers.add(p);
      }
    }

    // users 컬렉션을 documentId whereIn으로 한 번에(최대 10개씩) 가져오기
    final peerMap = <String, Map<String, dynamic>>{};
    final ids = peers.toList();
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      if (chunk.isEmpty) continue;
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final u in usersSnap.docs) {
        peerMap[u.id] = u.data();
      }
    }

    // RoomTile로 매핑
    final tiles = <RoomTile>[];
    for (final r in roomsRaw) {
      final parts = (r['participants'] as List<String>);
      final peerUid = parts.firstWhere((p) => p != myUid, orElse: () => '');
      final info = peerMap[peerUid];
      final name = (info?['name'] ??
              info?['userName'] ??
              info?['displayName'] ??
              '알 수 없음')
          .toString();
      final photo = (info?['imgpath'] ??
              info?['photoUrl'] ??
              info?['avatar'] ??
              info?['profileImage'])
          ?.toString();

      tiles.add(RoomTile(
        id: r['id'] as String,
        createdAt: r['createdAt'] as DateTime,
        lastAt: r['lastAt'] as DateTime,
        lastMessage: r['lastMessage'] as String,
        participants: parts,
        peerUid: peerUid,
        peerName: name,
        peerPhoto: photo,
      ));
    }
    return tiles;
  });
});
