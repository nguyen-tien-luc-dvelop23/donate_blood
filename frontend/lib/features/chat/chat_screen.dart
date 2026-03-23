import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
    // Poll every 5 seconds for new messages
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollMessages());
  }

  Options get _auth => Options(headers: {'Authorization': 'Bearer $_token'});

  Future<void> _fetchMessages() async {
    try {
      final res = await _dio.get('/Chat', options: _auth);
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
    if (_messages.isEmpty) { await _fetchMessages(); return; }
    try {
      final lastTime = _messages.last['createdAt'] as String? ?? '';
      final res = await _dio.get('/Chat', queryParameters: {'after': lastTime}, options: _auth);
      final newMsgs = res.data as List;
      if (newMsgs.isNotEmpty) {
        setState(() => _messages.addAll(newMsgs));
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final content = _msgCtrl.text.trim();
    if (content.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      final res = await _dio.post('/Chat', options: _auth, data: {'content': content});
      _msgCtrl.clear();
      setState(() => _messages.add(res.data));
      _scrollToBottom();
    } catch (_) {}
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
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    if (now.difference(dt).inMinutes < 1) return 'Vừa xong';
    if (now.difference(dt).inHours < 1) return '${now.difference(dt).inMinutes}p';
    if (dt.day == now.day) return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final cardCol = Theme.of(context).cardColor;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.chat_bubble, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cộng đồng', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${_messages.length} tin nhắn', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ]),
        ]),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchMessages),
        ],
      ),
      body: Column(children: [
        // Messages list
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4500)))
            : _messages.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Chưa có tin nhắn nào.\nHãy bắt đầu cuộc trò chuyện! 💬',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textCol.withOpacity(0.5), fontSize: 14)),
                ]))
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = _messages[i];
                    final isMe = msg['senderId'] == _myId;
                    final name = (msg['senderName'] as String? ?? '').isNotEmpty
                        ? msg['senderName'] : msg['senderPhone'] ?? '?';
                    final blood = msg['senderBloodType'] as String? ?? '';
                    final avatar = msg['senderAvatar'] as String? ?? '';
                    final time = _timeLabel(msg['createdAt']);
                    final showHeader = i == 0 || _messages[i - 1]['senderId'] != msg['senderId'];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 4, top: showHeader ? 8 : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                              backgroundColor: AppColors.primary,
                              child: avatar.isEmpty ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)) : null,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (showHeader && !isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Text(name, style: TextStyle(color: textCol.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold)),
                                      if (blood.isNotEmpty) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                          child: Text('🩸$blood', style: const TextStyle(color: Colors.redAccent, fontSize: 9)),
                                        ),
                                      ],
                                    ]),
                                  ),
                                Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isMe ? AppColors.primary : cardCol,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                                      bottomRight: Radius.circular(isMe ? 4 : 16),
                                    ),
                                  ),
                                  child: Text(msg['content'] ?? '',
                                      style: TextStyle(color: isMe ? Colors.white : textCol, fontSize: 14)),
                                ),
                                const SizedBox(height: 2),
                                Text(time, style: TextStyle(color: textCol.withOpacity(0.4), fontSize: 10)),
                              ],
                            ),
                          ),
                          if (isMe) const SizedBox(width: 4),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          color: const Color(0xFF1A1A2E),
          child: SafeArea(
            top: false,
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Nhắn gì đó...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF0D0D1A),
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
                  decoration: BoxDecoration(
                    color: _isSending ? Colors.grey : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
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
