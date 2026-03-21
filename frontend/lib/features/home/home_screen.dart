import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../sos/sos_page.dart';
import '../sos/sos_form_page.dart';
import '../map/blood_map_page.dart';
import '../profile/profile_page.dart';
import '../../core/api/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomePage(),
    BloodMapPage(),
    Center(child: Text('History Page')), // Placeholder cho Lịch sử
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1412),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Điều hướng đến form SOS khẩn cấp
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SOSFormPage()),
          );
        },
        backgroundColor: const Color(0xFFFF6A00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFF1E1412), width: 4),
        ),
        elevation: 0,
        child: const Icon(Icons.water_drop, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_filled, 'TRANG CHỦ'),
              _buildNavItem(1, Icons.map_outlined, 'BẢN ĐỒ'),
              const SizedBox(width: 48), // Khoảng trống cho FAB
              _buildNavItem(2, Icons.access_time_outlined, 'LỊCH SỬ'),
              _buildNavItem(3, Icons.person_outline, 'CÁ NHÂN'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFFFF6A00) : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  bool _isReadyToDonate = true;
  String? _fullName;
  String? _phone;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _authService.getLoggedName();
    final phone = await _authService.getLoggedPhone();
    setState(() {
      _fullName = name;
      _phone = phone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1210), // Màu nền tối
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40), // Khoảng trống padding bottom
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Top Bar)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF8C00),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Xin chào',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _fullName != null && _fullName!.isNotEmpty ? _fullName! : (_phone ?? 'Người dùng'),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: const [
                              Icon(Icons.location_on_outlined, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Hà Nội - Việt Nam',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                  ],
                ),
              ),

              // 2. Main Banner Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1582719471384-894fbb16e074?auto=format&fit=crop&q=80',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Cần máu khẩn cấp - LIVE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Cần máu khẩn cấp ',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '- LIVE',
                            style: TextStyle(color: Color(0xFFFF6A00), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const SOSPage()));
                      },
                      child: const Text('Xem tất cả', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal list of SOS Cards
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildSOSCard(
                      bloodType: 'O+',
                      hospitalName: 'Bệnh viện Bạch mai',
                      noteText: 'Cần gấp 2 đơn vị Tai nạn',
                      timeAndDistance: '5 phút trước 1.2km',
                      buttonText: 'Lực có thể giúp',
                    ),
                    _buildSOSCard(
                      bloodType: 'A+',
                      hospitalName: 'BV Nhi',
                      noteText: 'Cần tiểu cầu',
                      timeAndDistance: '20 phút trước',
                      buttonText: 'Tôi có thể giúp',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Activity and toggles
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Toggle Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1C1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red, size: 24),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sẵn sàng hiến máu', style: TextStyle(color: Colors.white, fontSize: 13)),
                                Text('Thông báo SOS gần bạn', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isReadyToDonate,
                            onChanged: (val) => setState(() => _isReadyToDonate = val),
                            activeColor: const Color(0xFFFF6A00),
                            activeTrackColor: const Color(0xFFFF6A00).withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Thank you banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF331E1E), // Đỏ nâu tối
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.water_drop_outlined, color: Color(0xFFFFB74D), size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Bạn đã hiến máu 3 lần', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                          const Text('Cảm ơn bạn ', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          Icon(Icons.favorite_border, color: Colors.red[300], size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Tiện Ích & Cộng đồng
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tiện Ích & Cộng đồng',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBigSquareCard(
                        icon: Icons.map_rounded,
                        label: 'Bản đồ hiến máu',
                        onTap: () {
                          // Navigate or handle via bottom bar
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBigSquareCard(
                        icon: Icons.emoji_events,
                        label: 'Vinh danh',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSOSCard({
    required String bloodType,
    required String hospitalName,
    required String noteText,
    required String timeAndDistance,
    required String buttonText,
  }) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF231917), // Nền thẻ
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3D00), // Đỏ cam
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    bloodType,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text('LIVE', style: TextStyle(color: Color(0xFFFF6A00), fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const Spacer(),
          Text(hospitalName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(noteText, style: const TextStyle(color: Color(0xFFFF6A00), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(timeAndDistance, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigSquareCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF231917),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFF6A00), size: 36),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
