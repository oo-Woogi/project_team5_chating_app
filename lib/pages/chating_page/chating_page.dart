import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/chating_page/widgets/chat_button.dart';
import 'package:project_team5_chating_app/widgets/appbar.dart';
import 'package:project_team5_chating_app/pages/chating_page/widgets/message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_team5_chating_app/data/repository/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatingPage extends ConsumerStatefulWidget {
  const ChatingPage({
    super.key,
    this.roomId,
    this.partnerUid,
    this.partnerName,
  });

  final String? roomId;
  final String? partnerUid;
  final String? partnerName;

  @override
  ConsumerState<ChatingPage> createState() => _ChatingPageState();
}

class _ChatingPageState extends ConsumerState<ChatingPage> {
  final ScrollController _scrollController = ScrollController();
  String? _roomId;

  @override
  void initState() {
    super.initState();
    _initializeRoomId();
  }

  Future<void> _initializeRoomId() async {
    if (widget.roomId != null && widget.roomId!.isNotEmpty) {
      _roomId = widget.roomId;
      print('Using provided roomId: $_roomId'); // 디버깅
    } else if (widget.partnerUid != null && widget.partnerUid!.isNotEmpty) {
      final myUid = FirebaseAuth.instance.currentUser?.uid;
      if (myUid != null) {
        _roomId = await ref
            .read(chatRepositoryProvider)
            .getOrCreateRoomId(
              myUid: myUid,
              partnerUid: widget.partnerUid!,
            );
        print('Generated roomId: $_roomId'); // 디버깅
        if (mounted) setState(() {});
      }
    } else {
      print('Error: No roomId or partnerUid provided'); // 디버깅
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('채팅방 ID 또는 상대 정보가 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget actions = IconButton(
      icon: Image.asset('assets/images/Frame.png', width: 24, height: 24),
      onPressed: () {},
    );

    final appBarTitle =
        (widget.partnerName != null && widget.partnerName!.isNotEmpty)
        ? widget.partnerName!
        : '채팅';

    return Scaffold(
      appBar: MyAppbar(title: appBarTitle, actions: actions),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '채팅방 이용 시 개인 정보 및 금융 정보 보호에 유의해주시기 바랍니다. \n광고, 스팸 사기 등의 메시지를 받은 경우 신고해 주세요.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Color(0xff777777),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (_roomId == null || _roomId!.isEmpty)
            const Expanded(
              child: Center(child: Text('채팅방을 열 수 없습니다. 다시 시도해주세요.')),
            )
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: ref
                    .read(chatRepositoryProvider)
                    .watchMessages(_roomId!),
                builder: (context, snapshot) {
                  print(
                    'StreamBuilder state: ${snapshot.connectionState}, '
                    'hasData: ${snapshot.hasData}, '
                    'docs: ${snapshot.data?.docs.length ?? 0}',
                  ); // 디버깅
                  if (snapshot.hasError) {
                    print('StreamBuilder error: ${snapshot.error}'); // 디버깅
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('메시지 불러오기 오류: ${snapshot.error}'),
                          ElevatedButton(
                            onPressed: () => setState(() {}), // 재시도
                            child: const Text('재시도'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  final me = FirebaseAuth.instance.currentUser?.uid ?? '';

                  if (docs.isEmpty) {
                    return const Center(child: Text('메시지가 없습니다.')); // 빈 상태 표시
                  }

                  final messages = docs.map((d) {
                    final data = d.data();
                    print('Doc data: $data'); // 디버깅
                    final DateTime t = _safeMessageTime(d);
                    return _Message(
                      text: (data['message'] ?? data['text'] ?? '').toString(),
                      time: t,
                      isMe: data['senderId'] == me,
                    );
                  }).toList();

                  messages.sort((a, b) => a.time.compareTo(b.time));

                  if (messages.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToBottom(),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatDateHeader(messages.first.time),
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Color(0xff333333),
                              ),
                            ),
                          ),
                        );
                      }
                      final i = index - 1;
                      return MessageBubble(
                        text: messages[i].text,
                        time: messages[i].time,
                        isMe: messages[i].isMe,
                        isTail: _isTail(messages, i),
                      );
                    },
                  );
                },
              ),
            ),
          ChatButton(
            onSendMessage: (text) async {
              final trimmed = text.trim();
              if (trimmed.isEmpty) return;

              final rid = _roomId;
              if (rid == null || rid.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('채팅방 정보가 없습니다. 다시 들어와 주세요.')),
                );
                return;
              }

              var uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              var name = FirebaseAuth.instance.currentUser?.displayName ?? '익명';
              if (uid.isEmpty) {
                try {
                  await FirebaseAuth.instance.signInAnonymously();
                  uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                  name = FirebaseAuth.instance.currentUser?.displayName ?? '익명';
                  print('Signed in anonymously: $uid'); // 디버깅
                } catch (e) {
                  print('Anonymous login failed: $e'); // 디버깅
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('로그인 오류'),
                      content: const Text('익명 로그인에 실패했습니다. 네트워크를 확인해주세요.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
              }
              if (uid.isEmpty) return;

              try {
                print(
                  'Sending message to room: roomId=$rid, uid=$uid, text="$trimmed"',
                ); // 디버깅
                await ref
                    .read(chatRepositoryProvider)
                    .sendMessageToRoom(
                      roomId: rid,
                      senderId: uid,
                      senderName: name,
                      text: trimmed,
                    );
                _scrollToBottom();
              } catch (e) {
                print('Send message failed: $e'); // 디버깅
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('메시지 전송에 실패했습니다.'),
                    action: SnackBarAction(
                      label: '재시도',
                      onPressed: () => ref
                          .read(chatRepositoryProvider)
                          .sendMessageToRoom(
                            roomId: rid,
                            senderId: uid,
                            senderName: name,
                            text: trimmed,
                          ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  bool _isSameMinute(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  bool _isTail(List<_Message> list, int index) {
    if (index == list.length - 1) return true;
    final curr = list[index];
    final next = list[index + 1];
    if (curr.isMe != next.isMe) return true;
    return !_isSameMinute(curr.time, next.time);
  }

  DateTime _safeMessageTime(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final DateTime? created = _coerceTime(data['createdAt']);
    if (created != null) return created;
    if (d.metadata.hasPendingWrites) return DateTime.now();
    final DateTime? client = _coerceTime(data['clientTime']);
    if (client != null) return client;
    return DateTime.fromMillisecondsSinceEpoch(1);
  }

  DateTime? _coerceTime(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is double) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String _formatDateHeader(DateTime d) {
    const wd = ['', '월', '화', '수', '목', '금', '토', '일'];
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y.$m.$day(${wd[d.weekday]})';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _Message {
  final String text;
  final DateTime time;
  final bool isMe;
  _Message({required this.text, required this.time, this.isMe = true});
}
