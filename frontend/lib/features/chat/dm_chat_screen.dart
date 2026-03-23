import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../core/api/api_client.dart';

class DmChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String recipientAvatar;
  final String recipientBloodType;

  const DmChatScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    required this.recipientAvatar,
    required this.recipientBloodType,
  });

  @override
  State<DmChatScreen> createState() => _DmChatScreenState();
}

class _DmChatScreenState extends State<DmChatScreen> {
  final Dio _dio = ApiClient().dio;
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<dynamic> _messages = [];
  Timer? _pollingTimer;

  String _token = '';
  String _myId = '';
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _myId = prefs.getString('userId') ?? '';
    await _fetchMessages();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollMessages());
  }

  Options get _auth => Options(headers: {'Authorization': 'Bearer $_token'});

  Future<void> _fetchMessages() async {
    try {
      final res = await _dio.get('/Chat/dm/${widget.recipientId}', options: _auth);
      setState(() {
        _messages.clear();
        _messages.addAll(res.data as List);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pollMessages() async {
    if (!mounted) return;
    try {
      final res = await _dio.get('/Chat/dm/${widget.recipientId}', options: _auth);
      final all = res.data as List;
      if (all.length != _messages.length) {
        setState(() { _messages.clear(); _messages.addAll(all); });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final content = _msgCtrl.text.trim();
    if (content.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      final res = await _dio.post('/Chat/dm', options: _auth, data: {
        'recipientId': widget.recipientId,
        'content': content,
      });
      _msgCtrl.clear();
      setState(() => _messages.add(res.data));
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        final isConnectionError = e.toString().contains('connection') || e.toString().contains('XMLHttpRequest');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isConnectionError
            ? '🔄 Máy chủ đang khởi động lại, vui lòng thử lại sau 30 giây'
            : 'Gửi thất bại: $e'),
          backgroundColor: isConnectionError ? Colors.orange : Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: _sendMessage,
          ),
        ));
      }
    }
    setState(() => _isSending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  String _timeLabel(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    if (!dateStr.endsWith('Z')) dateStr += 'Z';
    final dt = DateTime.tryParse(dateStr)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    if (now.difference(dt).inMinutes < 1) return 'Vừa xong';
    if (now.difference(dt).inHours < 1) return '${now.difference(dt).inMinutes}p';
    if (dt.day == now.day) return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final cardCol = Theme.of(context).cardColor;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isPrimary = const Color(0xFFFF4500);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        titleSpacing: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.recipientAvatar.isNotEmpty ? NetworkImage(widget.recipientAvatar) : null,
            backgroundColor: isPrimary,
            child: widget.recipientAvatar.isEmpty ? Text(
              widget.recipientName.isNotEmpty ? widget.recipientName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)) : null,
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.recipientName.isNotEmpty ? widget.recipientName : 'Người dùng',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            if (widget.recipientBloodType.isNotEmpty)
              Text('🩸 ${widget.recipientBloodType}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ])),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchMessages),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4500)))
            : _messages.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Chưa có tin nhắn.\nHãy bắt đầu cuộc trò chuyện! 💬',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textCol.withOpacity(0.5))),
                ]))
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = _messages[i];
                    final isMe = msg['senderId']?.toString() == _myId;
                    final time = _timeLabel(msg['createdAt']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 13,
                              backgroundImage: widget.recipientAvatar.isNotEmpty ? NetworkImage(widget.recipientAvatar) : null,
                              backgroundColor: isPrimary,
                              child: widget.recipientAvatar.isEmpty ? Text(
                                widget.recipientName.isNotEmpty ? widget.recipientName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 10)) : null,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? isPrimary : cardCol,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 18),
                                  ),
                                ),
                                child: Text(msg['content'] ?? '',
                                    style: TextStyle(color: isMe ? Colors.white : textCol, fontSize: 14)),
                              ),
                              const SizedBox(height: 3),
                              Text(time, style: TextStyle(color: textCol.withOpacity(0.4), fontSize: 10)),
                            ],
                          )),
                          if (isMe) const SizedBox(width: 4),
                        ],
                      ),
                    );
                  },
                ),
        ),
        // Input
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          color: const Color(0xFF1A1A2E),
          child: SafeArea(top: false, child: Row(children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Nhắn cho ${widget.recipientName.isNotEmpty ? widget.recipientName : 'người dùng'}...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true, fillColor: const Color(0xFF0D0D1A),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _isSending ? Colors.grey : isPrimary, shape: BoxShape.circle),
                child: _isSending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ])),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
}
