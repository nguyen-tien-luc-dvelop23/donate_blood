import 'package:flutter/material.dart';

class SosGuideBottomSheet extends StatelessWidget {
  const SosGuideBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF231A18), // Dark brownish color matching the design
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32), // Extra padding at bottom for safety
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content length
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Hướng dẫn tạo SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 1. Bảo mật
          _buildGuideItem(
            icon: Icons.shield_outlined,
            iconBg: const Color(0xFF273855),
            iconColor: const Color(0xFF5B8AE1),
            title: 'Bảo mật thông tin y tế',
            description: 'Để bảo vệ quyền riêng tư, hệ thống chỉ hiển thị nhóm máu và địa điểm. Tuyệt đối không nhập tên bệnh nhân hoặc số điện thoại vào phần mô tả.',
          ),
          const SizedBox(height: 24),

          // 2. Khi nào nên tạo SOS
          _buildGuideItem(
            icon: Icons.warning_amber_rounded,
            iconBg: const Color(0xFF4C3D1B),
            iconColor: const Color(0xFFE5A122),
            title: 'Khi nào nên tạo SOS?',
            description: 'Chỉ sử dụng cho các trường hợp khẩn cấp: tai nạn, phẫu thuật gấp hoặc cấp cứu thiếu máu. Không dùng cho các mục đích thông thường hoặc hỏi đáp.',
            highlight: 'khẩn cấp:',
            highlightColor: const Color(0xFFE5A122),
          ),
          const SizedBox(height: 24),

          // 3. Hoạt động thế nào
          _buildGuideItem(
            icon: Icons.sensors,
            iconBg: const Color(0xFF4C221F),
            iconColor: const Color(0xFFD24636),
            title: 'SOS hoạt động thế nào?',
            description: 'Thông báo được gửi thời gian thực tới người dùng ở gần có nhóm máu phù hợp. Hệ thống ưu tiên thông báo cho những người bật chế độ "Sẵn sàng hiến máu".',
            highlight: '"Sẵn sàng hiến máu".',
            highlightColor: const Color(0xFFE65100),
          ),
          const SizedBox(height: 32),

          // Note box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF332522),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LƯU Ý',
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mỗi yêu cầu SOS sẽ có hiệu lực trong vòng 24 giờ trừ khi bạn chủ động đóng yêu cầu.',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Tôi đã hiểu',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    String? highlight,
    Color? highlightColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              _buildRichDescription(description, highlight, highlightColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRichDescription(String description, String? highlight, Color? highlightColor) {
    if (highlight == null || highlightColor == null || !description.contains(highlight)) {
      return Text(
        description,
        style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
      );
    }

    final parts = description.split(highlight);

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: highlight,
            style: TextStyle(color: highlightColor, fontWeight: FontWeight.bold),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}
