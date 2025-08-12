// lib/pages/chating_list_page/widgets/chat_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_team5_chating_app/pages/chating_list_page/data/core/room_tiles_provider.dart';
import 'package:project_team5_chating_app/pages/chating_page/chating_page.dart';

class ChatItem extends StatelessWidget {
  final RoomTile room;
  const ChatItem({super.key, required this.room});

  String _format(DateTime t) {
    final now = DateTime.now();
    if (t.year == now.year && t.month == now.month && t.day == now.day) {
      return DateFormat('HH:mm').format(t);
    }
    if (t.year == now.year) {
      return DateFormat('M/d HH:mm').format(t);
    }
    return DateFormat('yyyy.M.d').format(t);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatingPage(
              roomId: room.id,
              partnerUid: room.peerUid.isEmpty ? null : room.peerUid,
              partnerName: room.peerName,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 사진
            SizedBox(
              width: 60,
              height: 60,
              child: ClipOval(
                child: (room.peerPhoto != null && room.peerPhoto!.isNotEmpty)
                    ? Image.network(
                        room.peerPhoto!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/images/icon_person_gray.png'),
                      )
                    : Image.asset('assets/images/icon_person_gray.png'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상대 이름
                    Text(
                      room.peerUid.isNotEmpty
                          ? room.peerName
                          : '참여자 ${room.participants.length}명',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 마지막 메시지
                    Text(
                      room.lastMessage.isEmpty
                          ? '메시지가 없습니다.'
                          : room.lastMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff777777),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 마지막 시간
            Text(
              _format(room.lastAt),
              style: const TextStyle(fontSize: 12, color: Color(0xff999999)),
            ),
          ],
        ),
      ),
    );
  }
}
