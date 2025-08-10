import 'package:flutter/material.dart';
import 'package:project_team5_chating_app/pages/chating_page/widgets/chat_button.dart';
import 'package:project_team5_chating_app/widgets/appbar.dart';
import 'package:project_team5_chating_app/pages/chating_page/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_team5_chating_app/data/repository/chat_repository.dart';
import 'dart:async';
import 'package:project_team5_chating_app/model/chat.dart';

class ChatingPage extends StatefulWidget {
  final String? roomId;
  final String myId;
  final String myName;
  final String? peerId;     // 상대방 사용자 id
  final String? peerName;   // 상대방 표시 이름

  const ChatingPage({
    super.key,
    required this.myId,
    required this.myName,
    this.roomId,
    this.peerId,
    this.peerName,
  });

  @override
  State<ChatingPage> createState() => _ChatingPageState();
}

class _ChatingPageState extends State<ChatingPage> {
  late final ChatRepository _repo;
  StreamSubscription<List<Chat>>? _sub;
  final ScrollController _scrollController = ScrollController();
  List<Chat> _messages = [];
  String _title = '채팅'; // 앱바 제목(기본값). 상대 이름을 로드해서 갱신.

  @override
  void initState() {
    super.initState();
    _repo = const ChatRepository();
    if (widget.roomId != null) {
      _sub = _repo.watchByAddress(widget.roomId!).listen((msgs) {
        if (!mounted) return;
        setState(() => _messages = msgs);
        _scrollToBottom();
      });
    }
    if (widget.roomId != null) {
      _ensureParticipant();
    }
    _initTitle();
  }

  @override
  void didUpdateWidget(covariant ChatingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomId != widget.roomId) {
      _sub?.cancel();
      _sub = null;
      setState(() {
        _messages = [];
      });
      if (widget.roomId != null) {
        _sub = _repo.watchByAddress(widget.roomId!).listen((msgs) {
          if (!mounted) return;
          setState(() => _messages = msgs);
          _scrollToBottom();
        });
        _ensureParticipant();
        _initTitle();
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (widget.roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 방을 선택하세요.')),
      );
      return;
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    try {
      await _repo.insert(
        sender: widget.myName,
        senderId: widget.myId,
        address: widget.roomId!,
        message: trimmed,
        createdAt: DateTime.now().toIso8601String(), // 로컬 타임스탬프를 ISO 문자열로 저장
      );
    } catch (e) {
      debugPrint('메시지 전송 실패: $e');
    }
  }

  DateTime _timeOf(Chat m) {
    final Object? v = m.createdAt;
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  Future<void> _ensureParticipant() async {
    try {
      final roomId = widget.roomId;
      if (roomId == null) return;
      final doc = FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(widget.myId);

      await doc.set({
        'userId': widget.myId,
        'name': widget.myName,
        'joinedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 상대 참가자 정보도 미리 저장(탐색 화면에서 이름/id를 전달받은 경우)
      if (widget.peerId != null && (widget.peerName?.trim().isNotEmpty ?? false)) {
        final peerDoc = FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .collection('participants')
            .doc(widget.peerId);

        await peerDoc.set({
          'userId': widget.peerId,
          'name': widget.peerName!.trim(),
          'joinedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('참가자 정보 저장 실패: $e');
    }
  }

  Future<void> _initTitle() async {
    // 1) 네비게이션에서 이미 peerName을 넘겨준 경우 즉시 사용 (단, 숫자 같은 비정상 값은 무시)
    final pn = widget.peerName?.trim();
    if (pn != null && pn.isNotEmpty && !RegExp(r'^\d+$').hasMatch(pn)) {
      if (!mounted) return;
      setState(() => _title = pn);
      return;
    }

    // 2) roomId가 있으면 rooms/{roomId}/participants 에서 나 이외의 참가자 이름을 읽어서 제목으로 사용
    final rid = widget.roomId;
    if (rid == null) return;

    try {
      final qs = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(rid)
          .collection('participants')
          .get();

      for (final d in qs.docs) {
        if (d.id == widget.myId) continue; // 나 자신은 건너뜀
        final data = d.data();
        final name = (data['name'] as String?)?.trim();
        if (name != null && name.isNotEmpty) {
          if (!mounted) return;
          setState(() => _title = name);
          break;
        }
      }
    } catch (e) {
      debugPrint('상대 이름 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 앱바에서 사용할 actions
    Widget actions = IconButton(
      icon: Image.asset('assets/images/Frame.png', width: 24, height: 24),
      onPressed: () {},
    );

    final now = DateTime.now();
    final headerDate = _messages.isNotEmpty ? _timeOf(_messages.first) : now;

    return Scaffold(
      appBar: MyAppbar(title: _title, actions: actions),
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

          // 메시지 영역
          Expanded(
            child: widget.roomId == null
                ? const Center(
                    child: Text(
                      '방을 먼저 선택해주세요.',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff777777),
                      ),
                    ),
                  )
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      if (_messages.isNotEmpty)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatDateHeader(headerDate),
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Color(0xff333333),
                              ),
                            ),
                          ),
                        ),
                      for (int i = 0; i < _messages.length; i++)
                        MessageBubble(
                          text: _messages[i].message,
                          time: _timeOf(_messages[i]),
                          isMe: _messages[i].senderId == widget.myId,
                          isTail: _isTail(i),
                        ),
                    ],
                  ),
          ),

          // 입력창
          ChatButton(
            onSendMessage: (text) => _sendMessage(text),
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
  bool _isTail(int index) {
    if (index == _messages.length - 1) return true;
    final curr = _messages[index];
    final next = _messages[index + 1];
    if (curr.senderId != next.senderId) return true; // 다른 사람의 메시지면 tail
    return !_isSameMinute(_timeOf(curr), _timeOf(next));
  }

  String _formatDateHeader(DateTime d) {
    const wd = ['', '월', '화', '수', '목', '금', '토', '일'];
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y.$m.$day(${wd[d.weekday]})';
  }
}
