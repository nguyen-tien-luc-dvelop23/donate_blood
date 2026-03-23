import 'package:flutter/material.dart';

class SOSGuidePage extends StatelessWidget {
  const SOSGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1615),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    _buildSection(
                      icon: Icons.verified_user,
                      iconColor: Colors.blueAccent,
                      bgColor: const Color(0xFF1E2530),
                      title: "Bảo mật thông tin y tế",
                      description: "Để bảo vệ quyền riêng tư, hệ thống chỉ hiển thị nhóm máu và địa điểm. Tuyệt đối không nhập tên bệnh nhân hoặc số điện thoại vào phần mô tả.",
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.orangeAccent,
                      bgColor: const Color(0xFF2D251A),
                      title: "Khi nào nên tạo SOS?",
                      description: "Chỉ sử dụng cho các trường hợp khẩn cấp: tai nạn, phẫu thuật gấp hoặc cấp cứu thiếu máu. Không dùng cho các mục đích thông thường hoặc hỏi đáp.",
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.sensors,
                      iconColor: Colors.redAccent,
                      bgColor: const Color(0xFF2D1A1A),
                      title: "SOS hoạt động thế nào?",
                      description: "Thông báo được gửi thời gian thực tới người dùng ở gần có nhóm máu phù hợp. Hệ thống ưu tiên thông báo cho những người bật chế độ 'Sẵn sàng hiến máu'.",
                    ),
                    const SizedBox(height: 48),
                    _buildNoteBox(),
                  ],
                ),
              ),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const Text(
        "Hướng dẫn tạo SOS",
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2726).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.4), size: 16),
              const SizedBox(width: 8),
              Text("LƯU Ý", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Mỗi yêu cầu SOS sẽ có hiệu lực trong vòng 24 giờ trừ khi bạn chủ động đóng yêu cầu.",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4800),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text("Tôi đã hiểu", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
