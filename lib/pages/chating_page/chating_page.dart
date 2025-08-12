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

  // 채팅방 식별자 및 상대 정보(선택)
  final String? roomId;
  final String? partnerUid;
  final String? partnerName;

  @override
  ConsumerState<ChatingPage> createState() => _ChatingPageState();
}

class _ChatingPageState extends ConsumerState<ChatingPage> {
  final ScrollController _scrollController = ScrollController();

  // 로컬 캐시 대신 Firestore 스트림 사용

  @override
  Widget build(BuildContext context) {
    // 앱바에서 사용할 actions
    Widget actions = IconButton(
      icon: Image.asset('assets/images/Frame.png', width: 24, height: 24),
      onPressed: () {},
    );

    final appBarTitle = (widget.partnerName != null && widget.partnerName!.isNotEmpty)
        ? widget.partnerName!
        : '채팅';

    return Scaffold(
      appBar: MyAppbar(title: appBarTitle, actions: actions),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
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
          const SizedBox.shrink(),

          // 메시지 영역 (Firestore 실시간)
          if (widget.roomId == null) const Expanded(child: SizedBox.shrink())
          else Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ref
                  .read(chatRepositoryProvider)
                  .watchChatMessagesRoot(widget.roomId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('메시지 불러오기 오류: ${snapshot.error}'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                debugPrint('[ChatStream] roomId=' + (widget.roomId ?? 'null') + ' docs=' + docs.length.toString());
                final me = FirebaseAuth.instance.currentUser?.uid;

                // Map documents to UI model with robust createdAt handling
                final messages = docs.map((d) {
                  final data = d.data();
                  final DateTime t = _safeMessageTime(d);
                  return _Message(
                    text: (data['message'] ?? data['text'] ?? '').toString(),
                    time: t,
                    isMe: data['senderId'] == me,
                  );
                }).toList();

                // Ensure stable chronological order (even if serverTimestamp is pending)
                messages.sort((a, b) => a.time.compareTo(b.time));

                if (messages.isNotEmpty) {
                  // 스크롤 맨 아래로
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                }

                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    if (messages.isNotEmpty)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
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
                      ),
                    for (int i = 0; i < messages.length; i++)
                      MessageBubble(
                        text: messages[i].text,
                        time: messages[i].time,
                        isMe: messages[i].isMe,
                        isTail: _isTail(messages, i),
                      ),
                  ],
                );
              },
            ),
          ),

          // 입력창
          ChatButton(
            onSendMessage: (text) async {
              final trimmed = text.trim();
              if (trimmed.isEmpty) return;

              // 1) roomId 확인
              final rid = widget.roomId;
              if (rid == null || rid.isEmpty) {
                debugPrint('[ChatSend] abort: roomId is null/empty');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('채팅방 정보가 없어요. 다시 들어와 주세요.')),
                );
                return;
              }

              // 2) UID 확보 (없으면 조용히 익명 로그인 시도)
              var uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              var name = FirebaseAuth.instance.currentUser?.displayName ?? '익명';
              if (uid.isEmpty) {
                try {
                  await FirebaseAuth.instance.signInAnonymously();
                  uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                  name = FirebaseAuth.instance.currentUser?.displayName ?? '익명';
                  debugPrint('[ChatSend] signed in anonymously: $uid');
                } catch (e) {
                  debugPrint('[ChatSend] signInAnonymously failed: $e');
                }
              }
              if (uid.isEmpty) {
                debugPrint('[ChatSend] abort: uid still empty after sign-in attempt');
                return;
              }

              // 3) 전송
              try {
                debugPrint('[ChatSend] send -> roomId=$rid uid=$uid text="$trimmed"');
                await ref.read(chatRepositoryProvider).sendChatMessageRoot(
                      roomId: rid,
                      senderId: uid,
                      senderName: name,
                      text: trimmed,
                    );
                _scrollToBottom();
              } catch (e) {
                debugPrint('[ChatSend] send error: $e');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('전송에 실패했어요. 잠시 후 다시 시도해주세요.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

// 두 객체가 같은 "분" 단위인지 비교
// 같은 분이면 시간 텍스트를 묶어 한 번만 보여줌
  bool _isSameMinute(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

// 현재 인덱스의 말풍선이 tail인지 확인
// 같은 사람 + 다른 사용자 연속해서 보낸 메시지 묶음의 마지막 부분에만 시간이 출력되도록 함
  bool _isTail(List<_Message> list, int index) {
    if (index == list.length - 1) return true;
    final curr = list[index];
    final next = list[index + 1];
    if (curr.isMe != next.isMe) return true;
    return !_isSameMinute(curr.time, next.time);
  }

  // createdAt가 서버타임스탬프로 아직 null일 수 있어 안전하게 DateTime을 산출
  DateTime _safeMessageTime(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();

    // 1) 가장 신뢰되는 값: createdAt (Timestamp / DateTime / int / String 모두 수용)
    final DateTime? created = _coerceTime(data['createdAt']);
    if (created != null) return created;

    // 2) 아직 로컬에서만 존재하는 pending write라면 현재 시간 사용 (화면에서 즉시 보이도록)
    if (d.metadata.hasPendingWrites) {
      return DateTime.now();
    }

    // 3) 클라이언트에서 넣어준 보조 시간 필드가 있다면 사용
    final DateTime? client = _coerceTime(data['clientTime']);
    if (client != null) return client;

    // 4) 완전한 폴백: 가장 앞에 오지 않도록 Epoch(0) 대신 약한 과거 시간으로 설정
    //    (정렬 시 맨 뒤로 밀리고, 서버 동기화 후 자연스럽게 재정렬됨)
    return DateTime.fromMillisecondsSinceEpoch(1);
  }

  // 다양한 타입(Timestamp, DateTime, int(millis), String(ISO8601))을 DateTime으로 변환
  DateTime? _coerceTime(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is int) {
      // 밀리초 기준으로 가정
      return DateTime.fromMillisecondsSinceEpoch(v);
    }
    if (v is double) {
      return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    }
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
}

class _Message {
  final String text;
  final DateTime time;
  final bool isMe; 
  _Message({
    required this.text, 
    required this.time, 
    this.isMe = true});
}
