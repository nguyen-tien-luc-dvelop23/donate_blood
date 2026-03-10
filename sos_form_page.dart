import 'package:flutter/material.dart';
import 'services/sos_service.dart';
import 'services/auth_service.dart';
import 'sos_success_page.dart';

extension _ColorExt on Color {
  Color op(double opacity) => withValues(alpha: opacity);
}

class SOSFormPage extends StatefulWidget {
  const SOSFormPage({super.key});

  @override
  State<SOSFormPage> createState() => _SOSFormPageState();
}

class _SOSFormPageState extends State<SOSFormPage> {
  final hospitalCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final sosService = SOSService();
  final authService = AuthService();

  String blood = "A+";
  bool loading = false;
  String reason = "Cấp cứu";

  final bloodGroups = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];
  final reasons = ["Cấp cứu", "Phẫu thuật", "Bệnh lý hiếm", "Khác"];

  Future<void> submitSOS() async {
    if (hospitalCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập bệnh viện/cơ sở y tế")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final sosId = await sosService.createSOS(
        bloodType: blood,
        hospitalName: hospitalCtrl.text.trim(),
        note: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : reason,
      );

      setState(() => loading = false);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SOSSuccessPage()),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thời gian hiện tại ("10:45")
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: const Color(0xFF160E0C), // Nền tối hơi ngả nâu
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tạo SOS Mới",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white.op(0.4), size: 22),
            onPressed: () => _showSOSHelpDialog(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              "Tạo Yêu cầu SOS Khẩn cấp",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Điền thông tin chính xác để nhận trợ giúp nhanh nhất\ntừ cộng đồng.",
              style: TextStyle(
                color: Colors.white.op(0.55),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Box Cảnh báo Y tế
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1E2B), // Nền xám xanh
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.op(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bảo mật thông tin Y tế",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.white.op(0.7),
                              fontSize: 13,
                              height: 1.4,
                            ),
                            children: const [
                              TextSpan(text: "Hệ thống chỉ hiển thị nhóm máu và địa điểm. Vui lòng "),
                              TextSpan(
                                text: "không",
                                style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              TextSpan(text: " nhập tên bệnh nhân hoặc số điện thoại vào mô tả."),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thời gian tạo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1412),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.white.op(0.5), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Thời gian tạo:",
                    style: TextStyle(color: Colors.white.op(0.5), fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    "$timeStr - Hôm nay",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nhóm máu
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                children: [
                  TextSpan(text: "Nhóm máu cần tìm ", style: TextStyle(color: Colors.white)),
                  TextSpan(text: "*", style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: bloodGroups.map((b) {
                final active = blood == b;
                return GestureDetector(
                  onTap: () => setState(() => blood = b),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width - 32 - 36) / 4,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFFFF6A00) : const Color(0xFF1E1412),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active ? const Color(0xFFFF6A00) : Colors.white.op(0.08),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          b,
                          style: TextStyle(
                            color: active ? Colors.white : Colors.white.op(0.8),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (active)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Color(0xFFFF6A00), size: 12),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Bệnh viện
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                children: [
                  TextSpan(text: "Địa điểm / Bệnh viện ", style: TextStyle(color: Colors.white)),
                  TextSpan(text: "*", style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: hospitalCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "VD: Bệnh viện Chợ Rẫy, Quận 5",
                hintStyle: TextStyle(color: Colors.white.op(0.5)),
                prefixIcon: Icon(Icons.location_on, color: Colors.white.op(0.5), size: 18),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.op(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.my_location, color: Colors.white.op(0.8), size: 16),
                ),
                filled: true,
                fillColor: const Color(0xFF1E1412),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.op(0.05)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.op(0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.op(0.2)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lý do
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                children: [
                  TextSpan(text: "Lý do khẩn cấp ", style: TextStyle(color: Colors.white)),
                  TextSpan(text: "*", style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1412),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.op(0.05)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: reason,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E1412),
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.op(0.5)),
                  items: reasons.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Row(
                        children: [
                          Icon(Icons.medical_services_outlined, color: Colors.white.op(0.5), size: 18),
                          const SizedBox(width: 12),
                          Text(r, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => reason = v);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Thông tin thêm
            const Text(
              "Thông tin thêm (Không bắt buộc)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Mô tả thêm về tình trạng, số lượng đơn vị\nmáu cần...",
                hintStyle: TextStyle(color: Colors.white.op(0.5), height: 1.5),
                filled: true,
                fillColor: const Color(0xFF1E1412),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.op(0.05)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.op(0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.op(0.2)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Nút Đăng
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: loading ? null : submitSOS,
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.campaign, size: 20),
                          SizedBox(width: 8),
                          Text("Đăng SOS Khẩn cấp", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ================= BẢNG HƯỚNG DẪN =================
  void _showSOSHelpDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF231815), // Nền nâu đen
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút Handle (kéo xuống)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.op(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Hướng dẫn tạo SOS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.white.op(0.05)),
              const SizedBox(height: 16),

              // Mục 1: Bảo mật thông tin
              _helpItem(
                icon: Icons.shield,
                iconColor: const Color(0xFF5B9BD5),
                bgColor: const Color(0xFF323B4E),
                title: "Bảo mật thông tin y tế",
                desc: "Để bảo vệ quyền riêng tư, hệ thống chỉ hiển thị ",
                highlight1: "nhóm máu",
                middle: " và ",
                highlight2: "địa điểm",
                desc2: ". Tuyệt đối không nhập tên bệnh nhân hoặc số điện thoại vào phần mô tả.",
              ),
              const SizedBox(height: 24),

              // Mục 2: Khi nào nên tạo
              _helpItem(
                icon: Icons.error_outline,
                iconColor: const Color(0xFFFFB300),
                bgColor: const Color(0xFF423214),
                title: "Khi nào nên tạo SOS?",
                desc: "Chỉ sử dụng cho các trường hợp ",
                highlight1: "khẩn cấp",
                middle: ": tai nạn, phẫu thuật gấp hoặc cấp cứu thiếu máu. Không dùng cho các mục đích thông thường hoặc hỏi đáp.",
              ),
              const SizedBox(height: 24),

              // Mục 3: SOS hoạt động thế nào
              _helpItem(
                icon: Icons.sensors,
                iconColor: const Color(0xFFFF4800),
                bgColor: const Color(0xFF3E1C14),
                title: "SOS hoạt động thế nào?",
                desc: "Thông báo được gửi ",
                highlight1: "thời gian thực",
                middle: " tới người dùng ở gần có nhóm máu phù hợp. Hệ thống ưu tiên thông báo cho những người đang bật chế độ ",
                highlight2: "\"Sẵn sàng hiến máu\"",
                desc2: ".",
                isItalic2: true,
              ),

              const SizedBox(height: 32),

              // Box Lưu ý
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.op(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.op(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.white.op(0.4), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "LƯU Ý",
                          style: TextStyle(
                            color: Colors.white.op(0.5),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Mỗi yêu cầu SOS sẽ có hiệu lực trong vòng 24 giờ trừ khi bạn chủ động đóng yêu cầu.",
                      style: TextStyle(
                        color: Colors.white.op(0.6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Nút Tôi đã hiểu
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Tôi đã hiểu",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _helpItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String desc,
    String? highlight1,
    String? middle,
    String? highlight2,
    String? desc2,
    bool isItalic2 = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white.op(0.6),
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: desc),
                    if (highlight1 != null)
                      TextSpan(
                        text: highlight1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (middle != null) TextSpan(text: middle),
                    if (highlight2 != null)
                      TextSpan(
                        text: highlight2,
                        style: TextStyle(
                          color: isItalic2 ? const Color(0xFFFF4800) : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontStyle: isItalic2 ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    if (desc2 != null) TextSpan(text: desc2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

