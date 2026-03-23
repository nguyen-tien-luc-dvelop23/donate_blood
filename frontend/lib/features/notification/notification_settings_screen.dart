import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notifEnabled = true;
  bool _sosNotif = true;
  bool _donationNotif = true;
  bool _chatNotif = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifEnabled = prefs.getBool('notif_enabled') ?? true;
      _sosNotif = prefs.getBool('notif_sos') ?? true;
      _donationNotif = prefs.getBool('notif_donation') ?? true;
      _chatNotif = prefs.getBool('notif_chat') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
        title: const Text('Cài đặt thông báo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6A00)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Master toggle
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _notifEnabled ? const Color(0xFFFF4500).withOpacity(0.1) : cardCol,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _notifEnabled ? const Color(0xFFFF4500) : textCol.withOpacity(0.1),
                    ),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _notifEnabled ? const Color(0xFFFF4500) : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Thông báo', style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(
                        _notifEnabled ? 'Đang bật — bạn sẽ nhận được thông báo' : 'Đã tắt — không nhận thông báo nào',
                        style: TextStyle(color: textCol.withOpacity(0.5), fontSize: 12),
                      ),
                    ])),
                    Switch(
                      value: _notifEnabled,
                      onChanged: (val) {
                        setState(() => _notifEnabled = val);
                        _save('notif_enabled', val);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFFFF4500),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: textCol.withOpacity(0.15),
                    ),
                  ]),
                ),

                // Sub settings (only when master is on)
                AnimatedOpacity(
                  opacity: _notifEnabled ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_notifEnabled,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardCol,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: textCol.withOpacity(0.05)),
                      ),
                      child: Column(children: [
                        _buildSettingTile(
                          icon: Icons.warning_amber_rounded,
                          iconColor: Colors.redAccent,
                          label: '🆘 Thông báo SOS',
                          sub: 'Khi có người cần máu khẩn cấp',
                          value: _sosNotif,
                          onChanged: (val) {
                            setState(() => _sosNotif = val);
                            _save('notif_sos', val);
                          },
                          textCol: textCol,
                        ),
                        Divider(color: textCol.withOpacity(0.05), height: 1, indent: 56),
                        _buildSettingTile(
                          icon: Icons.water_drop,
                          iconColor: Colors.green,
                          label: '🩸 Thông báo hiến máu',
                          sub: 'Khi có lịch hiến máu xác nhận',
                          value: _donationNotif,
                          onChanged: (val) {
                            setState(() => _donationNotif = val);
                            _save('notif_donation', val);
                          },
                          textCol: textCol,
                        ),
                        Divider(color: textCol.withOpacity(0.05), height: 1, indent: 56),
                        _buildSettingTile(
                          icon: Icons.chat_bubble,
                          iconColor: Colors.blueAccent,
                          label: '💬 Thông báo trò chuyện',
                          sub: 'Khi có tin nhắn mới trong cộng đồng',
                          value: _chatNotif,
                          onChanged: (val) {
                            setState(() => _chatNotif = val);
                            _save('notif_chat', val);
                          },
                          textCol: textCol,
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Info box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.info_outline, color: Colors.blueAccent, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'Thông báo được lưu trên server và hiển thị qua chuông 🔔 ở trang chủ. Cài đặt này chỉ áp dụng trên thiết bị này.',
                      style: TextStyle(color: textCol.withOpacity(0.6), fontSize: 12, height: 1.5),
                    )),
                  ]),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textCol,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: textCol, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: textCol.withOpacity(0.5), fontSize: 11)),
        ])),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFFFF4500),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: textCol.withOpacity(0.1),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]),
    );
  }
}
