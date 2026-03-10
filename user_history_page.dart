import 'package:flutter/material.dart';

extension _ColorExt on Color {
  Color op(double opacity) => withValues(alpha: opacity);
}

class UserHistoryPage extends StatelessWidget {
  const UserHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF160E0C),
      appBar: AppBar(
        title: const Text(
          "Lịch sử đóng góp",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thống kê
            _buildSummaryRow(),
            const SizedBox(height: 28),

            // Huy hiệu đạt được
            _buildBadgesSection(),
            const SizedBox(height: 24),

            // Filter
            _buildFilterRow(),
            const SizedBox(height: 32),

            // Timeline
            const Text(
              "Hành trình của bạn",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeline(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _buildSummaryRow() {
    return Row(
      children: [
        _summaryCard(
          icon: Icons.favorite_border,
          value: "4",
          label: "Tổng số lần hiến",
          iconColor: const Color(0xFFFF4800),
          valueColor: const Color(0xFFFF4800),
        ),
        const SizedBox(width: 12),
        _summaryCard(
          icon: Icons.water_drop_outlined,
          value: "1400",
          unit: "ml",
          label: "Tổng đơn vị máu",
          iconColor: const Color(0xFFFF4800),
          valueColor: const Color(0xFFFF4800),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    String? unit,
    required String label,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1412),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.op(0.04)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (unit != null)
                  Text(
                    unit,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.op(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BADGES =================
  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "HUY HIỆU ĐẠT ĐƯỢC",
          style: TextStyle(
            color: Color(0xFF5B9BD5), // Xanh dương nhẹ theo thiết kế
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _badgeItem(
              title: "Chiến binh 3\nlần",
              imageAvatar: "https://i.pravatar.cc/100?img=11",
              borderColor: const Color(0xFFFFB300), // Vàng cam
              hasStar: true,
            ),
            _badgeItem(
              title: "Tình nguyện\nviên",
              icon: Icons.volunteer_activism,
              iconColor: Colors.white,
              borderColor: const Color(0xFF5B9BD5),
              bgColor: const Color(0xFF1B2C42), // Nền xanh đậm
            ),
            _badgeItem(
              title: "Người cứu\nmạng",
              icon: Icons.medical_services,
              iconColor: Colors.white,
              borderColor: const Color(0xFFE57373),
              bgColor: const Color(0xFF3F1D1D), // Nền đỏ đậm
            ),
            _badgeItem(
              title: "Siêu anh\nhùng",
              icon: Icons.lock_outline,
              iconColor: Colors.white.op(0.3),
              borderColor: Colors.transparent,
              bgColor: Colors.white.op(0.05),
              isLocked: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _badgeItem({
    required String title,
    String? imageAvatar,
    IconData? icon,
    Color? iconColor,
    required Color borderColor,
    Color bgColor = Colors.transparent,
    bool hasStar = false,
    bool isLocked = false,
  }) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  border: Border.all(
                    color: borderColor,
                    width: isLocked ? 0 : 2,
                  ),
                  image: imageAvatar != null
                      ? DecorationImage(
                          image: NetworkImage(imageAvatar),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: icon != null
                    ? Icon(icon, color: iconColor, size: 24)
                    : null,
              ),
              if (hasStar)
                Positioned(
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, color: Colors.grey, size: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLocked ? Colors.white.op(0.4) : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTER =================
  Widget _buildFilterRow() {
    return Row(
      children: [
        _filterBtn("Tất cả", active: true),
        const SizedBox(width: 10),
        _filterBtn("Đã hiến"),
        const SizedBox(width: 10),
        _filterBtn("SOS đã tạo"),
      ],
    );
  }

  Widget _filterBtn(String label, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFF4800) : const Color(0xFF281C19),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.white.op(0.6),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ================= TIMELINE =================
  Widget _buildTimeline() {
    return Stack(
      children: [
        // Đường line dọc
        Positioned(
          left: 19,
          top: 20,
          bottom: 0,
          child: Container(
            width: 2,
            color: Colors.white.op(0.1),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CỤM 1: Hiện tại (SOS đang hoạt động)
            _timelineItem(
              nodeIcon: Icons.notifications_active,
              nodeColor: const Color(0xFFFF4800),
              isTopNode: true,
              tagLabel: "SOS • NHÓM A-",
              tagColor: const Color(0xFFFF4800),
              time: "2 giờ trước",
              title: "Cần máu gấp - Tai nạn",
              subtitle: "Bệnh viện Hữu nghị Việt Đức, Hà Nội",
              statusText: "Đang hoạt động",
              statusColor: const Color(0xFF2ECC71),
              showAvatarGroup: true,
            ),

            const SizedBox(height: 16),
            _monthDivider("THÁNG 10, 2023"),

            // CỤM 2: Lịch sử hiến thành công
            _timelineItem(
              nodeIcon: Icons.check,
              nodeColor: const Color(0xFF2ECC71),
              tagLabel: "350ml",
              tagColor: const Color(0xFFFF4800),
              time: "15/10/2023",
              title: "Hiến máu toàn phần",
              subtitle: "Viện Huyết học - Truyền máu TW",
              subtitleIcon: Icons.location_on_outlined,
              rightStatusTag: "THÀNH CÔNG",
              rightStatusColor: const Color(0xFF2ECC71),
            ),

            _timelineItem(
              nodeIcon: Icons.check,
              nodeColor: const Color(0xFF2ECC71),
              tagLabel: "1 đơn vị",
              tagColor: const Color(0xFFFF4800),
              time: "02/06/2023",
              title: "Hiến tiểu cầu",
              subtitle: "Bệnh viện Bạch Mai",
              subtitleIcon: Icons.location_on_outlined,
              rightStatusTag: "THÀNH CÔNG",
              rightStatusColor: const Color(0xFF2ECC71),
            ),

            const SizedBox(height: 16),
            _monthDivider("THÁNG 01, 2023"),

            // CỤM 3: Lịch sử cũ khác
            _timelineItem(
              nodeIcon: Icons.check_circle_outline,
              nodeColor: Colors.white.op(0.3),
              tagLabel: "SOS • NHÓM O+",
              tagColor: Colors.white.op(0.6),
              time: "10/01/2023",
              title: "Cần máu phẫu thuật tim",
              subtitle: "Bệnh viện Đại học Y Hà Nội",
              statusText: "ĐÃ ĐƯỢC HỖ TRỢ",
              statusColor: Colors.white.op(0.5),
            ),

            _timelineItem(
              nodeIcon: Icons.cancel_outlined,
              nodeColor: Colors.white.op(0.2),
              tagLabel: "Đăng ký hiến máu",
              tagColor: Colors.transparent,
              isTitleNotFirst: true, // Tiêu đề là Đăng ký hiến máu thay cho vị trí tag
              time: " Ngày dự kiến: 05/01/2023",
              subtitle: "Lý do: Sức khỏe không đảm bảo",
              subtitleItalic: true,
              rightStatusTag: "HỦY",
              rightStatusColor: Colors.white.op(0.3),
              opacity: 0.5,
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: Colors.white.op(0.2), shape: BoxShape.circle),
                ),
                const SizedBox(width: 24),
                Text("Bắt đầu hành trình", style: TextStyle(color: Colors.white.op(0.3), fontSize: 12)),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _monthDivider(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 42, bottom: 20),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: Colors.white.op(0.3), shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              color: const Color(0xFF5B9BD5),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required IconData nodeIcon,
    required Color nodeColor,
    bool isTopNode = false,
    String? tagLabel,
    Color tagColor = Colors.transparent,
    required String time,
    String? title,
    bool isTitleNotFirst = false,
    required String subtitle,
    IconData? subtitleIcon,
    bool subtitleItalic = false,
    String? statusText,
    Color? statusColor,
    String? rightStatusTag,
    Color? rightStatusColor,
    bool showAvatarGroup = false,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Node
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF160E0C), // Trùng nền để đè lên line
                shape: BoxShape.circle,
                border: Border.all(
                  color: isTopNode ? nodeColor : nodeColor.op(0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(nodeIcon, color: nodeColor, size: 14),
            ),
            const SizedBox(width: 16),

            // Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1412),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.op(0.04)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dòng 1: Tag & Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isTitleNotFirst && title != null)
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          )
                        else if (tagLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: tagColor.op(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tagLabel,
                              style: TextStyle(
                                color: tagColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        if (rightStatusTag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: rightStatusColor!.op(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              rightStatusTag,
                              style: TextStyle(
                                color: rightStatusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        else
                          Text(
                            time,
                            style: TextStyle(color: Colors.white.op(0.5), fontSize: 11),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Dòng 2: Title (nếu là dạng chuẩn)
                    if (!isTitleNotFirst && title != null)
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    
                    if (isTitleNotFirst)
                       Text(
                            time,
                            style: TextStyle(color: Colors.white.op(0.5), fontSize: 11),
                          ),

                    const SizedBox(height: 6),

                    // Dòng 3: Subtitle
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (subtitleIcon != null) ...[
                          Icon(subtitleIcon, color: Colors.white.op(0.4), size: 14),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.op(0.5),
                              fontSize: 12.5,
                              height: 1.4,
                              fontStyle: subtitleItalic ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (statusText != null) ...[
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.op(0.05)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          if (showAvatarGroup)
                            Row(
                              children: [
                                _miniAvatar("https://i.pravatar.cc/100?img=5"),
                                Transform.translate(
                                  offset: const Offset(-8, 0),
                                  child: _miniAvatar("https://i.pravatar.cc/100?img=11"),
                                ),
                                Transform.translate(
                                  offset: const Offset(-16, 0),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF283593), // Xanh lam đậm
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF1E1412), width: 2),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text("+3", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniAvatar(String url) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1E1412), width: 2),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
