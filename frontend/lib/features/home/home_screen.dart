import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../sos/sos_page.dart';
import '../sos/sos_form_page.dart';
import '../map/blood_map_page.dart';
import '../profile/profile_page.dart';
import '../../core/api/auth_service.dart';
import '../../core/api/sos_service.dart';
import '../history/history_page.dart';
import '../honor/honor_screen.dart';
import '../sos/confirm_support_screen.dart';
import '../chat/chat_list_screen.dart';
import '../notification/notification_screen.dart';
import '../../core/api/notification_service.dart';

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
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SOSFormPage()),
          );
        },
        backgroundColor: const Color(0xFFFF6A00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Theme.of(context).cardColor, width: 4),
        ),
        elevation: 0,
        child: const Icon(Icons.water_drop, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
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
  int _donationCount = 0;
  final _authService = AuthService();
  int _unreadCount = 0;
  Timer? _notifTimer;
  
  List<dynamic> _activeSosList = [];
  bool _isLoadingSos = true;
  final _sosService = SosService();
  final _notifService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadActiveSos();
    _loadUnreadCount();
    // Auto-refresh notification badge every 30 seconds
    _notifTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadUnreadCount());
  }

  @override
  void dispose() {
    _notifTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    final data = await _notifService.getNotifications();
    if (mounted) setState(() => _unreadCount = (data['unreadCount'] as int? ?? 0));
  }

  Future<void> _loadActiveSos() async {
    final list = await _sosService.getActiveSos();
    if (list.isEmpty) {
      list.addAll([
        {
          'id': 'dummy1',
          'bloodType': 'O+',
          'location': 'Bệnh viện Bạch Mai',
          'reason': 'Tai nạn giao thông',
          'description': 'Cần gấp 2 đơn vị máu toàn phần. Tình trạng bệnh nhân đang nguy kịch',
        },
        {
          'id': 'dummy2',
          'bloodType': 'A+',
          'location': 'Bệnh viện Nhi Đồng 2',
          'reason': 'Phẫu thuật gấp',
          'description': 'Bé gái 7 tuổi cần tiểu cầu gấp cho ca phẫu thuật tim',
        }
      ]);
    }
    if (mounted) {
      setState(() {
        _activeSosList = list;
        _isLoadingSos = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    final name = await _authService.getLoggedName();
    final phone = await _authService.getLoggedPhone();
    final count = await _authService.getLoggedDonationCount();
    if (mounted) {
      setState(() {
        _fullName = name;
        _phone = phone;
        _donationCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    var textSubCol = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
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
                          Text(
                            'Xin chào',
                            style: TextStyle(color: textSubCol, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _fullName != null && _fullName!.isNotEmpty ? _fullName! : (_phone ?? 'Người dùng'),
                            style: TextStyle(color: textTitleCol, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: textSubCol, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Hà Nội - Việt Nam',
                                style: TextStyle(color: textSubCol, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                        _loadUnreadCount(); // refresh after returning
                      },
                      child: Stack(
                        children: [
                          Icon(Icons.notifications_none, color: textTitleCol, size: 28),
                          if (_unreadCount > 0) Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 16, height: 16,
                              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(
                                _unreadCount > 9 ? '9+' : '$_unreadCount',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Main Banner Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/images/banner.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(40)),
                      child: const Center(
                        child: Text(
                          'Chưa có ảnh banner\n(Bạn hãy thả ảnh vào thư mục\nfrontend/assets/images/banner.png)', 
                          textAlign: TextAlign.center, 
                          style: TextStyle(color: Colors.white)
                        )
                      ),
                    ),
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
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Cần máu khẩn cấp ',
                            style: TextStyle(color: textTitleCol, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
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
                      child: Text('Xem tất cả', style: TextStyle(color: textSubCol, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal list of SOS Cards
              SizedBox(
                height: 200,
                child: _isLoadingSos 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6A00)))
                    : _activeSosList.isEmpty
                        ? Center(child: Text('Chưa có yêu cầu SOS nào', style: TextStyle(color: textTitleCol)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _activeSosList.length,
                            itemBuilder: (context, index) {
                              final sos = _activeSosList[index];
                              return _buildSOSCard(
                                bloodType: sos['bloodType']?.toString() ?? '?',
                                hospitalName: sos['location']?.toString() ?? 'Chưa rõ',
                                noteText: '${sos['reason']} - Cần gấp',
                                timeAndDistance: '5 phút trước - 1.2km', // dummy
                                buttonText: 'Tôi có thể giúp',
                                sosData: sos,
                              );
                            },
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
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red, size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sẵn sàng hiến máu', style: TextStyle(color: textTitleCol, fontSize: 13)),
                                Text('Thông báo SOS gần bạn', style: TextStyle(color: textSubCol, fontSize: 11)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isReadyToDonate,
                            onChanged: (val) => setState(() => _isReadyToDonate = val),
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFFFF6A00),
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Thank you banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.water_drop_outlined, color: Color(0xFFFFB74D), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _donationCount > 0
                                ? 'Bạn đã hiến máu $_donationCount lần. Xin cảm ơn! ❤️'
                                : 'Hãy hiến máu để cứu người!',
                              style: TextStyle(color: textSubCol, fontSize: 12)),
                          ),
                          Icon(Icons.favorite_border, color: Colors.red[300], size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Tiện Ích & Cộng đồng
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tiện Ích & Cộng đồng',
                  style: TextStyle(color: textTitleCol, fontSize: 16, fontWeight: FontWeight.bold),
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
                        label: 'Bản đồ',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodMapPage()));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBigSquareCard(
                        icon: Icons.emoji_events,
                        label: 'Vinh danh',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const HonorScreen()));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBigSquareCard(
                        icon: Icons.chat_bubble_outline,
                        label: 'Trò chuyện',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
                        },
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
    required dynamic sosData,
  }) {
    var textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    var textSubCol = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ConfirmSupportScreen(sosData: sosData)),
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1),
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
            Text(hospitalName, style: TextStyle(color: textTitleCol, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(noteText, style: const TextStyle(color: Color(0xFFFF6A00), fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(timeAndDistance, style: TextStyle(color: textSubCol, fontSize: 11)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ConfirmSupportScreen(sosData: sosData)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  minimumSize: const Size(double.infinity, 38),
                ),
                child: const Text('Tôi có thể giúp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigSquareCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    var textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFF6A00), size: 36),
            const SizedBox(height: 16),
            Text(label, style: TextStyle(color: textTitleCol, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
