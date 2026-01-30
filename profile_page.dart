import 'package:flutter/material.dart';
import 'login_page.dart';
import 'donation_history_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            const Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Color(0xFFE65100),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=profile"),
                    ),
                  ),
                  Positioned(
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
            const Text(
              "Nguyễn Văn A",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              "Thành viên tích cực",
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 30),

            _buildProfileItem(Icons.bloodtype, "Nhóm máu", "O+"),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DonationHistoryPage()),
                );
              },
              child: _buildProfileItem(Icons.calendar_today, "Lần hiến gần nhất", "12/06/2025"),
            ),
            _buildProfileItem(Icons.location_on, "Khu vực", "Hà Nội"),
            _buildProfileItem(Icons.phone, "Số điện thoại", "0987 654 ***"),

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
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
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
