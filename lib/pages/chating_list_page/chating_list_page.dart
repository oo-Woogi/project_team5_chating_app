// lib/pages/chating_list_page/chating_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/pages/chating_list_page/data/core/room_tiles_provider.dart';
import 'package:project_team5_chating_app/widgets/appbar.dart';
import 'package:project_team5_chating_app/widgets/bottom_navi.dart';
import 'package:project_team5_chating_app/pages/chating_list_page/widgets/chat_item.dart';

class ChatingListPage extends ConsumerWidget {
  const ChatingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomTilesProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff3f3f3),
      appBar: const MyAppbar(title: '채팅목록'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: roomsAsync.when(
          data: (rooms) {
            if (rooms.isEmpty) {
              return const Center(child: Text('메시지가 없습니다.'));
            }
            return ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemCount: rooms.length,
              itemBuilder: (_, i) => ChatItem(room: rooms[i]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('에러: $e')),
        ),
      ),
      bottomNavigationBar: BottomNavi(1),
    );
  }
}
