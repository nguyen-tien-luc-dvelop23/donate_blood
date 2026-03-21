import 'package:flutter/material.dart';
import '../auth/login/login_screen.dart';
import '../admin/admin_screen.dart';
import '../../core/api/auth_service.dart';
import '../history/history_page.dart';
import '../history/donation_history_page.dart';
import 'edit_profile_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _phone;
  String? _fullName;
  String? _bloodType;
  String? _avatarUrl;
  double _bloodVolume = 0.0;
  int _donationCount = 0;
  bool _isReadyToDonate = true;

  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final phone = await _authService.getLoggedPhone();
    final name = await _authService.getLoggedName();
    final bloodType = await _authService.getLoggedBloodType();
    final avatarUrl = await _authService.getLoggedAvatarUrl();
    final bloodVol = await _authService.getLoggedBloodVolume();
    final donationCount = await _authService.getLoggedDonationCount();

    if (mounted) {
      setState(() {
        _phone = phone;
        _fullName = name;
        _bloodType = bloodType;
        _avatarUrl = avatarUrl;
        _bloodVolume = bloodVol;
        _donationCount = donationCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1412),
      appBar: AppBar(
        title: const Text("Hồ sơ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Avatar
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                      if (updated == true) _loadUser();
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2D2726), width: 3),
                      ),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF2D2726),
                        backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                            ? NetworkImage(_avatarUrl!)
                            : null,
                        child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                            ? Text(
                                _fullName != null && _fullName!.isNotEmpty ? _fullName![0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              )
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        final updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                        if (updated == true) _loadUser();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1E1412), width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Name & Badges
            Text(
              _fullName ?? "Đang tải...",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    "Nhóm máu ${_bloodType ?? 'O+'}",
                    style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2726),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "ID: #${_phone?.substring(0, 4) ?? '0000'}84",
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Sẵn sàng hiến máu Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1C1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text("Sẵn sàng hiến máu", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Chỉ nhận thông báo SOS khi có yêu cầu\nphù hợp với nhóm máu của bạn.",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isReadyToDonate,
                    onChanged: (val) => setState(() => _isReadyToDonate = val),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.orange,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: const Color(0xFF1E1412),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Three Stats Blocks
            Row(
              children: [
                Expanded(child: _buildStatBox(Icons.favorite, Colors.redAccent, _donationCount.toString(), "SỐ LẦN HIẾN")),
                const SizedBox(width: 12),
                Expanded(child: _buildStatBox(Icons.water_drop, Colors.red, "${_bloodVolume.toStringAsFixed(2)}L", "TỔNG ĐƠN VỊ")),
                const SizedBox(width: 12),
                Expanded(child: _buildStatBox(Icons.person_add_alt_1, Colors.blueAccent, "12", "SOS HỖ TRỢ")),
              ],
            ),
            const SizedBox(height: 30),

            // 5. Thành tích & Huy hiệu
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Thành tích & Huy hiệu", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B3A42), Color(0xFF1D262B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.workspace_premium, color: Colors.amber, size: 24),
                        const Spacer(),
                        const Text("Người hùng thầm\nlặng", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A2B4C), Color(0xFF121B2F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bolt, color: Colors.lightBlueAccent, size: 24),
                        const Spacer(),
                        const Text("Phản ứng nhanh", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 6. Hoạt động
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("HOẠT ĐỘNG", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF2A1C1A), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildListTile(Icons.history, Colors.redAccent, "Lịch sử hiến tặng", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationHistoryPage()));
                  }),
                  Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 56),
                  _buildListTile(Icons.campaign, Colors.orangeAccent, "SOS đã tạo", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 7. Cài đặt & Bảo mật
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("CÀI ĐẶT & BẢO MẬT", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF2A1C1A), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildListTile(Icons.person_outline, Colors.blueAccent, "Chỉnh sửa thông tin", onTap: () async {
                    final updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    if (updated == true) _loadUser();
                  }),
                  Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 56),
                  _buildListTile(Icons.notifications_none, Colors.purpleAccent, "Cài đặt thông báo", onTap: () {}),
                ],
              ),
            ),

            if (_phone == 'admin') ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text("QUẢN LÝ NGƯỜI DÙNG", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, size: 20),
                label: const Text("Đăng xuất", style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  await _authService.logout();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(IconData icon, Color iconColor, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1C1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, Color iconColor, String title, {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
