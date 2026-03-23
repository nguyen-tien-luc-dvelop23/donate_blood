import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import 'dm_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  final Dio _dio = ApiClient().dio;
  late TabController _tabCtrl;

  List<dynamic> _allUsers = [];
  List<dynamic> _conversations = [];
  bool _loadingUsers = true;
  bool _loadingConvs = true;
  String _search = '';

  String _token = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _loadUsers();
    _loadConversations();
  }

  Options get _auth => Options(headers: {'Authorization': 'Bearer $_token'});

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final res = await _dio.get('/Chat/users', options: _auth);
      setState(() { _allUsers = res.data as List; _loadingUsers = false; });
    } catch (_) { setState(() => _loadingUsers = false); }
  }

  Future<void> _loadConversations() async {
    setState(() => _loadingConvs = true);
    try {
      final res = await _dio.get('/Chat/conversations', options: _auth);
      setState(() { _conversations = res.data as List; _loadingConvs = false; });
    } catch (_) { setState(() => _loadingConvs = false); }
  }

  List<dynamic> get _filteredUsers {
    if (_search.isEmpty) return _allUsers;
    return _allUsers.where((u) {
      final name = (u['fullName'] as String? ?? '').toLowerCase();
      final phone = (u['phoneNumber'] as String? ?? '').toLowerCase();
      return name.contains(_search.toLowerCase()) || phone.contains(_search.toLowerCase());
    }).toList();
  }

  List<dynamic> get _filteredConversations {
    if (_search.isEmpty) return _conversations;
    return _conversations.where((c) {
      final name = (c['userName'] as String? ?? '').toLowerCase();
      final phone = (c['userPhone'] as String? ?? '').toLowerCase();
      return name.contains(_search.toLowerCase()) || phone.contains(_search.toLowerCase());
    }).toList();
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}p';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.day}/${dt.month}';
  }

  void _openChat(String userId, String userName, String avatar, String blood) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => DmChatScreen(
        recipientId: userId,
        recipientName: userName,
        recipientAvatar: avatar,
        recipientBloodType: blood,
      ),
    )).then((_) => _loadConversations());
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
        title: const Text('Trò chuyện', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFFFF4500),
          labelColor: const Color(0xFFFF4500),
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Icon(Icons.chat_bubble_outline, size: 16), SizedBox(width: 6),
              Text('Cuộc trò chuyện', style: TextStyle(fontSize: 12)),
            ])),
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.people_outline, size: 16), const SizedBox(width: 6),
              Text('${_allUsers.length} thành viên', style: const TextStyle(fontSize: 12)),
            ])),
          ],
        ),
      ),
      body: Column(children: [
        // Search bar — auto-switch to Members tab when searching
        Container(
          color: const Color(0xFF1A1A2E),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            onChanged: (v) {
              setState(() => _search = v);
              // Auto-switch to Members tab when typing
              if (v.isNotEmpty && _tabCtrl.index == 0) {
                _tabCtrl.animateTo(1);
              }
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm thành viên...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              filled: true, fillColor: const Color(0xFF0D0D1A),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              // Tab 1: Conversations
              _loadingConvs
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4500)))
                : _filteredConversations.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('Chưa có cuộc trò chuyện nào.\nVào tab Thành viên để bắt đầu! 👥',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textCol.withOpacity(0.5))),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      color: const Color(0xFFFF4500),
                      child: ListView.separated(
                        itemCount: _filteredConversations.length,
                        separatorBuilder: (_, __) => Divider(color: textCol.withOpacity(0.05), height: 1, indent: 70),
                        itemBuilder: (ctx, i) {
                          final conv = _filteredConversations[i];
                          final avatar = conv['userAvatar'] as String? ?? '';
                          final name = (conv['userName'] as String? ?? '').isNotEmpty ? conv['userName'] : conv['userPhone'];
                          final blood = conv['userBloodType'] as String? ?? '';

                          return ListTile(
                            onTap: () => _openChat(conv['userId'].toString(), name, avatar, blood),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Stack(children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                backgroundColor: const Color(0xFFFF4500),
                                child: avatar.isEmpty ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
                              ),
                              if (blood.isNotEmpty) Positioned(bottom: 0, right: 0, child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(color: Colors.red.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                                child: Text(blood, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              )),
                            ]),
                            title: Text(name, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(conv['lastMessage'] ?? '', style: TextStyle(color: textCol.withOpacity(0.5), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Text(_timeAgo(conv['lastTime']), style: TextStyle(color: textCol.withOpacity(0.4), fontSize: 11)),
                          );
                        },
                      ),
                    ),

              // Tab 2: All Users
              _loadingUsers
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4500)))
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    color: const Color(0xFFFF4500),
                    child: _filteredUsers.isEmpty
                      ? Center(child: Text('Không tìm thấy người dùng', style: TextStyle(color: textCol.withOpacity(0.5))))
                      : ListView.separated(
                          itemCount: _filteredUsers.length,
                          separatorBuilder: (_, __) => Divider(color: textCol.withOpacity(0.05), height: 1, indent: 70),
                          itemBuilder: (ctx, i) {
                            final u = _filteredUsers[i];
                            final avatar = u['avatarUrl'] as String? ?? '';
                            final name = (u['fullName'] as String? ?? '').isNotEmpty ? u['fullName'] : u['phoneNumber'];
                            final blood = u['bloodType'] as String? ?? '';

                            return ListTile(
                              onTap: () => _openChat(u['id'].toString(), name, avatar, blood),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: Stack(children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                  backgroundColor: const Color(0xFFFF4500),
                                  child: avatar.isEmpty ? Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
                                ),
                                if (blood.isNotEmpty) Positioned(bottom: 0, right: 0, child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                                  child: Text(blood, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                )),
                              ]),
                              title: Text(name, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text('🩸 $blood • Nhấn để nhắn tin', style: TextStyle(color: textCol.withOpacity(0.5), fontSize: 12)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: const Color(0xFFFF4500).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                child: const Text('Nhắn tin', style: TextStyle(color: Color(0xFFFF4500), fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                  ),
            ],
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }
}
