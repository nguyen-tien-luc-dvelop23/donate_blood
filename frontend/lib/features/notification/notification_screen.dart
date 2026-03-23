import 'package:flutter/material.dart';
import '../../core/api/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _service = NotificationService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await _service.getNotifications();
    setState(() {
      _notifications = data['notifications'] ?? [];
      _isLoading = false;
    });
  }

  Future<void> _markAllRead() async {
    await _service.markAllRead();
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    if (!dateStr.endsWith('Z')) dateStr += 'Z';
    final dt = DateTime.tryParse(dateStr)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return DateFormat('dd/MM HH:mm').format(dt);
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'sos': return Icons.warning_amber_rounded;
      case 'donation': return Icons.water_drop;
      case 'chat': return Icons.chat_bubble;
      default: return Icons.notifications;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'sos': return Colors.redAccent;
      case 'donation': return Colors.green;
      case 'chat': return Colors.blue;
      default: return const Color(0xFFFF6A00);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final cardCol = Theme.of(context).cardColor;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final unread = _notifications.where((n) => !(n['isRead'] as bool? ?? false)).length;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(children: [
          const Text('Thông báo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(99)),
              child: Text('$unread mới', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Đọc tất cả', style: TextStyle(color: Color(0xFFFF6A00), fontSize: 12)),
            ),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _load),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6A00)))
        : _notifications.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.notifications_none, size: 60, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Chưa có thông báo nào', style: TextStyle(color: textCol.withOpacity(0.5), fontSize: 14)),
            ]))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFFF6A00),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => Divider(color: textCol.withOpacity(0.05), height: 1),
                itemBuilder: (ctx, i) {
                  final n = _notifications[i];
                  final isRead = n['isRead'] as bool? ?? false;
                  final type = n['type'] as String? ?? 'info';
                  final color = _colorFor(type);

                  return Material(
                    color: isRead ? Colors.transparent : color.withOpacity(0.05),
                    child: InkWell(
                      onTap: () async {
                        if (!isRead) {
                          await _service.markRead(n['id'].toString());
                          setState(() => n['isRead'] = true);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_iconFor(type), color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(n['title'] ?? '', style: TextStyle(
                                color: textCol, fontWeight: isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14))),
                              if (!isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                            ]),
                            const SizedBox(height: 4),
                            Text(n['body'] ?? '', style: TextStyle(color: textCol.withOpacity(0.6), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(_timeAgo(n['createdAt']), style: TextStyle(color: textCol.withOpacity(0.4), fontSize: 11)),
                          ])),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
