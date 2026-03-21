import 'package:flutter/material.dart';
import '../auth/login/login_screen.dart';
import '../admin/admin_screen.dart';
import '../../core/api/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _phone;
  String? _fullName;
  String? _bloodType;
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
    setState(() {
      _phone = phone;
      _fullName = name;
      _bloodType = bloodType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1615),
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFFE65100),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: const Color(0xFF2D2726),
                      child: Text(
                        _fullName != null && _fullName!.isNotEmpty
                            ? _fullName![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFE65100),
                      child: Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _fullName ?? "Đang tải...",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              "Thành viên tích cực",
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 30),

            _buildProfileItem(Icons.bloodtype, "Nhóm máu", _bloodType ?? "Chưa cập nhật"),
            _buildProfileItem(Icons.calendar_today, "Lần hiến gần nhất", "Chưa có"),
            _buildProfileItem(Icons.location_on, "Khu vực", "Hà Nội"),
            _buildProfileItem(Icons.phone, "Số điện thoại", _phone ?? "Đang tải..."),

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

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
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
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2726),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE65100), size: 24),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
          const Spacer(),
          Text(value, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
