import 'package:flutter/material.dart';

extension _ColorExt on Color {
  Color op(double opacity) => withValues(alpha: opacity);
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF160E0C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Vinh danh Cộng đồng",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner trên cùng
            _buildHonorBanner(),

            const SizedBox(height: 24),

            // Box thống kê chung
            _buildGlobalStats(),

            const SizedBox(height: 32),

            // Phần Top người hiến
            _buildTopDonorsHeader(),
            const SizedBox(height: 16),
            _buildTopDonorsList(),

            const SizedBox(height: 32),

            // Phần Huy hiệu & Tiến độ
            _buildBadgesHeader(),
            const SizedBox(height: 16),
            _buildBadgesList(),

            const SizedBox(height: 32),

            // Nút Gia nhập cộng đồng
            _buildJoinCommunityButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHonorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4800), Color(0xFFFF6A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.op(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            "Cảm ơn những trái tim vàng!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Sự cống hiến của bạn mang lại sự sống\ncho cộng đồng. Hãy tiếp tục lan tỏa yêu\nthương!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.op(0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1412),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.op(0.05)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group, color: Color(0xFFFF6A00), size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      "12.5k",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "THÀNH VIÊN",
                  style: TextStyle(color: Colors.white.op(0.5), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1412),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.op(0.05)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.water_drop, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      "8,450",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "ĐƠN VỊ MÁU",
                  style: TextStyle(color: Colors.white.op(0.5), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopDonorsHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Top người hiến",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                "Những tấm lòng vàng tiêu biểu",
                style: TextStyle(color: Colors.white.op(0.5), fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1412),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.op(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6A00),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Tháng này",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                child: Text(
                  "Toàn thời gian",
                  style: TextStyle(color: Colors.white.op(0.5), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopDonorsList() {
    return Column(
      children: [
        _donatorItem(
          rank: 1,
          name: "Nguyễn Văn A***",
          times: 35,
          location: "Hà Nội",
          volumeAmount: "12.5L",
          avatarUrl: 'https://i.pravatar.cc/100?img=11',
        ),
        const SizedBox(height: 12),
        _donatorItem(
          rank: 2,
          name: "Trần Thị B***",
          times: 28,
          location: "Đà Nẵng",
          volumeAmount: "9.8L",
          avatarUrl: 'https://i.pravatar.cc/100?img=5',
        ),
        const SizedBox(height: 12),
        _donatorItem(
          rank: 3,
          name: "Lê Văn C***",
          times: 20,
          location: "TP. HCM",
          volumeAmount: "7.0L",
          avatarUrl: 'https://i.pravatar.cc/100?img=33',
        ),
      ],
    );
  }

  Widget _donatorItem({
    required int rank,
    required String name,
    required int times,
    required String location,
    required String volumeAmount,
    required String avatarUrl,
  }) {
    Color rankColor;
    if (rank == 1) rankColor = const Color(0xFFFFD700); // Gold
    else if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
    else rankColor = const Color(0xFFCD7F32); // Bronze

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1412),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank == 1 ? rankColor.op(0.3) : Colors.white.op(0.05),
        ),
      ),
      child: Row(
        children: [
          // Rank column
          SizedBox(
            width: 30,
            child: rank == 1
                ? Icon(Icons.emoji_events, color: rankColor, size: 24)
                : Text(
                    rank.toString(),
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
          const SizedBox(width: 8),

          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              if (rank == 1)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      "1",
                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "$times lần hiến",
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      " • $location",
                      style: TextStyle(color: Colors.white.op(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Volume amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.op(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              volumeAmount,
              style: TextStyle(color: rankColor, fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "Huy hiệu & Tiến độ",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        Text(
          "XEM TẤT CẢ",
          style: TextStyle(color: const Color(0xFFFF4800), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildBadgesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _badgeCard(
            title: "Người cứu mạng",
            desc: "Đạt mốc 5 lần hiến máu tình nguyện",
            icon: Icons.monitor_heart,
            iconColor: const Color(0xFFFF4800),
            progress: 3,
            total: 5,
            progressColor: const Color(0xFFFF4800),
          ),
          const SizedBox(width: 12),
          _badgeCard(
            title: "Phản ứng nhanh",
            desc: "Phản hồi 3 cuộc gọi SOS trong 15p",
            icon: Icons.flash_on,
            iconColor: Colors.blueAccent,
            progress: 1,
            total: 3,
            progressColor: Colors.blueAccent,
          ),
          const SizedBox(width: 12),
          _badgeCard(
            title: "Chiến binh máu",
            desc: "Tổng lượng hiến đạt trên 5 Lít",
            icon: Icons.shield,
            iconColor: Colors.white.op(0.3),
            progress: 0,
            total: 5,
            progressColor: Colors.white.op(0.2),
            isLocked: true,
          ),
        ],
      ),
    );
  }

  Widget _badgeCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required int progress,
    required int total,
    required Color progressColor,
    bool isLocked = false,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1412),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.op(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isLocked)
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.op(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("KHÓA", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ),
          if (!isLocked) const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.op(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLocked ? Colors.white.op(0.5) : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.op(0.5),
              fontSize: 10,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tiến độ",
                style: TextStyle(color: Colors.white.op(0.5), fontSize: 10),
              ),
              Text(
                isLocked ? "0/5L" : "$progress/$total",
                style: TextStyle(
                  color: isLocked ? Colors.white.op(0.4) : progressColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: total > 0 ? progress / total : 0,
            backgroundColor: Colors.white.op(0.1),
            color: progressColor,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinCommunityButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF281C19), // Nâu đỏ cực trầm
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.op(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4800).op(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.handshake, color: Color(0xFFFF4800), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Gia nhập cộng đồng",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  "Hãy là một phần của cộng đồng này!",
                  style: TextStyle(color: Colors.white.op(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward, color: const Color(0xFFFF4800), size: 18),
        ],
      ),
    );
  }
}
