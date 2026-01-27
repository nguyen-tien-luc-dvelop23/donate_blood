import 'dart:async';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const bgDark = Color(0xFF120A08);
  static const cardDark = Color(0xFF1E1412);
  static const sosRed = Color(0xFFB71C1C);
  static const ctaOrange = Color(0xFFFF6A00);

  final PageController _bannerController = PageController();
  Timer? _timer;
  int _currentBanner = 0;

  final bannerImages = [
    "https://vienhuyethoc.vn/wp-content/uploads/2020/04/9b06cdd8ae45551b0c54.jpg",
    "https://vienhuyethoc.vn/wp-content/uploads/2022/10/75D8A6FC-288C-4CE3-82B7-EFCF9D8986A2.jpeg",
    "https://tphcm.cdnchinhphu.vn/334895287454388224/2023/1/4/z401284275032931829e9450440eae6efd1e9693354d16.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _currentBanner = (_currentBanner + 1) % bannerImages.length;
      _bannerController.animateToPage(
        _currentBanner,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgDark, Color(0xFF1C0F0C)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 12),
            _banner(),
            const SizedBox(height: 20),
            _sosSection(),
            const SizedBox(height: 16),
            _readyDonate(),
            const SizedBox(height: 16),
            _donationStat(),
            const SizedBox(height: 24),
            _communitySection(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: ctaOrange,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Xin chào,", style: TextStyle(color: Colors.white70)),
            Text(
              "Nguyễn Văn A",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: ctaOrange),
                SizedBox(width: 4),
                Text("Hà Nội, Việt Nam",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            )
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications, color: Colors.white),
        )
      ],
    );
  }

  // ================= BANNER =================
  Widget _banner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            PageView.builder(
              controller: _bannerController,
              itemCount: bannerImages.length,
              itemBuilder: (_, i) {
                return Image.network(
                  bannerImages[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 16,
              bottom: 14,
              child: Text(
                "Kết nối người cần máu\nvới cộng đồng hiến tặng",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= SOS =================
  Widget _sosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              "Cần máu khẩn cấp",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 6),
            Text("• LIVE", style: TextStyle(color: ctaOrange)),
            Spacer(),
            Text("Xem tất cả", style: TextStyle(color: Colors.white54)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _sosCard("O+", "Bệnh viện Bạch Mai",
                  "Cần gấp 2 đơn vị • Tai nạn", "5 phút trước • 1.2km"),
              _sosCard("A-", "BV Chợ Rẫy",
                  "Cần tiểu cầu", "15 phút trước • 3.5km"),
            ],
          ),
        )
      ],
    );
  }

  Widget _sosCard(
      String blood, String hospital, String note, String time) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: sosRed.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: sosRed,
                child: Text(blood,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Text("LIVE",
                  style: TextStyle(
                      color: ctaOrange, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(hospital,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(note, style: const TextStyle(color: ctaOrange)),
          const SizedBox(height: 6),
          Text(time, style: const TextStyle(color: Colors.white54)),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ctaOrange,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            child: const Text("Tôi có thể giúp"),
          )
        ],
      ),
    );
  }

  // ================= READY =================
  Widget _readyDonate() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: sosRed),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sẵn sàng hiến máu",
                    style: TextStyle(color: Colors.white)),
                Text("Thông báo SOS gần bạn",
                    style: TextStyle(color: Colors.white54)),
              ],
            ),
          ),
          Switch(value: true, onChanged: (_) {}, activeColor: ctaOrange),
        ],
      ),
    );
  }

  // ================= STAT =================
  Widget _donationStat() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.bloodtype, color: ctaOrange),
          SizedBox(width: 10),
          Text(
            "Bạn đã hiến máu ",
            style: TextStyle(color: Colors.white),
          ),
          Text(
            "3 lần",
            style:
                TextStyle(color: ctaOrange, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Text("Cảm ơn bạn ❤️", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  // ================= COMMUNITY =================
  Widget _communitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tiện ích & Cộng đồng",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _util(Icons.map, "Bản đồ hiến máu"),
            const SizedBox(width: 12),
            _util(Icons.emoji_events, "Vinh danh"),
          ],
        )
      ],
    );
  }

  Widget _util(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ctaOrange),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
